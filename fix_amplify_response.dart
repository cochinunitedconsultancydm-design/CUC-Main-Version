import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final entities = dir.listSync(recursive: true);
  
  final regex = RegExp(r'(Amplify\.API\.(?:query|mutate)\([^)]+\))(?!\.response)');
  
  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      if (regex.hasMatch(content)) {
        final newContent = content.replaceAllMapped(regex, (match) {
          return '${match.group(1)}.response';
        });
        await entity.writeAsString(newContent);
        print('Added .response to ${entity.path}');
      }
    }
  }
}
