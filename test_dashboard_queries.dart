import 'dart:io';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import 'lib/amplify_outputs.dart';
import 'lib/models/ModelProvider.dart' as amplify_models;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('Configuring Amplify...');
    final authPlugin = AmplifyAuthCognito();
    final apiPlugin = AmplifyAPI(options: APIPluginOptions(modelProvider: amplify_models.ModelProvider.instance));
    
    await Amplify.addPlugins([authPlugin, apiPlugin]);
    await Amplify.configure(amplifyConfig);
    print('Amplify configured successfully.');
    
    print('Testing query 1: Clients');
    await Amplify.API.query(request: ModelQueries.list(amplify_models.Clients.classType)).response;
    
    print('Testing query 2: ClientLicenses (STATUS=Active)');
    await Amplify.API.query(request: ModelQueries.list(amplify_models.ClientLicenses.classType, where: amplify_models.ClientLicenses.STATUS.eq('Active'))).response;
    
    print('Testing query 3: Tasks (STATUS != Completed)');
    await Amplify.API.query(request: ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.STATUS.ne('Completed'))).response;
    
    print('Testing query 4: Deals (STAGE != Completed)');
    await Amplify.API.query(request: ModelQueries.list(amplify_models.Deals.classType, where: amplify_models.Deals.STAGE.ne('Completed'))).response;
    
    print('Testing query 5: Billings (STATUS=Received, TYPE=INVOICE)');
    await Amplify.API.query(request: ModelQueries.list(amplify_models.Billings.classType, where: amplify_models.Billings.STATUS.eq('Received').and(amplify_models.Billings.TYPE.eq('INVOICE')))).response;
    
    print('Testing query 6: CompanyBills');
    await Amplify.API.query(request: ModelQueries.list(amplify_models.CompanyBills.classType)).response;
    
    print('Testing query 7: Users');
    await Amplify.API.query(request: ModelQueries.list(amplify_models.Users.classType)).response;
    
    print('Testing query 8: UserSessions');
    await Amplify.API.query(request: ModelQueries.list(amplify_models.UserSessions.classType)).response;
    
    print('Testing query 9: ActivityLogs');
    await Amplify.API.query(request: ModelQueries.list(amplify_models.ActivityLogs.classType)).response;
    
    print('ALL QUERIES SUCCEEDED!');
    
  } catch (e) {
    print('TEST FAILED: $e');
  }
  
  exit(0);
}
