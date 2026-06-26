const fs = require('fs');

const fields = [
    ['property_name', 'String?', 'string', false],
    ['client_name', 'String?', 'string', false],
    ['location', 'String?', 'string', false],
    ['property_type', 'String?', 'string', false],
    ['owner_name', 'String?', 'string', false],
    ['owner_phone_numbers', 'List<String>?', 'collection', false],
    ['broker_details', 'String?', 'string', false],
    ['care_of', 'String?', 'string', false],
    ['area', 'String?', 'string', false],
    ['price', 'double?', 'double', false],
    ['is_negotiable', 'bool?', 'bool', false],
    ['floor', 'String?', 'string', false],
    ['has_balcony', 'bool?', 'bool', false],
    ['balcony_count', 'int?', 'int', false],
    ['is_furnished', 'bool?', 'bool', false],
    ['has_car_parking', 'bool?', 'bool', false],
    ['expenses', 'String?', 'string', false],
    ['photos', 'List<String>?', 'collection', false],
    ['status', 'String?', 'string', false],
    ['notes', 'String?', 'string', false],
    ['created_at', 'String?', 'string', false],
    ['updated_at', 'String?', 'string', false]
];

let out = `// NOTE: This file is generated and may not follow lint rules defined in your app
import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class Properties extends amplify_core.Model {
  static const classType = const _PropertiesModelType();
  final String id;
`;

for (let f of fields) {
    out += `  final ${f[1]} _${f[0]};\n`;
}

out += "  final amplify_core.TemporalDateTime? _createdAt;\n";
out += "  final amplify_core.TemporalDateTime? _updatedAt;\n\n";
out += "  @override\n  getInstanceType() => classType;\n\n";
out += "  @override\n  String getId() => id;\n\n";

out += `  PropertiesModelIdentifier get modelIdentifier {
      return PropertiesModelIdentifier(id: id);
  }\n\n`;

for (let f of fields) {
    out += `  ${f[1]} get ${f[0]} => _${f[0]};\n`;
}

out += "  amplify_core.TemporalDateTime? get createdAt => _createdAt;\n";
out += "  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;\n\n";

out += "  const Properties._internal({required this.id";
for (let f of fields) {
    out += `, ${f[0]}`;
}
out += ", createdAt, updatedAt}): ";

out += fields.map(f => `_${f[0]} = ${f[0]}`).join(", ");
out += ", _createdAt = createdAt, _updatedAt = updatedAt;\n\n";

out += "  factory Properties({String? id";
for (let f of fields) {
    out += `, ${f[1]} ${f[0]}`;
}
out += "}) {\n    return Properties._internal(\n      id: id == null ? amplify_core.UUID.getUUID() : id,\n";
for (let f of fields) {
    out += `      ${f[0]}: ${f[0]},\n`;
}
out += "    );\n  }\n\n";

out += `  bool equals(Object other) => this == other;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Properties &&
        id == other.id`;

for (let f of fields) {
    if (f[1].includes("List")) {
        out += ` &&\n        amplify_core.DeepCollectionEquality().equals(_${f[0]}, other._${f[0]})`;
    } else {
        out += ` &&\n        _${f[0]} == other._${f[0]}`;
    }
}
out += ";\n  }\n\n";

out += "  @override\n  int get hashCode => toString().hashCode;\n\n";

out += `  @override
  String toString() {
    var buffer = new StringBuffer();
    buffer.write("Properties {");
    buffer.write("id=" + "$id" + ", ");\n`;
for (let f of fields) {
    out += `    buffer.write("${f[0]}=" + (_${f[0]} != null ? _${f[0]}!.toString() : "null") + ", ");\n`;
}
out += '    buffer.write("}");\n    return buffer.toString();\n  }\n\n';

out += "  Properties copyWith({";
for (let f of fields) {
    out += `${f[1]} ${f[0]}, `;
}
out += "}) {\n    return Properties._internal(\n      id: id,\n";
for (let f of fields) {
    out += `      ${f[0]}: ${f[0]} ?? this.${f[0]},\n`;
}
out += "    );\n  }\n\n";

out += "  Properties copyWithModelFieldValues({";
for (let f of fields) {
    out += `ModelFieldValue<${f[1]}>? ${f[0]}, `;
}
out += "}) {\n    return Properties._internal(\n      id: id,\n";
for (let f of fields) {
    out += `      ${f[0]}: ${f[0]} == null ? this.${f[0]} : ${f[0]}.value,\n`;
}
out += "    );\n  }\n\n";

out += `  Properties.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData['id'],\n`;
for (let f of fields) {
    if (f[2] === "double") {
        out += `        _${f[0]} = (jsonData['${f[0]}'] as num?)?.toDouble(),\n`;
    } else if (f[1].includes("List")) {
        out += `        _${f[0]} = jsonData['${f[0]}']?.cast<String>(),\n`;
    } else {
        out += `        _${f[0]} = jsonData['${f[0]}'],\n`;
    }
}
out += "        _createdAt = jsonData['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(jsonData['createdAt']) : null,\n";
out += "        _updatedAt = jsonData['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(jsonData['updatedAt']) : null;\n\n";

out += `  Map<String, dynamic> toJson() => {
    'id': id,\n`;
for (let f of fields) {
    out += `    '${f[0]}': _${f[0]},\n`;
}
out += `    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format()
  };

  Map<String, Object?> toMap() => {
    'id': id,\n`;
for (let f of fields) {
    out += `    '${f[0]}': _${f[0]},\n`;
}
out += `    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<PropertiesModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<PropertiesModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");\n`;
for (let f of fields) {
    out += `  static final ${f[0].toUpperCase()} = amplify_core.QueryField(fieldName: "${f[0]}");\n`;
}

out += `  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
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

    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());\n`;

for (let f of fields) {
    if (f[2] === "collection") {
        out += `    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: '${f[0]}',
      isRequired: ${f[3]},
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));\n`;
    } else {
        out += `    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Properties.${f[0].toUpperCase()},
      isRequired: ${f[3]},
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.${f[2]})
    ));\n`;
    }
}

out += `
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
`;

fs.writeFileSync('lib/models/Properties.dart', out);
