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

/** This is an auto generated class representing the UserSessions type in your schema. */
class UserSessions extends amplify_core.Model {
  static const classType = const _UserSessionsModelType();
  final String id;
  final int? _user_id;
  final String? _login_time;
  final String? _logout_time;
  final String? _ip_address;
  final bool? _is_active;
  final String? _status;
  final int? _active_seconds;
  final int? _idle_seconds;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated(
    '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.',
  )
  @override
  String getId() => id;

  UserSessionsModelIdentifier get modelIdentifier {
    return UserSessionsModelIdentifier(id: id);
  }

  int? get user_id {
    return _user_id;
  }

  String? get login_time {
    return _login_time;
  }

  String? get logout_time {
    return _logout_time;
  }

  String? get ip_address {
    return _ip_address;
  }

  bool? get is_active {
    return _is_active;
  }

  String? get status {
    return _status;
  }

  int? get active_seconds {
    return _active_seconds;
  }

  int? get idle_seconds {
    return _idle_seconds;
  }

  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }

  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const UserSessions._internal({
    required this.id,
    user_id,
    login_time,
    logout_time,
    ip_address,
    is_active,
    status,
    active_seconds,
    idle_seconds,
    createdAt,
    updatedAt,
  }) : _user_id = user_id,
       _login_time = login_time,
       _logout_time = logout_time,
       _ip_address = ip_address,
       _is_active = is_active,
       _status = status,
       _active_seconds = active_seconds,
       _idle_seconds = idle_seconds,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory UserSessions({
    String? id,
    int? user_id,
    String? login_time,
    String? logout_time,
    String? ip_address,
    bool? is_active,
    String? status,
    int? active_seconds,
    int? idle_seconds,
  }) {
    return UserSessions._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      user_id: user_id,
      login_time: login_time,
      logout_time: logout_time,
      ip_address: ip_address,
      is_active: is_active,
      status: status,
      active_seconds: active_seconds,
      idle_seconds: idle_seconds,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserSessions &&
        id == other.id &&
        _user_id == other._user_id &&
        _login_time == other._login_time &&
        _logout_time == other._logout_time &&
        _ip_address == other._ip_address &&
        _is_active == other._is_active &&
        _status == other._status &&
        _active_seconds == other._active_seconds &&
        _idle_seconds == other._idle_seconds;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("UserSessions {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write(
      "user_id=" + (_user_id != null ? _user_id!.toString() : "null") + ", ",
    );
    buffer.write("login_time=" + "$_login_time" + ", ");
    buffer.write("logout_time=" + "$_logout_time" + ", ");
    buffer.write("ip_address=" + "$_ip_address" + ", ");
    buffer.write(
      "is_active=" +
          (_is_active != null ? _is_active!.toString() : "null") +
          ", ",
    );
    buffer.write("status=" + "$_status" + ", ");
    buffer.write(
      "active_seconds=" +
          (_active_seconds != null ? _active_seconds!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "idle_seconds=" +
          (_idle_seconds != null ? _idle_seconds!.toString() : "null") +
          ", ",
    );
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

  UserSessions copyWith({
    int? user_id,
    String? login_time,
    String? logout_time,
    String? ip_address,
    bool? is_active,
    String? status,
    int? active_seconds,
    int? idle_seconds,
  }) {
    return UserSessions._internal(
      id: id,
      user_id: user_id ?? this.user_id,
      login_time: login_time ?? this.login_time,
      logout_time: logout_time ?? this.logout_time,
      ip_address: ip_address ?? this.ip_address,
      is_active: is_active ?? this.is_active,
      status: status ?? this.status,
      active_seconds: active_seconds ?? this.active_seconds,
      idle_seconds: idle_seconds ?? this.idle_seconds,
    );
  }

  UserSessions copyWithModelFieldValues({
    ModelFieldValue<int?>? user_id,
    ModelFieldValue<String?>? login_time,
    ModelFieldValue<String?>? logout_time,
    ModelFieldValue<String?>? ip_address,
    ModelFieldValue<bool?>? is_active,
    ModelFieldValue<String?>? status,
    ModelFieldValue<int?>? active_seconds,
    ModelFieldValue<int?>? idle_seconds,
  }) {
    return UserSessions._internal(
      id: id,
      user_id: user_id == null ? this.user_id : user_id.value,
      login_time: login_time == null ? this.login_time : login_time.value,
      logout_time: logout_time == null ? this.logout_time : logout_time.value,
      ip_address: ip_address == null ? this.ip_address : ip_address.value,
      is_active: is_active == null ? this.is_active : is_active.value,
      status: status == null ? this.status : status.value,
      active_seconds: active_seconds == null
          ? this.active_seconds
          : active_seconds.value,
      idle_seconds: idle_seconds == null
          ? this.idle_seconds
          : idle_seconds.value,
    );
  }

  UserSessions.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _user_id = (json['user_id'] as num?)?.toInt(),
      _login_time = json['login_time'],
      _logout_time = json['logout_time'],
      _ip_address = json['ip_address'],
      _is_active = json['is_active'],
      _status = json['status'],
      _active_seconds = (json['active_seconds'] as num?)?.toInt(),
      _idle_seconds = (json['idle_seconds'] as num?)?.toInt(),
      _createdAt = json['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
          : null,
      _updatedAt = json['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': _user_id,
    'login_time': _login_time,
    'logout_time': _logout_time,
    'ip_address': _ip_address,
    'is_active': _is_active,
    'status': _status,
    'active_seconds': _active_seconds,
    'idle_seconds': _idle_seconds,
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': _user_id,
    'login_time': _login_time,
    'logout_time': _logout_time,
    'ip_address': _ip_address,
    'is_active': _is_active,
    'status': _status,
    'active_seconds': _active_seconds,
    'idle_seconds': _idle_seconds,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<UserSessionsModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<UserSessionsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER_ID = amplify_core.QueryField(fieldName: "user_id");
  static final LOGIN_TIME = amplify_core.QueryField(fieldName: "login_time");
  static final LOGOUT_TIME = amplify_core.QueryField(fieldName: "logout_time");
  static final IP_ADDRESS = amplify_core.QueryField(fieldName: "ip_address");
  static final IS_ACTIVE = amplify_core.QueryField(fieldName: "is_active");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final ACTIVE_SECONDS = amplify_core.QueryField(
    fieldName: "active_seconds",
  );
  static final IDLE_SECONDS = amplify_core.QueryField(
    fieldName: "idle_seconds",
  );
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "UserSessions";
      modelSchemaDefinition.pluralName = "UserSessions";

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
          key: UserSessions.USER_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: UserSessions.LOGIN_TIME,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: UserSessions.LOGOUT_TIME,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: UserSessions.IP_ADDRESS,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: UserSessions.IS_ACTIVE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.bool,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: UserSessions.STATUS,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: UserSessions.ACTIVE_SECONDS,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: UserSessions.IDLE_SECONDS,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
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

class _UserSessionsModelType extends amplify_core.ModelType<UserSessions> {
  const _UserSessionsModelType();

  @override
  UserSessions fromJson(Map<String, dynamic> jsonData) {
    return UserSessions.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'UserSessions';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [UserSessions] in your schema.
 */
class UserSessionsModelIdentifier
    implements amplify_core.ModelIdentifier<UserSessions> {
  final String id;

  /** Create an instance of UserSessionsModelIdentifier using [id] the primary key. */
  const UserSessionsModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'UserSessionsModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UserSessionsModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
