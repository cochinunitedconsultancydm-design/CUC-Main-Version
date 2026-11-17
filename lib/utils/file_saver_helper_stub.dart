Future<String> saveFile(String content, String fileName) async {
  throw UnsupportedError('Saving files is not supported on this platform');
}

Future<String> saveBytes(List<int> bytes, String fileName, {String mimeType = 'application/octet-stream'}) async {
  throw UnsupportedError('Saving files is not supported on this platform');
}
