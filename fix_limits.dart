import 'dart:io';

void processFile(File file) {
  String content = file.readAsStringSync();
  bool modified = false;
  int index = 0;
  String searchStr = 'ModelQueries.list(';
  
  while (true) {
    int idx = content.indexOf(searchStr, index);
    if (idx == -1) break;
    
    int startIdx = idx + searchStr.length;
    int parenCount = 1;
    int endIdx = startIdx;
    
    while (endIdx < content.length && parenCount > 0) {
      if (content[endIdx] == '(') {
        parenCount++;
      } else if (content[endIdx] == ')') {
        parenCount--;
      }
      endIdx++;
    }
    
    if (parenCount == 0) {
      String innerContent = content.substring(startIdx, endIdx - 1);
      
      // Check if 'limit:' is already present
      if (!RegExp(r'\blimit\s*:').hasMatch(innerContent)) {
        String innerStripped = innerContent.trimRight();
        String newInner;
        if (innerStripped.endsWith(',')) {
          newInner = innerContent + ' limit: 10000';
        } else {
          newInner = innerContent + ', limit: 10000';
        }
        
        content = content.substring(0, startIdx) + newInner + content.substring(endIdx - 1);
        modified = true;
      }
    }
    index = startIdx;
  }
  
  if (modified) {
    file.writeAsStringSync(content);
    print('Updated ${file.path}');
  }
}

void main() {
  Directory libDir = Directory('lib');
  int count = 0;
  if (libDir.existsSync()) {
    List<FileSystemEntity> entities = libDir.listSync(recursive: true);
    for (var entity in entities) {
      if (entity is File && entity.path.endsWith('.dart')) {
        try {
          processFile(entity);
          count++;
        } catch (e) {
          print('Error processing ${entity.path}: $e');
        }
      }
    }
    print('Processed $count files.');
  } else {
    print('lib directory not found');
  }
}
