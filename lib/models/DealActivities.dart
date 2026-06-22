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


/** This is an auto generated class representing the DealActivities type in your schema. */
class DealActivities extends amplify_core.Model {
  static const classType = const _DealActivitiesModelType();
  final String id;
  final int? _deal_id;
  final String? _type;
  final String? _title;
  final String? _description;
  final String? _due_date;
  final bool? _is_completed;
  final int? _created_by;
  final String? _created_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  DealActivitiesModelIdentifier get modelIdentifier {
      return DealActivitiesModelIdentifier(
        id: id
      );
  }
  
  int? get deal_id {
    return _deal_id;
  }
  
  String? get type {
    return _type;
  }
  
  String? get title {
    return _title;
  }
  
  String? get description {
    return _description;
  }
  
  String? get due_date {
    return _due_date;
  }
  
  bool? get is_completed {
    return _is_completed;
  }
  
  int? get created_by {
    return _created_by;
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
  
  const DealActivities._internal({required this.id, deal_id, type, title, description, due_date, is_completed, created_by, created_at, createdAt, updatedAt}): _deal_id = deal_id, _type = type, _title = title, _description = description, _due_date = due_date, _is_completed = is_completed, _created_by = created_by, _created_at = created_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory DealActivities({String? id, int? deal_id, String? type, String? title, String? description, String? due_date, bool? is_completed, int? created_by, String? created_at}) {
    return DealActivities._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      deal_id: deal_id,
      type: type,
      title: title,
      description: description,
      due_date: due_date,
      is_completed: is_completed,
      created_by: created_by,
      created_at: created_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DealActivities &&
      id == other.id &&
      _deal_id == other._deal_id &&
      _type == other._type &&
      _title == other._title &&
      _description == other._description &&
      _due_date == other._due_date &&
      _is_completed == other._is_completed &&
      _created_by == other._created_by &&
      _created_at == other._created_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DealActivities {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("deal_id=" + (_deal_id != null ? _deal_id!.toString() : "null") + ", ");
    buffer.write("type=" + "$_type" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("due_date=" + "$_due_date" + ", ");
    buffer.write("is_completed=" + (_is_completed != null ? _is_completed!.toString() : "null") + ", ");
    buffer.write("created_by=" + (_created_by != null ? _created_by!.toString() : "null") + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DealActivities copyWith({int? deal_id, String? type, String? title, String? description, String? due_date, bool? is_completed, int? created_by, String? created_at}) {
    return DealActivities._internal(
      id: id,
      deal_id: deal_id ?? this.deal_id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      due_date: due_date ?? this.due_date,
      is_completed: is_completed ?? this.is_completed,
      created_by: created_by ?? this.created_by,
      created_at: created_at ?? this.created_at);
  }
  
  DealActivities copyWithModelFieldValues({
    ModelFieldValue<int?>? deal_id,
    ModelFieldValue<String?>? type,
    ModelFieldValue<String?>? title,
    ModelFieldValue<String?>? description,
    ModelFieldValue<String?>? due_date,
    ModelFieldValue<bool?>? is_completed,
    ModelFieldValue<int?>? created_by,
    ModelFieldValue<String?>? created_at
  }) {
    return DealActivities._internal(
      id: id,
      deal_id: deal_id == null ? this.deal_id : deal_id.value,
      type: type == null ? this.type : type.value,
      title: title == null ? this.title : title.value,
      description: description == null ? this.description : description.value,
      due_date: due_date == null ? this.due_date : due_date.value,
      is_completed: is_completed == null ? this.is_completed : is_completed.value,
      created_by: created_by == null ? this.created_by : created_by.value,
      created_at: created_at == null ? this.created_at : created_at.value
    );
  }
  
  DealActivities.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _deal_id = (json['deal_id'] as num?)?.toInt(),
      _type = json['type'],
      _title = json['title'],
      _description = json['description'],
      _due_date = json['due_date'],
      _is_completed = json['is_completed'],
      _created_by = (json['created_by'] as num?)?.toInt(),
      _created_at = json['created_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'deal_id': _deal_id, 'type': _type, 'title': _title, 'description': _description, 'due_date': _due_date, 'is_completed': _is_completed, 'created_by': _created_by, 'created_at': _created_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'deal_id': _deal_id,
    'type': _type,
    'title': _title,
    'description': _description,
    'due_date': _due_date,
    'is_completed': _is_completed,
    'created_by': _created_by,
    'created_at': _created_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<DealActivitiesModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<DealActivitiesModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DEAL_ID = amplify_core.QueryField(fieldName: "deal_id");
  static final TYPE = amplify_core.QueryField(fieldName: "type");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final DUE_DATE = amplify_core.QueryField(fieldName: "due_date");
  static final IS_COMPLETED = amplify_core.QueryField(fieldName: "is_completed");
  static final CREATED_BY = amplify_core.QueryField(fieldName: "created_by");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DealActivities";
    modelSchemaDefinition.pluralName = "DealActivities";
    
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
      key: DealActivities.DEAL_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealActivities.TYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealActivities.TITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealActivities.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealActivities.DUE_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealActivities.IS_COMPLETED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealActivities.CREATED_BY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealActivities.CREATED_AT,
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

class _DealActivitiesModelType extends amplify_core.ModelType<DealActivities> {
  const _DealActivitiesModelType();
  
  @override
  DealActivities fromJson(Map<String, dynamic> jsonData) {
    return DealActivities.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'DealActivities';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [DealActivities] in your schema.
 */
class DealActivitiesModelIdentifier implements amplify_core.ModelIdentifier<DealActivities> {
  final String id;

  /** Create an instance of DealActivitiesModelIdentifier using [id] the primary key. */
  const DealActivitiesModelIdentifier({
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
  String toString() => 'DealActivitiesModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is DealActivitiesModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}