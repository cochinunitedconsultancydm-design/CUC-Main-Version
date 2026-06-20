import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('test staff_locations upsert', () async {
    final supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
    final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';
    final supabase = SupabaseClient(supabaseUrl, supabaseKey);

    print('Attempting to upsert into staff_locations...');
    try {
      final res = await supabase.from('staff_locations').upsert({
        'user_id': 1, // Assume 1 is a valid user ID (e.g. manager)
        'latitude': 9.9312,
        'longitude': 76.2673,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).select();
      print('Upsert success: $res');
    } catch (e) {
      print('Upsert failed: $e');
    }
  });
}
