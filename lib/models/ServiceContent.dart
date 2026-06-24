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


/** This is an auto generated class representing the ServiceContent type in your schema. */
class ServiceContent extends amplify_core.Model {
  static const classType = const _ServiceContentModelType();
  final String id;
  final int? _service_id;
  final String? _title;
  final String? _description;
  final String? _image_path;
  final String? _details;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ServiceContentModelIdentifier get modelIdentifier {
      return ServiceContentModelIdentifier(
        id: id
      );
  }
  
  int? get service_id {
    return _service_id;
  }
  
  String? get title {
    return _title;
  }
  
  String? get description {
    return _description;
  }
  
  String? get image_path {
    return _image_path;
  }
  
  String? get details {
    return _details;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const ServiceContent._internal({required this.id, service_id, title, description, image_path, details, createdAt, updatedAt}): _service_id = service_id, _title = title, _description = description, _image_path = image_path, _details = details, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory ServiceContent({String? id, int? service_id, String? title, String? description, String? image_path, String? details}) {
    return ServiceContent._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      service_id: service_id,
      title: title,
      description: description,
      image_path: image_path,
      details: details);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ServiceContent &&
      id == other.id &&
      _service_id == other._service_id &&
      _title == other._title &&
      _description == other._description &&
      _image_path == other._image_path &&
      _details == other._details;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("ServiceContent {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("service_id=" + (_service_id != null ? _service_id!.toString() : "null") + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("image_path=" + "$_image_path" + ", ");
    buffer.write("details=" + "$_details" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  ServiceContent copyWith({int? service_id, String? title, String? description, String? image_path, String? details}) {
    return ServiceContent._internal(
      id: id,
      service_id: service_id ?? this.service_id,
      title: title ?? this.title,
      description: description ?? this.description,
      image_path: image_path ?? this.image_path,
      details: details ?? this.details);
  }
  
  ServiceContent copyWithModelFieldValues({
    ModelFieldValue<int?>? service_id,
    ModelFieldValue<String?>? title,
    ModelFieldValue<String?>? description,
    ModelFieldValue<String?>? image_path,
    ModelFieldValue<String?>? details
  }) {
    return ServiceContent._internal(
      id: id,
      service_id: service_id == null ? this.service_id : service_id.value,
      title: title == null ? this.title : title.value,
      description: description == null ? this.description : description.value,
      image_path: image_path == null ? this.image_path : image_path.value,
      details: details == null ? this.details : details.value
    );
  }
  
  ServiceContent.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _service_id = safeParseInt(json['service_id']),
      _title = json['title'],
      _description = json['description'],
      _image_path = json['image_path'],
      _details = json['details'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'service_id': _service_id, 'title': _title, 'description': _description, 'image_path': _image_path, 'details': _details, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'service_id': _service_id,
    'title': _title,
    'description': _description,
    'image_path': _image_path,
    'details': _details,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ServiceContentModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ServiceContentModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final SERVICE_ID = amplify_core.QueryField(fieldName: "service_id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final IMAGE_PATH = amplify_core.QueryField(fieldName: "image_path");
  static final DETAILS = amplify_core.QueryField(fieldName: "details");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ServiceContent";
    modelSchemaDefinition.pluralName = "ServiceContents";
    
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
      key: ServiceContent.SERVICE_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ServiceContent.TITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ServiceContent.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ServiceContent.IMAGE_PATH,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ServiceContent.DETAILS,
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

class _ServiceContentModelType extends amplify_core.ModelType<ServiceContent> {
  const _ServiceContentModelType();
  
  @override
  ServiceContent fromJson(Map<String, dynamic> jsonData) {
    return ServiceContent.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'ServiceContent';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ServiceContent] in your schema.
 */
class ServiceContentModelIdentifier implements amplify_core.ModelIdentifier<ServiceContent> {
  final String id;

  /** Create an instance of ServiceContentModelIdentifier using [id] the primary key. */
  const ServiceContentModelIdentifier({
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
  String toString() => 'ServiceContentModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ServiceContentModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}