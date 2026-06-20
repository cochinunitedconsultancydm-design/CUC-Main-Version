import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('test fetch checklists', () async {
    final supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
    final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';
    final supabase = SupabaseClient(supabaseUrl, supabaseKey);

    final targetDate = DateTime.now().toIso8601String().split('T')[0];
    
    try {
      final res = await supabase
        .from('checklists')
        .select()
        .or('due_date.eq.$targetDate,and(status.eq.Pending,due_date.lt.$targetDate)')
        .order('created_at', ascending: false);
      
      print('Found ${res.length} tasks.');
      for (var task in res) {
        print('- ${task['title']} (Due: ${task['due_date']}, Status: ${task['status']})');
      }
    } catch (e) {
      print('Query failed: $e');
    }
  });
}
