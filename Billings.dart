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


/** This is an auto generated class representing the Billings type in your schema. */
class Billings extends amplify_core.Model {
  static const classType = const _BillingsModelType();
  final String id;
  final String? _invoice_no;
  final String? _client_name;
  final String? _date;
  final String? _amount;
  final String? _type;
  final String? _data;
  final String? _created_at;
  final String? _category;
  final String? _authorities;
  final String? _status;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  BillingsModelIdentifier get modelIdentifier {
      return BillingsModelIdentifier(
        id: id
      );
  }
  
  String? get invoice_no {
    return _invoice_no;
  }
  
  String? get client_name {
    return _client_name;
  }
  
  String? get date {
    return _date;
  }
  
  String? get amount {
    return _amount;
  }
  
  String? get type {
    return _type;
  }
  
  String? get data {
    return _data;
  }
  
  String? get created_at {
    return _created_at;
  }
  
  String? get category {
    return _category;
  }
  
  String? get authorities {
    return _authorities;
  }
  
  String? get status {
    return _status;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Billings._internal({required this.id, invoice_no, client_name, date, amount, type, data, created_at, category, authorities, status, createdAt, updatedAt}): _invoice_no = invoice_no, _client_name = client_name, _date = date, _amount = amount, _type = type, _data = data, _created_at = created_at, _category = category, _authorities = authorities, _status = status, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Billings({String? id, String? invoice_no, String? client_name, String? date, String? amount, String? type, String? data, String? created_at, String? category, String? authorities, String? status}) {
    return Billings._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      invoice_no: invoice_no,
      client_name: client_name,
      date: date,
      amount: amount,
      type: type,
      data: data,
      created_at: created_at,
      category: category,
      authorities: authorities,
      status: status);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Billings &&
      id == other.id &&
      _invoice_no == other._invoice_no &&
      _client_name == other._client_name &&
      _date == other._date &&
      _amount == other._amount &&
      _type == other._type &&
      _data == other._data &&
      _created_at == other._created_at &&
      _category == other._category &&
      _authorities == other._authorities &&
      _status == other._status;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Billings {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("invoice_no=" + "$_invoice_no" + ", ");
    buffer.write("client_name=" + "$_client_name" + ", ");
    buffer.write("date=" + "$_date" + ", ");
    buffer.write("amount=" + "$_amount" + ", ");
    buffer.write("type=" + "$_type" + ", ");
    buffer.write("data=" + "$_data" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("category=" + "$_category" + ", ");
    buffer.write("authorities=" + "$_authorities" + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Billings copyWith({String? invoice_no, String? client_name, String? date, String? amount, String? type, String? data, String? created_at, String? category, String? authorities, String? status}) {
    return Billings._internal(
      id: id,
      invoice_no: invoice_no ?? this.invoice_no,
      client_name: client_name ?? this.client_name,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      data: data ?? this.data,
      created_at: created_at ?? this.created_at,
      category: category ?? this.category,
      authorities: authorities ?? this.authorities,
      status: status ?? this.status);
  }
  
  Billings copyWithModelFieldValues({
    ModelFieldValue<String?>? invoice_no,
    ModelFieldValue<String?>? client_name,
    ModelFieldValue<String?>? date,
    ModelFieldValue<String?>? amount,
    ModelFieldValue<String?>? type,
    ModelFieldValue<String?>? data,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? category,
    ModelFieldValue<String?>? authorities,
    ModelFieldValue<String?>? status
  }) {
    return Billings._internal(
      id: id,
      invoice_no: invoice_no == null ? this.invoice_no : invoice_no.value,
      client_name: client_name == null ? this.client_name : client_name.value,
      date: date == null ? this.date : date.value,
      amount: amount == null ? this.amount : amount.value,
      type: type == null ? this.type : type.value,
      data: data == null ? this.data : data.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      category: category == null ? this.category : category.value,
      authorities: authorities == null ? this.authorities : authorities.value,
      status: status == null ? this.status : status.value
    );
  }
  
  Billings.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _invoice_no = json['invoice_no'],
      _client_name = json['client_name'],
      _date = json['date'],
      _amount = json['amount'],
      _type = json['type'],
      _data = json['data'],
      _created_at = json['created_at'],
      _category = json['category'],
      _authorities = json['authorities'],
      _status = json['status'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'invoice_no': _invoice_no, 'client_name': _client_name, 'date': _date, 'amount': _amount, 'type': _type, 'data': _data, 'created_at': _created_at, 'category': _category, 'authorities': _authorities, 'status': _status, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'invoice_no': _invoice_no,
    'client_name': _client_name,
    'date': _date,
    'amount': _amount,
    'type': _type,
    'data': _data,
    'created_at': _created_at,
    'category': _category,
    'authorities': _authorities,
    'status': _status,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<BillingsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<BillingsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final INVOICE_NO = amplify_core.QueryField(fieldName: "invoice_no");
  static final CLIENT_NAME = amplify_core.QueryField(fieldName: "client_name");
  static final DATE = amplify_core.QueryField(fieldName: "date");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final TYPE = amplify_core.QueryField(fieldName: "type");
  static final DATA = amplify_core.QueryField(fieldName: "data");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final CATEGORY = amplify_core.QueryField(fieldName: "category");
  static final AUTHORITIES = amplify_core.QueryField(fieldName: "authorities");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Billings";
    modelSchemaDefinition.pluralName = "Billings";
    
    modelSchemaDefinition.authRules = [
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
      key: Billings.INVOICE_NO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Billings.CLIENT_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Billings.DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Billings.AMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Billings.TYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Billings.DATA,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Billings.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Billings.CATEGORY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Billings.AUTHORITIES,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Billings.STATUS,
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

class _BillingsModelType extends amplify_core.ModelType<Billings> {
  const _BillingsModelType();
  
  @override
  Billings fromJson(Map<String, dynamic> jsonData) {
    return Billings.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Billings';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Billings] in your schema.
 */
class BillingsModelIdentifier implements amplify_core.ModelIdentifier<Billings> {
  final String id;

  /** Create an instance of BillingsModelIdentifier using [id] the primary key. */
  const BillingsModelIdentifier({
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
  String toString() => 'BillingsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is BillingsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}