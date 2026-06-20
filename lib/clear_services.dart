import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  final supabase = SupabaseClient(
    'https://bzxtgiqjgfojblezdubd.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo',
  );

  debugPrint('Deleting all records from service_content...');
  try {
    // Delete all records where id is greater than 0
    await supabase.from('service_content').delete().neq('id', 0);
    debugPrint('Successfully deleted all records from service_content.');
  } catch (e) {
    debugPrint('Failed to delete: $e');
  }
}
