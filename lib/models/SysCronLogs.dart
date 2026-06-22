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


/** This is an auto generated class representing the SysCronLogs type in your schema. */
class SysCronLogs extends amplify_core.Model {
  static const classType = const _SysCronLogsModelType();
  final String id;
  final String? _job_name;
  final String? _last_run_date;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SysCronLogsModelIdentifier get modelIdentifier {
      return SysCronLogsModelIdentifier(
        id: id
      );
  }
  
  String? get job_name {
    return _job_name;
  }
  
  String? get last_run_date {
    return _last_run_date;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const SysCronLogs._internal({required this.id, job_name, last_run_date, createdAt, updatedAt}): _job_name = job_name, _last_run_date = last_run_date, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory SysCronLogs({String? id, String? job_name, String? last_run_date}) {
    return SysCronLogs._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      job_name: job_name,
      last_run_date: last_run_date);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SysCronLogs &&
      id == other.id &&
      _job_name == other._job_name &&
      _last_run_date == other._last_run_date;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("SysCronLogs {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("job_name=" + "$_job_name" + ", ");
    buffer.write("last_run_date=" + "$_last_run_date" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  SysCronLogs copyWith({String? job_name, String? last_run_date}) {
    return SysCronLogs._internal(
      id: id,
      job_name: job_name ?? this.job_name,
      last_run_date: last_run_date ?? this.last_run_date);
  }
  
  SysCronLogs copyWithModelFieldValues({
    ModelFieldValue<String?>? job_name,
    ModelFieldValue<String?>? last_run_date
  }) {
    return SysCronLogs._internal(
      id: id,
      job_name: job_name == null ? this.job_name : job_name.value,
      last_run_date: last_run_date == null ? this.last_run_date : last_run_date.value
    );
  }
  
  SysCronLogs.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _job_name = json['job_name'],
      _last_run_date = json['last_run_date'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'job_name': _job_name, 'last_run_date': _last_run_date, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'job_name': _job_name,
    'last_run_date': _last_run_date,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<SysCronLogsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<SysCronLogsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final JOB_NAME = amplify_core.QueryField(fieldName: "job_name");
  static final LAST_RUN_DATE = amplify_core.QueryField(fieldName: "last_run_date");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "SysCronLogs";
    modelSchemaDefinition.pluralName = "SysCronLogs";
    
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
      key: SysCronLogs.JOB_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SysCronLogs.LAST_RUN_DATE,
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

class _SysCronLogsModelType extends amplify_core.ModelType<SysCronLogs> {
  const _SysCronLogsModelType();
  
  @override
  SysCronLogs fromJson(Map<String, dynamic> jsonData) {
    return SysCronLogs.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'SysCronLogs';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [SysCronLogs] in your schema.
 */
class SysCronLogsModelIdentifier implements amplify_core.ModelIdentifier<SysCronLogs> {
  final String id;

  /** Create an instance of SysCronLogsModelIdentifier using [id] the primary key. */
  const SysCronLogsModelIdentifier({
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
  String toString() => 'SysCronLogsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SysCronLogsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}