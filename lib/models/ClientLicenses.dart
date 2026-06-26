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

/** This is an auto generated class representing the ClientLicenses type in your schema. */
class ClientLicenses extends amplify_core.Model {
  static const classType = const _ClientLicensesModelType();
  final String id;
  final int? _client_id;
  final int? _license_type_id;
  final String? _file_no;
  final String? _service_date;
  final String? _expiry_date;
  final String? _status;
  final String? _notes;
  final String? _created_at;
  final String? _updated_at;
  final String? _manual_client_name;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated(
    '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.',
  )
  @override
  String getId() => id;

  ClientLicensesModelIdentifier get modelIdentifier {
    return ClientLicensesModelIdentifier(id: id);
  }

  int? get client_id {
    return _client_id;
  }

  int? get license_type_id {
    return _license_type_id;
  }

  String? get file_no {
    return _file_no;
  }

  String? get service_date {
    return _service_date;
  }

  String? get expiry_date {
    return _expiry_date;
  }

  String? get status {
    return _status;
  }

  String? get notes {
    return _notes;
  }

  String? get created_at {
    return _created_at;
  }

  String? get updated_at {
    return _updated_at;
  }

  String? get manual_client_name {
    return _manual_client_name;
  }

  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }

  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const ClientLicenses._internal({
    required this.id,
    client_id,
    license_type_id,
    file_no,
    service_date,
    expiry_date,
    status,
    notes,
    created_at,
    updated_at,
    manual_client_name,
    createdAt,
    updatedAt,
  }) : _client_id = client_id,
       _license_type_id = license_type_id,
       _file_no = file_no,
       _service_date = service_date,
       _expiry_date = expiry_date,
       _status = status,
       _notes = notes,
       _created_at = created_at,
       _updated_at = updated_at,
       _manual_client_name = manual_client_name,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory ClientLicenses({
    String? id,
    int? client_id,
    int? license_type_id,
    String? file_no,
    String? service_date,
    String? expiry_date,
    String? status,
    String? notes,
    String? created_at,
    String? updated_at,
    String? manual_client_name,
  }) {
    return ClientLicenses._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      client_id: client_id,
      license_type_id: license_type_id,
      file_no: file_no,
      service_date: service_date,
      expiry_date: expiry_date,
      status: status,
      notes: notes,
      created_at: created_at,
      updated_at: updated_at,
      manual_client_name: manual_client_name,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientLicenses &&
        id == other.id &&
        _client_id == other._client_id &&
        _license_type_id == other._license_type_id &&
        _file_no == other._file_no &&
        _service_date == other._service_date &&
        _expiry_date == other._expiry_date &&
        _status == other._status &&
        _notes == other._notes &&
        _created_at == other._created_at &&
        _updated_at == other._updated_at &&
        _manual_client_name == other._manual_client_name;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("ClientLicenses {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write(
      "client_id=" +
          (_client_id != null ? _client_id!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "license_type_id=" +
          (_license_type_id != null ? _license_type_id!.toString() : "null") +
          ", ",
    );
    buffer.write("file_no=" + "$_file_no" + ", ");
    buffer.write("service_date=" + "$_service_date" + ", ");
    buffer.write("expiry_date=" + "$_expiry_date" + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("notes=" + "$_notes" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("updated_at=" + "$_updated_at" + ", ");
    buffer.write("manual_client_name=" + "$_manual_client_name" + ", ");
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

  ClientLicenses copyWith({
    int? client_id,
    int? license_type_id,
    String? file_no,
    String? service_date,
    String? expiry_date,
    String? status,
    String? notes,
    String? created_at,
    String? updated_at,
    String? manual_client_name,
  }) {
    return ClientLicenses._internal(
      id: id,
      client_id: client_id ?? this.client_id,
      license_type_id: license_type_id ?? this.license_type_id,
      file_no: file_no ?? this.file_no,
      service_date: service_date ?? this.service_date,
      expiry_date: expiry_date ?? this.expiry_date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      manual_client_name: manual_client_name ?? this.manual_client_name,
    );
  }

  ClientLicenses copyWithModelFieldValues({
    ModelFieldValue<int?>? client_id,
    ModelFieldValue<int?>? license_type_id,
    ModelFieldValue<String?>? file_no,
    ModelFieldValue<String?>? service_date,
    ModelFieldValue<String?>? expiry_date,
    ModelFieldValue<String?>? status,
    ModelFieldValue<String?>? notes,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? updated_at,
    ModelFieldValue<String?>? manual_client_name,
  }) {
    return ClientLicenses._internal(
      id: id,
      client_id: client_id == null ? this.client_id : client_id.value,
      license_type_id: license_type_id == null
          ? this.license_type_id
          : license_type_id.value,
      file_no: file_no == null ? this.file_no : file_no.value,
      service_date: service_date == null
          ? this.service_date
          : service_date.value,
      expiry_date: expiry_date == null ? this.expiry_date : expiry_date.value,
      status: status == null ? this.status : status.value,
      notes: notes == null ? this.notes : notes.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      updated_at: updated_at == null ? this.updated_at : updated_at.value,
      manual_client_name: manual_client_name == null
          ? this.manual_client_name
          : manual_client_name.value,
    );
  }

  ClientLicenses.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _client_id = (json['client_id'] as num?)?.toInt(),
      _license_type_id = (json['license_type_id'] as num?)?.toInt(),
      _file_no = json['file_no'],
      _service_date = json['service_date'],
      _expiry_date = json['expiry_date'],
      _status = json['status'],
      _notes = json['notes'],
      _created_at = json['created_at'],
      _updated_at = json['updated_at'],
      _manual_client_name = json['manual_client_name'],
      _createdAt = json['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
          : null,
      _updatedAt = json['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'client_id': _client_id,
    'license_type_id': _license_type_id,
    'file_no': _file_no,
    'service_date': _service_date,
    'expiry_date': _expiry_date,
    'status': _status,
    'notes': _notes,
    'created_at': _created_at,
    'updated_at': _updated_at,
    'manual_client_name': _manual_client_name,
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'client_id': _client_id,
    'license_type_id': _license_type_id,
    'file_no': _file_no,
    'service_date': _service_date,
    'expiry_date': _expiry_date,
    'status': _status,
    'notes': _notes,
    'created_at': _created_at,
    'updated_at': _updated_at,
    'manual_client_name': _manual_client_name,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<ClientLicensesModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<ClientLicensesModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CLIENT_ID = amplify_core.QueryField(fieldName: "client_id");
  static final LICENSE_TYPE_ID = amplify_core.QueryField(
    fieldName: "license_type_id",
  );
  static final FILE_NO = amplify_core.QueryField(fieldName: "file_no");
  static final SERVICE_DATE = amplify_core.QueryField(
    fieldName: "service_date",
  );
  static final EXPIRY_DATE = amplify_core.QueryField(fieldName: "expiry_date");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final NOTES = amplify_core.QueryField(fieldName: "notes");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final UPDATED_AT = amplify_core.QueryField(fieldName: "updated_at");
  static final MANUAL_CLIENT_NAME = amplify_core.QueryField(
    fieldName: "manual_client_name",
  );
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "ClientLicenses";
      modelSchemaDefinition.pluralName = "ClientLicenses";

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
          key: ClientLicenses.CLIENT_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ClientLicenses.LICENSE_TYPE_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ClientLicenses.FILE_NO,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ClientLicenses.SERVICE_DATE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ClientLicenses.EXPIRY_DATE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ClientLicenses.STATUS,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ClientLicenses.NOTES,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ClientLicenses.CREATED_AT,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ClientLicenses.UPDATED_AT,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: ClientLicenses.MANUAL_CLIENT_NAME,
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

class _ClientLicensesModelType extends amplify_core.ModelType<ClientLicenses> {
  const _ClientLicensesModelType();

  @override
  ClientLicenses fromJson(Map<String, dynamic> jsonData) {
    return ClientLicenses.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'ClientLicenses';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ClientLicenses] in your schema.
 */
class ClientLicensesModelIdentifier
    implements amplify_core.ModelIdentifier<ClientLicenses> {
  final String id;

  /** Create an instance of ClientLicensesModelIdentifier using [id] the primary key. */
  const ClientLicensesModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'ClientLicensesModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ClientLicensesModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
