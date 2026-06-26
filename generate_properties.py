import os

fields = [
    ('property_name', 'String?', 'string', False),
    ('client_name', 'String?', 'string', False),
    ('location', 'String?', 'string', False),
    ('property_type', 'String?', 'string', False),
    ('owner_name', 'String?', 'string', False),
    ('owner_phone_numbers', 'List<String>?', 'collection', False),
    ('broker_details', 'String?', 'string', False),
    ('care_of', 'String?', 'string', False),
    ('area', 'String?', 'string', False),
    ('price', 'double?', 'double', False),
    ('is_negotiable', 'bool?', 'bool', False),
    ('floor', 'String?', 'string', False),
    ('has_balcony', 'bool?', 'bool', False),
    ('balcony_count', 'int?', 'int', False),
    ('is_furnished', 'bool?', 'bool', False),
    ('has_car_parking', 'bool?', 'bool', False),
    ('expenses', 'String?', 'string', False),
    ('photos', 'List<String>?', 'collection', False),
    ('status', 'String?', 'string', False),
    ('notes', 'String?', 'string', False),
    ('created_at', 'String?', 'string', False),
    ('updated_at', 'String?', 'string', False)
]

out = """// NOTE: This file is generated and may not follow lint rules defined in your app
import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class Properties extends amplify_core.Model {
  static const classType = const _PropertiesModelType();
  final String id;
"""

for f in fields:
    out += f"  final {f[1]} _{f[0]};\n"

out += "  final amplify_core.TemporalDateTime? _createdAt;\n"
out += "  final amplify_core.TemporalDateTime? _updatedAt;\n\n"
out += "  @override\n  getInstanceType() => classType;\n\n"
out += "  @override\n  String getId() => id;\n\n"

out += """  PropertiesModelIdentifier get modelIdentifier {
      return PropertiesModelIdentifier(id: id);
  }\n\n"""

for f in fields:
    out += f"  {f[1]} get {f[0]} => _{f[0]};\n"

out += "  amplify_core.TemporalDateTime? get createdAt => _createdAt;\n"
out += "  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;\n\n"

out += "  const Properties._internal({required this.id"
for f in fields:
    out += f", {f[0]}"
out += ", createdAt, updatedAt}): "

out += ", ".join([f"_{f[0]} = {f[0]}" for f in fields])
out += ", _createdAt = createdAt, _updatedAt = updatedAt;\n\n"

out += "  factory Properties({String? id"
for f in fields:
    out += f", {f[1]} {f[0]}"
out += "}) {\n    return Properties._internal(\n      id: id == null ? amplify_core.UUID.getUUID() : id,\n"
for f in fields:
    out += f"      {f[0]}: {f[0]},\n"
out += "    );\n  }\n\n"

out += """  bool equals(Object other) => this == other;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Properties &&
        id == other.id"""

for f in fields:
    if "List" in f[1]:
        out += f" &&\n        amplify_core.DeepCollectionEquality().equals(_{f[0]}, other._{f[0]})"
    else:
        out += f" &&\n        _{f[0]} == other._{f[0]}"
out += ";\n  }\n\n"

out += "  @override\n  int get hashCode => toString().hashCode;\n\n"

out += """  @override
  String toString() {
    var buffer = new StringBuffer();
    buffer.write("Properties {");
    buffer.write("id=" + "$id" + ", ");\n"""
for f in fields:
    out += f'    buffer.write("{f[0]}=" + (_{f[0]} != null ? _{f[0]}!.toString() : "null") + ", ");\n'
out += '    buffer.write("}");\n    return buffer.toString();\n  }\n\n'

out += "  Properties copyWith({"
for f in fields:
    out += f"{f[1]} {f[0]}, "
out += "}) {\n    return Properties._internal(\n      id: id,\n"
for f in fields:
    out += f"      {f[0]}: {f[0]} ?? this.{f[0]},\n"
out += "    );\n  }\n\n"

out += "  Properties copyWithModelFieldValues({"
for f in fields:
    out += f"ModelFieldValue<{f[1]}>? {f[0]}, "
out += "}) {\n    return Properties._internal(\n      id: id,\n"
for f in fields:
    out += f"      {f[0]}: {f[0]} == null ? this.{f[0]} : {f[0]}.value,\n"
out += "    );\n  }\n\n"

out += """  Properties.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData['id'],\n"""
for f in fields:
    if f[2] == "double":
        out += f"        _{f[0]} = (jsonData['{f[0]}'] as num?)?.toDouble(),\n"
    elif "List" in f[1]:
        out += f"        _{f[0]} = jsonData['{f[0]}']?.cast<String>(),\n"
    else:
        out += f"        _{f[0]} = jsonData['{f[0]}'],\n"
out += "        _createdAt = jsonData['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(jsonData['createdAt']) : null,\n"
out += "        _updatedAt = jsonData['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(jsonData['updatedAt']) : null;\n\n"

out += """  Map<String, dynamic> toJson() => {
    'id': id,\n"""
for f in fields:
    out += f"    '{f[0]}': _{f[0]},\n"
out += """    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format()
  };

  Map<String, Object?> toMap() => {
    'id': id,\n"""
for f in fields:
    out += f"    '{f[0]}': _{f[0]},\n"
out += """    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<PropertiesModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<PropertiesModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");\n"""
for f in fields:
    out += f'  static final {f[0].upper()} = amplify_core.QueryField(fieldName: "{f[0]}");\n'

out += """  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Properties";
    modelSchemaDefinition.pluralName = "Properties";

    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        provider: amplify_core.AuthRuleProvider.IAM,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];

    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());\n"""

for f in fields:
    if f[2] == "collection":
        out += f"""    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: '{f[0]}',
      isRequired: {str(f[3]).lower()},
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));\n"""
    else:
        out += f"""    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Properties.{f[0].upper()},
      isRequired: {str(f[3]).lower()},
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.{f[2]})
    ));\n"""

out += """
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

class _PropertiesModelType extends amplify_core.ModelType<Properties> {
  const _PropertiesModelType();

  @override
  Properties fromJson(Map<String, dynamic> jsonData) {
    return Properties.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'Properties';
  }
}

class PropertiesModelIdentifier implements amplify_core.ModelIdentifier<Properties> {
  final String id;
  const PropertiesModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries.map((entry) => (<String, dynamic>{entry.key: entry.value})).toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'PropertiesModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PropertiesModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
"""

with open('lib/models/Properties.dart', 'w') as f:
    f.write(out)
