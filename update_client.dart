import 'dart:io';

void main() {
  final file = File('lib/models/client.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('final List<String>? companies;')) {
    content = content.replaceFirst(
      'final String? balanceDue;',
      'final String? balanceDue;\n  final List<String>? companies;'
    );
    
    content = content.replaceFirst(
      'this.balanceDue,',
      'this.balanceDue,\n    this.companies,'
    );
    
    content = content.replaceFirst(
      'balanceDue: data[\'balance_due\'] as String?,',
      'balanceDue: data[\'balance_due\'] as String?,\n      companies: (data[\'companies\'] as List?)?.map((e) => e.toString()).toList(),'
    );
    
    content = content.replaceFirst(
      'balanceDue: model.balance_due,',
      'balanceDue: model.balance_due,\n      companies: model.companies,'
    );
    
    content = content.replaceFirst(
      'balanceDue: balanceDue ?? this.balanceDue,',
      'balanceDue: balanceDue ?? this.balanceDue,\n      companies: companies ?? this.companies,'
    );
    
    content = content.replaceFirst(
      'String? balanceDue,',
      'String? balanceDue,\n    List<String>? companies,'
    );
    
    file.writeAsStringSync(content);
  }
}
