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
import '../utils/safe_json_parse.dart';


/** This is an auto generated class representing the CompanyBills type in your schema. */
class CompanyBills extends amplify_core.Model {
  static const classType = const _CompanyBillsModelType();
  final String id;
  final String? _category;
  final String? _title;
  final double? _amount;
  final String? _bill_date;
  final String? _status;
  final String? _description;
  final String? _created_at;
  final int? _spent_by;
  final String? _spent_by_name;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CompanyBillsModelIdentifier get modelIdentifier {
      return CompanyBillsModelIdentifier(
        id: id
      );
  }
  
  String? get category {
    return _category;
  }
  
  String? get title {
    return _title;
  }
  
  double? get amount {
    return _amount;
  }
  
  String? get bill_date {
    return _bill_date;
  }
  
  String? get status {
    return _status;
  }
  
  String? get description {
    return _description;
  }
  
  String? get created_at {
    return _created_at;
  }
  
  int? get spent_by {
    return _spent_by;
  }
  
  String? get spent_by_name {
    return _spent_by_name;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const CompanyBills._internal({required this.id, category, title, amount, bill_date, status, description, created_at, spent_by, spent_by_name, createdAt, updatedAt}): _category = category, _title = title, _amount = amount, _bill_date = bill_date, _status = status, _description = description, _created_at = created_at, _spent_by = spent_by, _spent_by_name = spent_by_name, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory CompanyBills({String? id, String? category, String? title, double? amount, String? bill_date, String? status, String? description, String? created_at, int? spent_by, String? spent_by_name}) {
    return CompanyBills._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      category: category,
      title: title,
      amount: amount,
      bill_date: bill_date,
      status: status,
      description: description,
      created_at: created_at,
      spent_by: spent_by,
      spent_by_name: spent_by_name);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompanyBills &&
      id == other.id &&
      _category == other._category &&
      _title == other._title &&
      _amount == other._amount &&
      _bill_date == other._bill_date &&
      _status == other._status &&
      _description == other._description &&
      _created_at == other._created_at &&
      _spent_by == other._spent_by &&
      _spent_by_name == other._spent_by_name;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("CompanyBills {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("category=" + "$_category" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("bill_date=" + "$_bill_date" + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("spent_by=" + (_spent_by != null ? _spent_by!.toString() : "null") + ", ");
    buffer.write("spent_by_name=" + "$_spent_by_name" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  CompanyBills copyWith({String? category, String? title, double? amount, String? bill_date, String? status, String? description, String? created_at, int? spent_by, String? spent_by_name}) {
    return CompanyBills._internal(
      id: id,
      category: category ?? this.category,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      bill_date: bill_date ?? this.bill_date,
      status: status ?? this.status,
      description: description ?? this.description,
      created_at: created_at ?? this.created_at,
      spent_by: spent_by ?? this.spent_by,
      spent_by_name: spent_by_name ?? this.spent_by_name);
  }
  
  CompanyBills copyWithModelFieldValues({
    ModelFieldValue<String?>? category,
    ModelFieldValue<String?>? title,
    ModelFieldValue<double?>? amount,
    ModelFieldValue<String?>? bill_date,
    ModelFieldValue<String?>? status,
    ModelFieldValue<String?>? description,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<int?>? spent_by,
    ModelFieldValue<String?>? spent_by_name
  }) {
    return CompanyBills._internal(
      id: id,
      category: category == null ? this.category : category.value,
      title: title == null ? this.title : title.value,
      amount: amount == null ? this.amount : amount.value,
      bill_date: bill_date == null ? this.bill_date : bill_date.value,
      status: status == null ? this.status : status.value,
      description: description == null ? this.description : description.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      spent_by: spent_by == null ? this.spent_by : spent_by.value,
      spent_by_name: spent_by_name == null ? this.spent_by_name : spent_by_name.value
    );
  }
  
  CompanyBills.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _category = json['category'],
      _title = json['title'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _bill_date = json['bill_date'],
      _status = json['status'],
      _description = json['description'],
      _created_at = json['created_at'],
      _spent_by = safeParseInt(json['spent_by']),
      _spent_by_name = json['spent_by_name'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'category': _category, 'title': _title, 'amount': _amount, 'bill_date': _bill_date, 'status': _status, 'description': _description, 'created_at': _created_at, 'spent_by': _spent_by, 'spent_by_name': _spent_by_name, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'category': _category,
    'title': _title,
    'amount': _amount,
    'bill_date': _bill_date,
    'status': _status,
    'description': _description,
    'created_at': _created_at,
    'spent_by': _spent_by,
    'spent_by_name': _spent_by_name,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CompanyBillsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CompanyBillsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CATEGORY = amplify_core.QueryField(fieldName: "category");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final BILL_DATE = amplify_core.QueryField(fieldName: "bill_date");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final SPENT_BY = amplify_core.QueryField(fieldName: "spent_by");
  static final SPENT_BY_NAME = amplify_core.QueryField(fieldName: "spent_by_name");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "CompanyBills";
    modelSchemaDefinition.pluralName = "CompanyBills";
    
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
      key: CompanyBills.CATEGORY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompanyBills.TITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompanyBills.AMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompanyBills.BILL_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompanyBills.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompanyBills.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompanyBills.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompanyBills.SPENT_BY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompanyBills.SPENT_BY_NAME,
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

class _CompanyBillsModelType extends amplify_core.ModelType<CompanyBills> {
  const _CompanyBillsModelType();
  
  @override
  CompanyBills fromJson(Map<String, dynamic> jsonData) {
    return CompanyBills.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'CompanyBills';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [CompanyBills] in your schema.
 */
class CompanyBillsModelIdentifier implements amplify_core.ModelIdentifier<CompanyBills> {
  final String id;

  /** Create an instance of CompanyBillsModelIdentifier using [id] the primary key. */
  const CompanyBillsModelIdentifier({
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
  String toString() => 'CompanyBillsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CompanyBillsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}