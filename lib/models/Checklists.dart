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


/** This is an auto generated class representing the Checklists type in your schema. */
class Checklists extends amplify_core.Model {
  static const classType = const _ChecklistsModelType();
  final String id;
  final String? _title;
  final String? _description;
  final int? _manager_id;
  final int? _responsible_id;
  final String? _status;
  final String? _remarks;
  final String? _reason;
  final String? _due_date;
  final String? _created_at;
  final String? _updated_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ChecklistsModelIdentifier get modelIdentifier {
      return ChecklistsModelIdentifier(
        id: id
      );
  }
  
  String? get title {
    return _title;
  }
  
  String? get description {
    return _description;
  }
  
  int? get manager_id {
    return _manager_id;
  }
  
  int? get responsible_id {
    return _responsible_id;
  }
  
  String? get status {
    return _status;
  }
  
  String? get remarks {
    return _remarks;
  }
  
  String? get reason {
    return _reason;
  }
  
  String? get due_date {
    return _due_date;
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
  
  const Checklists._internal({required this.id, title, description, manager_id, responsible_id, status, remarks, reason, due_date, created_at, updated_at, createdAt, updatedAt}): _title = title, _description = description, _manager_id = manager_id, _responsible_id = responsible_id, _status = status, _remarks = remarks, _reason = reason, _due_date = due_date, _created_at = created_at, _updated_at = updated_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Checklists({String? id, String? title, String? description, int? manager_id, int? responsible_id, String? status, String? remarks, String? reason, String? due_date, String? created_at, String? updated_at}) {
    return Checklists._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      description: description,
      manager_id: manager_id,
      responsible_id: responsible_id,
      status: status,
      remarks: remarks,
      reason: reason,
      due_date: due_date,
      created_at: created_at,
      updated_at: updated_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Checklists &&
      id == other.id &&
      _title == other._title &&
      _description == other._description &&
      _manager_id == other._manager_id &&
      _responsible_id == other._responsible_id &&
      _status == other._status &&
      _remarks == other._remarks &&
      _reason == other._reason &&
      _due_date == other._due_date &&
      _created_at == other._created_at &&
      _updated_at == other._updated_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Checklists {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("manager_id=" + (_manager_id != null ? _manager_id!.toString() : "null") + ", ");
    buffer.write("responsible_id=" + (_responsible_id != null ? _responsible_id!.toString() : "null") + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("remarks=" + "$_remarks" + ", ");
    buffer.write("reason=" + "$_reason" + ", ");
    buffer.write("due_date=" + "$_due_date" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("updated_at=" + "$_updated_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Checklists copyWith({String? title, String? description, int? manager_id, int? responsible_id, String? status, String? remarks, String? reason, String? due_date, String? created_at, String? updated_at}) {
    return Checklists._internal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      manager_id: manager_id ?? this.manager_id,
      responsible_id: responsible_id ?? this.responsible_id,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      reason: reason ?? this.reason,
      due_date: due_date ?? this.due_date,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at);
  }
  
  Checklists copyWithModelFieldValues({
    ModelFieldValue<String?>? title,
    ModelFieldValue<String?>? description,
    ModelFieldValue<int?>? manager_id,
    ModelFieldValue<int?>? responsible_id,
    ModelFieldValue<String?>? status,
    ModelFieldValue<String?>? remarks,
    ModelFieldValue<String?>? reason,
    ModelFieldValue<String?>? due_date,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? updated_at
  }) {
    return Checklists._internal(
      id: id,
      title: title == null ? this.title : title.value,
      description: description == null ? this.description : description.value,
      manager_id: manager_id == null ? this.manager_id : manager_id.value,
      responsible_id: responsible_id == null ? this.responsible_id : responsible_id.value,
      status: status == null ? this.status : status.value,
      remarks: remarks == null ? this.remarks : remarks.value,
      reason: reason == null ? this.reason : reason.value,
      due_date: due_date == null ? this.due_date : due_date.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      updated_at: updated_at == null ? this.updated_at : updated_at.value
    );
  }
  
  Checklists.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _description = json['description'],
      _manager_id = (json['manager_id'] as num?)?.toInt(),
      _responsible_id = (json['responsible_id'] as num?)?.toInt(),
      _status = json['status'],
      _remarks = json['remarks'],
      _reason = json['reason'],
      _due_date = json['due_date'],
      _created_at = json['created_at'],
      _updated_at = json['updated_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'description': _description, 'manager_id': _manager_id, 'responsible_id': _responsible_id, 'status': _status, 'remarks': _remarks, 'reason': _reason, 'due_date': _due_date, 'created_at': _created_at, 'updated_at': _updated_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'title': _title,
    'description': _description,
    'manager_id': _manager_id,
    'responsible_id': _responsible_id,
    'status': _status,
    'remarks': _remarks,
    'reason': _reason,
    'due_date': _due_date,
    'created_at': _created_at,
    'updated_at': _updated_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ChecklistsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ChecklistsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final MANAGER_ID = amplify_core.QueryField(fieldName: "manager_id");
  static final RESPONSIBLE_ID = amplify_core.QueryField(fieldName: "responsible_id");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final REMARKS = amplify_core.QueryField(fieldName: "remarks");
  static final REASON = amplify_core.QueryField(fieldName: "reason");
  static final DUE_DATE = amplify_core.QueryField(fieldName: "due_date");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final UPDATED_AT = amplify_core.QueryField(fieldName: "updated_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Checklists";
    modelSchemaDefinition.pluralName = "Checklists";
    
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
      key: Checklists.TITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Checklists.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Checklists.MANAGER_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Checklists.RESPONSIBLE_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Checklists.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Checklists.REMARKS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Checklists.REASON,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Checklists.DUE_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Checklists.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Checklists.UPDATED_AT,
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

class _ChecklistsModelType extends amplify_core.ModelType<Checklists> {
  const _ChecklistsModelType();
  
  @override
  Checklists fromJson(Map<String, dynamic> jsonData) {
    return Checklists.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Checklists';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Checklists] in your schema.
 */
class ChecklistsModelIdentifier implements amplify_core.ModelIdentifier<Checklists> {
  final String id;

  /** Create an instance of ChecklistsModelIdentifier using [id] the primary key. */
  const ChecklistsModelIdentifier({
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
  String toString() => 'ChecklistsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ChecklistsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}