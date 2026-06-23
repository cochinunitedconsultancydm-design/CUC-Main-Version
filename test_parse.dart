import 'dart:convert';
import 'package:amplify_core/amplify_core.dart';
import 'amplify_outputs.dart';

void main() {
  try {
    final json = jsonDecode(amplifyConfig) as Map<String, Object?>;
    final outputs = AmplifyOutputs.fromJson(json);
    print('SUCCESS!');
    print(outputs.storage != null ? 'Storage is NOT null' : 'Storage is null');
  } catch (e, st) {
    print('ERROR: $e');
    print(st);
  }
}
