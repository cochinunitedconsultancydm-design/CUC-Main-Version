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


/** This is an auto generated class representing the ClientDocuments type in your schema. */
class ClientDocuments extends amplify_core.Model {
  static const classType = const _ClientDocumentsModelType();
  final String id;
  final String? _client_id;
  final String? _client_name;
  final String? _document_name;
  final String? _storage_path;
  final String? _og_copy;
  final String? _remarks;
  final String? _created_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ClientDocumentsModelIdentifier get modelIdentifier {
      return ClientDocumentsModelIdentifier(
        id: id
      );
  }
  
  String? get client_id {
    return _client_id;
  }
  
  String? get client_name {
    return _client_name;
  }
  
  String? get document_name {
    return _document_name;
  }
  
  String? get storage_path {
    return _storage_path;
  }
  
  String? get og_copy {
    return _og_copy;
  }
  
  String? get remarks {
    return _remarks;
  }
  
  String? get created_at {
    return _created_at;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const ClientDocuments._internal({required this.id, client_id, client_name, document_name, storage_path, og_copy, remarks, created_at, createdAt, updatedAt}): _client_id = client_id, _client_name = client_name, _document_name = document_name, _storage_path = storage_path, _og_copy = og_copy, _remarks = remarks, _created_at = created_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory ClientDocuments({String? id, String? client_id, String? client_name, String? document_name, String? storage_path, String? og_copy, String? remarks, String? created_at}) {
    return ClientDocuments._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      client_id: client_id,
      client_name: client_name,
      document_name: document_name,
      storage_path: storage_path,
      og_copy: og_copy,
      remarks: remarks,
      created_at: created_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientDocuments &&
      id == other.id &&
      _client_id == other._client_id &&
      _client_name == other._client_name &&
      _document_name == other._document_name &&
      _storage_path == other._storage_path &&
      _og_copy == other._og_copy &&
      _remarks == other._remarks &&
      _created_at == other._created_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("ClientDocuments {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("client_id=" + "$_client_id" + ", ");
    buffer.write("client_name=" + "$_client_name" + ", ");
    buffer.write("document_name=" + "$_document_name" + ", ");
    buffer.write("storage_path=" + "$_storage_path" + ", ");
    buffer.write("og_copy=" + "$_og_copy" + ", ");
    buffer.write("remarks=" + "$_remarks" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  ClientDocuments copyWith({String? client_id, String? client_name, String? document_name, String? storage_path, String? og_copy, String? remarks, String? created_at}) {
    return ClientDocuments._internal(
      id: id,
      client_id: client_id ?? this.client_id,
      client_name: client_name ?? this.client_name,
      document_name: document_name ?? this.document_name,
      storage_path: storage_path ?? this.storage_path,
      og_copy: og_copy ?? this.og_copy,
      remarks: remarks ?? this.remarks,
      created_at: created_at ?? this.created_at);
  }
  
  ClientDocuments copyWithModelFieldValues({
    ModelFieldValue<String?>? client_id,
    ModelFieldValue<String?>? client_name,
    ModelFieldValue<String?>? document_name,
    ModelFieldValue<String?>? storage_path,
    ModelFieldValue<String?>? og_copy,
    ModelFieldValue<String?>? remarks,
    ModelFieldValue<String?>? created_at
  }) {
    return ClientDocuments._internal(
      id: id,
      client_id: client_id == null ? this.client_id : client_id.value,
      client_name: client_name == null ? this.client_name : client_name.value,
      document_name: document_name == null ? this.document_name : document_name.value,
      storage_path: storage_path == null ? this.storage_path : storage_path.value,
      og_copy: og_copy == null ? this.og_copy : og_copy.value,
      remarks: remarks == null ? this.remarks : remarks.value,
      created_at: created_at == null ? this.created_at : created_at.value
    );
  }
  
  ClientDocuments.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _client_id = json['client_id'],
      _client_name = json['client_name'],
      _document_name = json['document_name'],
      _storage_path = json['storage_path'],
      _og_copy = json['og_copy'],
      _remarks = json['remarks'],
      _created_at = json['created_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'client_id': _client_id, 'client_name': _client_name, 'document_name': _document_name, 'storage_path': _storage_path, 'og_copy': _og_copy, 'remarks': _remarks, 'created_at': _created_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'client_id': _client_id,
    'client_name': _client_name,
    'document_name': _document_name,
    'storage_path': _storage_path,
    'og_copy': _og_copy,
    'remarks': _remarks,
    'created_at': _created_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ClientDocumentsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ClientDocumentsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CLIENT_ID = amplify_core.QueryField(fieldName: "client_id");
  static final CLIENT_NAME = amplify_core.QueryField(fieldName: "client_name");
  static final DOCUMENT_NAME = amplify_core.QueryField(fieldName: "document_name");
  static final STORAGE_PATH = amplify_core.QueryField(fieldName: "storage_path");
  static final OG_COPY = amplify_core.QueryField(fieldName: "og_copy");
  static final REMARKS = amplify_core.QueryField(fieldName: "remarks");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ClientDocuments";
    modelSchemaDefinition.pluralName = "ClientDocuments";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.IDENTITYPOOL,
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
      key: ClientDocuments.CLIENT_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ClientDocuments.CLIENT_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ClientDocuments.DOCUMENT_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ClientDocuments.STORAGE_PATH,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ClientDocuments.OG_COPY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ClientDocuments.REMARKS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ClientDocuments.CREATED_AT,
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

class _ClientDocumentsModelType extends amplify_core.ModelType<ClientDocuments> {
  const _ClientDocumentsModelType();
  
  @override
  ClientDocuments fromJson(Map<String, dynamic> jsonData) {
    return ClientDocuments.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'ClientDocuments';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ClientDocuments] in your schema.
 */
class ClientDocumentsModelIdentifier implements amplify_core.ModelIdentifier<ClientDocuments> {
  final String id;

  /** Create an instance of ClientDocumentsModelIdentifier using [id] the primary key. */
  const ClientDocumentsModelIdentifier({
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
  String toString() => 'ClientDocumentsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ClientDocumentsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}