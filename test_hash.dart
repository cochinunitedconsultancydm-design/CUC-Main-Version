import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  print(sha256.convert(utf8.encode('_-hnrfubIKTb6iYQSiNV1w==:123456')));
}
