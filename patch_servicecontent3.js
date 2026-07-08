const fs = require('fs');
let c = fs.readFileSync('lib/models/ServiceContent.dart', 'utf8');

c = c.replace(
  'final String? _details;',
  'final String? _details;\n  final String? _pdf_url;\n  final String? _previous_case_id;'
);

c = c.replace(
  'String? get details {\n    return _details;\n  }',
  'String? get details {\n    return _details;\n  }\n  \n  String? get pdf_url {\n    return _pdf_url;\n  }\n  \n  String? get previous_case_id {\n    return _previous_case_id;\n  }'
);

c = c.replace(
  'const ServiceContent._internal({required this.id, service_id, title, description, image_path, details}): _service_id = service_id, _title = title, _description = description, _image_path = image_path, _details = details;',
  'const ServiceContent._internal({required this.id, service_id, title, description, image_path, details, pdf_url, previous_case_id}): _service_id = service_id, _title = title, _description = description, _image_path = image_path, _details = details, _pdf_url = pdf_url, _previous_case_id = previous_case_id;'
);

c = c.replace(
  'factory ServiceContent({String? id, int? service_id, String? title, String? description, String? image_path, String? details}) {',
  'factory ServiceContent({String? id, int? service_id, String? title, String? description, String? image_path, String? details, String? pdf_url, String? previous_case_id}) {'
);

c = c.replace(
  '      details: details);',
  '      details: details,\n      pdf_url: pdf_url,\n      previous_case_id: previous_case_id);'
);

c = c.replace(
  '      _details == other._details;',
  '      _details == other._details &&\n      _pdf_url == other._pdf_url &&\n      _previous_case_id == other._previous_case_id;'
);

c = c.replace(
  '      _details.hashCode;',
  '      _details.hashCode ^\n      _pdf_url.hashCode ^\n      _previous_case_id.hashCode;'
);

c = c.replace(
  'ServiceContent copyWith({int? service_id, String? title, String? description, String? image_path, String? details}) {',
  'ServiceContent copyWith({int? service_id, String? title, String? description, String? image_path, String? details, String? pdf_url, String? previous_case_id}) {'
);

c = c.replace(
  '      details: details ?? this.details);',
  '      details: details ?? this.details,\n      pdf_url: pdf_url ?? this.pdf_url,\n      previous_case_id: previous_case_id ?? this.previous_case_id);'
);

c = c.replace(
  '    ModelFieldValue<String?>? details\n  }) {',
  '    ModelFieldValue<String?>? details,\n    ModelFieldValue<String?>? pdf_url,\n    ModelFieldValue<String?>? previous_case_id\n  }) {'
);

c = c.replace(
  '      details: details == null ? this.details : details.value\n    );',
  '      details: details == null ? this.details : details.value,\n      pdf_url: pdf_url == null ? this.pdf_url : pdf_url.value,\n      previous_case_id: previous_case_id == null ? this.previous_case_id : previous_case_id.value\n    );'
);

c = c.replace(
  '      _details = json[\'details\'];',
  '      _details = json[\'details\'],\n      _pdf_url = json[\'pdf_url\'],\n      _previous_case_id = json[\'previous_case_id\'];'
);

c = c.replace(
  '\'details\': _details\n  };',
  '\'details\': _details, \'pdf_url\': _pdf_url, \'previous_case_id\': _previous_case_id\n  };'
);

c = c.replace(
  '\'details\': _details\n  };',
  '\'details\': _details,\n    \'pdf_url\': _pdf_url,\n    \'previous_case_id\': _previous_case_id\n  };'
);

c = c.replace(
  'static final DETAILS = amplify_core.QueryField(fieldName: "details");',
  'static final DETAILS = amplify_core.QueryField(fieldName: "details");\n  static final PDF_URL = amplify_core.QueryField(fieldName: "pdf_url");\n  static final PREVIOUS_CASE_ID = amplify_core.QueryField(fieldName: "previous_case_id");'
);

fs.writeFileSync('lib/models/ServiceContent.dart', c);
console.log('Patched correctly.');
