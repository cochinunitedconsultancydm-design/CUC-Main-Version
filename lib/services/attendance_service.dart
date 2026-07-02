import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';

import 'package:cuc_app/services/backup_aware_api.dart';

class AttendanceService {
  // Check if currently checked in
  Future<Map<String, dynamic>?> getCheckInStatus(dynamic userId) async {
    final req = ModelQueries.list(
      StaffAttendance.classType,
      where: StaffAttendance.ATTENDANCE_DATE.eq(DateTime.now().toIso8601String().split('T')[0])
    );
    final res = await Amplify.API.query(request: req).response;
    final all = res.data?.items.whereType<StaffAttendance>() ?? [];
    
    final matches = all.where((e) => e.user_id?.toString() == userId.toString() && e.check_out_time == null).toList();
    if (matches.isNotEmpty) {
      final first = matches.first;
      return {
        'id': first.id,
        'user_id': first.user_id,
        'check_in_time': first.check_in_time,
        'check_out_time': first.check_out_time,
        'attendance_date': first.attendance_date,
      };
    }
    return null;
  }

  // Get daily total time in minutes
  Future<int> getDailyTotalTime(dynamic userId, String date) async {
    final req = ModelQueries.list(
      StaffAttendance.classType,
      where: StaffAttendance.ATTENDANCE_DATE.eq(date)
    );
    final res = await Amplify.API.query(request: req).response;
    final all = res.data?.items.whereType<StaffAttendance>() ?? [];
    
    final matches = all.where((e) => e.user_id?.toString() == userId.toString());
        
    int totalMinutes = 0;
    for (var row in matches) {
      final checkInStr = row.check_in_time;
      final checkOutStr = row.check_out_time;
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
  Future<bool> checkIn(dynamic userId) async {
    final att = StaffAttendance(
      user_id: int.tryParse(userId.toString()) ?? 0,
      check_in_time: DateTime.now().toUtc().toIso8601String(),
      attendance_date: DateTime.now().toIso8601String().split('T')[0],
    );
    await BackupAwareApi().create(att);

    return true;
  }

  // Check Out
  Future<bool> checkOut(dynamic attendanceId) async {
    final req = ModelQueries.list(StaffAttendance.classType, where: StaffAttendance.ID.eq(attendanceId.toString()));
    final res = await Amplify.API.query(request: req).response;
    if (res.data?.items.isNotEmpty == true) {
      final att = res.data!.items.first!;
      final updated = att.copyWith(check_out_time: DateTime.now().toUtc().toIso8601String());
      await BackupAwareApi().update(updated);
    }

    return true;
  }
}
