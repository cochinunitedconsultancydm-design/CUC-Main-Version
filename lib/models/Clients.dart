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


/** This is an auto generated class representing the Clients type in your schema. */
class Clients extends amplify_core.Model {
  static const classType = const _ClientsModelType();
  final String id;
  final String? _name;
  final String? _email;
  final String? _phone;
  final String? _address;
  final String? _created_at;
  final String? _type_of_work;
  final String? _case_number;
  final String? _dob;
  final int? _review_rating;
  final String? _file_no;
  final String? _file_date;
  final bool? _is_contacted;
  final String? _managed_by;
  final String? _balance_due;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ClientsModelIdentifier get modelIdentifier {
      return ClientsModelIdentifier(
        id: id
      );
  }
  
  String? get name {
    return _name;
  }
  
  String? get email {
    return _email;
  }
  
  String? get phone {
    return _phone;
  }
  
  String? get address {
    return _address;
  }
  
  String? get created_at {
    return _created_at;
  }
  
  String? get type_of_work {
    return _type_of_work;
  }
  
  String? get case_number {
    return _case_number;
  }
  
  String? get dob {
    return _dob;
  }
  
  int? get review_rating {
    return _review_rating;
  }
  
  String? get file_no {
    return _file_no;
  }
  
  String? get file_date {
    return _file_date;
  }
  
  bool? get is_contacted {
    return _is_contacted;
  }
  
  String? get managed_by {
    return _managed_by;
  }
  
