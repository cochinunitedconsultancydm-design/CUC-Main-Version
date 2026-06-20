import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('test insert checklist', () async {
    final supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
    final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';
    final supabase = SupabaseClient(supabaseUrl, supabaseKey);

    print('Attempting to insert checklist...');
    try {
      final res = await supabase.from('checklists').insert({
        'title': 'Test Checklist',
        'description': 'test desc',
        'status': 'Pending',
        'responsible_id': 1,
        'manager_id': 1,
        'due_date': DateTime.now().toIso8601String().split('T')[0],
      }).select();
      print('Insert success: $res');
      
      final id = res.first['id'];
      await supabase.from('checklists').delete().eq('id', id);
    } catch (e) {
      print('Insert failed: $e');
    }
  });
}
