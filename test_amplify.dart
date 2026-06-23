import 'dart:convert';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'amplify_outputs.dart';

void main() async {
  try {
    final s3 = AmplifyStorageS3();
    await Amplify.addPlugin(s3);
    await Amplify.configure(amplifyConfig);
    print('SUCCESS!');
  } catch (e, st) {
    print('ERROR: $e');
    print(st);
  }
}
