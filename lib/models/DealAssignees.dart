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

/** This is an auto generated class representing the DealAssignees type in your schema. */
class DealAssignees extends amplify_core.Model {
  static const classType = const _DealAssigneesModelType();
  final String id;
  final int? _deal_id;
  final int? _user_id;
  final String? _role;
  final String? _assigned_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated(
    '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.',
  )
  @override
  String getId() => id;

  DealAssigneesModelIdentifier get modelIdentifier {
    return DealAssigneesModelIdentifier(id: id);
  }

  int? get deal_id {
    return _deal_id;
  }

  int? get user_id {
    return _user_id;
  }

  String? get role {
    return _role;
  }

  String? get assigned_at {
    return _assigned_at;
  }

  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }

  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const DealAssignees._internal({
    required this.id,
    deal_id,
    user_id,
    role,
    assigned_at,
    createdAt,
    updatedAt,
  }) : _deal_id = deal_id,
       _user_id = user_id,
       _role = role,
       _assigned_at = assigned_at,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory DealAssignees({
    String? id,
    int? deal_id,
    int? user_id,
    String? role,
    String? assigned_at,
  }) {
    return DealAssignees._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      deal_id: deal_id,
      user_id: user_id,
      role: role,
      assigned_at: assigned_at,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DealAssignees &&
        id == other.id &&
        _deal_id == other._deal_id &&
        _user_id == other._user_id &&
        _role == other._role &&
        _assigned_at == other._assigned_at;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("DealAssignees {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write(
      "deal_id=" + (_deal_id != null ? _deal_id!.toString() : "null") + ", ",
    );
    buffer.write(
      "user_id=" + (_user_id != null ? _user_id!.toString() : "null") + ", ",
    );
    buffer.write("role=" + "$_role" + ", ");
    buffer.write("assigned_at=" + "$_assigned_at" + ", ");
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

  DealAssignees copyWith({
    int? deal_id,
    int? user_id,
    String? role,
    String? assigned_at,
  }) {
    return DealAssignees._internal(
      id: id,
      deal_id: deal_id ?? this.deal_id,
      user_id: user_id ?? this.user_id,
      role: role ?? this.role,
      assigned_at: assigned_at ?? this.assigned_at,
    );
  }

  DealAssignees copyWithModelFieldValues({
    ModelFieldValue<int?>? deal_id,
    ModelFieldValue<int?>? user_id,
    ModelFieldValue<String?>? role,
    ModelFieldValue<String?>? assigned_at,
  }) {
    return DealAssignees._internal(
      id: id,
      deal_id: deal_id == null ? this.deal_id : deal_id.value,
      user_id: user_id == null ? this.user_id : user_id.value,
      role: role == null ? this.role : role.value,
      assigned_at: assigned_at == null ? this.assigned_at : assigned_at.value,
    );
  }

  DealAssignees.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _deal_id = (json['deal_id'] as num?)?.toInt(),
      _user_id = (json['user_id'] as num?)?.toInt(),
      _role = json['role'],
      _assigned_at = json['assigned_at'],
      _createdAt = json['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
          : null,
      _updatedAt = json['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'deal_id': _deal_id,
    'user_id': _user_id,
    'role': _role,
    'assigned_at': _assigned_at,
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'deal_id': _deal_id,
    'user_id': _user_id,
    'role': _role,
    'assigned_at': _assigned_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<DealAssigneesModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<DealAssigneesModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DEAL_ID = amplify_core.QueryField(fieldName: "deal_id");
  static final USER_ID = amplify_core.QueryField(fieldName: "user_id");
  static final ROLE = amplify_core.QueryField(fieldName: "role");
  static final ASSIGNED_AT = amplify_core.QueryField(fieldName: "assigned_at");
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "DealAssignees";
      modelSchemaDefinition.pluralName = "DealAssignees";

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
          key: DealAssignees.DEAL_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: DealAssignees.USER_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: DealAssignees.ROLE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: DealAssignees.ASSIGNED_AT,
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

class _DealAssigneesModelType extends amplify_core.ModelType<DealAssignees> {
  const _DealAssigneesModelType();

  @override
  DealAssignees fromJson(Map<String, dynamic> jsonData) {
    return DealAssignees.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'DealAssignees';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [DealAssignees] in your schema.
 */
class DealAssigneesModelIdentifier
    implements amplify_core.ModelIdentifier<DealAssignees> {
  final String id;

  /** Create an instance of DealAssigneesModelIdentifier using [id] the primary key. */
  const DealAssigneesModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'DealAssigneesModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DealAssigneesModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
