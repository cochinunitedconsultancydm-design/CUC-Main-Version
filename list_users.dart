import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'lib/models/ModelProvider.dart';
import 'lib/amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Amplify.addPlugin(AmplifyAPI(modelProvider: ModelProvider.instance));
    await Amplify.configure(amplifyconfig);
    print("Amplify configured");

    final req = ModelQueries.list(Users.classType);
    final res = await Amplify.API.query(request: req).response;
    final items = res.data?.items.where((e) => e != null).cast<Users>().toList() ?? [];
    
    print("Total users: ${items.length}");
    for (var u in items) {
      print("User: ID=${u.id}, Name=${u.name}, Username=${u.username}, Password=${u.password}, Role=${u.role}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
