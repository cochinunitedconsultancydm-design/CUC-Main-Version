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


/** This is an auto generated class representing the Contacts type in your schema. */
class Contacts extends amplify_core.Model {
  static const classType = const _ContactsModelType();
  final String id;
  final String? _name;
  final String? _designation;
  final String? _office;
  final String? _personal_number;
  final String? _official_number;
  final String? _email;
  final String? _place;
  final String? _native_place;
  final String? _working_place;
  final String? _created_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ContactsModelIdentifier get modelIdentifier {
      return ContactsModelIdentifier(
        id: id
      );
  }
  
  String get name {
    try {
      return _name!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get designation {
    return _designation;
  }
  
  String? get office {
    return _office;
  }
  
  String? get personal_number {
    return _personal_number;
  }
  
  String? get official_number {
    return _official_number;
  }
  
  String? get email {
    return _email;
  }
  
  String? get place {
    return _place;
  }
  
  String? get native_place {
    return _native_place;
  }
  
  String? get working_place {
    return _working_place;
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
  
  const Contacts._internal({required this.id, required name, designation, office, personal_number, official_number, email, place, native_place, working_place, created_at, createdAt, updatedAt}): _name = name, _designation = designation, _office = office, _personal_number = personal_number, _official_number = official_number, _email = email, _place = place, _native_place = native_place, _working_place = working_place, _created_at = created_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Contacts({String? id, required String name, String? designation, String? office, String? personal_number, String? official_number, String? email, String? place, String? native_place, String? working_place, String? created_at}) {
    return Contacts._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      designation: designation,
      office: office,
      personal_number: personal_number,
      official_number: official_number,
      email: email,
      place: place,
      native_place: native_place,
      working_place: working_place,
      created_at: created_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Contacts &&
      id == other.id &&
      _name == other._name &&
      _designation == other._designation &&
      _office == other._office &&
      _personal_number == other._personal_number &&
      _official_number == other._official_number &&
      _email == other._email &&
      _place == other._place &&
      _native_place == other._native_place &&
      _working_place == other._working_place &&
      _created_at == other._created_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Contacts {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("designation=" + "$_designation" + ", ");
    buffer.write("office=" + "$_office" + ", ");
    buffer.write("personal_number=" + "$_personal_number" + ", ");
    buffer.write("official_number=" + "$_official_number" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("place=" + "$_place" + ", ");
    buffer.write("native_place=" + "$_native_place" + ", ");
    buffer.write("working_place=" + "$_working_place" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Contacts copyWith({String? name, String? designation, String? office, String? personal_number, String? official_number, String? email, String? place, String? native_place, String? working_place, String? created_at}) {
    return Contacts._internal(
      id: id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      office: office ?? this.office,
      personal_number: personal_number ?? this.personal_number,
      official_number: official_number ?? this.official_number,
      email: email ?? this.email,
      place: place ?? this.place,
      native_place: native_place ?? this.native_place,
      working_place: working_place ?? this.working_place,
      created_at: created_at ?? this.created_at);
  }
  
  Contacts copyWithModelFieldValues({
    ModelFieldValue<String>? name,
    ModelFieldValue<String?>? designation,
    ModelFieldValue<String?>? office,
    ModelFieldValue<String?>? personal_number,
    ModelFieldValue<String?>? official_number,
    ModelFieldValue<String?>? email,
    ModelFieldValue<String?>? place,
    ModelFieldValue<String?>? native_place,
    ModelFieldValue<String?>? working_place,
    ModelFieldValue<String?>? created_at
  }) {
    return Contacts._internal(
      id: id,
      name: name == null ? this.name : name.value,
      designation: designation == null ? this.designation : designation.value,
      office: office == null ? this.office : office.value,
      personal_number: personal_number == null ? this.personal_number : personal_number.value,
      official_number: official_number == null ? this.official_number : official_number.value,
      email: email == null ? this.email : email.value,
      place: place == null ? this.place : place.value,
      native_place: native_place == null ? this.native_place : native_place.value,
      working_place: working_place == null ? this.working_place : working_place.value,
      created_at: created_at == null ? this.created_at : created_at.value
    );
  }
  
  Contacts.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _designation = json['designation'],
      _office = json['office'],
      _personal_number = json['personal_number'],
      _official_number = json['official_number'],
      _email = json['email'],
      _place = json['place'],
      _native_place = json['native_place'],
      _working_place = json['working_place'],
      _created_at = json['created_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'designation': _designation, 'office': _office, 'personal_number': _personal_number, 'official_number': _official_number, 'email': _email, 'place': _place, 'native_place': _native_place, 'working_place': _working_place, 'created_at': _created_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'designation': _designation,
    'office': _office,
    'personal_number': _personal_number,
    'official_number': _official_number,
    'email': _email,
    'place': _place,
    'native_place': _native_place,
    'working_place': _working_place,
    'created_at': _created_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ContactsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ContactsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final DESIGNATION = amplify_core.QueryField(fieldName: "designation");
  static final OFFICE = amplify_core.QueryField(fieldName: "office");
  static final PERSONAL_NUMBER = amplify_core.QueryField(fieldName: "personal_number");
  static final OFFICIAL_NUMBER = amplify_core.QueryField(fieldName: "official_number");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static final PLACE = amplify_core.QueryField(fieldName: "place");
  static final NATIVE_PLACE = amplify_core.QueryField(fieldName: "native_place");
  static final WORKING_PLACE = amplify_core.QueryField(fieldName: "working_place");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Contacts";
    modelSchemaDefinition.pluralName = "Contacts";
    
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
      key: Contacts.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Contacts.DESIGNATION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Contacts.OFFICE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Contacts.PERSONAL_NUMBER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Contacts.OFFICIAL_NUMBER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Contacts.EMAIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Contacts.PLACE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Contacts.NATIVE_PLACE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Contacts.WORKING_PLACE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Contacts.CREATED_AT,
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

class _ContactsModelType extends amplify_core.ModelType<Contacts> {
  const _ContactsModelType();
  
  @override
  Contacts fromJson(Map<String, dynamic> jsonData) {
    return Contacts.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Contacts';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Contacts] in your schema.
 */
class ContactsModelIdentifier implements amplify_core.ModelIdentifier<Contacts> {
  final String id;

  /** Create an instance of ContactsModelIdentifier using [id] the primary key. */
  const ContactsModelIdentifier({
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
  String toString() => 'ContactsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ContactsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}