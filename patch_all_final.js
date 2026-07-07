const fs = require('fs');

let c;
try {
  c = fs.readFileSync('lib/models/Users.dart', 'utf8');
} catch (e) {
  console.log(e);
}

// Convert string cleanly.
c = c.replace(/final String\? _blood_group;/g, 'final String? _blood_group;\n  final String? _wedding_anniversary;');
c = c.replace(/String\? get blood_group \{[\r\n\s]*return _blood_group;[\r\n\s]*\}/g, 'String? get blood_group {\n    return _blood_group;\n  }\n\n  String? get wedding_anniversary {\n    return _wedding_anniversary;\n  }');
c = c.replace(/blood_group,\s*personal_email/g, 'blood_group, wedding_anniversary, personal_email');
c = c.replace(/String\? blood_group,\s*String\? personal_email/g, 'String? blood_group, String? wedding_anniversary, String? personal_email');
c = c.replace(/_blood_group = blood_group,\s*_personal_email/g, '_blood_group = blood_group, _wedding_anniversary = wedding_anniversary, _personal_email');
c = c.replace(/blood_group: blood_group,[\r\n\s]*personal_email: personal_email/g, 'blood_group: blood_group,\n      wedding_anniversary: wedding_anniversary,\n      personal_email: personal_email');
c = c.replace(/&& _blood_group == other\._blood_group[\r\n\s]*&& _personal_email/g, '&& _blood_group == other._blood_group\n      && _wedding_anniversary == other._wedding_anniversary\n      && _personal_email');
c = c.replace(/buffer\.write\("blood_group=" \+ "\$_blood_group" \+ ", "\);[\r\n\s]*buffer\.write\("personal_email/g, 'buffer.write("blood_group=" + "$_blood_group" + ", ");\n    buffer.write("wedding_anniversary=" + "$_wedding_anniversary" + ", ");\n    buffer.write("personal_email');
c = c.replace(/blood_group: blood_group \?\? this\.blood_group,[\r\n\s]*personal_email: personal_email/g, 'blood_group: blood_group ?? this.blood_group,\n      wedding_anniversary: wedding_anniversary ?? this.wedding_anniversary,\n      personal_email: personal_email');
c = c.replace(/ModelFieldValue<String\?>\? blood_group,[\r\n\s]*ModelFieldValue<String\?>\? personal_email/g, 'ModelFieldValue<String?>? blood_group,\n    ModelFieldValue<String?>? wedding_anniversary,\n    ModelFieldValue<String?>? personal_email');
c = c.replace(/blood_group: blood_group == null \? this\.blood_group : blood_group\.value,[\r\n\s]*personal_email: personal_email/g, 'blood_group: blood_group == null ? this.blood_group : blood_group.value,\n      wedding_anniversary: wedding_anniversary == null ? this.wedding_anniversary : wedding_anniversary.value,\n      personal_email: personal_email');
c = c.replace(/_blood_group = json\['blood_group'\],[\r\n\s]*_personal_email/g, '_blood_group = json[\'blood_group\'],\n      _wedding_anniversary = json[\'wedding_anniversary\'],\n      _personal_email');
c = c.replace(/'blood_group': _blood_group,[\r\n\s]*'personal_email/g, '\'blood_group\': _blood_group,\n      \'wedding_anniversary\': _wedding_anniversary,\n      \'personal_email');
c = c.replace(/static final BLOOD_GROUP = amplify_core\.QueryField\(fieldName: "blood_group"\);[\r\n\s]*static final PERSONAL_EMAIL/g, 'static final BLOOD_GROUP = amplify_core.QueryField(fieldName: "blood_group");\n  static final WEDDING_ANNIVERSARY = amplify_core.QueryField(fieldName: "wedding_anniversary");\n  static final PERSONAL_EMAIL');
c = c.replace(/key: Users\.BLOOD_GROUP,[\r\n\s]*isRequired: false,[\r\n\s]*ofType: amplify_core\.ModelFieldType\(amplify_core\.ModelFieldTypeEnum\.string\)[\r\n\s]*\)\);[\r\n\s]*modelSchemaDefinition\.addField\(amplify_core\.ModelFieldDefinition\.field\([\r\n\s]*key: Users\.PERSONAL_EMAIL,/g, 'key: Users.BLOOD_GROUP,\n      isRequired: false,\n      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)\n    ));\n    \n    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(\n      key: Users.WEDDING_ANNIVERSARY,\n      isRequired: false,\n      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)\n    ));\n    \n    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(\n      key: Users.PERSONAL_EMAIL,');

fs.writeFileSync('lib/models/Users.dart', c, 'utf8');
