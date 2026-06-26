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

/** This is an auto generated class representing the StaffAttendance type in your schema. */
class StaffAttendance extends amplify_core.Model {
  static const classType = const _StaffAttendanceModelType();
  final String id;
  final int? _user_id;
  final String? _check_in_time;
  final String? _check_out_time;
  final String? _attendance_date;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated(
    '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.',
  )
  @override
  String getId() => id;

  StaffAttendanceModelIdentifier get modelIdentifier {
    return StaffAttendanceModelIdentifier(id: id);
  }

  int? get user_id {
    return _user_id;
  }

  String? get check_in_time {
    return _check_in_time;
  }

  String? get check_out_time {
    return _check_out_time;
  }

  String? get attendance_date {
    return _attendance_date;
  }

  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }

  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const StaffAttendance._internal({
    required this.id,
    user_id,
    check_in_time,
    check_out_time,
    attendance_date,
    createdAt,
    updatedAt,
  }) : _user_id = user_id,
       _check_in_time = check_in_time,
       _check_out_time = check_out_time,
       _attendance_date = attendance_date,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory StaffAttendance({
    String? id,
    int? user_id,
    String? check_in_time,
    String? check_out_time,
    String? attendance_date,
  }) {
    return StaffAttendance._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      user_id: user_id,
      check_in_time: check_in_time,
      check_out_time: check_out_time,
      attendance_date: attendance_date,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StaffAttendance &&
        id == other.id &&
        _user_id == other._user_id &&
        _check_in_time == other._check_in_time &&
        _check_out_time == other._check_out_time &&
        _attendance_date == other._attendance_date;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("StaffAttendance {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write(
      "user_id=" + (_user_id != null ? _user_id!.toString() : "null") + ", ",
    );
    buffer.write("check_in_time=" + "$_check_in_time" + ", ");
    buffer.write("check_out_time=" + "$_check_out_time" + ", ");
    buffer.write("attendance_date=" + "$_attendance_date" + ", ");
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

  StaffAttendance copyWith({
    int? user_id,
    String? check_in_time,
    String? check_out_time,
    String? attendance_date,
  }) {
    return StaffAttendance._internal(
      id: id,
      user_id: user_id ?? this.user_id,
      check_in_time: check_in_time ?? this.check_in_time,
      check_out_time: check_out_time ?? this.check_out_time,
      attendance_date: attendance_date ?? this.attendance_date,
    );
  }

  StaffAttendance copyWithModelFieldValues({
    ModelFieldValue<int?>? user_id,
    ModelFieldValue<String?>? check_in_time,
    ModelFieldValue<String?>? check_out_time,
    ModelFieldValue<String?>? attendance_date,
  }) {
    return StaffAttendance._internal(
      id: id,
      user_id: user_id == null ? this.user_id : user_id.value,
      check_in_time: check_in_time == null
          ? this.check_in_time
          : check_in_time.value,
      check_out_time: check_out_time == null
          ? this.check_out_time
          : check_out_time.value,
      attendance_date: attendance_date == null
          ? this.attendance_date
          : attendance_date.value,
    );
  }

  StaffAttendance.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _user_id = (json['user_id'] as num?)?.toInt(),
      _check_in_time = json['check_in_time'],
      _check_out_time = json['check_out_time'],
      _attendance_date = json['attendance_date'],
      _createdAt = json['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
          : null,
      _updatedAt = json['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': _user_id,
    'check_in_time': _check_in_time,
    'check_out_time': _check_out_time,
    'attendance_date': _attendance_date,
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': _user_id,
    'check_in_time': _check_in_time,
    'check_out_time': _check_out_time,
    'attendance_date': _attendance_date,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<StaffAttendanceModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<StaffAttendanceModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER_ID = amplify_core.QueryField(fieldName: "user_id");
  static final CHECK_IN_TIME = amplify_core.QueryField(
    fieldName: "check_in_time",
  );
  static final CHECK_OUT_TIME = amplify_core.QueryField(
    fieldName: "check_out_time",
  );
  static final ATTENDANCE_DATE = amplify_core.QueryField(
    fieldName: "attendance_date",
  );
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "StaffAttendance";
      modelSchemaDefinition.pluralName = "StaffAttendances";

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
          key: StaffAttendance.USER_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: StaffAttendance.CHECK_IN_TIME,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: StaffAttendance.CHECK_OUT_TIME,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: StaffAttendance.ATTENDANCE_DATE,
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

class _StaffAttendanceModelType
    extends amplify_core.ModelType<StaffAttendance> {
  const _StaffAttendanceModelType();

  @override
  StaffAttendance fromJson(Map<String, dynamic> jsonData) {
    return StaffAttendance.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'StaffAttendance';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [StaffAttendance] in your schema.
 */
class StaffAttendanceModelIdentifier
    implements amplify_core.ModelIdentifier<StaffAttendance> {
  final String id;

  /** Create an instance of StaffAttendanceModelIdentifier using [id] the primary key. */
  const StaffAttendanceModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'StaffAttendanceModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is StaffAttendanceModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
