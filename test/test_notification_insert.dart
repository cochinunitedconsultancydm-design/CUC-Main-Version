import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('test insert notification', () async {
    final supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
    final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';
    final supabase = SupabaseClient(supabaseUrl, supabaseKey);

    print('Attempting to insert notification...');
    try {
      final res = await supabase.from('notifications').insert({
        'user_id': 1,
        'title': 'Test title',
        'message': 'test message',
        'type': 'checklist',
        'is_read': false,
      }).select();
      print('Insert notification success: $res');
      
      final id = res.first['id'];
      await supabase.from('notifications').delete().eq('id', id);
    } catch (e) {
      print('Insert notification failed: $e');
    }
  });
}
