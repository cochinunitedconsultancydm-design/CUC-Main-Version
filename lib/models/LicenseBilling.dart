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


/** This is an auto generated class representing the LicenseBilling type in your schema. */
class LicenseBilling extends amplify_core.Model {
  static const classType = const _LicenseBillingModelType();
  final String id;
  final int? _client_license_id;
  final double? _amount;
  final String? _payment_status;
  final String? _invoice_no;
  final String? _payment_date;
  final String? _created_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  LicenseBillingModelIdentifier get modelIdentifier {
      return LicenseBillingModelIdentifier(
        id: id
      );
  }
  
  int? get client_license_id {
    return _client_license_id;
  }
  
  double? get amount {
    return _amount;
  }
  
  String? get payment_status {
    return _payment_status;
  }
  
  String? get invoice_no {
    return _invoice_no;
  }
  
  String? get payment_date {
    return _payment_date;
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
  
  const LicenseBilling._internal({required this.id, client_license_id, amount, payment_status, invoice_no, payment_date, created_at, createdAt, updatedAt}): _client_license_id = client_license_id, _amount = amount, _payment_status = payment_status, _invoice_no = invoice_no, _payment_date = payment_date, _created_at = created_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory LicenseBilling({String? id, int? client_license_id, double? amount, String? payment_status, String? invoice_no, String? payment_date, String? created_at}) {
    return LicenseBilling._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      client_license_id: client_license_id,
      amount: amount,
      payment_status: payment_status,
      invoice_no: invoice_no,
      payment_date: payment_date,
      created_at: created_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LicenseBilling &&
      id == other.id &&
      _client_license_id == other._client_license_id &&
      _amount == other._amount &&
      _payment_status == other._payment_status &&
      _invoice_no == other._invoice_no &&
      _payment_date == other._payment_date &&
      _created_at == other._created_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("LicenseBilling {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("client_license_id=" + (_client_license_id != null ? _client_license_id!.toString() : "null") + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("payment_status=" + "$_payment_status" + ", ");
    buffer.write("invoice_no=" + "$_invoice_no" + ", ");
    buffer.write("payment_date=" + "$_payment_date" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  LicenseBilling copyWith({int? client_license_id, double? amount, String? payment_status, String? invoice_no, String? payment_date, String? created_at}) {
    return LicenseBilling._internal(
      id: id,
      client_license_id: client_license_id ?? this.client_license_id,
      amount: amount ?? this.amount,
      payment_status: payment_status ?? this.payment_status,
      invoice_no: invoice_no ?? this.invoice_no,
      payment_date: payment_date ?? this.payment_date,
      created_at: created_at ?? this.created_at);
  }
  
  LicenseBilling copyWithModelFieldValues({
    ModelFieldValue<int?>? client_license_id,
    ModelFieldValue<double?>? amount,
    ModelFieldValue<String?>? payment_status,
    ModelFieldValue<String?>? invoice_no,
    ModelFieldValue<String?>? payment_date,
    ModelFieldValue<String?>? created_at
  }) {
    return LicenseBilling._internal(
      id: id,
      client_license_id: client_license_id == null ? this.client_license_id : client_license_id.value,
      amount: amount == null ? this.amount : amount.value,
      payment_status: payment_status == null ? this.payment_status : payment_status.value,
      invoice_no: invoice_no == null ? this.invoice_no : invoice_no.value,
      payment_date: payment_date == null ? this.payment_date : payment_date.value,
      created_at: created_at == null ? this.created_at : created_at.value
    );
  }
  
  LicenseBilling.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _client_license_id = (json['client_license_id'] as num?)?.toInt(),
      _amount = (json['amount'] as num?)?.toDouble(),
      _payment_status = json['payment_status'],
      _invoice_no = json['invoice_no'],
      _payment_date = json['payment_date'],
      _created_at = json['created_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'client_license_id': _client_license_id, 'amount': _amount, 'payment_status': _payment_status, 'invoice_no': _invoice_no, 'payment_date': _payment_date, 'created_at': _created_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'client_license_id': _client_license_id,
    'amount': _amount,
    'payment_status': _payment_status,
    'invoice_no': _invoice_no,
    'payment_date': _payment_date,
    'created_at': _created_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<LicenseBillingModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<LicenseBillingModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CLIENT_LICENSE_ID = amplify_core.QueryField(fieldName: "client_license_id");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final PAYMENT_STATUS = amplify_core.QueryField(fieldName: "payment_status");
  static final INVOICE_NO = amplify_core.QueryField(fieldName: "invoice_no");
  static final PAYMENT_DATE = amplify_core.QueryField(fieldName: "payment_date");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "LicenseBilling";
    modelSchemaDefinition.pluralName = "LicenseBillings";
    
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
      key: LicenseBilling.CLIENT_LICENSE_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseBilling.AMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseBilling.PAYMENT_STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseBilling.INVOICE_NO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseBilling.PAYMENT_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: LicenseBilling.CREATED_AT,
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

class _LicenseBillingModelType extends amplify_core.ModelType<LicenseBilling> {
  const _LicenseBillingModelType();
  
  @override
  LicenseBilling fromJson(Map<String, dynamic> jsonData) {
    return LicenseBilling.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'LicenseBilling';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [LicenseBilling] in your schema.
 */
class LicenseBillingModelIdentifier implements amplify_core.ModelIdentifier<LicenseBilling> {
  final String id;

  /** Create an instance of LicenseBillingModelIdentifier using [id] the primary key. */
  const LicenseBillingModelIdentifier({
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
  String toString() => 'LicenseBillingModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is LicenseBillingModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}