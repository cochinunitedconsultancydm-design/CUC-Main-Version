import 'dart:io';

void main() async {
  final file = File('lib/models/Users.dart');
  var code = await file.readAsString();

  final fields = [
    ['designation', '_designation', 'DESIGNATION'],
    ['personal_phone', '_personal_phone', 'PERSONAL_PHONE'],
    ['aadhar_card', '_aadhar_card', 'AADHAR_CARD'],
    ['driving_license', '_driving_license', 'DRIVING_LICENSE'],
    ['insurance', '_insurance', 'INSURANCE'],
    ['emergency_contact', '_emergency_contact', 'EMERGENCY_CONTACT'],
    ['offer_letter', '_offer_letter', 'OFFER_LETTER'],
    ['dob', '_dob', 'DOB'],
    ['salary', '_salary', 'SALARY'],
    ['work_time', '_work_time', 'WORK_TIME'],
    ['blood_group', '_blood_group', 'BLOOD_GROUP'],
    ['personal_email', '_personal_email', 'PERSONAL_EMAIL'],
    ['company_email', '_company_email', 'COMPANY_EMAIL'],
    ['company_phone', '_company_phone', 'COMPANY_PHONE'],
  ];

  // 1. Declarations
  final declPatch = fields.map((f) => '  final String? ${f[1]};').join('\n');
  code = code.replaceAll('final String? _email;', 'final String? _email;\n$declPatch');

  // 2. Getters
  final getterPatch = fields.map((f) => '  String? get ${f[0]} {\n    return ${f[1]};\n  }\n').join('\n');
  code = code.replaceAll('String? get email {\n    return _email;\n  }', 'String? get email {\n    return _email;\n  }\n  \n$getterPatch');

  // 3. _internal constructor params
  final param1Patch = fields.map((f) => f[0]).join(', ');
  code = code.replaceAll('email, createdAt', 'email, $param1Patch, createdAt');
  final param2Patch = fields.map((f) => '${f[1]} = ${f[0]}').join(', ');
  code = code.replaceAll('_email = email, _createdAt', '_email = email, $param2Patch, _createdAt');

  // 4. factory params
  final param3Patch = fields.map((f) => 'String? ${f[0]}').join(', ');
  code = code.replaceAll('String? email}) {', 'String? email, $param3Patch}) {');
  final param4Patch = fields.map((f) => '${f[0]}: ${f[0]}').join(',\n      ');
  code = code.replaceAll('email: email);', 'email: email,\n      $param4Patch);');

  // 5. ==
  final eqPatch = fields.map((f) => '&& ${f[1]} == other.${f[1]}').join('\n      ');
  code = code.replaceAll('_email == other._email;', '_email == other._email\n      $eqPatch;');

  // 6. toString
  final strPatch = fields.map((f) => 'buffer.write("${f[0]}=" + "\$${f[1]}" + ", ");').join('\n    ');
  code = code.replaceAll('buffer.write("email=" + "\$_email" + ", ");', 'buffer.write("email=" + "\$_email" + ", ");\n    $strPatch');

  // 7. copyWith
  final param5Patch = param3Patch;
  code = code.replaceAll('String? email}) {', 'String? email, $param5Patch}) {');
  final param6Patch = fields.map((f) => '${f[0]}: ${f[0]} ?? this.${f[0]}').join(',\n      ');
  code = code.replaceAll('email: email ?? this.email);', 'email: email ?? this.email,\n      $param6Patch);');

  // 8. copyWithModelFieldValues
  final param7Patch = fields.map((f) => 'ModelFieldValue<String?>? ${f[0]}').join(',\n    ');
  code = code.replaceAll('ModelFieldValue<String?>? email\n  }) {', 'ModelFieldValue<String?>? email,\n    $param7Patch\n  }) {');
  final param8Patch = fields.map((f) => '${f[0]}: ${f[0]} == null ? this.${f[0]} : ${f[0]}.value').join(',\n      ');
  code = code.replaceAll('email: email == null ? this.email : email.value\n    );', 'email: email == null ? this.email : email.value,\n      $param8Patch\n    );');

  // 9. fromJson
  final json1Patch = fields.map((f) => '${f[1]} = json[\'${f[0]}\']').join(',\n      ');
  code = code.replaceAll('_email = json[\'email\'],', '_email = json[\'email\'],\n      $json1Patch,');

  // 10. toJson
  final json2Patch = fields.map((f) => '\'${f[0]}\': ${f[1]}').join(', ');
  code = code.replaceAll('\'email\': _email', '\'email\': _email, $json2Patch');

  // 11. toMap
  final mapPatch = fields.map((f) => '\'${f[0]}\': ${f[1]}').join(',\n    ');
  code = code.replaceAll('\'email\': _email,', '\'email\': _email,\n    $mapPatch,');

  // 12. QueryField
  final qfPatch = fields.map((f) => 'static final ${f[2]} = amplify_core.QueryField(fieldName: "${f[0]}");').join('\n  ');
  code = code.replaceAll('static final EMAIL = amplify_core.QueryField(fieldName: "email");', 'static final EMAIL = amplify_core.QueryField(fieldName: "email");\n  $qfPatch');

  // 13. modelSchemaDefinition.addField
  final addFieldPatch = fields.map((f) => '''modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.${f[2]},
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));''').join('\n    ');
  
  final targetAddField = '''modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.EMAIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));''';
  code = code.replaceAll(targetAddField, '''$targetAddField\n    $addFieldPatch''');

  await file.writeAsString(code);
}
