import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final entities = dir.listSync(recursive: true);
  
  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      if ((content.contains('ModelQueries') || content.contains('ModelMutations')) && 
          !content.contains('package:amplify_api/amplify_api.dart')) {
        
        final lines = content.split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('import ')) {
            lines.insert(i, "import 'package:amplify_api/amplify_api.dart';");
            break;
          }
        }
        await entity.writeAsString(lines.join('\n'));
        print('Added import to ${entity.path}');
      }
    }
  }
}
