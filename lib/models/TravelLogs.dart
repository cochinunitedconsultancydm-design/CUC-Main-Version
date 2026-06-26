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

/** This is an auto generated class representing the TravelLogs type in your schema. */
class TravelLogs extends amplify_core.Model {
  static const classType = const _TravelLogsModelType();
  final String id;
  final int? _user_id;
  final String? _destination;
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

  TravelLogsModelIdentifier get modelIdentifier {
    return TravelLogsModelIdentifier(id: id);
  }

  int? get user_id {
    return _user_id;
  }

  String? get destination {
    return _destination;
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

  const TravelLogs._internal({
    required this.id,
    user_id,
    destination,
    created_at,
    createdAt,
    updatedAt,
  }) : _user_id = user_id,
       _destination = destination,
       _created_at = created_at,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory TravelLogs({
    String? id,
    int? user_id,
    String? destination,
    String? created_at,
  }) {
    return TravelLogs._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      user_id: user_id,
      destination: destination,
      created_at: created_at,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TravelLogs &&
        id == other.id &&
        _user_id == other._user_id &&
        _destination == other._destination &&
        _created_at == other._created_at;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("TravelLogs {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write(
      "user_id=" + (_user_id != null ? _user_id!.toString() : "null") + ", ",
    );
    buffer.write("destination=" + "$_destination" + ", ");
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

  TravelLogs copyWith({int? user_id, String? destination, String? created_at}) {
    return TravelLogs._internal(
      id: id,
      user_id: user_id ?? this.user_id,
      destination: destination ?? this.destination,
      created_at: created_at ?? this.created_at,
    );
  }

  TravelLogs copyWithModelFieldValues({
    ModelFieldValue<int?>? user_id,
    ModelFieldValue<String?>? destination,
    ModelFieldValue<String?>? created_at,
  }) {
    return TravelLogs._internal(
      id: id,
      user_id: user_id == null ? this.user_id : user_id.value,
      destination: destination == null ? this.destination : destination.value,
      created_at: created_at == null ? this.created_at : created_at.value,
    );
  }

  TravelLogs.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _user_id = (json['user_id'] as num?)?.toInt(),
      _destination = json['destination'],
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
    'destination': _destination,
    'created_at': _created_at,
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': _user_id,
    'destination': _destination,
    'created_at': _created_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<TravelLogsModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<TravelLogsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER_ID = amplify_core.QueryField(fieldName: "user_id");
  static final DESTINATION = amplify_core.QueryField(fieldName: "destination");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "TravelLogs";
      modelSchemaDefinition.pluralName = "TravelLogs";

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
          key: TravelLogs.USER_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: TravelLogs.DESTINATION,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: TravelLogs.CREATED_AT,
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

class _TravelLogsModelType extends amplify_core.ModelType<TravelLogs> {
  const _TravelLogsModelType();

  @override
  TravelLogs fromJson(Map<String, dynamic> jsonData) {
    return TravelLogs.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'TravelLogs';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [TravelLogs] in your schema.
 */
class TravelLogsModelIdentifier
    implements amplify_core.ModelIdentifier<TravelLogs> {
  final String id;

  /** Create an instance of TravelLogsModelIdentifier using [id] the primary key. */
  const TravelLogsModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'TravelLogsModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TravelLogsModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
