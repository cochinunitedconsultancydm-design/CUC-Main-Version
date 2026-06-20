import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  print('Fetching all services...');
  final result = await supabase.from('service_content').select().order('title', ascending: true);
  
  final groups = <String, List<Map<String, dynamic>>>{};
  
  for (var s in result) {
    var t = s['title'].toString().toLowerCase();
    t = t.replaceAll('checklist', '');
    t = t.replaceAll(RegExp(r'\(\d+\)'), '');
    t = t.replaceAll('-', ' ');
    t = t.replaceAll('_', ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    if (!groups.containsKey(t)) {
      groups[t] = [];
    }
    groups[t]!.add(s);
  }

  int deleteCount = 0;
  for (var entry in groups.entries) {
    if (entry.value.length > 1) {
      entry.value.sort((a, b) {
        final aDocs = a['details'] != null && a['details']['document_url'] != null ? 1 : 0;
        final bDocs = b['details'] != null && b['details']['document_url'] != null ? 1 : 0;
        if (aDocs != bDocs) return bDocs.compareTo(aDocs);
        return (a['id'] as int).compareTo(b['id'] as int);
      });
      
      final toDelete = entry.value.sublist(1);
      for (var s in toDelete) {
        print('Deleting duplicate: ${s['title']} (ID: ${s['id']})');
        try {
          await supabase.from('service_content').delete().eq('id', s['id']);
          deleteCount++;
        } catch(e) {
          print('Failed to delete: $e');
        }
      }
    }
  }
  
  print('Done. Deleted $deleteCount duplicate records.');
}
