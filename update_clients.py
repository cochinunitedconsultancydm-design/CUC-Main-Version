import re

file_path = 'lib/models/Clients.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# If companies is already added, skip
if '_companies' not in content:
    # 1. Add field
    content = re.sub(r'(final String\?\s+_balance_due;)', r'\1\n  final List<String>? _companies;', content)
    
    # 2. Add getter
    getter = '''  List<String>? get companies {
    return _companies;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {'''
    content = content.replace('  amplify_core.TemporalDateTime? get updatedAt {', getter)
    
    # 3. Add to constructor
    content = content.replace('balance_due, createdAt, updatedAt})', 'balance_due, List<String>? companies, createdAt, updatedAt})')
    content = content.replace('_balance_due = balance_due, _createdAt', '_balance_due = balance_due, _companies = companies, _createdAt')
    
    # 4. Add to factory
    content = content.replace('String? balance_due}) {', 'String? balance_due, List<String>? companies}) {')
    content = content.replace('balance_due: balance_due', 'balance_due: balance_due,\n      companies: companies != null ? List<String>.unmodifiable(companies) : companies')
    
    # 5. Add to copyWith
    content = content.replace('String? balance_due}', 'String? balance_due, List<String>? companies}')
    content = content.replace('balance_due: balance_due ?? this.balance_due', 'balance_due: balance_due ?? this.balance_due,\n      companies: companies ?? this.companies')
    
    # 6. Add to equals
    content = content.replace('_balance_due == other._balance_due;', '  _balance_due == other._balance_due &&\n        DeepCollectionEquality().equals(_companies, other._companies);')
    # Add import for DeepCollectionEquality if not present
    if 'collection.dart' not in content:
        content = "import 'package:collection/collection.dart';\n" + content
    
    # 7. Add to toString
    content = content.replace('buffer.write("balance_due=" + "$_balance_due" + ", ");', 'buffer.write("balance_due=" + "$_balance_due" + ", ");\n    buffer.write("companies=" + (_companies != null ? _companies!.toString() : "null") + ", ");')
    
    # 8. Add to fromJson
    content = content.replace('_balance_due = json[\'balance_due\'],', '_balance_due = json[\'balance_due\'],\n      _companies = json[\'companies\']?.cast<String>(),')
    
    # 9. Add to toJson
    content = content.replace("'balance_due': _balance_due, 'createdAt'", "'balance_due': _balance_due, 'companies': _companies, 'createdAt'")
    
    # 10. Add to toMap
    content = content.replace("'balance_due': _balance_due,", "'balance_due': _balance_due,\n      'companies': _companies,")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
