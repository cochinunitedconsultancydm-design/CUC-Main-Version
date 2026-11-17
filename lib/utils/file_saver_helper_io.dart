import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveFile(String content, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsString(content);
  return file.path;
}

Future<String> saveBytes(List<int> bytes, String fileName, {String mimeType = 'application/octet-stream'}) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}
