import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'time_tracking_service.dart';
import 'logging_service.dart';
import 'location_tracking_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_name';
  static const String _roleKey = 'user_role';
  static const String _sessionIdKey = 'session_id';
  static const String _userIdKey = 'current_user_id';

  final _supabase = Supabase.instance.client;

  Future<bool> login(String username, String password) async {
    try {
      print('Attempting login for: $username');
      final res = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));

      if (res != null) {
        print('User found: ${res['id']}, Role: ${res['role']}');
        
        int? sessionId;
        try {
          // Record login session (optional, don't block login if it fails)
          final sessionRes = await _supabase
              .from('user_sessions')
              .insert({'user_id': res['id']})
              .select()
              .single()
              .timeout(const Duration(seconds: 5));
          sessionId = sessionRes['id'];
          print('Session created: $sessionId (Type: ${sessionId.runtimeType})');
        } catch (e) {
          print('Optional session recording failed: $e');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, 'token-${res['id']}-${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString(_userKey, res['name'] ?? res['username']);
        await prefs.setString(_roleKey, res['role'] ?? 'staff');
        
        // Safer ID storage
        if (sessionId != null && sessionId is int) {
          await prefs.setInt(_sessionIdKey, sessionId);
          TimeTrackingService.instance.startTracking(sessionId);
        } else if (sessionId != null && sessionId is String) {
          await prefs.setString('${_sessionIdKey}_str', sessionId.toString());
          // Assuming sessionId might be parsable or TimeTracker supports string IDs. 
          // For now, we only track if it's an int.
        }

        final userId = res['id'];
        if (userId is int) {
          await prefs.setInt(_userIdKey, userId);
        } else {
          await prefs.setString('${_userIdKey}_str', userId.toString());
        }

        await LoggingService().logAction(action: 'LOGIN', targetType: 'System', targetId: res['username'], details: 'User logged in');

        final String userRole = res['role'] ?? 'staff';

        print('Login successful for: ${res['name']}');
        return true;
      } else {
        print('No user found with those credentials');
      }
    } catch (e) {
      print('Login error: $e');
      if (e is TimeoutException) {
        print('Connection timed out. Please check your internet connection.');
      }
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getInt(_sessionIdKey);
    
    if (sessionId != null) {
      try {
        TimeTrackingService.instance.stopTracking();
        LocationTrackingService().stopTracking();
        await _supabase
            .from('user_sessions')
            .update({'logout_time': DateTime.now().toIso8601String(), 'is_active': false})
            .eq('id', sessionId);
      } catch (e) {
        print('Logout session error: $e');
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

  // --- Forgot Password Stub Methods ---
  
  Future<bool> sendPasswordResetCode(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    print('Stub: Sent reset code to $email');
    // In a real app, this would call an Edge Function to send an email
    return true; // Return true if successful
  }

  Future<bool> verifyResetCode(String email, String code) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    print('Stub: Verifying code $code for $email');
    // In a real app, this would verify the code against a DB record or OTP table
    // For now, accept any code that is 6 digits
    return code.length == 6;
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    print('Stub: Updating password for $email');
    try {
      // In a real app, this should securely update the user table
      // e.g., await _supabase.from('users').update({'password': newPassword}).eq('email', email);
      // NOTE: Using raw passwords is not recommended, consider hashing in backend!
      return true;
    } catch (e) {
      print('Failed to update password: $e');
      return false;
    }
  }
}
