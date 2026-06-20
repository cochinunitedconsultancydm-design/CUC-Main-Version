import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  final result = await supabase.from('service_content').select();
  print('Total rows in DB: ${result.length}');
  
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

  int duplicateGroups = 0;
  for (var entry in groups.entries) {
    if (entry.value.length > 1) {
      duplicateGroups++;
      print('Group "${entry.key}" has ${entry.value.length} items.');
    }
  }
  
  print('Duplicate groups: $duplicateGroups');
}
