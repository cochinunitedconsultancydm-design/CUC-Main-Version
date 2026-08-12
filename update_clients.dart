import 'dart:io';

void main() {
  final file = File('lib/models/Clients.dart');
  var content = file.readAsStringSync();
  
  if (content.contains('_companies')) return;

  content = content.replaceFirst('final String? _balance_due;', 'final String? _balance_due;\n  final List<String>? _companies;');
  
  content = content.replaceFirst('  amplify_core.TemporalDateTime? get updatedAt {', '''  List<String>? get companies {
    return _companies;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {''');

  content = content.replaceFirst('balance_due, createdAt, updatedAt})', 'balance_due, List<String>? companies, createdAt, updatedAt})');
  content = content.replaceFirst('_balance_due = balance_due, _createdAt', '_balance_due = balance_due, _companies = companies, _createdAt');

  content = content.replaceFirst('String? balance_due}) {', 'String? balance_due, List<String>? companies}) {');
  content = content.replaceFirst('balance_due: balance_due', 'balance_due: balance_due,\n      companies: companies != null ? List<String>.unmodifiable(companies) : companies');

  content = content.replaceFirst('String? balance_due}', 'String? balance_due, List<String>? companies}');
  content = content.replaceFirst('balance_due: balance_due ?? this.balance_due', 'balance_due: balance_due ?? this.balance_due,\n      companies: companies ?? this.companies');

  content = content.replaceFirst('_balance_due == other._balance_due;', '  _balance_due == other._balance_due &&\n        DeepCollectionEquality().equals(_companies, other._companies);');
  
  if (!content.contains('collection.dart')) {
    content = "import 'package:collection/collection.dart';\n" + content;
  }

  content = content.replaceFirst('buffer.write("balance_due=" + "\$_balance_due" + ", ");', 'buffer.write("balance_due=" + "\$_balance_due" + ", ");\n    buffer.write("companies=" + (_companies != null ? _companies!.toString() : "null") + ", ");');

  content = content.replaceFirst('_balance_due = json[\'balance_due\'],', '_balance_due = json[\'balance_due\'],\n      _companies = json[\'companies\']?.cast<String>(),');

  content = content.replaceFirst("'balance_due': _balance_due, 'createdAt'", "'balance_due': _balance_due, 'companies': _companies, 'createdAt'");

  content = content.replaceFirst("'balance_due': _balance_due,", "'balance_due': _balance_due,\n      'companies': _companies,");

  file.writeAsStringSync(content);
}
