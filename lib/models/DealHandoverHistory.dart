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
import '../utils/safe_json_parse.dart';


/** This is an auto generated class representing the DealHandoverHistory type in your schema. */
class DealHandoverHistory extends amplify_core.Model {
  static const classType = const _DealHandoverHistoryModelType();
  final String id;
  final int? _deal_id;
  final int? _from_user_id;
  final int? _to_user_id;
  final String? _note;
  final String? _handed_over_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  DealHandoverHistoryModelIdentifier get modelIdentifier {
      return DealHandoverHistoryModelIdentifier(
        id: id
      );
  }
  
  int? get deal_id {
    return _deal_id;
  }
  
  int? get from_user_id {
    return _from_user_id;
  }
  
  int? get to_user_id {
    return _to_user_id;
  }
  
  String? get note {
    return _note;
  }
  
  String? get handed_over_at {
    return _handed_over_at;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const DealHandoverHistory._internal({required this.id, deal_id, from_user_id, to_user_id, note, handed_over_at, createdAt, updatedAt}): _deal_id = deal_id, _from_user_id = from_user_id, _to_user_id = to_user_id, _note = note, _handed_over_at = handed_over_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory DealHandoverHistory({String? id, int? deal_id, int? from_user_id, int? to_user_id, String? note, String? handed_over_at}) {
    return DealHandoverHistory._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      deal_id: deal_id,
      from_user_id: from_user_id,
      to_user_id: to_user_id,
      note: note,
      handed_over_at: handed_over_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DealHandoverHistory &&
      id == other.id &&
      _deal_id == other._deal_id &&
      _from_user_id == other._from_user_id &&
      _to_user_id == other._to_user_id &&
      _note == other._note &&
      _handed_over_at == other._handed_over_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DealHandoverHistory {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("deal_id=" + (_deal_id != null ? _deal_id!.toString() : "null") + ", ");
    buffer.write("from_user_id=" + (_from_user_id != null ? _from_user_id!.toString() : "null") + ", ");
    buffer.write("to_user_id=" + (_to_user_id != null ? _to_user_id!.toString() : "null") + ", ");
    buffer.write("note=" + "$_note" + ", ");
    buffer.write("handed_over_at=" + "$_handed_over_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DealHandoverHistory copyWith({int? deal_id, int? from_user_id, int? to_user_id, String? note, String? handed_over_at}) {
    return DealHandoverHistory._internal(
      id: id,
      deal_id: deal_id ?? this.deal_id,
      from_user_id: from_user_id ?? this.from_user_id,
      to_user_id: to_user_id ?? this.to_user_id,
      note: note ?? this.note,
      handed_over_at: handed_over_at ?? this.handed_over_at);
  }
  
  DealHandoverHistory copyWithModelFieldValues({
    ModelFieldValue<int?>? deal_id,
    ModelFieldValue<int?>? from_user_id,
    ModelFieldValue<int?>? to_user_id,
    ModelFieldValue<String?>? note,
    ModelFieldValue<String?>? handed_over_at
  }) {
    return DealHandoverHistory._internal(
      id: id,
      deal_id: deal_id == null ? this.deal_id : deal_id.value,
      from_user_id: from_user_id == null ? this.from_user_id : from_user_id.value,
      to_user_id: to_user_id == null ? this.to_user_id : to_user_id.value,
      note: note == null ? this.note : note.value,
      handed_over_at: handed_over_at == null ? this.handed_over_at : handed_over_at.value
    );
  }
  
  DealHandoverHistory.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _deal_id = safeParseInt(json['deal_id']),
      _from_user_id = safeParseInt(json['from_user_id']),
      _to_user_id = safeParseInt(json['to_user_id']),
      _note = json['note'],
      _handed_over_at = json['handed_over_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'deal_id': _deal_id, 'from_user_id': _from_user_id, 'to_user_id': _to_user_id, 'note': _note, 'handed_over_at': _handed_over_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'deal_id': _deal_id,
    'from_user_id': _from_user_id,
    'to_user_id': _to_user_id,
    'note': _note,
    'handed_over_at': _handed_over_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<DealHandoverHistoryModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<DealHandoverHistoryModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DEAL_ID = amplify_core.QueryField(fieldName: "deal_id");
  static final FROM_USER_ID = amplify_core.QueryField(fieldName: "from_user_id");
  static final TO_USER_ID = amplify_core.QueryField(fieldName: "to_user_id");
  static final NOTE = amplify_core.QueryField(fieldName: "note");
  static final HANDED_OVER_AT = amplify_core.QueryField(fieldName: "handed_over_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DealHandoverHistory";
    modelSchemaDefinition.pluralName = "DealHandoverHistories";
    
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
      key: DealHandoverHistory.DEAL_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealHandoverHistory.FROM_USER_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealHandoverHistory.TO_USER_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealHandoverHistory.NOTE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DealHandoverHistory.HANDED_OVER_AT,
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

class _DealHandoverHistoryModelType extends amplify_core.ModelType<DealHandoverHistory> {
  const _DealHandoverHistoryModelType();
  
  @override
  DealHandoverHistory fromJson(Map<String, dynamic> jsonData) {
    return DealHandoverHistory.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'DealHandoverHistory';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [DealHandoverHistory] in your schema.
 */
class DealHandoverHistoryModelIdentifier implements amplify_core.ModelIdentifier<DealHandoverHistory> {
  final String id;

  /** Create an instance of DealHandoverHistoryModelIdentifier using [id] the primary key. */
  const DealHandoverHistoryModelIdentifier({
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
  String toString() => 'DealHandoverHistoryModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is DealHandoverHistoryModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}