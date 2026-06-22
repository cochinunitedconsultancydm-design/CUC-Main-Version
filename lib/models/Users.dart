/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the Users type in your schema. */
class Users extends amplify_core.Model {
  static const classType = const _UsersModelType();
  final String id;
  final String? _username;
  final String? _password;
  final String? _role;
  final String? _name;
  final String? _created_at;
  final String? _last_seen;
  final String? _email;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UsersModelIdentifier get modelIdentifier {
      return UsersModelIdentifier(
        id: id
      );
  }
  
  String? get username {
    return _username;
  }
  
  String? get password {
    return _password;
  }
  
  String? get role {
    return _role;
  }
  
  String? get name {
    return _name;
  }
  
  String? get created_at {
    return _created_at;
  }
  
  String? get last_seen {
    return _last_seen;
  }
  
  String? get email {
    return _email;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Users._internal({required this.id, username, password, role, name, created_at, last_seen, email, createdAt, updatedAt}): _username = username, _password = password, _role = role, _name = name, _created_at = created_at, _last_seen = last_seen, _email = email, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Users({String? id, String? username, String? password, String? role, String? name, String? created_at, String? last_seen, String? email}) {
    return Users._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      username: username,
      password: password,
      role: role,
      name: name,
      created_at: created_at,
      last_seen: last_seen,
      email: email);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Users &&
      id == other.id &&
      _username == other._username &&
      _password == other._password &&
      _role == other._role &&
      _name == other._name &&
      _created_at == other._created_at &&
      _last_seen == other._last_seen &&
      _email == other._email;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Users {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("username=" + "$_username" + ", ");
    buffer.write("password=" + "$_password" + ", ");
    buffer.write("role=" + "$_role" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("last_seen=" + "$_last_seen" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Users copyWith({String? username, String? password, String? role, String? name, String? created_at, String? last_seen, String? email}) {
    return Users._internal(
      id: id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      created_at: created_at ?? this.created_at,
      last_seen: last_seen ?? this.last_seen,
      email: email ?? this.email);
  }
  
  Users copyWithModelFieldValues({
    ModelFieldValue<String?>? username,
    ModelFieldValue<String?>? password,
    ModelFieldValue<String?>? role,
    ModelFieldValue<String?>? name,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? last_seen,
    ModelFieldValue<String?>? email
  }) {
    return Users._internal(
      id: id,
      username: username == null ? this.username : username.value,
      password: password == null ? this.password : password.value,
      role: role == null ? this.role : role.value,
      name: name == null ? this.name : name.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      last_seen: last_seen == null ? this.last_seen : last_seen.value,
      email: email == null ? this.email : email.value
    );
  }
  
  Users.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _username = json['username'],
      _password = json['password'],
      _role = json['role'],
      _name = json['name'],
      _created_at = json['created_at'],
      _last_seen = json['last_seen'],
      _email = json['email'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'username': _username, 'password': _password, 'role': _role, 'name': _name, 'created_at': _created_at, 'last_seen': _last_seen, 'email': _email, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'username': _username,
    'password': _password,
    'role': _role,
    'name': _name,
    'created_at': _created_at,
    'last_seen': _last_seen,
    'email': _email,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UsersModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UsersModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERNAME = amplify_core.QueryField(fieldName: "username");
  static final PASSWORD = amplify_core.QueryField(fieldName: "password");
  static final ROLE = amplify_core.QueryField(fieldName: "role");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final LAST_SEEN = amplify_core.QueryField(fieldName: "last_seen");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Users";
    modelSchemaDefinition.pluralName = "Users";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.IAM,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.USERNAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.PASSWORD,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.ROLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.LAST_SEEN,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.EMAIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _UsersModelType extends amplify_core.ModelType<Users> {
  const _UsersModelType();
  
  @override
  Users fromJson(Map<String, dynamic> jsonData) {
    return Users.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Users';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Users] in your schema.
 */
class UsersModelIdentifier implements amplify_core.ModelIdentifier<Users> {
  final String id;

  /** Create an instance of UsersModelIdentifier using [id] the primary key. */
  const UsersModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'UsersModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UsersModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}