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

/** This is an auto generated class representing the Notifications type in your schema. */
class Notifications extends amplify_core.Model {
  static const classType = const _NotificationsModelType();
  final String id;
  final int? _user_id;
  final String? _title;
  final String? _message;
  final String? _type;
  final bool? _is_read;
  final String? _created_at;
  final int? _deal_id;
  final int? _task_id;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated(
    '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.',
  )
  @override
  String getId() => id;

  NotificationsModelIdentifier get modelIdentifier {
    return NotificationsModelIdentifier(id: id);
  }

  int? get user_id {
    return _user_id;
  }

  String? get title {
    return _title;
  }

  String? get message {
    return _message;
  }

  String? get type {
    return _type;
  }

  bool? get is_read {
    return _is_read;
  }

  String? get created_at {
    return _created_at;
  }

  int? get deal_id {
    return _deal_id;
  }

  int? get task_id {
    return _task_id;
  }

  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }

  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const Notifications._internal({
    required this.id,
    user_id,
    title,
    message,
    type,
    is_read,
    created_at,
    deal_id,
    task_id,
    createdAt,
    updatedAt,
  }) : _user_id = user_id,
       _title = title,
       _message = message,
       _type = type,
       _is_read = is_read,
       _created_at = created_at,
       _deal_id = deal_id,
       _task_id = task_id,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory Notifications({
    String? id,
    int? user_id,
    String? title,
    String? message,
    String? type,
    bool? is_read,
    String? created_at,
    int? deal_id,
    int? task_id,
  }) {
    return Notifications._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      user_id: user_id,
      title: title,
      message: message,
      type: type,
      is_read: is_read,
      created_at: created_at,
      deal_id: deal_id,
      task_id: task_id,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Notifications &&
        id == other.id &&
        _user_id == other._user_id &&
        _title == other._title &&
        _message == other._message &&
        _type == other._type &&
        _is_read == other._is_read &&
        _created_at == other._created_at &&
        _deal_id == other._deal_id &&
        _task_id == other._task_id;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("Notifications {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write(
      "user_id=" + (_user_id != null ? _user_id!.toString() : "null") + ", ",
    );
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("message=" + "$_message" + ", ");
    buffer.write("type=" + "$_type" + ", ");
    buffer.write(
      "is_read=" + (_is_read != null ? _is_read!.toString() : "null") + ", ",
    );
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write(
      "deal_id=" + (_deal_id != null ? _deal_id!.toString() : "null") + ", ",
    );
    buffer.write(
      "task_id=" + (_task_id != null ? _task_id!.toString() : "null") + ", ",
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

  Notifications copyWith({
    int? user_id,
    String? title,
    String? message,
    String? type,
    bool? is_read,
    String? created_at,
    int? deal_id,
    int? task_id,
  }) {
    return Notifications._internal(
      id: id,
      user_id: user_id ?? this.user_id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      is_read: is_read ?? this.is_read,
      created_at: created_at ?? this.created_at,
      deal_id: deal_id ?? this.deal_id,
      task_id: task_id ?? this.task_id,
    );
  }

  Notifications copyWithModelFieldValues({
    ModelFieldValue<int?>? user_id,
    ModelFieldValue<String?>? title,
    ModelFieldValue<String?>? message,
    ModelFieldValue<String?>? type,
    ModelFieldValue<bool?>? is_read,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<int?>? deal_id,
    ModelFieldValue<int?>? task_id,
  }) {
    return Notifications._internal(
      id: id,
      user_id: user_id == null ? this.user_id : user_id.value,
      title: title == null ? this.title : title.value,
      message: message == null ? this.message : message.value,
      type: type == null ? this.type : type.value,
      is_read: is_read == null ? this.is_read : is_read.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      deal_id: deal_id == null ? this.deal_id : deal_id.value,
      task_id: task_id == null ? this.task_id : task_id.value,
    );
  }

  Notifications.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _user_id = (json['user_id'] as num?)?.toInt(),
      _title = json['title'],
      _message = json['message'],
      _type = json['type'],
      _is_read = json['is_read'],
      _created_at = json['created_at'],
      _deal_id = (json['deal_id'] as num?)?.toInt(),
      _task_id = (json['task_id'] as num?)?.toInt(),
      _createdAt = json['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
          : null,
      _updatedAt = json['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': _user_id,
    'title': _title,
    'message': _message,
    'type': _type,
    'is_read': _is_read,
    'created_at': _created_at,
    'deal_id': _deal_id,
    'task_id': _task_id,
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': _user_id,
    'title': _title,
    'message': _message,
    'type': _type,
    'is_read': _is_read,
    'created_at': _created_at,
    'deal_id': _deal_id,
    'task_id': _task_id,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<NotificationsModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<NotificationsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER_ID = amplify_core.QueryField(fieldName: "user_id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final MESSAGE = amplify_core.QueryField(fieldName: "message");
  static final TYPE = amplify_core.QueryField(fieldName: "type");
  static final IS_READ = amplify_core.QueryField(fieldName: "is_read");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final DEAL_ID = amplify_core.QueryField(fieldName: "deal_id");
  static final TASK_ID = amplify_core.QueryField(fieldName: "task_id");
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "Notifications";
      modelSchemaDefinition.pluralName = "Notifications";

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
          key: Notifications.USER_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Notifications.TITLE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Notifications.MESSAGE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Notifications.TYPE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Notifications.IS_READ,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.bool,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Notifications.CREATED_AT,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Notifications.DEAL_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Notifications.TASK_ID,
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

class _NotificationsModelType extends amplify_core.ModelType<Notifications> {
  const _NotificationsModelType();

  @override
  Notifications fromJson(Map<String, dynamic> jsonData) {
    return Notifications.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'Notifications';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Notifications] in your schema.
 */
class NotificationsModelIdentifier
    implements amplify_core.ModelIdentifier<Notifications> {
  final String id;

  /** Create an instance of NotificationsModelIdentifier using [id] the primary key. */
  const NotificationsModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'NotificationsModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is NotificationsModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
