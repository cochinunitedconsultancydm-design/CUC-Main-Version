import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    'final apiPlugin = AmplifyAPI(modelProvider: ModelProvider.instance);',
    'final apiPlugin = AmplifyAPI(options: APIPluginOptions(modelProvider: ModelProvider.instance));'
  );
  file.writeAsStringSync(content);
}
