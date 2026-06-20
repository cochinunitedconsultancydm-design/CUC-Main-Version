import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // In a production app, this key should be stored securely and not hardcoded.
  // For CUC consultancy, we use a 32-character AES key.
  final _key = encrypt.Key.fromUtf8('CUC-Consultancy-Secure-AES-Key32');
  final _iv = encrypt.IV.fromUtf8('CUC-Consultancy-'); // Must be exactly 16 bytes
  
  // Use CBC mode explicitly for better consistency
  late final _encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

  String encryptText(String text) {
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  String decryptText(String encryptedBase64) {
    if (encryptedBase64.isEmpty) return "";
    try {
      return _encrypter.decrypt64(encryptedBase64, iv: _iv);
    } catch (e) {
      // Fallback for old keys or plain text
      if (encryptedBase64.length > 10 && (encryptedBase64.contains('/') || encryptedBase64.endsWith('=='))) {
        return "🔒 [Legacy Message]";
      }
      return encryptedBase64;
    }
  }
}
