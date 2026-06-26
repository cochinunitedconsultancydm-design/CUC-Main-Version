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

/** This is an auto generated class representing the LicenseServices type in your schema. */
class LicenseServices extends amplify_core.Model {
  static const classType = const _LicenseServicesModelType();
  final String id;
  final int? _client_license_id;
  final String? _service_description;
  final double? _service_cost;
  final String? _service_date;
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

  LicenseServicesModelIdentifier get modelIdentifier {
    return LicenseServicesModelIdentifier(id: id);
  }

  int? get client_license_id {
    return _client_license_id;
  }

  String? get service_description {
    return _service_description;
  }

  double? get service_cost {
    return _service_cost;
  }

  String? get service_date {
    return _service_date;
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

  const LicenseServices._internal({
    required this.id,
    client_license_id,
    service_description,
    service_cost,
    service_date,
    created_at,
    createdAt,
    updatedAt,
  }) : _client_license_id = client_license_id,
       _service_description = service_description,
       _service_cost = service_cost,
       _service_date = service_date,
       _created_at = created_at,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory LicenseServices({
    String? id,
    int? client_license_id,
    String? service_description,
    double? service_cost,
    String? service_date,
    String? created_at,
  }) {
    return LicenseServices._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      client_license_id: client_license_id,
      service_description: service_description,
      service_cost: service_cost,
      service_date: service_date,
      created_at: created_at,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LicenseServices &&
        id == other.id &&
        _client_license_id == other._client_license_id &&
        _service_description == other._service_description &&
        _service_cost == other._service_cost &&
        _service_date == other._service_date &&
        _created_at == other._created_at;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("LicenseServices {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write(
      "client_license_id=" +
          (_client_license_id != null
              ? _client_license_id!.toString()
              : "null") +
          ", ",
    );
    buffer.write("service_description=" + "$_service_description" + ", ");
    buffer.write(
      "service_cost=" +
          (_service_cost != null ? _service_cost!.toString() : "null") +
          ", ",
    );
    buffer.write("service_date=" + "$_service_date" + ", ");
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

  LicenseServices copyWith({
    int? client_license_id,
    String? service_description,
    double? service_cost,
    String? service_date,
    String? created_at,
  }) {
    return LicenseServices._internal(
      id: id,
      client_license_id: client_license_id ?? this.client_license_id,
      service_description: service_description ?? this.service_description,
      service_cost: service_cost ?? this.service_cost,
      service_date: service_date ?? this.service_date,
      created_at: created_at ?? this.created_at,
    );
  }

  LicenseServices copyWithModelFieldValues({
    ModelFieldValue<int?>? client_license_id,
    ModelFieldValue<String?>? service_description,
    ModelFieldValue<double?>? service_cost,
    ModelFieldValue<String?>? service_date,
    ModelFieldValue<String?>? created_at,
  }) {
    return LicenseServices._internal(
      id: id,
      client_license_id: client_license_id == null
          ? this.client_license_id
          : client_license_id.value,
      service_description: service_description == null
          ? this.service_description
          : service_description.value,
      service_cost: service_cost == null
          ? this.service_cost
          : service_cost.value,
      service_date: service_date == null
          ? this.service_date
          : service_date.value,
      created_at: created_at == null ? this.created_at : created_at.value,
    );
  }

  LicenseServices.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _client_license_id = (json['client_license_id'] as num?)?.toInt(),
      _service_description = json['service_description'],
      _service_cost = (json['service_cost'] as num?)?.toDouble(),
      _service_date = json['service_date'],
      _created_at = json['created_at'],
      _createdAt = json['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
          : null,
      _updatedAt = json['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'client_license_id': _client_license_id,
    'service_description': _service_description,
    'service_cost': _service_cost,
    'service_date': _service_date,
    'created_at': _created_at,
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'client_license_id': _client_license_id,
    'service_description': _service_description,
    'service_cost': _service_cost,
    'service_date': _service_date,
    'created_at': _created_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<LicenseServicesModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<LicenseServicesModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CLIENT_LICENSE_ID = amplify_core.QueryField(
    fieldName: "client_license_id",
  );
  static final SERVICE_DESCRIPTION = amplify_core.QueryField(
    fieldName: "service_description",
  );
  static final SERVICE_COST = amplify_core.QueryField(
    fieldName: "service_cost",
  );
  static final SERVICE_DATE = amplify_core.QueryField(
    fieldName: "service_date",
  );
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "LicenseServices";
      modelSchemaDefinition.pluralName = "LicenseServices";

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
          key: LicenseServices.CLIENT_LICENSE_ID,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: LicenseServices.SERVICE_DESCRIPTION,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: LicenseServices.SERVICE_COST,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.double,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: LicenseServices.SERVICE_DATE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: LicenseServices.CREATED_AT,
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

class _LicenseServicesModelType
    extends amplify_core.ModelType<LicenseServices> {
  const _LicenseServicesModelType();

  @override
  LicenseServices fromJson(Map<String, dynamic> jsonData) {
    return LicenseServices.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'LicenseServices';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [LicenseServices] in your schema.
 */
class LicenseServicesModelIdentifier
    implements amplify_core.ModelIdentifier<LicenseServices> {
  final String id;

  /** Create an instance of LicenseServicesModelIdentifier using [id] the primary key. */
  const LicenseServicesModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'LicenseServicesModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LicenseServicesModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
