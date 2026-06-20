import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final testDir = Directory('test');

  if (libDir.existsSync()) {
    for (var entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        var content = entity.readAsStringSync();
        if (RegExp(r'\bprint\(').hasMatch(content)) {
          content = content.replaceAll(RegExp(r'\bprint\('), 'debugPrint(');
          if (!content.contains("import 'package:flutter/foundation.dart';")) {
            content = "import 'package:flutter/foundation.dart';\n" + content;
          }
          entity.writeAsStringSync(content);
          print('Fixed ${entity.path}');
        }
      }
    }
  }

  if (testDir.existsSync()) {
    for (var entity in testDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        var content = entity.readAsStringSync();
        if (!content.contains('avoid_print') && RegExp(r'\bprint\(').hasMatch(content)) {
          content = '// ignore_for_file: avoid_print\n' + content;
          entity.writeAsStringSync(content);
          print('Ignored print in ${entity.path}');
        }
      }
    }
  }
}
