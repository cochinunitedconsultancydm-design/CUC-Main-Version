import 'package:supabase_flutter/supabase_flutter.dart';
import 'location_tracking_service.dart';

class AttendanceService {
  final _supabase = Supabase.instance.client;

  // Check if currently checked in
  Future<Map<String, dynamic>?> getCheckInStatus(int userId) async {
    final res = await _supabase
        .from('staff_attendance')
        .select()
        .eq('user_id', userId)
        .eq('attendance_date', DateTime.now().toIso8601String().split('T')[0])
        .isFilter('check_out_time', null)
        .maybeSingle();
    return res;
  }

  // Get daily total time in minutes
  Future<int> getDailyTotalTime(int userId, String date) async {
    final res = await _supabase
        .from('staff_attendance')
        .select()
        .eq('user_id', userId)
        .eq('attendance_date', date);
        
    int totalMinutes = 0;
    for (var row in res) {
      final checkInStr = row['check_in_time'];
      final checkOutStr = row['check_out_time'];
      if (checkInStr != null) {
        final checkIn = DateTime.parse(checkInStr);
        final checkOut = checkOutStr != null ? DateTime.parse(checkOutStr) : DateTime.now().toUtc();
        final diff = checkOut.difference(checkIn).inMinutes;
        if (diff > 0) totalMinutes += diff;
      }
    }
    return totalMinutes;
  }

  // Check In
  Future<bool> checkIn(int userId) async {
    await _supabase.from('staff_attendance').insert({
      'user_id': userId,
      'check_in_time': DateTime.now().toUtc().toIso8601String(),
      'attendance_date': DateTime.now().toIso8601String().split('T')[0],
    });
    await LocationTrackingService().startTracking();
    return true;
  }

  // Check Out
  Future<bool> checkOut(int attendanceId) async {
    await _supabase.from('staff_attendance').update({
      'check_out_time': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', attendanceId);
    await LocationTrackingService().stopTracking();
    return true;
  }
}
