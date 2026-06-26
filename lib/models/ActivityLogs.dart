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

/** This is an auto generated class representing the ActivityLogs type in your schema. */
class ActivityLogs extends amplify_core.Model {
  static const classType = const _ActivityLogsModelType();
  final String id;
  final int? _user_id;
  final String? _action;
  final String? _target_type;
  final String? _target_id;
  final String? _details;
  final String? _created_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated(
    '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.',
  )
  @override
  String getId() => id;

  ActivityLogsModelIdentifier get modelIdentifier {
    return ActivityLogsModelIdentifier(id: id);
  }

  int? get user_id {
    return _user_id;
  }

  String? get action {
    return _action;
  }

  String? get target_type {
    return _target_type;
  }

  String? get target_id {
    return _target_id;
  }

  String? get details {
    return _details;
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

  const ActivityLogs._internal({
    required this.id,
    user_id,
    action,
    target_type,
    target_id,
    details,
    created_at,
    createdAt,
    updatedAt,
  }) : _user_id = user_id,
       _action = action,
       _target_type = target_type,
       _target_id = target_id,
       _details = details,
       _created_at = created_at,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory ActivityLogs({
    String? id,
    int? user_id,
    String? action,
    String? target_type,
    String? target_id,
    String? details,
    String? created_at,
  }) {
    return ActivityLogs._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      user_id: user_id,
      action: action,
      target_type: target_type,
      target_id: target_id,
      details: details,
      created_at: created_at,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActivityLogs &&
        id == other.id &&
        _user_id == other._user_id &&
        _action == other._action &&
        _target_type == other._target_type &&
        _target_id == other._target_id &&
        _details == other._details &&
        _created_at == other._created_at;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("ActivityLogs {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write(
      "user_id=" + (_user_id != null ? _user_id!.toString() : "null") + ", ",
    );
    buffer.write("action=" + "$_action" + ", ");
    buffer.write("target_type=" + "$_target_type" + ", ");
    buffer.write("target_id=" + "$_target_id" + ", ");
    buffer.write("details=" + "$_details" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write(
      "createdAt=" +
          (_createdAt != null ? _createdAt!.format() : "null") +
          ", ",
    );
    buffer.write(
      "updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"),
    );
    buffer.write("}");

    return buffer.toString();
  }

  ActivityLogs copyWith({
    int? user_id,
    String? action,
    String? target_type,
    String? target_id,
    String? details,
    String? created_at,
  }) {
    return ActivityLogs._internal(
      id: id,
      user_id: user_id ?? this.user_id,
      action: action ?? this.action,
      target_type: target_type ?? this.target_type,
      target_id: target_id ?? this.target_id,
      details: details ?? this.details,
      created_at: created_at ?? this.created_at,
    );
  }

  ActivityLogs copyWithModelFieldValues({
    ModelFieldValue<int?>? user_id,
    ModelFieldValue<String?>? action,
    ModelFieldValue<String?>? target_type,
    ModelFieldValue<String?>? target_id,
    ModelFieldValue<String?>? details,
    ModelFieldValue<String?>? created_at,
  }) {
    return ActivityLogs._internal(
      id: id,
      user_id: user_id == null ? this.user_id : user_id.value,
      action: action == null ? this.action : action.value,
      target_type: target_type == null ? this.target_type : target_type.value,
      target_id: target_id == null ? this.target_id : target_id.value,
      details: details == null ? this.details : details.value,
      created_at: created_at == null ? this.created_at : created_at.value,
    );
  }

  ActivityLogs.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _user_id = (json['user_id'] as num?)?.toInt(),
      _action = json['action'],
      _target_type = json['target_type'],
      _target_id = json['target_id'],
      _details = json['details'],
      _created_at = json['created_at'],
      _createdAt = json['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
          : null,
      _updatedAt = json['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': _user_id,
    'action': _action,
    'target_type': _target_type,
    'target_id': _target_id,
    'details': _details,
    'created_at': _created_at,
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': _user_id,
    'action': _action,
    'target_type': _target_type,
    'target_id': _target_id,
    'details': _details,
    'created_at': _created_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<ActivityLogsModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<ActivityLogsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER_ID = amplify_core.QueryField(fieldName: "user_id");
  static final ACTION = amplify_core.QueryField(fieldName: "action");
  static final TARGET_TYPE = amplify_core.QueryField(fieldName: "target_type");
  static final TARGET_ID = amplify_core.QueryField(fieldName: "target_id");
  static final DETAILS = amplify_core.QueryField(fieldName: "details");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "ActivityLogs";
      modelSchemaDefinition.pluralName = "ActivityLogs";

      modelSchemaDefinition.authRules = [
        amplify_core.AuthRule(
          authStrategy: amplify_core.AuthStrategy.PUBLIC,
          provider: amplify_core.AuthRuleProvider.IAM,
          operations: const [
            amplify_core.ModelOperation.CREATE,
            amplify_core.ModelOperation.UPDATE,
            amplify_core.ModelOperation.DELETE,
            amplify_core.ModelOperation.READ,
          ],
        ),
        amplify_core.AuthRule(
          authStrategy: amplify_core.AuthStrategy.PRIVATE,
          operations: const [
            amplify_core.ModelOperation.CREATE,
            amplify_core.ModelOperation.UPDATE,
            amplify_core.ModelOperation.DELETE,
            amplify_core.ModelOperation.READ,
          ],
        ),
      ];

      modelSchemaDefinition.indexes = [
        amplify_core.ModelIndex(fields: const ["id"], name: null),
      ];

      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ActivityLogs.USER_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ActivityLogs.ACTION,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ActivityLogs.TARGET_TYPE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ActivityLogs.TARGET_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ActivityLogs.DETAILS,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ActivityLogs.CREATED_AT,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.nonQueryField(
          fieldName: 'createdAt',
          isRequired: false,
          isReadOnly: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.dateTime,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.nonQueryField(
          fieldName: 'updatedAt',
          isRequired: false,
          isReadOnly: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.dateTime,
          ),
        ),
      );
    },
  );
}

class _ActivityLogsModelType extends amplify_core.ModelType<ActivityLogs> {
  const _ActivityLogsModelType();

  @override
  ActivityLogs fromJson(Map<String, dynamic> jsonData) {
    return ActivityLogs.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'ActivityLogs';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ActivityLogs] in your schema.
 */
class ActivityLogsModelIdentifier
    implements amplify_core.ModelIdentifier<ActivityLogs> {
  final String id;

  /** Create an instance of ActivityLogsModelIdentifier using [id] the primary key. */
  const ActivityLogsModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'ActivityLogsModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ActivityLogsModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
