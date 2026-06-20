import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  print('Testing update on service_content...');
  
  // Try to update ID 710 (Company Incorporatin)
  final res = await supabase.from('service_content').update({'title': 'Company Incorporation'}).eq('id', 710).select();
  print('Update result: $res');
}
