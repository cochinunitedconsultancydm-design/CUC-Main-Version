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


/** This is an auto generated class representing the Tasks type in your schema. */
class Tasks extends amplify_core.Model {
  static const classType = const _TasksModelType();
  final String id;
  final String? _title;
  final String? _description;
  final int? _assigned_to;
  final int? _assigned_by;
  final String? _status;
  final String? _due_date;
  final String? _created_at;
  final String? _location;
  final String? _client_name;
  final String? _phone_number;
  final String? _updated_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  TasksModelIdentifier get modelIdentifier {
      return TasksModelIdentifier(
        id: id
      );
  }
  
  String? get title {
    return _title;
  }
  
  String? get description {
    return _description;
  }
  
  int? get assigned_to {
    return _assigned_to;
  }
  
  int? get assigned_by {
    return _assigned_by;
  }
  
  String? get status {
    return _status;
  }
  
  String? get due_date {
    return _due_date;
  }
  
  String? get created_at {
    return _created_at;
  }
  
  String? get location {
    return _location;
  }
  
  String? get client_name {
    return _client_name;
  }
  
  String? get phone_number {
    return _phone_number;
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
  
  const Tasks._internal({required this.id, title, description, assigned_to, assigned_by, status, due_date, created_at, location, client_name, phone_number, updated_at, createdAt, updatedAt}): _title = title, _description = description, _assigned_to = assigned_to, _assigned_by = assigned_by, _status = status, _due_date = due_date, _created_at = created_at, _location = location, _client_name = client_name, _phone_number = phone_number, _updated_at = updated_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Tasks({String? id, String? title, String? description, int? assigned_to, int? assigned_by, String? status, String? due_date, String? created_at, String? location, String? client_name, String? phone_number, String? updated_at}) {
    return Tasks._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      description: description,
      assigned_to: assigned_to,
      assigned_by: assigned_by,
      status: status,
      due_date: due_date,
      created_at: created_at,
      location: location,
      client_name: client_name,
      phone_number: phone_number,
      updated_at: updated_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Tasks &&
      id == other.id &&
      _title == other._title &&
      _description == other._description &&
      _assigned_to == other._assigned_to &&
      _assigned_by == other._assigned_by &&
      _status == other._status &&
      _due_date == other._due_date &&
      _created_at == other._created_at &&
      _location == other._location &&
      _client_name == other._client_name &&
      _phone_number == other._phone_number &&
      _updated_at == other._updated_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Tasks {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("assigned_to=" + (_assigned_to != null ? _assigned_to!.toString() : "null") + ", ");
    buffer.write("assigned_by=" + (_assigned_by != null ? _assigned_by!.toString() : "null") + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("due_date=" + "$_due_date" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("location=" + "$_location" + ", ");
    buffer.write("client_name=" + "$_client_name" + ", ");
    buffer.write("phone_number=" + "$_phone_number" + ", ");
    buffer.write("updated_at=" + "$_updated_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Tasks copyWith({String? title, String? description, int? assigned_to, int? assigned_by, String? status, String? due_date, String? created_at, String? location, String? client_name, String? phone_number, String? updated_at}) {
    return Tasks._internal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      assigned_to: assigned_to ?? this.assigned_to,
      assigned_by: assigned_by ?? this.assigned_by,
      status: status ?? this.status,
      due_date: due_date ?? this.due_date,
      created_at: created_at ?? this.created_at,
      location: location ?? this.location,
      client_name: client_name ?? this.client_name,
      phone_number: phone_number ?? this.phone_number,
      updated_at: updated_at ?? this.updated_at);
  }
  
  Tasks copyWithModelFieldValues({
    ModelFieldValue<String?>? title,
    ModelFieldValue<String?>? description,
    ModelFieldValue<int?>? assigned_to,
    ModelFieldValue<int?>? assigned_by,
    ModelFieldValue<String?>? status,
    ModelFieldValue<String?>? due_date,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? location,
    ModelFieldValue<String?>? client_name,
    ModelFieldValue<String?>? phone_number,
    ModelFieldValue<String?>? updated_at
  }) {
    return Tasks._internal(
      id: id,
      title: title == null ? this.title : title.value,
      description: description == null ? this.description : description.value,
      assigned_to: assigned_to == null ? this.assigned_to : assigned_to.value,
      assigned_by: assigned_by == null ? this.assigned_by : assigned_by.value,
      status: status == null ? this.status : status.value,
      due_date: due_date == null ? this.due_date : due_date.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      location: location == null ? this.location : location.value,
      client_name: client_name == null ? this.client_name : client_name.value,
      phone_number: phone_number == null ? this.phone_number : phone_number.value,
      updated_at: updated_at == null ? this.updated_at : updated_at.value
    );
  }
  
  Tasks.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _description = json['description'],
      _assigned_to = (json['assigned_to'] as num?)?.toInt(),
      _assigned_by = (json['assigned_by'] as num?)?.toInt(),
      _status = json['status'],
      _due_date = json['due_date'],
      _created_at = json['created_at'],
      _location = json['location'],
      _client_name = json['client_name'],
      _phone_number = json['phone_number'],
      _updated_at = json['updated_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'description': _description, 'assigned_to': _assigned_to, 'assigned_by': _assigned_by, 'status': _status, 'due_date': _due_date, 'created_at': _created_at, 'location': _location, 'client_name': _client_name, 'phone_number': _phone_number, 'updated_at': _updated_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'title': _title,
    'description': _description,
    'assigned_to': _assigned_to,
    'assigned_by': _assigned_by,
    'status': _status,
    'due_date': _due_date,
    'created_at': _created_at,
    'location': _location,
    'client_name': _client_name,
    'phone_number': _phone_number,
    'updated_at': _updated_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<TasksModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<TasksModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final ASSIGNED_TO = amplify_core.QueryField(fieldName: "assigned_to");
  static final ASSIGNED_BY = amplify_core.QueryField(fieldName: "assigned_by");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final DUE_DATE = amplify_core.QueryField(fieldName: "due_date");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final LOCATION = amplify_core.QueryField(fieldName: "location");
  static final CLIENT_NAME = amplify_core.QueryField(fieldName: "client_name");
  static final PHONE_NUMBER = amplify_core.QueryField(fieldName: "phone_number");
  static final UPDATED_AT = amplify_core.QueryField(fieldName: "updated_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Tasks";
    modelSchemaDefinition.pluralName = "Tasks";
    
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
      key: Tasks.TITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.ASSIGNED_TO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.ASSIGNED_BY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.DUE_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.LOCATION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.CLIENT_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.PHONE_NUMBER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Tasks.UPDATED_AT,
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

class _TasksModelType extends amplify_core.ModelType<Tasks> {
  const _TasksModelType();
  
  @override
  Tasks fromJson(Map<String, dynamic> jsonData) {
    return Tasks.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Tasks';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Tasks] in your schema.
 */
class TasksModelIdentifier implements amplify_core.ModelIdentifier<Tasks> {
  final String id;

  /** Create an instance of TasksModelIdentifier using [id] the primary key. */
  const TasksModelIdentifier({
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
  String toString() => 'TasksModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is TasksModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}