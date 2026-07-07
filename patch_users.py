import re

with open('lib/models/Users.dart', 'r') as f:
    code = f.read()

fields = [
    ('designation', '_designation', 'DESIGNATION'),
    ('personal_phone', '_personal_phone', 'PERSONAL_PHONE'),
    ('aadhar_card', '_aadhar_card', 'AADHAR_CARD'),
    ('driving_license', '_driving_license', 'DRIVING_LICENSE'),
    ('insurance', '_insurance', 'INSURANCE'),
    ('emergency_contact', '_emergency_contact', 'EMERGENCY_CONTACT'),
    ('offer_letter', '_offer_letter', 'OFFER_LETTER'),
    ('dob', '_dob', 'DOB'),
    ('salary', '_salary', 'SALARY'),
    ('work_time', '_work_time', 'WORK_TIME'),
    ('blood_group', '_blood_group', 'BLOOD_GROUP'),
    ('personal_email', '_personal_email', 'PERSONAL_EMAIL'),
    ('company_email', '_company_email', 'COMPANY_EMAIL'),
    ('company_phone', '_company_phone', 'COMPANY_PHONE'),
]

# 1. Declarations
decl_patch = "\n".join([f"  final String? {p};" for n, p, c in fields])
code = code.replace("final String? _email;", f"final String? _email;\n{decl_patch}")

# 2. Getters
getter_patch = "\n".join([f"  String? get {n} {{\n    return {p};\n  }}\n" for n, p, c in fields])
code = code.replace("String? get email {\n    return _email;\n  }", f"String? get email {{\n    return _email;\n  }}\n  \n{getter_patch}")

# 3. _internal constructor params
param1_patch = ", ".join([f"{n}" for n, p, c in fields])
code = code.replace("email, createdAt", f"email, {param1_patch}, createdAt")
param2_patch = ", ".join([f"{p} = {n}" for n, p, c in fields])
code = code.replace("_email = email, _createdAt", f"_email = email, {param2_patch}, _createdAt")

# 4. factory params
param3_patch = ", ".join([f"String? {n}" for n, p, c in fields])
code = code.replace("String? email}) {", f"String? email, {param3_patch}}}) {{")
param4_patch = ",\n      ".join([f"{n}: {n}" for n, p, c in fields])
code = code.replace("email: email);", f"email: email,\n      {param4_patch});")

# 5. ==
eq_patch = "\n      ".join([f"&& {p} == other.{p}" for n, p, c in fields])
code = code.replace("_email == other._email;", f"_email == other._email {eq_patch};")

# 6. toString
str_patch = "\n    ".join([f'buffer.write("{n}=" + "${p}" + ", ");' for n, p, c in fields])
code = code.replace('buffer.write("email=" + "$_email" + ", ");', f'buffer.write("email=" + "$_email" + ", ");\n    {str_patch}')

# 7. copyWith
param5_patch = param3_patch
code = code.replace("String? email}) {", f"String? email, {param5_patch}}}) {{")
param6_patch = ",\n      ".join([f"{n}: {n} ?? this.{n}" for n, p, c in fields])
code = code.replace("email: email ?? this.email);", f"email: email ?? this.email,\n      {param6_patch});")

# 8. copyWithModelFieldValues
param7_patch = ",\n    ".join([f"ModelFieldValue<String?>? {n}" for n, p, c in fields])
code = code.replace("ModelFieldValue<String?>? email\n  }) {", f"ModelFieldValue<String?>? email,\n    {param7_patch}\n  }}) {{")
param8_patch = ",\n      ".join([f"{n}: {n} == null ? this.{n} : {n}.value" for n, p, c in fields])
code = code.replace("email: email == null ? this.email : email.value\n    );", f"email: email == null ? this.email : email.value,\n      {param8_patch}\n    );")

# 9. fromJson
json1_patch = ",\n      ".join([f"{p} = json['{n}']" for n, p, c in fields])
code = code.replace("_email = json['email'],", f"_email = json['email'],\n      {json1_patch},")

# 10. toJson
json2_patch = ", ".join([f"'{n}': {p}" for n, p, c in fields])
code = code.replace("'email': _email", f"'email': _email, {json2_patch}")

# 11. toMap
map_patch = ",\n    ".join([f"'{n}': {p}" for n, p, c in fields])
code = code.replace("'email': _email,", f"'email': _email,\n    {map_patch},")

# 12. QueryField
qf_patch = "\n  ".join([f'static final {c} = amplify_core.QueryField(fieldName: "{n}");' for n, p, c in fields])
code = code.replace('static final EMAIL = amplify_core.QueryField(fieldName: "email");', f'static final EMAIL = amplify_core.QueryField(fieldName: "email");\n  {qf_patch}')

# 13. modelSchemaDefinition.addField
addField_patch = "\n    ".join([
f"""modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.{c},
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));""" for n, p, c in fields
])
code = code.replace("""modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.EMAIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));""", f"""modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Users.EMAIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));\n    {addField_patch}""")

with open('lib/models/Users.dart', 'w') as f:
    f.write(code)
