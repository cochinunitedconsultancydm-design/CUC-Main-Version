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


/** This is an auto generated class representing the InwardPosts type in your schema. */
class InwardPosts extends amplify_core.Model {
  static const classType = const _InwardPostsModelType();
  final String id;
  final String? _sender_name;
  final String? _recipient_name;
  final String? _received_by;
  final String? _description;
  final String? _status;
  final String? _received_date;
  final String? _created_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  InwardPostsModelIdentifier get modelIdentifier {
      return InwardPostsModelIdentifier(
        id: id
      );
  }
  
  String? get sender_name {
    return _sender_name;
  }
  
  String? get recipient_name {
    return _recipient_name;
  }
  
  String? get received_by {
    return _received_by;
  }
  
  String? get description {
    return _description;
  }
  
  String? get status {
    return _status;
  }
  
  String? get received_date {
    return _received_date;
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
  
  const InwardPosts._internal({required this.id, sender_name, recipient_name, received_by, description, status, received_date, created_at, createdAt, updatedAt}): _sender_name = sender_name, _recipient_name = recipient_name, _received_by = received_by, _description = description, _status = status, _received_date = received_date, _created_at = created_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory InwardPosts({String? id, String? sender_name, String? recipient_name, String? received_by, String? description, String? status, String? received_date, String? created_at}) {
    return InwardPosts._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      sender_name: sender_name,
      recipient_name: recipient_name,
      received_by: received_by,
      description: description,
      status: status,
      received_date: received_date,
      created_at: created_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InwardPosts &&
      id == other.id &&
      _sender_name == other._sender_name &&
      _recipient_name == other._recipient_name &&
      _received_by == other._received_by &&
      _description == other._description &&
      _status == other._status &&
      _received_date == other._received_date &&
      _created_at == other._created_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("InwardPosts {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("sender_name=" + "$_sender_name" + ", ");
    buffer.write("recipient_name=" + "$_recipient_name" + ", ");
    buffer.write("received_by=" + "$_received_by" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("received_date=" + "$_received_date" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  InwardPosts copyWith({String? sender_name, String? recipient_name, String? received_by, String? description, String? status, String? received_date, String? created_at}) {
    return InwardPosts._internal(
      id: id,
      sender_name: sender_name ?? this.sender_name,
      recipient_name: recipient_name ?? this.recipient_name,
      received_by: received_by ?? this.received_by,
      description: description ?? this.description,
      status: status ?? this.status,
      received_date: received_date ?? this.received_date,
      created_at: created_at ?? this.created_at);
  }
  
  InwardPosts copyWithModelFieldValues({
    ModelFieldValue<String?>? sender_name,
    ModelFieldValue<String?>? recipient_name,
    ModelFieldValue<String?>? received_by,
    ModelFieldValue<String?>? description,
    ModelFieldValue<String?>? status,
    ModelFieldValue<String?>? received_date,
    ModelFieldValue<String?>? created_at
  }) {
    return InwardPosts._internal(
      id: id,
      sender_name: sender_name == null ? this.sender_name : sender_name.value,
      recipient_name: recipient_name == null ? this.recipient_name : recipient_name.value,
      received_by: received_by == null ? this.received_by : received_by.value,
      description: description == null ? this.description : description.value,
      status: status == null ? this.status : status.value,
      received_date: received_date == null ? this.received_date : received_date.value,
      created_at: created_at == null ? this.created_at : created_at.value
    );
  }
  
  InwardPosts.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _sender_name = json['sender_name'],
      _recipient_name = json['recipient_name'],
      _received_by = json['received_by'],
      _description = json['description'],
      _status = json['status'],
      _received_date = json['received_date'],
      _created_at = json['created_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'sender_name': _sender_name, 'recipient_name': _recipient_name, 'received_by': _received_by, 'description': _description, 'status': _status, 'received_date': _received_date, 'created_at': _created_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'sender_name': _sender_name,
    'recipient_name': _recipient_name,
    'received_by': _received_by,
    'description': _description,
    'status': _status,
    'received_date': _received_date,
    'created_at': _created_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<InwardPostsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<InwardPostsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final SENDER_NAME = amplify_core.QueryField(fieldName: "sender_name");
  static final RECIPIENT_NAME = amplify_core.QueryField(fieldName: "recipient_name");
  static final RECEIVED_BY = amplify_core.QueryField(fieldName: "received_by");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final RECEIVED_DATE = amplify_core.QueryField(fieldName: "received_date");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "InwardPosts";
    modelSchemaDefinition.pluralName = "InwardPosts";
    
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
      key: InwardPosts.SENDER_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InwardPosts.RECIPIENT_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InwardPosts.RECEIVED_BY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InwardPosts.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InwardPosts.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InwardPosts.RECEIVED_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InwardPosts.CREATED_AT,
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

class _InwardPostsModelType extends amplify_core.ModelType<InwardPosts> {
  const _InwardPostsModelType();
  
  @override
  InwardPosts fromJson(Map<String, dynamic> jsonData) {
    return InwardPosts.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'InwardPosts';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [InwardPosts] in your schema.
 */
class InwardPostsModelIdentifier implements amplify_core.ModelIdentifier<InwardPosts> {
  final String id;

  /** Create an instance of InwardPostsModelIdentifier using [id] the primary key. */
  const InwardPostsModelIdentifier({
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
  String toString() => 'InwardPostsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is InwardPostsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}