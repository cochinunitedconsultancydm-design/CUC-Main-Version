import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/ModelProvider.dart';
import 'time_tracking_service.dart';
import 'logging_service.dart';
import 'location_tracking_service.dart';
import 'security_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_name';
  static const String _roleKey = 'user_role';
  static const String _sessionIdKey = 'session_id';
  static const String _userIdKey = 'current_user_id';

  final SecurityService _security = SecurityService();

  Future<bool> login(String username, String password) async {
    try {
      // SECURITY: Rate limiting — check if account is locked
      final lockMessage = _security.checkRateLimit(username);
      if (lockMessage != null) {
        debugPrint('Login blocked: $lockMessage');
        return false;
      }

      debugPrint('Attempting login for: $username');

      // SECURITY: Fetch by username only, then verify password hash locally.
      // This prevents sending the password as a GraphQL query parameter.
      final request = ModelQueries.list(
        Users.classType,
        where: Users.USERNAME.eq(username),
      );
      final response = await Amplify.API.query(request: request).response;
      final users = response.data?.items;

      if (users == null || users.isEmpty) {
        debugPrint('Login failed: user not found');
        _security.recordFailedAttempt(username);
        await LoggingService().logAction(
          action: 'LOGIN_FAILED',
          targetType: 'System',
          targetId: username,
          details: 'User not found',
        );
        return false;
      }

      final res = users.first!;
      final storedPassword = res.password ?? '';

      // SECURITY: Verify password using hash comparison
      if (!_security.verifyPassword(password, storedPassword)) {
        debugPrint('Login failed: invalid password');
        _security.recordFailedAttempt(username);
        await LoggingService().logAction(
          action: 'LOGIN_FAILED',
          targetType: 'System',
          targetId: username,
          details: 'Invalid password (attempt #${_security.checkRateLimit(username) != null ? "LOCKED" : "recorded"})',
        );
        return false;
      }

      // SECURITY: Auto-migrate legacy plaintext passwords to hashed
      if (_security.isLegacyPassword(storedPassword)) {
        try {
          final hashedPassword = _security.hashPassword(password);
          final updated = res.copyWith(password: hashedPassword);
          await Amplify.API.mutate(request: ModelMutations.update(updated)).response;
          debugPrint('Security: Migrated plaintext password to hash for $username');
        } catch (e) {
          debugPrint('Security: Password migration failed (non-critical): $e');
        }
      }

      // SECURITY: Clear failed attempts on success
      _security.clearFailedAttempts(username);

      debugPrint('User authenticated: ${res.id}, Role: ${res.role}');

      String? sessionId;
      try {
        final session = UserSessions(
          user_id: int.tryParse(res.id) ?? 0,
          login_time: DateTime.now().toIso8601String(),
          is_active: true,
        );
        final sessionReq = ModelMutations.create(session);
        final sessionRes = await Amplify.API.mutate(request: sessionReq).response;
        sessionId = sessionRes.data?.id;
        debugPrint('Session created: $sessionId');
      } catch (e) {
        debugPrint('Optional session recording failed: $e');
      }

      final prefs = await SharedPreferences.getInstance();

      // SECURITY: Use cryptographically secure random token
      await prefs.setString(_tokenKey, _security.generateSecureToken());
      await prefs.setString(_userKey, res.name ?? res.username ?? '');
      await prefs.setString(_roleKey, res.role ?? 'staff');

      // SECURITY: Record last activity time for session timeout
      await prefs.setInt(SecurityService.lastActivityKey, DateTime.now().millisecondsSinceEpoch);

      if (sessionId != null) {
        await prefs.setString('${_sessionIdKey}_str', sessionId);
        TimeTrackingService.instance.startTracking(int.tryParse(sessionId) ?? 0);
      }

      await prefs.setString('${_userIdKey}_str', res.id);
      await prefs.setInt(_userIdKey, int.tryParse(res.id) ?? 0);

      await LoggingService().logAction(
        action: 'LOGIN',
        targetType: 'System',
        targetId: res.username ?? '',
        details: 'User logged in',
      );

      debugPrint('Login successful for: ${res.name}');
      return true;
    } catch (e, stack) {
      debugPrint('Login error: $e\n$stack');
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionIdStr = prefs.getString('${_sessionIdKey}_str');

    if (sessionIdStr != null) {
      try {
        TimeTrackingService.instance.stopTracking();
        LocationTrackingService().stopTracking();
        final request = ModelQueries.get(
          UserSessions.classType,
          UserSessionsModelIdentifier(id: sessionIdStr),
        );
        final response = await Amplify.API.query(request: request).response;
        final session = response.data;
        if (session != null) {
          final updatedSession = session.copyWith(
            logout_time: DateTime.now().toIso8601String(),
            is_active: false,
          );
          await Amplify.API.mutate(request: ModelMutations.update(updatedSession)).response;
        }
      } catch (e) {
        debugPrint('Logout session error: $e');
      }
    }

    final userName = prefs.getString(_userKey) ?? 'Unknown';
    await LoggingService().logAction(
      action: 'LOGOUT',
      targetType: 'System',
      targetId: userName,
      details: 'User logged out',
    );

    // SECURITY: Clear all sensitive data from local storage
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_userIdKey);
    await prefs.remove('${_sessionIdKey}_str');
    await prefs.remove('${_userIdKey}_str');
    await prefs.remove(SecurityService.lastActivityKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_tokenKey)) return false;

    // SECURITY: Check session timeout
    final lastActivity = prefs.getInt(SecurityService.lastActivityKey);
    if (_security.isSessionExpired(lastActivity)) {
      debugPrint('Security: Session expired due to inactivity');
      await logout();
      return false;
    }

    return true;
  }

  /// Call this periodically to refresh the activity timestamp (e.g., on navigation).
  Future<void> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_tokenKey)) {
      await prefs.setInt(SecurityService.lastActivityKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<bool> isManager() async {
    final role = await getUserRole();
    return role == 'manager';
  }

  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<void> saveRememberMe(String username, bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', remember);
    if (remember) {
      await prefs.setString('remembered_username', username);
    } else {
      await prefs.remove('remembered_username');
    }
  }

  Future<Map<String, dynamic>> getRememberedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('remembered_username') ?? '',
      'remember': prefs.getBool('remember_me') ?? false,
    };
  }

  // SECURITY: Password reset is not yet implemented with a real email backend.
  // These methods return false so the UI can show an honest error message.
  Future<bool> sendPasswordResetCode(String email) async {
    // TODO: Implement with AWS SES or Cognito for real email delivery
    debugPrint('Password reset not yet configured for: $email');
    return false;
  }

  Future<bool> verifyResetCode(String email, String code) async {
    // TODO: Implement with real verification backend
    return false;
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    // TODO: Implement with real password update backend
    return false;
  }

  /// Get the rate limit message for a username (for UI display).
  String? getRateLimitMessage(String username) {
    return _security.checkRateLimit(username);
  }
}
