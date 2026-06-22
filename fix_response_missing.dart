import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    var content = file.readAsStringSync();
    bool changed = false;

    // We want to replace things like:
    // await Amplify.API.mutate(request: ModelMutations.update(updatedClient));
    // with:
    // await Amplify.API.mutate(request: ModelMutations.update(updatedClient)).response;
    
    // Simple regex: `await Amplify\.API\.(mutate|query)\((.*?)\);` where it doesn't end with `.response;`
    // Actually, maybe `\)\)` without `.response`?
    
    final newContent = content.replaceAllMapped(
      RegExp(r'(await (?:amplify_core\.)?Amplify\.API\.(?:mutate|query)\(request: [^;]+?\))(?!\.response);'),
      (match) => '${match.group(1)}.response;'
    );
    
    if (newContent != content) {
      file.writeAsStringSync(newContent);
      print('Fixed \${file.path}');
    }
  }
}
