// Essential AWS Amplify Gen 2 configuration for Flutter.
// The model_introspection section is intentionally omitted because
// the app uses ModelProvider.instance (generated Dart models) instead.
const amplifyConfig = r'''{
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
  "storage": {
    "aws_region": "ap-southeast-2",
    "bucket_name": "amplify-cucmainversion-ad-clientfilesbucket5d3f5cb-nv9kkdsbkf1p",
    "buckets": [
      {
        "name": "clientFiles",
        "bucket_name": "amplify-cucmainversion-ad-clientfilesbucket5d3f5cb-nv9kkdsbkf1p",
        "aws_region": "ap-southeast-2"
      }
    ]
  },
  "version": "1.4"
}''';
