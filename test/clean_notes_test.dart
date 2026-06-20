// ignore_for_file: avoid_print
import 'package:supabase/supabase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clean notes', () async {
    final supabase = SupabaseClient(
      'https://bzxtgiqjgfojblezdubd.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo',
    );

    try {
      final response = await supabase.from('service_content').select();
      for (var row in response) {
        if (row['details'] != null && row['details']['notes'] != null) {
          String notes = row['details']['notes'].toString();
          
          List<String> rawLines = notes.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          List<String> merged = [];
          for (var line in rawLines) {
            // Remove existing bullet points to re-apply them cleanly
            line = line.replaceAll(RegExp(r'^[\•\-\*]\s*'), '');
            
            if (merged.isNotEmpty && RegExp(r'^([a-z\-\(\)]|not |of |and |or |for )').hasMatch(line)) {
              merged[merged.length - 1] += ' $line';
            } else {
              merged.add(line);
            }
          }
          
          // Re-apply bullet points
          String cleanedNotes = merged.where((e) => e.length > 2).map((e) => '• $e').join('\n\n');
          
          final details = Map<String, dynamic>.from(row['details']);
          details['notes'] = cleanedNotes;
          
          await supabase.from('service_content').update({'details': details}).eq('id', row['id']);
          print('Cleaned ${row['title']}');
        }
      }
      print('Successfully cleaned all notes!');
    } catch (e) {
      print('Failed: $e');
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
