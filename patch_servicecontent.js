const fs = require('fs');
let c = fs.readFileSync('lib/models/ServiceContent.dart', 'utf8');

c = c.replace(/final String\? _details;/g, 'final String? _details;\n  final String? _pdf_url;\n  final String? _previous_case_id;');
c = c.replace(/String\? get details {\n    return _details;\n  }/g, 'String? get details {\n    return _details;\n  }\n  \n  String? get pdf_url {\n    return _pdf_url;\n  }\n  \n  String? get previous_case_id {\n    return _previous_case_id;\n  }');
c = c.replace(/_details = details;/g, '_details = details, _pdf_url = pdf_url, _previous_case_id = previous_case_id;');
c = c.replace(/this\.id, service_id, title, description, image_path, details}/g, 'this.id, service_id, title, description, image_path, details, pdf_url, previous_case_id}');
c = c.replace(/details: details\);/g, 'details: details,\n      pdf_url: pdf_url,\n      previous_case_id: previous_case_id);');
c = c.replace(/String\? details}/g, 'String? details, String? pdf_url, String? previous_case_id}');
c = c.replace(/_details == other\._details;/g, '_details == other._details &&\n      _pdf_url == other._pdf_url &&\n      _previous_case_id == other._previous_case_id;');
c = c.replace(/_details\.hashCode;/g, '_details.hashCode ^\n      _pdf_url.hashCode ^\n      _previous_case_id.hashCode;');
c = c.replace(/String\? details,/g, 'String? details, String? pdf_url, String? previous_case_id,');
c = c.replace(/details: details \?\? this\.details/g, 'details: details ?? this.details,\n      pdf_url: pdf_url ?? this.pdf_url,\n      previous_case_id: previous_case_id ?? this.previous_case_id');
c = c.replace(/ModelFieldValue<String\?>\? details/g, 'ModelFieldValue<String?>? details,\n    ModelFieldValue<String?>? pdf_url,\n    ModelFieldValue<String?>? previous_case_id');
c = c.replace(/details: details == null \? this\.details : details\.value/g, 'details: details == null ? this.details : details.value,\n      pdf_url: pdf_url == null ? this.pdf_url : pdf_url.value,\n      previous_case_id: previous_case_id == null ? this.previous_case_id : previous_case_id.value');
c = c.replace(/_details = json\['details'\],/g, '_details = json[\'details\'],\n      _pdf_url = json[\'pdf_url\'],\n      _previous_case_id = json[\'previous_case_id\'],');
c = c.replace(/'details': _details,/g, '\'details\': _details, \'pdf_url\': _pdf_url, \'previous_case_id\': _previous_case_id,');
c = c.replace(/static final DETAILS = amplify_core\.QueryField\(fieldName: "details"\);/g, 'static final DETAILS = amplify_core.QueryField(fieldName: "details");\n  static final PDF_URL = amplify_core.QueryField(fieldName: "pdf_url");\n  static final PREVIOUS_CASE_ID = amplify_core.QueryField(fieldName: "previous_case_id");');

fs.writeFileSync('lib/models/ServiceContent.dart', c);
console.log('Patched ServiceContent.dart');
