import 'package:supabase/supabase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clear services', () async {
    final supabase = SupabaseClient(
      'https://bzxtgiqjgfojblezdubd.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo',
    );

    print('Deleting all records from service_content...');
    try {
      await supabase.from('service_content').delete().neq('id', 0);
      print('Successfully deleted all records from service_content.');
    } catch (e) {
      print('Failed to delete: $e');
    }
  });
}
