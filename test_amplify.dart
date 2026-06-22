import 'dart:io';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

import 'lib/amplify_outputs.dart';
import 'lib/models/ModelProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Starting Amplify config test...');
  try {
    final apiPlugin = AmplifyAPI(options: APIPluginOptions(modelProvider: ModelProvider.instance));
    final authPlugin = AmplifyAuthCognito();
    final storagePlugin = AmplifyStorageS3();
    await Amplify.addPlugins([apiPlugin, authPlugin, storagePlugin]);
    await Amplify.configure(amplifyConfig);
    print('SUCCESS_CONFIG');
  } catch (e, stack) {
    print('ERROR_CONFIG: $e\n$stack');
  }
  exit(0);
}