  String? get balance_due {
    return _balance_due;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Clients._internal({required this.id, name, email, phone, address, created_at, type_of_work, case_number, dob, review_rating, file_no, file_date, is_contacted, managed_by, balance_due, createdAt, updatedAt}): _name = name, _email = email, _phone = phone, _address = address, _created_at = created_at, _type_of_work = type_of_work, _case_number = case_number, _dob = dob, _review_rating = review_rating, _file_no = file_no, _file_date = file_date, _is_contacted = is_contacted, _managed_by = managed_by, _balance_due = balance_due, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Clients({String? id, String? name, String? email, String? phone, String? address, String? created_at, String? type_of_work, String? case_number, String? dob, int? review_rating, String? file_no, String? file_date, bool? is_contacted, String? managed_by, String? balance_due}) {
    return Clients._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      created_at: created_at,
      type_of_work: type_of_work,
      case_number: case_number,
      dob: dob,
      review_rating: review_rating,
      file_no: file_no,
      file_date: file_date,
      is_contacted: is_contacted,
      managed_by: managed_by,
      balance_due: balance_due);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Clients &&
      id == other.id &&
      _name == other._name &&
      _email == other._email &&
      _phone == other._phone &&
      _address == other._address &&
      _created_at == other._created_at &&
      _type_of_work == other._type_of_work &&
      _case_number == other._case_number &&
      _dob == other._dob &&
      _review_rating == other._review_rating &&
      _file_no == other._file_no &&
      _file_date == other._file_date &&
      _is_contacted == other._is_contacted &&
      _managed_by == other._managed_by &&
      _balance_due == other._balance_due;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Clients {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("phone=" + "$_phone" + ", ");
    buffer.write("address=" + "$_address" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("type_of_work=" + "$_type_of_work" + ", ");
    buffer.write("case_number=" + "$_case_number" + ", ");
    buffer.write("dob=" + "$_dob" + ", ");
    buffer.write("review_rating=" + (_review_rating != null ? _review_rating!.toString() : "null") + ", ");
    buffer.write("file_no=" + "$_file_no" + ", ");
    buffer.write("file_date=" + "$_file_date" + ", ");
    buffer.write("is_contacted=" + (_is_contacted != null ? _is_contacted!.toString() : "null") + ", ");
    buffer.write("managed_by=" + "$_managed_by" + ", ");
    buffer.write("balance_due=" + "$_balance_due" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Clients copyWith({String? name, String? email, String? phone, String? address, String? created_at, String? type_of_work, String? case_number, String? dob, int? review_rating, String? file_no, String? file_date, bool? is_contacted, String? managed_by, String? balance_due}) {
    return Clients._internal(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      created_at: created_at ?? this.created_at,
      type_of_work: type_of_work ?? this.type_of_work,
      case_number: case_number ?? this.case_number,
      dob: dob ?? this.dob,
      review_rating: review_rating ?? this.review_rating,
      file_no: file_no ?? this.file_no,
      file_date: file_date ?? this.file_date,
      is_contacted: is_contacted ?? this.is_contacted,
      managed_by: managed_by ?? this.managed_by,
      balance_due: balance_due ?? this.balance_due);
  }
  
  Clients copyWithModelFieldValues({
    ModelFieldValue<String?>? name,
    ModelFieldValue<String?>? email,
    ModelFieldValue<String?>? phone,
    ModelFieldValue<String?>? address,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? type_of_work,
    ModelFieldValue<String?>? case_number,
    ModelFieldValue<String?>? dob,
    ModelFieldValue<int?>? review_rating,
    ModelFieldValue<String?>? file_no,
    ModelFieldValue<String?>? file_date,
    ModelFieldValue<bool?>? is_contacted,
    ModelFieldValue<String?>? managed_by,
    ModelFieldValue<String?>? balance_due
  }) {
    return Clients._internal(
      id: id,
      name: name == null ? this.name : name.value,
      email: email == null ? this.email : email.value,
      phone: phone == null ? this.phone : phone.value,
      address: address == null ? this.address : address.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      type_of_work: type_of_work == null ? this.type_of_work : type_of_work.value,
      case_number: case_number == null ? this.case_number : case_number.value,
      dob: dob == null ? this.dob : dob.value,
      review_rating: review_rating == null ? this.review_rating : review_rating.value,
      file_no: file_no == null ? this.file_no : file_no.value,
      file_date: file_date == null ? this.file_date : file_date.value,
      is_contacted: is_contacted == null ? this.is_contacted : is_contacted.value,
      managed_by: managed_by == null ? this.managed_by : managed_by.value,
      balance_due: balance_due == null ? this.balance_due : balance_due.value
    );
  }
  
  Clients.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _email = json['email'],
      _phone = json['phone'],
      _address = json['address'],
      _created_at = json['created_at'],
      _type_of_work = json['type_of_work'],
      _case_number = json['case_number'],
      _dob = json['dob'],
      _review_rating = (json['review_rating'] as num?)?.toInt(),
      _file_no = json['file_no'],
      _file_date = json['file_date'],
      _is_contacted = json['is_contacted'],
      _managed_by = json['managed_by'],
      _balance_due = json['balance_due'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'email': _email, 'phone': _phone, 'address': _address, 'created_at': _created_at, 'type_of_work': _type_of_work, 'case_number': _case_number, 'dob': _dob, 'review_rating': _review_rating, 'file_no': _file_no, 'file_date': _file_date, 'is_contacted': _is_contacted, 'managed_by': _managed_by, 'balance_due': _balance_due, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'email': _email,
    'phone': _phone,
    'address': _address,
    'created_at': _created_at,
    'type_of_work': _type_of_work,
    'case_number': _case_number,
    'dob': _dob,
    'review_rating': _review_rating,
    'file_no': _file_no,
    'file_date': _file_date,
    'is_contacted': _is_contacted,
    'managed_by': _managed_by,
    'balance_due': _balance_due,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ClientsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ClientsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static final PHONE = amplify_core.QueryField(fieldName: "phone");
  static final ADDRESS = amplify_core.QueryField(fieldName: "address");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final TYPE_OF_WORK = amplify_core.QueryField(fieldName: "type_of_work");
  static final CASE_NUMBER = amplify_core.QueryField(fieldName: "case_number");
  static final DOB = amplify_core.QueryField(fieldName: "dob");
  static final REVIEW_RATING = amplify_core.QueryField(fieldName: "review_rating");
  static final FILE_NO = amplify_core.QueryField(fieldName: "file_no");
  static final FILE_DATE = amplify_core.QueryField(fieldName: "file_date");
  static final IS_CONTACTED = amplify_core.QueryField(fieldName: "is_contacted");
  static final MANAGED_BY = amplify_core.QueryField(fieldName: "managed_by");
  static final BALANCE_DUE = amplify_core.QueryField(fieldName: "balance_due");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Clients";
    modelSchemaDefinition.pluralName = "Clients";
    
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
      key: Clients.NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.EMAIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.PHONE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.ADDRESS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.TYPE_OF_WORK,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.CASE_NUMBER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.DOB,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.REVIEW_RATING,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.FILE_NO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.FILE_DATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.IS_CONTACTED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.MANAGED_BY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Clients.BALANCE_DUE,
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

class _ClientsModelType extends amplify_core.ModelType<Clients> {
  const _ClientsModelType();
  
  @override
  Clients fromJson(Map<String, dynamic> jsonData) {
    return Clients.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Clients';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Clients] in your schema.
 */
class ClientsModelIdentifier implements amplify_core.ModelIdentifier<Clients> {
  final String id;

  /** Create an instance of ClientsModelIdentifier using [id] the primary key. */
  const ClientsModelIdentifier({
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
  String toString() => 'ClientsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ClientsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}