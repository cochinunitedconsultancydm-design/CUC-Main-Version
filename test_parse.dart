import 'dart:convert';

void main() {
  // Replicate what Amplify.configure() does internally
  final jsonStr = r'''{
  "auth": {
    "user_pool_id": "ap-southeast-2_yOUTSxwNq",
    "aws_region": "ap-southeast-2",
    "user_pool_client_id": "75llj8ak4vanas40t0qqk2g3vi",
    "identity_pool_id": "ap-southeast-2:164eb032-bee8-47bb-9498-e5126a27211e",
    "mfa_methods": [],
    "standard_required_attributes": ["email"],
    "username_attributes": ["email"],
    "user_verification_types": ["email"],
    "groups": [],
    "mfa_configuration": "NONE",
    "password_policy": {
      "min_length": 8,
      "require_lowercase": true,
      "require_numbers": true,
      "require_symbols": true,
      "require_uppercase": true
    },
    "unauthenticated_identities_enabled": true
  },
  "data": {
    "url": "https://zfyxg2hobzh5nies4ou5o3epvq.appsync-api.ap-southeast-2.amazonaws.com/graphql",
    "aws_region": "ap-southeast-2",
    "default_authorization_type": "AWS_IAM",
    "authorization_types": ["AMAZON_COGNITO_USER_POOLS"]
  },
  "version": "1.4"
}''';

  final json = jsonDecode(jsonStr) as Map<String, Object?>;
  print('JSON keys: ${json.keys.toList()}');
  print('data field: ${json['data']}');
  print('data type: ${json['data'].runtimeType}');
  
  // Check if data parses OK
  final dataJson = json['data'];
  print('data field value: $dataJson');
}
