import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:cuc_app/models/ModelProvider.dart';
import 'package:cuc_app/amplify_outputs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Amplify.addPlugins([
      AmplifyAPI(options: APIPluginOptions(modelProvider: ModelProvider.instance)),
      AmplifyAuthCognito()
    ]);
    await Amplify.configure(amplifyConfig);
    
    print("CONFIGURED");
    
    final licensesReq = ModelQueries.list(ClientLicenses.classType);
    final licensesRes = await Amplify.API.query(request: licensesReq).response;
    
    print("HAS ERRORS: \${licensesRes.hasErrors}");
    print("ERRORS: \${licensesRes.errors}");
    print("DATA: \${licensesRes.data?.items.length}");
    
  } catch (e) {
    print("EXCEPTION: \$e");
  }
}
