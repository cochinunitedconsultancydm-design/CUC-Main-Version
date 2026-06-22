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


/** This is an auto generated class representing the LicenseNotifications type in your schema. */
class LicenseNotifications extends amplify_core.Model {
  static const classType = const _LicenseNotificationsModelType();
  final String id;
  final int? _client_license_id;
  final String? _notification_type;
  final String? _message;
  final bool? _is_sent;
  final String? _scheduled_date;
  final String? _created_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  LicenseNotificationsModelIdentifier get modelIdentifier {
      return LicenseNotificationsModelIdentifier(
        id: id
      );
  }
  
  int? get client_license_id {
    return _client_license_id;
  }
  
  String? get notification_type {
    return _notification_type;
  }
  
  String? get message {
    return _message;
  }
  
  bool? get is_sent {
    return _is_sent;
  }
  
  String? get scheduled_date {
    return _scheduled_date;
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
  
  const LicenseNotifications._internal({required this.id, client_license_id, notification_type, message, is_sent, scheduled_date, created_at, createdAt, updatedAt}): _client_license_id = client_license_id, _notification_type = notification_type, _message = message, _is_sent = is_sent, _scheduled_date = scheduled_date, _created_at = created_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory LicenseNotifications({String? id, int? client_license_id, String? notification_type, String? message, bool? is_sent, String? scheduled_date, String? created_at}) {
    return LicenseNotifications._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      client_license_id: client_license_id,
      notification_type: notification_type,
      message: message,
      is_sent: is_sent,
      scheduled_date: scheduled_date,
      created_at: created_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LicenseNotifications &&
      id == other.id &&
      _client_license_id == other._client_license_id &&
      _notification_type == other._notification_type &&
      _message == other._message &&
      _is_sent == other._is_sent &&
      _scheduled_date == other._scheduled_date &&
      _created_at == other._created_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("LicenseNotifications {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("client_license_id=" + (_client_license_id != null ? _client_license_id!.toString() : "null") + ", ");
    buffer.write("notification_type=" + "$_notification_type" + ", ");
    buffer.write("message=" + "$_message" + ", ");
    buffer.write("is_sent=" + (_is_sent != null ? _is_sent!.toString() : "null") + ", ");
    buffer.write("scheduled_date=" + "$_scheduled_date" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  LicenseNotifications copyWith({int? client_license_id, String? notification_type, String? message, bool? is_sent, String? scheduled_date, String? created_at}) {
    return LicenseNotifications._internal(
      id: id,
      client_license_id: client_license_id ?? this.client_license_id,
      notification_type: notification_type ?? this.notification_type,
      message: message ?? this.message,
      is_sent: is_sent ?? this.is_sent,
      scheduled_date: scheduled_date ?? this.scheduled_date,
      created_at: created_at ?? this.created_at);
  }
  
  LicenseNotifications copyWithModelFieldValues({
    ModelFieldValue<int?>? client_license_id,
    ModelFieldValue<String?>? notification_type,
    ModelFieldValue<String?>? message,
    ModelFieldValue<bool?>? is_sent,
    ModelFieldValue<String?>? scheduled_date,
    ModelFieldValue<String?>? created_at
  }) {
    return LicenseNotifications._internal(
      id: id,
      client_license_id: client_license_id == null ? this.client_license_id : client_license_id.value,
      notification_type: notification_type == null ? this.notification_type : notification_type.value,
      message: message == null ? this.message : message.value,
      is_sent: is_sent == null ? this.is_sent : is_sent.value,
      scheduled_date: scheduled_date == null ? this.scheduled_date : scheduled_date.value,
      created_at: created_at == null ? this.created_at : created_at.value
    );
  }
  
  LicenseNotifications.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _client_license_id = (json['client_license_id'] as num?)?.toInt(),
      _notification_type = json['notification_type'],
      _message = json['message'],
      _is_sent = json['is_sent'],
      _scheduled_date = json['scheduled_date'],
      _created_at = json['created_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'client_license_id': _client_license_id, 'notification_type': _notification_type, 'message': _message, 'is_sent': _is_sent, 'scheduled_date': _scheduled_date, 'created_at': _created_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'client_license_id': _client_license_id,
    'notification_type': _notification_type,
    'message': _message,
    'is_sent': _is_sent,
    'scheduled_date': _scheduled_date,
    'created_at': _created_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<LicenseNotificationsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<LicenseNotificationsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CLIENT_LICENSE_ID = amplify_core.QueryField(fieldName: "client_license_id");
  static final NOTIFICATION_TYPE = amplify_core.QueryField(fieldName: "notification_type");
  static final MESSAGE = amplify_core.QueryField(fieldName: "message");
  static final IS_SENT = amplify_core.QueryField(fieldName: "is_sent");
  static final SCHEDULED_DATE = amplify_core.QueryField(fieldName: "scheduled_date");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "LicenseNotifications";
    modelSchemaDefinition.pluralName = "LicenseNotifications";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.IDENTITYPOOL,
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
      key: LicenseNotifications.CLIENT_LICENSE_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseNotifications.NOTIFICATION_TYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseNotifications.MESSAGE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseNotifications.IS_SENT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseNotifications.SCHEDULED_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseNotifications.CREATED_AT,
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

class _LicenseNotificationsModelType extends amplify_core.ModelType<LicenseNotifications> {
  const _LicenseNotificationsModelType();
  
  @override
  LicenseNotifications fromJson(Map<String, dynamic> jsonData) {
    return LicenseNotifications.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'LicenseNotifications';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [LicenseNotifications] in your schema.
 */
class LicenseNotificationsModelIdentifier implements amplify_core.ModelIdentifier<LicenseNotifications> {
  final String id;

  /** Create an instance of LicenseNotificationsModelIdentifier using [id] the primary key. */
  const LicenseNotificationsModelIdentifier({
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
  String toString() => 'LicenseNotificationsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is LicenseNotificationsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}