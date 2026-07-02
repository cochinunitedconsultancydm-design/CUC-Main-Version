import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/ModelProvider.dart';
import 'time_tracking_service.dart';
import 'logging_service.dart';

import 'security_service.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
import 'supabase_backup_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_name';
  static const String _roleKey = 'user_role';
  static const String _sessionIdKey = 'session_id';
  static const String _userIdKey = 'current_user_id';

  final SecurityService _security = SecurityService();

  Future<bool> login(String username, String password) async {
    try {
      final lockMessage = _security.checkRateLimit(username);
      if (lockMessage != null) {
        debugPrint('Login blocked: $lockMessage');
        return false;
      }

      debugPrint('Attempting Cognito login for: $username');

      final normalizedUser = username.toLowerCase().trim();
      final userPart = normalizedUser.contains('@') ? normalizedUser.split('@')[0] : normalizedUser;
      final loginEmail = normalizedUser.contains('@') ? normalizedUser : '$userPart@cuc.local';

      String targetRole = 'staff';
      if (userPart == 'irshad' || userPart == 'jesna') {
        targetRole = 'manager';
      } else if (userPart == 'admin') {
        targetRole = 'admin';
      }

      // Clear any stale Cognito session before attempting new sign-in
      try {
        await Amplify.Auth.signOut();
      } catch (e) {
        // Ignore
      }

      // SECURITY: Authenticate against AWS Cognito securely!
      var signInResult = await Amplify.Auth.signIn(
        username: loginEmail,
        password: password,
      );

      if (signInResult.nextStep.signInStep == AuthSignInStep.confirmSignInWithNewPassword) {
        debugPrint('User requires password change. Automatically setting permanent password.');
        signInResult = await Amplify.Auth.confirmSignIn(
          confirmationValue: password,
        );
      }

      if (!signInResult.isSignedIn) {
        debugPrint('Cognito Login failed: Not signed in. Step: ${signInResult.nextStep.signInStep}');
        _security.recordFailedAttempt(username);
        return false;
      }

      // Query AppSync after successful login, using standard User Pools authorization.
      Users? dbUser;
      try {
        final request = ModelQueries.list(
          Users.classType,
          limit: 1000,
        );
        final response = await Amplify.API.query(request: request).response;
        final allUsers = response.data?.items.whereType<Users>().toList() ?? [];

        final users = allUsers.where((u) {
          if (loginEmail.contains('@')) {
            return u.email?.toLowerCase().trim() == loginEmail;
          }
          return u.username?.toLowerCase().trim() == normalizedUser;
        }).toList();

        if (users.isNotEmpty) {
          dbUser = users.first;
          if (dbUser.role != targetRole) {
            debugPrint('Updating user role in AppSync for ${dbUser.username} to: $targetRole');
            final updatedUser = dbUser.copyWith(role: targetRole);
            await BackupAwareApi().update(updatedUser);
            dbUser = updatedUser;
          }
        }
      } catch (e) {
        debugPrint('Failed to query AppSync for user: $e');
      }

      // Auto-create the user in AppSync if they don't exist but Cognito login succeeded.
      if (dbUser == null) {
        dbUser = Users(
          username: username,
          email: loginEmail,
          role: targetRole,
          name: username,
        );
        try {
          await BackupAwareApi().create(dbUser);
        } catch (e) {
          debugPrint('Failed to auto-create user in AppSync: $e');
        }
      }

      _security.clearFailedAttempts(username);
      debugPrint('User authenticated: ${dbUser.id}, Role: ${dbUser.role}');
      
      final res = dbUser; // for compatibility with existing code below

      int supabaseUserId = await SupabaseBackupService().getUserIdByUsername(username) ?? 0;

      String? sessionId;
      try {
        final session = UserSessions(
          user_id: supabaseUserId,
          login_time: DateTime.now().toIso8601String(),
          is_active: true,
        );
        final sessionReq = ModelMutations.create(session);
        final sessionRes = await Amplify.API.mutate(request: sessionReq).response;
        sessionId = sessionRes.data?.id;
      } catch (e) {
        debugPrint('Session recording failed: $e');
      }

      final prefs = await SharedPreferences.getInstance();

      final authSession = await Amplify.Auth.fetchAuthSession();
      await prefs.setString(_tokenKey, authSession.isSignedIn ? 'cognito_active' : _security.generateSecureToken());
      await prefs.setString(_userKey, res.name ?? res.username ?? '');
      await prefs.setString(_roleKey, res.role ?? 'staff');
      await prefs.setInt(SecurityService.lastActivityKey, DateTime.now().millisecondsSinceEpoch);

      if (sessionId != null) {
        await prefs.setString('${_sessionIdKey}_str', sessionId);
        TimeTrackingService.instance.startTracking(int.tryParse(sessionId) ?? 0);
      }

      await prefs.setString('${_userIdKey}_str', res.id);
      await prefs.setInt(_userIdKey, supabaseUserId);

      await LoggingService().logAction(
        action: 'LOGIN',
        targetType: 'System',
        targetId: res.username ?? '',
        details: 'User logged in via Cognito',
      );

      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      _security.recordFailedAttempt(username);
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionIdStr = prefs.getString('${_sessionIdKey}_str');

    if (sessionIdStr != null) {
      try {
        TimeTrackingService.instance.stopTracking();

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
          await BackupAwareApi().update(updatedSession);
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

    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      debugPrint('Cognito SignOut error: $e');
    }

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
    try {
      final authSession = await Amplify.Auth.fetchAuthSession();
      if (!authSession.isSignedIn) {
        await logout();
        return false;
      }
    } catch (e) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_tokenKey)) return false;

    final lastActivity = prefs.getInt(SecurityService.lastActivityKey);
    if (_security.isSessionExpired(lastActivity)) {
      debugPrint('Security: Session expired due to inactivity');
      await logout();
      return false;
    }

    try {
      final userIdStr = prefs.getString('${_userIdKey}_str');
      if (userIdStr != null) {
        final request = ModelQueries.get(
          Users.classType, 
          UsersModelIdentifier(id: userIdStr)
        );
        final response = await Amplify.API.query(request: request).response;
        final user = response.data;
        
        if (user != null) {
          await prefs.setString(_roleKey, user.role ?? 'staff');
        } else {
          debugPrint('Security: User not found in database. Forcing logout.');
          await logout();
          return false;
        }
      }
    } catch (e) {
      debugPrint('Security: Could not verify role with server: $e');
    }

    return true;
  }

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
    try {
      return prefs.getInt(_userIdKey);
    } catch (e) {
      final strId = prefs.getString('${_userIdKey}_str') ?? prefs.getString(_userIdKey);
      return strId != null ? int.tryParse(strId) : null;
    }
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

  Future<bool> sendPasswordResetCode(String email) async {
    try {
      String loginEmail = email;
      if (!loginEmail.contains('@')) loginEmail = '${email.trim().toLowerCase()}@cuc.local';
      
      final result = await Amplify.Auth.resetPassword(username: loginEmail);
      return result.isPasswordReset;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  Future<bool> verifyResetCode(String email, String code) async {
    // Requires newPassword which isn't in this signature, so we just return false
    return false;
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    return false;
  }

  String? getRateLimitMessage(String username) {
    return _security.checkRateLimit(username);
  }
}
