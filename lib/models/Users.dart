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


/** This is an auto generated class representing the Users type in your schema. */
class Users extends amplify_core.Model {
  static const classType = const _UsersModelType();
  final String id;
  final String? _username;
  final String? _password;
  final String? _role;
  final String? _name;
  final String? _created_at;
  final String? _last_seen;
  final String? _email;
  final String? _designation;
  final String? _personal_phone;
  final String? _aadhar_card;
  final String? _driving_license;
  final String? _insurance;
  final String? _emergency_contact;
  final String? _offer_letter;
  final String? _dob;
  final String? _salary;
  final String? _work_time;
  final String? _blood_group;
  final String? _personal_email;
  final String? _company_email;
  final String? _company_phone;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UsersModelIdentifier get modelIdentifier {
      return UsersModelIdentifier(
        id: id
      );
  }
  
  String? get username {
    return _username;
  }
  
  String? get password {
    return _password;
  }
  
  String? get role {
    return _role;
  }
  
  String? get name {
    return _name;
  }
  
  String? get created_at {
    return _created_at;
  }
  
  String? get last_seen {
    return _last_seen;
  }
  
  String? get email {
    return _email;
  }
  
  String? get designation {
    return _designation;
  }

  String? get personal_phone {
    return _personal_phone;
  }

  String? get aadhar_card {
    return _aadhar_card;
  }

  String? get driving_license {
    return _driving_license;
  }

  String? get insurance {
    return _insurance;
  }

  String? get emergency_contact {
    return _emergency_contact;
  }

  String? get offer_letter {
    return _offer_letter;
  }

  String? get dob {
    return _dob;
  }

  String? get salary {
    return _salary;
  }

  String? get work_time {
    return _work_time;
  }

  String? get blood_group {
    return _blood_group;
  }

  String? get personal_email {
    return _personal_email;
  }

  String? get company_email {
    return _company_email;
  }

