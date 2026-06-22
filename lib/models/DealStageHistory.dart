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


/** This is an auto generated class representing the DealStageHistory type in your schema. */
class DealStageHistory extends amplify_core.Model {
  static const classType = const _DealStageHistoryModelType();
  final String id;
  final int? _deal_id;
  final String? _from_stage;
  final String? _to_stage;
  final int? _changed_by;
  final String? _changed_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  DealStageHistoryModelIdentifier get modelIdentifier {
      return DealStageHistoryModelIdentifier(
        id: id
      );
  }
  
  int? get deal_id {
    return _deal_id;
  }
  
  String? get from_stage {
    return _from_stage;
  }
  
  String? get to_stage {
    return _to_stage;
  }
  
  int? get changed_by {
    return _changed_by;
  }
  
  String? get changed_at {
    return _changed_at;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const DealStageHistory._internal({required this.id, deal_id, from_stage, to_stage, changed_by, changed_at, createdAt, updatedAt}): _deal_id = deal_id, _from_stage = from_stage, _to_stage = to_stage, _changed_by = changed_by, _changed_at = changed_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory DealStageHistory({String? id, int? deal_id, String? from_stage, String? to_stage, int? changed_by, String? changed_at}) {
    return DealStageHistory._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      deal_id: deal_id,
      from_stage: from_stage,
      to_stage: to_stage,
      changed_by: changed_by,
      changed_at: changed_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DealStageHistory &&
      id == other.id &&
      _deal_id == other._deal_id &&
      _from_stage == other._from_stage &&
      _to_stage == other._to_stage &&
      _changed_by == other._changed_by &&
      _changed_at == other._changed_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DealStageHistory {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("deal_id=" + (_deal_id != null ? _deal_id!.toString() : "null") + ", ");
    buffer.write("from_stage=" + "$_from_stage" + ", ");
    buffer.write("to_stage=" + "$_to_stage" + ", ");
    buffer.write("changed_by=" + (_changed_by != null ? _changed_by!.toString() : "null") + ", ");
    buffer.write("changed_at=" + "$_changed_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DealStageHistory copyWith({int? deal_id, String? from_stage, String? to_stage, int? changed_by, String? changed_at}) {
    return DealStageHistory._internal(
      id: id,
      deal_id: deal_id ?? this.deal_id,
      from_stage: from_stage ?? this.from_stage,
      to_stage: to_stage ?? this.to_stage,
      changed_by: changed_by ?? this.changed_by,
      changed_at: changed_at ?? this.changed_at);
  }
  
  DealStageHistory copyWithModelFieldValues({
    ModelFieldValue<int?>? deal_id,
    ModelFieldValue<String?>? from_stage,
    ModelFieldValue<String?>? to_stage,
    ModelFieldValue<int?>? changed_by,
    ModelFieldValue<String?>? changed_at
  }) {
    return DealStageHistory._internal(
      id: id,
      deal_id: deal_id == null ? this.deal_id : deal_id.value,
      from_stage: from_stage == null ? this.from_stage : from_stage.value,
      to_stage: to_stage == null ? this.to_stage : to_stage.value,
      changed_by: changed_by == null ? this.changed_by : changed_by.value,
      changed_at: changed_at == null ? this.changed_at : changed_at.value
    );
  }
  
  DealStageHistory.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _deal_id = (json['deal_id'] as num?)?.toInt(),
      _from_stage = json['from_stage'],
      _to_stage = json['to_stage'],
      _changed_by = (json['changed_by'] as num?)?.toInt(),
      _changed_at = json['changed_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'deal_id': _deal_id, 'from_stage': _from_stage, 'to_stage': _to_stage, 'changed_by': _changed_by, 'changed_at': _changed_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'deal_id': _deal_id,
    'from_stage': _from_stage,
    'to_stage': _to_stage,
    'changed_by': _changed_by,
    'changed_at': _changed_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<DealStageHistoryModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<DealStageHistoryModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DEAL_ID = amplify_core.QueryField(fieldName: "deal_id");
  static final FROM_STAGE = amplify_core.QueryField(fieldName: "from_stage");
  static final TO_STAGE = amplify_core.QueryField(fieldName: "to_stage");
  static final CHANGED_BY = amplify_core.QueryField(fieldName: "changed_by");
  static final CHANGED_AT = amplify_core.QueryField(fieldName: "changed_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DealStageHistory";
    modelSchemaDefinition.pluralName = "DealStageHistories";
    
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
      key: DealStageHistory.DEAL_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealStageHistory.FROM_STAGE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealStageHistory.TO_STAGE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealStageHistory.CHANGED_BY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealStageHistory.CHANGED_AT,
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

class _DealStageHistoryModelType extends amplify_core.ModelType<DealStageHistory> {
  const _DealStageHistoryModelType();
  
  @override
  DealStageHistory fromJson(Map<String, dynamic> jsonData) {
    return DealStageHistory.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'DealStageHistory';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [DealStageHistory] in your schema.
 */
class DealStageHistoryModelIdentifier implements amplify_core.ModelIdentifier<DealStageHistory> {
  final String id;

  /** Create an instance of DealStageHistoryModelIdentifier using [id] the primary key. */
  const DealStageHistoryModelIdentifier({
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
  String toString() => 'DealStageHistoryModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is DealStageHistoryModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}