import 'file_saver_helper_stub.dart'
    if (dart.library.html) 'file_saver_helper_web.dart'
    if (dart.library.io) 'file_saver_helper_io.dart';

class FileSaverHelper {
  static Future<String> saveJsonFile({
    required String jsonString,
    required String fileName,
  }) => saveFile(jsonString, fileName);

  static Future<String> saveBytesFile({
    required List<int> bytes,
    required String fileName,
    String mimeType = 'application/octet-stream',
  }) => saveBytes(bytes, fileName, mimeType: mimeType);
}
