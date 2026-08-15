import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // Key should be provided via --dart-define=ENCRYPTION_KEY=...
  // In a production app, this key should be stored securely and not hardcoded.
  static const _keyString = String.fromEnvironment(
    'ENCRYPTION_KEY',
    defaultValue: 'CUC-Consultancy-Secure-AES-Key32',
  );
  final _key = encrypt.Key.fromUtf8(_keyString);

  // Legacy IV kept for decrypting old messages encrypted with the static IV.
  final _legacyIv = encrypt.IV.fromUtf8('CUC-Consultancy-'); // 16 bytes

  // Use CBC mode explicitly for consistency.
  late final _encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

  String encryptText(String text) {
    // Generate a random IV for each encryption to ensure unique ciphertext.
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(text, iv: iv);
    // Prepend the IV (base64) separated by ':' so the decrypter can extract it.
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptText(String encryptedBase64) {
    if (encryptedBase64.isEmpty) return "";
    try {
      // New format: "iv_base64:ciphertext_base64"
      if (encryptedBase64.contains(':')) {
        final colonIdx = encryptedBase64.indexOf(':');
        final ivPart = encryptedBase64.substring(0, colonIdx);
        final cipherPart = encryptedBase64.substring(colonIdx + 1);
        if (ivPart.isNotEmpty && cipherPart.isNotEmpty) {
          final iv = encrypt.IV.fromBase64(ivPart);
          return _encrypter.decrypt64(cipherPart, iv: iv);
        }
      }
      // Legacy format: decrypt with the old static IV
      return _encrypter.decrypt64(encryptedBase64, iv: _legacyIv);
    } catch (e) {
      // Fallback for old keys or plain text
      if (encryptedBase64.length > 10 && (encryptedBase64.contains('/') || encryptedBase64.endsWith('=='))) {
        return "🔒 [Legacy Message]";
      }
      return encryptedBase64;
    }
  }
}
