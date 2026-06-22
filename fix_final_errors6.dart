import 'dart:io';

void main() {
  final cfFile = File('lib/screens/client_files_dialog.dart');
  var cfText = cfFile.readAsStringSync();
  // `AWSFile.fromFile` is deprecated or unavailable, use `AWSFile.fromPath`
  cfText = cfText.replaceAll("AWSFile.fromFile(", "AWSFile.fromPath(");
  // Undefined name 'file' - probably should be 'pickedFile' or something
  // 516: `final fileUrl = await StorageService().uploadFile(file, filePath);` -> maybe `pickedFile`?
  cfText = cfText.replaceAll("uploadFile(file, filePath)", "uploadFile(pickedFile, filePath)");
  cfFile.writeAsStringSync(cfText);
  print('Fixed client_files_dialog.dart');

  final chFile = File('lib/screens/chat_screen.dart');
  var chText = chFile.readAsStringSync();
  // `onData` isn't defined on StreamSubscription maybe? 
  // It's probably `listen((data) { ... })` instead of `.listen(onData: (data) { ... })`
  chText = chText.replaceAll("onData: ", "");
  chFile.writeAsStringSync(chText);
  print('Fixed chat_screen.dart');
}
