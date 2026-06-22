import 'dart:io';

void main() {
  final dir = Directory('lib/models');
  final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    var content = file.readAsStringSync();
    if (content.contains('amplify_core.AuthRuleProvider.IDENTITYPOOL')) {
      content = content.replaceAll('amplify_core.AuthRuleProvider.IDENTITYPOOL', 'amplify_core.AuthRuleProvider.iam');
      file.writeAsStringSync(content);
    }
  }
}
