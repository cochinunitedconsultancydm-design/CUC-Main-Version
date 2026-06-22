import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final entities = dir.listSync(recursive: true);
  
  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = await entity.readAsString();
      bool changed = false;
      
      // Fix misplaced .response
      final misplacedResponse = RegExp(r'(ModelMutations\.(?:update|create|delete|deleteById)\([^)]+\))\.response');
      if (misplacedResponse.hasMatch(content)) {
        content = content.replaceAllMapped(misplacedResponse, (match) => match.group(1)!);
        changed = true;
      }
      
      final misplacedQueryResponse = RegExp(r'(ModelQueries\.(?:list|get)\([^)]+\))\.response');
      if (misplacedQueryResponse.hasMatch(content)) {
        content = content.replaceAllMapped(misplacedQueryResponse, (match) => match.group(1)!);
        changed = true;
      }
      
      // Fix getDateTime() to getDateTimeInUtc() or dateTime
      // Note: TemporalDateTime has a `getDateTimeInUtc()` method in amplify. Let's replace getDateTime() with getDateTimeInUtc()
      if (content.contains('.getDateTime()')) {
        content = content.replaceAll('.getDateTime()', '.getDateTimeInUtc()');
        changed = true;
      }
      
      if (changed) {
        await entity.writeAsString(content);
        print('Fixed ${entity.path}');
      }
    }
  }
}
