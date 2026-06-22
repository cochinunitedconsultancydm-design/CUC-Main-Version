import 'dart:io';

void main() {
  final content = File('lib/screens/license_management_screen.dart').readAsStringSync();
  int braceCount = 0;
  final lines = content.split('\n');
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    for (int j = 0; j < line.length; j++) {
      if (line[j] == '{') braceCount++;
      if (line[j] == '}') braceCount--;
    }
    if (braceCount == 0 && i > 30) {
      print('Ended at line ' + (i + 1).toString());
      break;
    }
  }
}
