import 'package:supabase_flutter/supabase_flutter.dart';

class ClientService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> searchClients(String query) async {
    final response = await _client
        .from('clients')
        .select('name, address, phone, email, type_of_work, balance_due')
        .ilike('name', '%$query%')
        .limit(10);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  Future<List<Map<String, dynamic>>> getAllClients() async {
    final response = await _client
        .from('clients')
        .select()
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
}
