import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';

class ClientService {

  Future<List<Map<String, dynamic>>> searchClients(String query) async {
    try {
      final req = ModelQueries.list(
        Clients.classType,
        where: Clients.NAME.contains(query)
      );
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<Clients>().toList() ?? [];
      
      return items.take(10).map((c) => {
        'name': c.name,
        'address': c.address,
        'phone': c.phone,
        'email': c.email,
        'type_of_work': c.type_of_work,
        'balance_due': c.balance_due,
      }).toList();
    } catch (e) {
      safePrint('Error searchClients: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getAllClients() async {
    try {
      final req = ModelQueries.list(Clients.classType);
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
