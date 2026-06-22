import 'dart:io';

void main() {
  final file = File('lib/screens/license_management_screen.dart');
  var content = file.readAsStringSync();
  
  if (content.contains("if (confirmed == true) {\\n        final updatedModel")) {
    content = content.replaceFirst("if (confirmed == true) {\\n        final updatedModel", "if (confirmed == true) {\\n      try {\\n        final updatedModel");
  }
  
  // also wait, let's use a robust replace
  content = content.replaceAll("if (confirmed == true) {\\r\\n        final updatedModel", "if (confirmed == true) {\\n      try {\\n        final updatedModel");
  content = content.replaceAll("if (confirmed == true) {\\n        final updatedModel", "if (confirmed == true) {\\n      try {\\n        final updatedModel");
  
  file.writeAsStringSync(content);
  print('Fixed missing try block');
}