  String? get company_phone {
    return _company_phone;
  }

  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Users._internal({required this.id, username, password, role, name, created_at, last_seen, email, designation, personal_phone, aadhar_card, driving_license, insurance, emergency_contact, offer_letter, dob, salary, work_time, blood_group, personal_email, company_email, company_phone, createdAt, updatedAt}): _username = username, _password = password, _role = role, _name = name, _created_at = created_at, _last_seen = last_seen, _email = email, _designation = designation, _personal_phone = personal_phone, _aadhar_card = aadhar_card, _driving_license = driving_license, _insurance = insurance, _emergency_contact = emergency_contact, _offer_letter = offer_letter, _dob = dob, _salary = salary, _work_time = work_time, _blood_group = blood_group, _personal_email = personal_email, _company_email = company_email, _company_phone = company_phone, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Users({String? id, String? username, String? password, String? role, String? name, String? created_at, String? last_seen, String? email, String? designation, String? personal_phone, String? aadhar_card, String? driving_license, String? insurance, String? emergency_contact, String? offer_letter, String? dob, String? salary, String? work_time, String? blood_group, String? personal_email, String? company_email, String? company_phone}) {
    return Users._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      username: username,
      password: password,
      role: role,
      name: name,
      created_at: created_at,
      last_seen: last_seen,
      email: email,
      designation: designation,
      personal_phone: personal_phone,
      aadhar_card: aadhar_card,
      driving_license: driving_license,
      insurance: insurance,
      emergency_contact: emergency_contact,
      offer_letter: offer_letter,
      dob: dob,
      salary: salary,
      work_time: work_time,
      blood_group: blood_group,
      personal_email: personal_email,
      company_email: company_email,
      company_phone: company_phone);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Users &&
      id == other.id &&
      _username == other._username &&
      _password == other._password &&
      _role == other._role &&
      _name == other._name &&
      _created_at == other._created_at &&
      _last_seen == other._last_seen &&
      _email == other._email
      && _designation == other._designation
      && _personal_phone == other._personal_phone
      && _aadhar_card == other._aadhar_card
      && _driving_license == other._driving_license
      && _insurance == other._insurance
      && _emergency_contact == other._emergency_contact
      && _offer_letter == other._offer_letter
      && _dob == other._dob
      && _salary == other._salary
      && _work_time == other._work_time
      && _blood_group == other._blood_group
      && _personal_email == other._personal_email
      && _company_email == other._company_email
      && _company_phone == other._company_phone;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Users {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("username=" + "$_username" + ", ");
    buffer.write("password=" + "$_password" + ", ");
    buffer.write("role=" + "$_role" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("last_seen=" + "$_last_seen" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("designation=" + "$_designation" + ", ");
    buffer.write("personal_phone=" + "$_personal_phone" + ", ");
    buffer.write("aadhar_card=" + "$_aadhar_card" + ", ");
    buffer.write("driving_license=" + "$_driving_license" + ", ");
    buffer.write("insurance=" + "$_insurance" + ", ");
    buffer.write("emergency_contact=" + "$_emergency_contact" + ", ");
    buffer.write("offer_letter=" + "$_offer_letter" + ", ");
    buffer.write("dob=" + "$_dob" + ", ");
    buffer.write("salary=" + "$_salary" + ", ");
    buffer.write("work_time=" + "$_work_time" + ", ");
    buffer.write("blood_group=" + "$_blood_group" + ", ");
    buffer.write("personal_email=" + "$_personal_email" + ", ");
    buffer.write("company_email=" + "$_company_email" + ", ");
    buffer.write("company_phone=" + "$_company_phone" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Users copyWith({String? username, String? password, String? role, String? name, String? created_at, String? last_seen, String? email, String? designation, String? personal_phone, String? aadhar_card, String? driving_license, String? insurance, String? emergency_contact, String? offer_letter, String? dob, String? salary, String? work_time, String? blood_group, String? personal_email, String? company_email, String? company_phone}) {
    return Users._internal(
      id: id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      created_at: created_at ?? this.created_at,
      last_seen: last_seen ?? this.last_seen,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      personal_phone: personal_phone ?? this.personal_phone,
      aadhar_card: aadhar_card ?? this.aadhar_card,
      driving_license: driving_license ?? this.driving_license,
      insurance: insurance ?? this.insurance,
      emergency_contact: emergency_contact ?? this.emergency_contact,
      offer_letter: offer_letter ?? this.offer_letter,
      dob: dob ?? this.dob,
      salary: salary ?? this.salary,
      work_time: work_time ?? this.work_time,
      blood_group: blood_group ?? this.blood_group,
      personal_email: personal_email ?? this.personal_email,
      company_email: company_email ?? this.company_email,
      company_phone: company_phone ?? this.company_phone);
  }
  
  Users copyWithModelFieldValues({
    ModelFieldValue<String?>? username,
    ModelFieldValue<String?>? password,
    ModelFieldValue<String?>? role,
    ModelFieldValue<String?>? name,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? last_seen,
    ModelFieldValue<String?>? email,
    ModelFieldValue<String?>? designation,
    ModelFieldValue<String?>? personal_phone,
    ModelFieldValue<String?>? aadhar_card,
    ModelFieldValue<String?>? driving_license,
    ModelFieldValue<String?>? insurance,
    ModelFieldValue<String?>? emergency_contact,
    ModelFieldValue<String?>? offer_letter,
    ModelFieldValue<String?>? dob,
    ModelFieldValue<String?>? salary,
    ModelFieldValue<String?>? work_time,
    ModelFieldValue<String?>? blood_group,
    ModelFieldValue<String?>? personal_email,
    ModelFieldValue<String?>? company_email,
    ModelFieldValue<String?>? company_phone
  }) {
    return Users._internal(
      id: id,
      username: username == null ? this.username : username.value,
      password: password == null ? this.password : password.value,
      role: role == null ? this.role : role.value,
      name: name == null ? this.name : name.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      last_seen: last_seen == null ? this.last_seen : last_seen.value,
      email: email == null ? this.email : email.value,
      designation: designation == null ? this.designation : designation.value,
      personal_phone: personal_phone == null ? this.personal_phone : personal_phone.value,
      aadhar_card: aadhar_card == null ? this.aadhar_card : aadhar_card.value,
      driving_license: driving_license == null ? this.driving_license : driving_license.value,
      insurance: insurance == null ? this.insurance : insurance.value,
      emergency_contact: emergency_contact == null ? this.emergency_contact : emergency_contact.value,
      offer_letter: offer_letter == null ? this.offer_letter : offer_letter.value,
      dob: dob == null ? this.dob : dob.value,
      salary: salary == null ? this.salary : salary.value,
      work_time: work_time == null ? this.work_time : work_time.value,
      blood_group: blood_group == null ? this.blood_group : blood_group.value,
      personal_email: personal_email == null ? this.personal_email : personal_email.value,
      company_email: company_email == null ? this.company_email : company_email.value,
      company_phone: company_phone == null ? this.company_phone : company_phone.value
    );
  }
  
  Users.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _username = json['username'],
      _password = json['password'],
      _role = json['role'],
      _name = json['name'],
      _created_at = json['created_at'],
      _last_seen = json['last_seen'],
      _email = json['email'],
      _designation = json['designation'],
      _personal_phone = json['personal_phone'],
      _aadhar_card = json['aadhar_card'],
      _driving_license = json['driving_license'],
      _insurance = json['insurance'],
      _emergency_contact = json['emergency_contact'],
      _offer_letter = json['offer_letter'],
      _dob = json['dob'],
      _salary = json['salary'],
      _work_time = json['work_time'],
      _blood_group = json['blood_group'],
      _personal_email = json['personal_email'],
      _company_email = json['company_email'],
      _company_phone = json['company_phone'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'username': _username, 'password': _password, 'role': _role, 'name': _name, 'created_at': _created_at, 'last_seen': _last_seen, 'email': _email,
    'designation': _designation,
    'personal_phone': _personal_phone,
    'aadhar_card': _aadhar_card,
    'driving_license': _driving_license,
    'insurance': _insurance,
    'emergency_contact': _emergency_contact,
    'offer_letter': _offer_letter,
    'dob': _dob,
    'salary': _salary,
    'work_time': _work_time,
    'blood_group': _blood_group,
    'personal_email': _personal_email,
    'company_email': _company_email,
    'company_phone': _company_phone,
    'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'username': _username,
    'password': _password,
    'role': _role,
    'name': _name,
    'created_at': _created_at,
    'last_seen': _last_seen,
    'email': _email,
    'designation': _designation,
    'personal_phone': _personal_phone,
    'aadhar_card': _aadhar_card,
    'driving_license': _driving_license,
    'insurance': _insurance,
    'emergency_contact': _emergency_contact,
    'offer_letter': _offer_letter,
    'dob': _dob,
    'salary': _salary,
    'work_time': _work_time,
    'blood_group': _blood_group,
    'personal_email': _personal_email,
    'company_email': _company_email,
    'company_phone': _company_phone,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UsersModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UsersModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERNAME = amplify_core.QueryField(fieldName: "username");
  static final PASSWORD = amplify_core.QueryField(fieldName: "password");
  static final ROLE = amplify_core.QueryField(fieldName: "role");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final LAST_SEEN = amplify_core.QueryField(fieldName: "last_seen");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
//   static final DESIGNATION = amplify_core.QueryField(fieldName: "designation");
//   static final PERSONAL_PHONE = amplify_core.QueryField(fieldName: "personal_phone");
//   static final AADHAR_CARD = amplify_core.QueryField(fieldName: "aadhar_card");
//   static final DRIVING_LICENSE = amplify_core.QueryField(fieldName: "driving_license");
//   static final INSURANCE = amplify_core.QueryField(fieldName: "insurance");
//   static final EMERGENCY_CONTACT = amplify_core.QueryField(fieldName: "emergency_contact");
//   static final OFFER_LETTER = amplify_core.QueryField(fieldName: "offer_letter");
//   static final DOB = amplify_core.QueryField(fieldName: "dob");
//   static final SALARY = amplify_core.QueryField(fieldName: "salary");
//   static final WORK_TIME = amplify_core.QueryField(fieldName: "work_time");
//   static final BLOOD_GROUP = amplify_core.QueryField(fieldName: "blood_group");
//   static final PERSONAL_EMAIL = amplify_core.QueryField(fieldName: "personal_email");
//   static final COMPANY_EMAIL = amplify_core.QueryField(fieldName: "company_email");
//   static final COMPANY_PHONE = amplify_core.QueryField(fieldName: "company_phone");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Users";
    modelSchemaDefinition.pluralName = "Users";
    
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
      key: Users.USERNAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.PASSWORD,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.ROLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.LAST_SEEN,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.EMAIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.DESIGNATION,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.PERSONAL_PHONE,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.AADHAR_CARD,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.DRIVING_LICENSE,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.INSURANCE,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.EMERGENCY_CONTACT,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.OFFER_LETTER,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.DOB,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.SALARY,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.WORK_TIME,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.BLOOD_GROUP,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.PERSONAL_EMAIL,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.COMPANY_EMAIL,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
//     modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
//       key: Users.COMPANY_PHONE,
//       isRequired: false,
//       ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
//       ));
// //     
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

class _UsersModelType extends amplify_core.ModelType<Users> {
  const _UsersModelType();
  
  @override
  Users fromJson(Map<String, dynamic> jsonData) {
    return Users.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Users';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Users] in your schema.
 */
class UsersModelIdentifier implements amplify_core.ModelIdentifier<Users> {
  final String id;

  /** Create an instance of UsersModelIdentifier using [id] the primary key. */
  const UsersModelIdentifier({
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
  String toString() => 'UsersModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UsersModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}
