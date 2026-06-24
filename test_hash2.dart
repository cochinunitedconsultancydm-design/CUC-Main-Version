import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  const String _hashPrefix = '\$cuc\$';
  
  String _sha256Hash(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool verifyPassword(String plainPassword, String storedPasswordRaw) {
    final storedPassword = storedPasswordRaw.trim();
    if (!storedPassword.startsWith(_hashPrefix)) {
      return plainPassword == storedPassword;
    }

    final parts = storedPassword.substring(_hashPrefix.length).split('\$');
    if (parts.length != 2) return false;

    final salt = parts[0].trim();
    final storedHash = parts[1].trim();
    final computedHash = _sha256Hash(plainPassword, salt);
    
    print('PlainPassword: "$plainPassword"');
    print('Salt: "$salt"');
    print('StoredHash: "$storedHash"');
    print('ComputedHash: "$computedHash"');
    
    return computedHash == storedHash;
  }

  final stored = '\$cuc\$z2NYiTnUZNtlttRXnawbMA==\$1116f09099e60edc0ce9bb700593a1a0de57a23cb30b5914fcf8f4e3ba1ffb1e';
  print('Result: ${verifyPassword('123456', stored)}');
}
