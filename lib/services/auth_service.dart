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

  String? lastLoginError;

  final SecurityService _security = SecurityService();

  Future<bool> login(String username, String password) async {
    lastLoginError = null;
    try {
      final lockMessage = _security.checkRateLimit(username);
      if (lockMessage != null) {
        lastLoginError = lockMessage;
        debugPrint('Login blocked: $lockMessage');
        return false;
      }

      debugPrint('Attempting Cognito login...');

      final normalizedUser = username.toLowerCase().trim();
      final userPart = normalizedUser.contains('@') ? normalizedUser.split('@')[0] : normalizedUser;

      // Candidate emails in prioritized order:
      final List<String> candidateEmails = [];
      if (normalizedUser.contains('@')) {
        candidateEmails.add(normalizedUser);
        if (normalizedUser == 'cochinunitedconsultancy2020@gmail.com') {
          candidateEmails.add('harshina@cuc.local');
        } else if (normalizedUser == 'cucarya@gmail.com') {
          candidateEmails.add('arya@cuc.local');
        } else {
          candidateEmails.add('$userPart@cuc.local');
        }
      } else {
        // Plain username (e.g. 'harshina', 'admin', 'midhun', 'arya')
        // Primary Cognito email for all staff is <userPart>@cuc.local
        candidateEmails.add('$userPart@cuc.local');
        if (userPart == 'harshina') {
          candidateEmails.add('cochinunitedconsultancy2020@gmail.com');
        } else if (userPart == 'arya') {
          candidateEmails.add('cucarya@gmail.com');
        }
        candidateEmails.add('$userPart@cuc.com');
      }

      // Determine default role for new users if they don't exist
      String defaultRole = 'staff';
      if (userPart == 'jesna' || userPart == 'harshina') {
        defaultRole = 'manager';
      } else if (userPart == 'irshad') {
        defaultRole = 'hr';
      } else if (userPart == 'admin') {
        defaultRole = 'admin';
      }

      // Only sign out if a previous session is still active
      try {
        final currentSession = await Amplify.Auth.fetchAuthSession().timeout(const Duration(seconds: 2));
        if (currentSession.isSignedIn) {
          await Amplify.Auth.signOut().timeout(const Duration(seconds: 3));
        }
      } catch (_) {}

      // SECURITY: Authenticate against AWS Cognito securely!
      SignInResult? signInResult;
      String successfulLoginEmail = candidateEmails.first;
      Object? lastError;

      for (final emailToTry in candidateEmails) {
        try {
          debugPrint('Trying Cognito signIn with: $emailToTry');
          final res = await Amplify.Auth.signIn(
            username: emailToTry,
            password: password,
          ).timeout(const Duration(seconds: 12));
          signInResult = res;
          successfulLoginEmail = emailToTry;
          break;
        } catch (err) {
          lastError = err;
          debugPrint('Cognito signIn attempt failed for $emailToTry: $err');
          final errStr = err.toString();
          if (errStr.contains('Incorrect username or password') || errStr.contains('NotAuthorizedException')) {
            lastLoginError = 'Incorrect username or password.';
          } else if (errStr.contains('UserNotFoundException') || errStr.contains('User does not exist')) {
            lastLoginError = 'User account does not exist in Cognito.';
          } else if (errStr.contains('TimeoutException')) {
            lastLoginError = 'Login request timed out. Please check your network connection.';
          } else {
            lastLoginError = 'Login failed: $err';
          }
        }
      }

      if (signInResult == null) {
        debugPrint('All Cognito signIn attempts failed. Last error: $lastError');
        _security.recordFailedAttempt(username);
        return false;
      }

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
        final allUsers = (response.data?.items ?? []).whereType<Users>().toList() ?? [];

        final users = allUsers.where((u) {
          final uName = u.username?.toLowerCase().trim();
          final uMail = u.email?.toLowerCase().trim();
          if (normalizedUser.contains('@')) {
            return uMail == normalizedUser || uName == userPart;
          }
          return uName == normalizedUser ||
                 uMail == '$normalizedUser@cuc.local' ||
                 (userPart == 'harshina' && (uName == 'harshina' || uMail == 'harshina@cuc.local'));
        }).toList();

        if (users.isNotEmpty) {
          dbUser = users.first;
          // We no longer overwrite the user's role on every login.
          // The role assigned in Staff Management will persist.
        }
      } catch (e) {
        debugPrint('Failed to query AppSync for user: $e');
      }

      // Auto-create the user in AppSync if they don't exist but Cognito login succeeded.
      if (dbUser == null) {
        dbUser = Users(
          username: username,
          email: successfulLoginEmail,
          role: defaultRole,
          name: username,
        );
        try {
          await BackupAwareApi().create(dbUser);
        } catch (e) {
          debugPrint('Failed to auto-create user in AppSync: $e');
        }
      }

      _security.clearFailedAttempts(username);
      debugPrint('User authenticated successfully. Role: ${dbUser.role}');
      
      final res = dbUser; // for compatibility with existing code below

      int supabaseUserId = await SupabaseBackupService().getUserIdByUsername(username) ?? 0;

      // Close any previous dangling active sessions for this user before creating a new one
      try {
        final oldReq = ModelQueries.list(
          UserSessions.classType,
          where: UserSessions.USER_ID.eq(supabaseUserId).and(UserSessions.IS_ACTIVE.eq(true)),
          limit: 20,
        );
        final oldRes = await Amplify.API.query(request: oldReq).response;
        for (final oldSession in (oldRes.data?.items ?? []).whereType<UserSessions>()) {
          final closed = oldSession.copyWith(
            is_active: false,
            logout_time: DateTime.now().toIso8601String(),
            status: 'Offline',
          );
          await BackupAwareApi().update(closed);
        }
      } catch (e) {
        debugPrint('Error closing dangling sessions: $e');
      }

      String? sessionId;
      try {
        final session = UserSessions(
          user_id: supabaseUserId,
          login_time: DateTime.now().toIso8601String(),
          is_active: true,
          status: 'Active',
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
        TimeTrackingService.instance.startTracking(sessionId);
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

  Future<bool> clientLogin(String phone, String dob) async {
    try {
      final lockMessage = _security.checkRateLimit(phone);
      if (lockMessage != null) {
        debugPrint('Login blocked: $lockMessage');
        return false;
      }

      debugPrint('Attempting Client login...');

      try {
        await Amplify.Auth.signOut();
      } catch (e) {}

      const portalEmail = String.fromEnvironment('PORTAL_EMAIL', defaultValue: 'portal@cuc.local');
      const portalPassword = String.fromEnvironment('PORTAL_PASSWORD', defaultValue: 'CucPortalUser@2024');

      bool isPortalSignedIn = false;
      
      try {
        final authSession = await Amplify.Auth.fetchAuthSession();
        isPortalSignedIn = authSession.isSignedIn;
      } catch (e) {}

      if (!isPortalSignedIn) {
        try {
          var signInResult = await Amplify.Auth.signIn(
            username: portalEmail,
            password: portalPassword,
          );
          isPortalSignedIn = signInResult.isSignedIn;
        } on AuthException catch (e) {
          if (e.message.contains('User does not exist') || e.message.contains('Incorrect username')) {
            try {
              await Amplify.Auth.signUp(
                username: portalEmail,
                password: portalPassword,
                options: SignUpOptions(userAttributes: {
                  CognitoUserAttributeKey.email: 'portal@cuc.local',
                }),
              );
              // Retry login after signup
              var signInResult = await Amplify.Auth.signIn(
                username: portalEmail,
                password: portalPassword,
              );
              isPortalSignedIn = signInResult.isSignedIn;
            } catch (signupErr) {
              debugPrint('Portal auto-signup failed: $signupErr');
              return false;
            }
          } else {
            debugPrint('Portal login failed: $e');
            return false;
          }
        }
      }

      if (!isPortalSignedIn) {
        debugPrint('Portal sign in failed.');
        return false;
      }

      final request = ModelQueries.list(
        Clients.classType,
        limit: 10000,
      );
      final response = await Amplify.API.query(request: request).response;
      if (response.hasErrors) {
        debugPrint('DEBUG: GraphQL Errors: ${response.errors}');
      }
      final allClients = (response.data?.items ?? []).whereType<Clients>().toList() ?? [];
      debugPrint('DEBUG: Fetched ${allClients.length} clients to filter');

      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
      final clients = allClients.where((c) {
        if (c.dob != dob) return false;
        final dbPhone = (c.phone ?? '').replaceAll(RegExp(r'\s+'), '');
        return dbPhone == cleanPhone;
      }).toList();

      if (clients.isEmpty) {
        debugPrint('Client login failed: credentials not found');
        await Amplify.Auth.signOut();
        _security.recordFailedAttempt(phone);
        return false;
      }

      final client = clients.first;

      _security.clearFailedAttempts(phone);
      debugPrint('Client authenticated successfully');

      final prefs = await SharedPreferences.getInstance();

      final authSession = await Amplify.Auth.fetchAuthSession();
      await prefs.setString(_tokenKey, authSession.isSignedIn ? 'cognito_active' : _security.generateSecureToken());
      await prefs.setString(_userKey, client.name ?? 'Client');
      await prefs.setString(_roleKey, 'client');
      await prefs.setInt(SecurityService.lastActivityKey, DateTime.now().millisecondsSinceEpoch);

      // Store client ID in the user ID key so that isLoggedIn logic can find it
      await prefs.setString('${_userIdKey}_str', client.id);

      await LoggingService().logAction(
        action: 'CLIENT_LOGIN',
        targetType: 'System',
        targetId: client.phone ?? '',
        details: 'Client logged in via portal',
      );

      return true;
    } catch (e) {
      debugPrint('Client login error: $e');
      _security.recordFailedAttempt(phone);
    }
    return false;
  }

  Future<void> logout({bool waitNetwork = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionIdStr = prefs.getString('${_sessionIdKey}_str');
    final userName = prefs.getString(_userKey) ?? 'Unknown';
    final userId = prefs.getInt(_userIdKey) ?? int.tryParse(prefs.getString('${_userIdKey}_str') ?? '') ?? 0;

    Future<void> performNetworkLogout() async {
      try {
        await TimeTrackingService.instance.stopTracking();
      } catch (e) {
        debugPrint('stopTracking error: $e');
      }

      if (sessionIdStr != null && sessionIdStr.isNotEmpty) {
        try {
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
              status: 'Offline',
            );
            await BackupAwareApi().update(updatedSession);
          }
        } catch (e) {
          debugPrint('Logout session error: $e');
        }
      }

      await LoggingService().logAction(
        action: 'LOGOUT',
        targetType: 'System',
        targetId: userName,
        details: 'User logged out',
        userId: userId,
        userName: userName,
      );

      try {
        await Amplify.Auth.signOut();
      } catch (e) {
        debugPrint('Cognito SignOut error: $e');
      }
    }

    try {
      await performNetworkLogout().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Logout network wait error: $e');
    }

    // Clear local prefs immediately so session state is wiped
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
      final currentRole = prefs.getString(_roleKey);
      
      if (userIdStr != null) {
        if (currentRole == 'client') {
          final request = ModelQueries.get(
            Clients.classType, 
            ClientsModelIdentifier(id: userIdStr)
          );
          final response = await Amplify.API.query(request: request).response;
          final client = response.data;
          
          if (client != null) {
            await prefs.setString(_roleKey, 'client');
          } else {
            debugPrint('Security: Client not found in database. Forcing logout.');
            await logout();
            return false;
          }
        } else {
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
    return role?.toLowerCase().trim() == 'admin';
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

  Future<String?> getUserIdStr() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_userIdKey}_str');
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
