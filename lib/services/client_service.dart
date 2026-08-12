import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';

class ClientService {

  Future<List<Map<String, dynamic>>> searchClients(String query) async {
    try {
      final req = ModelQueries.list(
        Clients.classType,
        limit: 10000
      );
      final res = await Amplify.API.query(request: req).response;
      var items = (res.data?.items ?? []).whereType<Clients>().toList() ?? [];
      
      final lowerQuery = query.toLowerCase();
      var filtered = items.where((c) => (c.name ?? '').toLowerCase().contains(lowerQuery)).toList();
      
      return filtered.take(10).map((c) => {
        'name': c.name,
        'address': c.address,
        'phone': c.phone,
        'email': c.email,
        'type_of_work': c.type_of_work,
        'balance_due': c.balance_due,
        'companies': c.companies,
      }).toList();
    } catch (e) {
      safePrint('Error searchClients: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getAllClients() async {
    try {
      final req = ModelQueries.list(Clients.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<Clients>().toList() ?? [];
      
      items.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      return items.map((c) => c.toJson()).toList();
    } catch (e) {
      safePrint('Error getAllClients: $e');
      return [];
    }
  }
}
