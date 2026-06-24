import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Centralized security utilities for the CUC application.
/// Handles password hashing, rate limiting, and session management.
class SecurityService {
  // Singleton
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // ========================================
  // PASSWORD HASHING (SHA-256 + Salt)
  // ========================================

  /// Prefix to identify hashed passwords vs legacy plaintext.
  static const String _hashPrefix = '\$cuc\$';

  /// Generates a cryptographically secure random salt.
  String _generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Hashes a password with the given salt using SHA-256.
  String _sha256Hash(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Creates a storable password string: $cuc$<salt>$<hash>
  String hashPassword(String plainPassword) {
    final salt = _generateSalt();
    final hash = _sha256Hash(plainPassword, salt);
    return '$_hashPrefix$salt\$$hash';
  }

  /// Verifies a password against a stored hash.
  /// Returns true if the password matches.
  bool verifyPassword(String plainPasswordRaw, String storedPasswordRaw) {
    final plainPassword = plainPasswordRaw.trim();
    final storedPassword = storedPasswordRaw.trim();
    if (!storedPassword.startsWith(_hashPrefix)) {
      // Legacy plaintext password — direct comparison
      return plainPassword == storedPassword;
    }

    // Extract salt and hash from stored value: $cuc$<salt>$<hash>
    final parts = storedPassword.substring(_hashPrefix.length).split('\$');
    if (parts.length != 2) return false;

    final salt = parts[0].trim();
    final storedHash = parts[1].trim();
    final computedHash = _sha256Hash(plainPassword, salt);
    
    debugPrint('SECURITY DEBUG: PlainPassword="$plainPassword"');
    debugPrint('SECURITY DEBUG: Salt="$salt"');
    debugPrint('SECURITY DEBUG: StoredHash="$storedHash"');
    debugPrint('SECURITY DEBUG: ComputedHash="$computedHash"');
    
    return computedHash == storedHash;
  }

  /// Checks if a stored password is still in legacy plaintext format.
  bool isLegacyPassword(String storedPassword) {
    return !storedPassword.startsWith(_hashPrefix);
  }

  // ========================================
  // LOGIN RATE LIMITING
  // ========================================

  /// Track failed login attempts per username: { username: (count, lastAttemptTime) }
  final Map<String, _LoginAttemptRecord> _loginAttempts = {};

  /// Max failed attempts before lockout.
  static const int maxFailedAttempts = 5;

  /// Lockout duration after max failed attempts.
  static const Duration lockoutDuration = Duration(minutes: 15);

  /// Check if a username is currently locked out.
  /// Returns null if not locked, or a human-readable message if locked.
  String? checkRateLimit(String username) {
    final record = _loginAttempts[username];
    if (record == null) return null;

    if (record.failedCount >= maxFailedAttempts) {
      final elapsed = DateTime.now().difference(record.lastAttempt);
      if (elapsed < lockoutDuration) {
        final remaining = lockoutDuration - elapsed;
        return 'Account locked. Try again in ${remaining.inMinutes + 1} minute(s).';
      } else {
        // Lockout expired, reset
        _loginAttempts.remove(username);
        return null;
      }
    }
    return null;
  }

  /// Record a failed login attempt.
  void recordFailedAttempt(String username) {
    final record = _loginAttempts[username];
    if (record != null) {
      record.failedCount++;
      record.lastAttempt = DateTime.now();
    } else {
      _loginAttempts[username] = _LoginAttemptRecord(
        failedCount: 1,
        lastAttempt: DateTime.now(),
      );
    }
    debugPrint('Security: Failed attempt #${_loginAttempts[username]!.failedCount} for $username');
  }

  /// Clear failed attempts on successful login.
  void clearFailedAttempts(String username) {
    _loginAttempts.remove(username);
  }

  // ========================================
  // SECURE TOKEN GENERATION
  // ========================================

  /// Generate a cryptographically secure auth token.
  String generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // ========================================
  // SESSION TIMEOUT
  // ========================================

  /// Session timeout duration (30 minutes of inactivity).
  static const Duration sessionTimeout = Duration(minutes: 30);

  /// Key for storing last activity time.
  static const String lastActivityKey = 'last_activity_time';

  /// Check if the session has expired based on last activity.
  bool isSessionExpired(int? lastActivityMs) {
    if (lastActivityMs == null) return true;
    final lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityMs);
    final elapsed = DateTime.now().difference(lastActivity);
    return elapsed > sessionTimeout;
  }

  // ========================================
  // INPUT SANITIZATION
  // ========================================

  /// Sanitize a text input by trimming and limiting length.
  String sanitize(String input, {int maxLength = 500}) {
    String sanitized = input.trim();
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    return sanitized;
  }

  /// Validate username format.
  String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username is required';
    }
    if (username.length < 3) return 'Username must be at least 3 characters';
    if (username.length > 50) return 'Username is too long';
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, dots, and underscores';
    }
    return null;
  }

  /// Validate password strength.
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password.length > 128) return 'Password is too long';
    return null;
  }

  /// Mask a sensitive string for display (e.g., passwords in exports).
  String maskSensitive(String? value) {
    if (value == null || value.isEmpty) return '••••••';
    if (value.length <= 2) return '••••••';
    return '${value[0]}${'•' * (value.length - 2)}${value[value.length - 1]}';
  }
}

class _LoginAttemptRecord {
  int failedCount;
  DateTime lastAttempt;

  _LoginAttemptRecord({
    required this.failedCount,
    required this.lastAttempt,
  });
}
