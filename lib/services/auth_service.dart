import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/ModelProvider.dart';
import 'time_tracking_service.dart';
import 'logging_service.dart';
import 'location_tracking_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_name';
  static const String _roleKey = 'user_role';
  static const String _sessionIdKey = 'session_id';
  static const String _userIdKey = 'current_user_id';

  Future<bool> login(String username, String password) async {
    try {
      debugPrint('Attempting login for: $username');
      
      // DIAGNOSTIC 1: Fetch user without checking password first
      final testReq = ModelQueries.list(Users.classType, where: Users.USERNAME.eq(username));
      final testRes = await Amplify.API.query(request: testReq).response;
      if (testRes.data?.items.isNotEmpty == true) {
        debugPrint('DIAGNOSTIC: User found in DB. Stored password is: "${testRes.data!.items.first!.password}"');
        debugPrint('DIAGNOSTIC: You entered password: "$password"');
        if (testRes.data!.items.first!.password != password) {
          debugPrint('DIAGNOSTIC ERROR: Passwords do not match!');
        }
      } else {
        debugPrint('DIAGNOSTIC ERROR: User "$username" does NOT exist in the database!');
      }

      final request = ModelQueries.list(
        Users.classType,
        where: Users.USERNAME.eq(username).and(Users.PASSWORD.eq(password)),
      );
      final response = await Amplify.API.query(request: request).response;
      final users = response.data?.items;

      if (users != null && users.isNotEmpty) {
        final res = users.first!;
        debugPrint('User found: ${res.id}, Role: ${res.role}');
        
        String? sessionId;
        try {
          final session = UserSessions(
            user_id: int.tryParse(res.id) ?? 0, 
            login_time: DateTime.now().toIso8601String(), 
            is_active: true
          );
          final sessionReq = ModelMutations.create(session);
          final sessionRes = await Amplify.API.mutate(request: sessionReq).response;
          sessionId = sessionRes.data?.id;
          debugPrint('Session created: $sessionId');
        } catch (e) {
          debugPrint('Optional session recording failed: $e');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, 'token-${res.id}-${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString(_userKey, res.name ?? res.username ?? '');
        await prefs.setString(_roleKey, res.role ?? 'staff');
        
        if (sessionId != null) {
          await prefs.setString('${_sessionIdKey}_str', sessionId);
          // Assuming TimeTrackingService uses integer ID or we skip for now
          TimeTrackingService.instance.startTracking(int.tryParse(sessionId) ?? 0);
        }

        await prefs.setString('${_userIdKey}_str', res.id);
        await prefs.setInt(_userIdKey, int.tryParse(res.id) ?? 0);

        await LoggingService().logAction(action: 'LOGIN', targetType: 'System', targetId: res.username ?? '', details: 'User logged in');

        debugPrint('Login successful for: ${res.name}');
        return true;
      } else {
        debugPrint('No user found with those credentials');
      }
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
        final request = ModelQueries.get(UserSessions.classType, UserSessionsModelIdentifier(id: sessionIdStr));
        final response = await Amplify.API.query(request: request).response;
        final session = response.data;
        if (session != null) {
           final updatedSession = session.copyWith(logout_time: DateTime.now().toIso8601String(), is_active: false);
           await Amplify.API.mutate(request: ModelMutations.update(updatedSession)).response;
        }
      } catch (e) {
        debugPrint('Logout session error: $e');
      }
    }
    
    final userName = prefs.getString(_userKey) ?? 'Unknown';
    await LoggingService().logAction(action: 'LOGOUT', targetType: 'System', targetId: userName, details: 'User logged out');
    
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_userIdKey);
    await prefs.remove('${_sessionIdKey}_str');
    await prefs.remove('${_userIdKey}_str');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
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

  Future<bool> sendPasswordResetCode(String email) async {
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('Stub: Sent reset code to $email');
    return true; 
  }

  Future<bool> verifyResetCode(String email, String code) async {
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('Stub: Verifying code $code for $email');
    return code.length == 6;
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('Stub: Updating password for $email');
    return true;
  }
}
