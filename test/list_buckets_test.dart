// ignore_for_file: avoid_print
import 'package:supabase/supabase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('list buckets', () async {
    final supabase = SupabaseClient(
      'https://bzxtgiqjgfojblezdubd.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo',
    );

    try {
      final buckets = await supabase.storage.listBuckets();
      for (var bucket in buckets) {
        print('Bucket: ${bucket.name}');
      }
    } catch (e) {
      print('Failed: $e');
    }
  });
}
