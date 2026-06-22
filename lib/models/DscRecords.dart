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


/** This is an auto generated class representing the DscRecords type in your schema. */
class DscRecords extends amplify_core.Model {
  static const classType = const _DscRecordsModelType();
  final String id;
  final String? _username;
  final String? _password;
  final String? _client_name;
  final String? _email_id;
  final String? _phone_no;
  final String? _dsc_taken_date;
  final String? _dsc_expiry_date;
  final String? _created_at;
  final String? _updated_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  DscRecordsModelIdentifier get modelIdentifier {
      return DscRecordsModelIdentifier(
        id: id
      );
  }
  
  String? get username {
    return _username;
  }
  
  String? get password {
    return _password;
  }
  
  String? get client_name {
    return _client_name;
  }
  
  String? get email_id {
    return _email_id;
  }
  
  String? get phone_no {
    return _phone_no;
  }
  
  String? get dsc_taken_date {
    return _dsc_taken_date;
  }
  
  String? get dsc_expiry_date {
    return _dsc_expiry_date;
  }
  
  String? get created_at {
    return _created_at;
  }
  
  String? get updated_at {
    return _updated_at;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const DscRecords._internal({required this.id, username, password, client_name, email_id, phone_no, dsc_taken_date, dsc_expiry_date, created_at, updated_at, createdAt, updatedAt}): _username = username, _password = password, _client_name = client_name, _email_id = email_id, _phone_no = phone_no, _dsc_taken_date = dsc_taken_date, _dsc_expiry_date = dsc_expiry_date, _created_at = created_at, _updated_at = updated_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory DscRecords({String? id, String? username, String? password, String? client_name, String? email_id, String? phone_no, String? dsc_taken_date, String? dsc_expiry_date, String? created_at, String? updated_at}) {
    return DscRecords._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      username: username,
      password: password,
      client_name: client_name,
      email_id: email_id,
      phone_no: phone_no,
      dsc_taken_date: dsc_taken_date,
      dsc_expiry_date: dsc_expiry_date,
      created_at: created_at,
      updated_at: updated_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DscRecords &&
      id == other.id &&
      _username == other._username &&
      _password == other._password &&
      _client_name == other._client_name &&
      _email_id == other._email_id &&
      _phone_no == other._phone_no &&
      _dsc_taken_date == other._dsc_taken_date &&
      _dsc_expiry_date == other._dsc_expiry_date &&
      _created_at == other._created_at &&
      _updated_at == other._updated_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DscRecords {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("username=" + "$_username" + ", ");
    buffer.write("password=" + "$_password" + ", ");
    buffer.write("client_name=" + "$_client_name" + ", ");
    buffer.write("email_id=" + "$_email_id" + ", ");
    buffer.write("phone_no=" + "$_phone_no" + ", ");
    buffer.write("dsc_taken_date=" + "$_dsc_taken_date" + ", ");
    buffer.write("dsc_expiry_date=" + "$_dsc_expiry_date" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("updated_at=" + "$_updated_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DscRecords copyWith({String? username, String? password, String? client_name, String? email_id, String? phone_no, String? dsc_taken_date, String? dsc_expiry_date, String? created_at, String? updated_at}) {
    return DscRecords._internal(
      id: id,
      username: username ?? this.username,
      password: password ?? this.password,
      client_name: client_name ?? this.client_name,
      email_id: email_id ?? this.email_id,
      phone_no: phone_no ?? this.phone_no,
      dsc_taken_date: dsc_taken_date ?? this.dsc_taken_date,
      dsc_expiry_date: dsc_expiry_date ?? this.dsc_expiry_date,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at);
  }
  
  DscRecords copyWithModelFieldValues({
    ModelFieldValue<String?>? username,
    ModelFieldValue<String?>? password,
    ModelFieldValue<String?>? client_name,
    ModelFieldValue<String?>? email_id,
    ModelFieldValue<String?>? phone_no,
    ModelFieldValue<String?>? dsc_taken_date,
    ModelFieldValue<String?>? dsc_expiry_date,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? updated_at
  }) {
    return DscRecords._internal(
      id: id,
      username: username == null ? this.username : username.value,
      password: password == null ? this.password : password.value,
      client_name: client_name == null ? this.client_name : client_name.value,
      email_id: email_id == null ? this.email_id : email_id.value,
      phone_no: phone_no == null ? this.phone_no : phone_no.value,
      dsc_taken_date: dsc_taken_date == null ? this.dsc_taken_date : dsc_taken_date.value,
      dsc_expiry_date: dsc_expiry_date == null ? this.dsc_expiry_date : dsc_expiry_date.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      updated_at: updated_at == null ? this.updated_at : updated_at.value
    );
  }
  
  DscRecords.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _username = json['username'],
      _password = json['password'],
      _client_name = json['client_name'],
      _email_id = json['email_id'],
      _phone_no = json['phone_no'],
      _dsc_taken_date = json['dsc_taken_date'],
      _dsc_expiry_date = json['dsc_expiry_date'],
      _created_at = json['created_at'],
      _updated_at = json['updated_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'username': _username, 'password': _password, 'client_name': _client_name, 'email_id': _email_id, 'phone_no': _phone_no, 'dsc_taken_date': _dsc_taken_date, 'dsc_expiry_date': _dsc_expiry_date, 'created_at': _created_at, 'updated_at': _updated_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'username': _username,
    'password': _password,
    'client_name': _client_name,
    'email_id': _email_id,
    'phone_no': _phone_no,
    'dsc_taken_date': _dsc_taken_date,
    'dsc_expiry_date': _dsc_expiry_date,
    'created_at': _created_at,
    'updated_at': _updated_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<DscRecordsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<DscRecordsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERNAME = amplify_core.QueryField(fieldName: "username");
  static final PASSWORD = amplify_core.QueryField(fieldName: "password");
  static final CLIENT_NAME = amplify_core.QueryField(fieldName: "client_name");
  static final EMAIL_ID = amplify_core.QueryField(fieldName: "email_id");
  static final PHONE_NO = amplify_core.QueryField(fieldName: "phone_no");
  static final DSC_TAKEN_DATE = amplify_core.QueryField(fieldName: "dsc_taken_date");
  static final DSC_EXPIRY_DATE = amplify_core.QueryField(fieldName: "dsc_expiry_date");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final UPDATED_AT = amplify_core.QueryField(fieldName: "updated_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DscRecords";
    modelSchemaDefinition.pluralName = "DscRecords";
    
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
      key: DscRecords.USERNAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DscRecords.PASSWORD,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DscRecords.CLIENT_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DscRecords.EMAIL_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DscRecords.PHONE_NO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DscRecords.DSC_TAKEN_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DscRecords.DSC_EXPIRY_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DscRecords.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DscRecords.UPDATED_AT,
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

class _DscRecordsModelType extends amplify_core.ModelType<DscRecords> {
  const _DscRecordsModelType();
  
  @override
  DscRecords fromJson(Map<String, dynamic> jsonData) {
    return DscRecords.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'DscRecords';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [DscRecords] in your schema.
 */
class DscRecordsModelIdentifier implements amplify_core.ModelIdentifier<DscRecords> {
  final String id;

  /** Create an instance of DscRecordsModelIdentifier using [id] the primary key. */
  const DscRecordsModelIdentifier({
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
  String toString() => 'DscRecordsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is DscRecordsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}