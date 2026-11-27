import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../services/supabase_backup_service.dart';

/// Single unified attendance record for a staff member on a specific day
class DailyAttendanceRecord {
  final String staffKey;
  final int day;
  final DateTime date;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool isActive;
  bool isAutoReconciled;
  String? checkoutReason;
  final List<AttendanceEvent> events;

  DailyAttendanceRecord({
    required this.staffKey,
    required this.day,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.isActive = false,
    this.isAutoReconciled = false,
    this.checkoutReason,
    List<AttendanceEvent>? events,
  }) : events = events ?? [];

  DateTime? get firstIn => checkInTime;
  DateTime? get lastOut => checkOutTime;

  String? get durationStr {
    if (checkInTime == null) return null;
    final end = checkOutTime ?? (isActive ? DateTime.now() : null);
    if (end == null) return null;
    final diff = end.difference(checkInTime!);
    if (diff.isNegative) return null;

    // Filter out dangling sessions closed days later (exceeding 16 hours or across different dates)
    if (diff.inHours > 16 || (checkOutTime != null && checkOutTime!.day != checkInTime!.day)) {
      return null;
    }

    final hours = diff.inHours;
    final mins = diff.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }
}

/// An individual attendance or session activity event
class AttendanceEvent {
  final String title;
  final DateTime time;
  final String type; // 'IN' or 'OUT'
  final String source; // 'Top Bar Check-In' or 'System Login Session'
  final String? ipAddress;
  final String? status;

  AttendanceEvent({
    required this.title,
    required this.time,
    required this.type,
    required this.source,
    this.ipAddress,
    this.status,
  });
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _isLoading = true;
  String _searchQuery = '';

  List<amplify_models.Users> _allStaff = [];
  Map<String, int> _usernameToIdMap = {};

  // Matrix: staffKey -> (dayNumber -> DailyAttendanceRecord)
  Map<String, Map<int, DailyAttendanceRecord>> _attendanceMatrix = {};

  // Synchronized scroll controllers
  late final ScrollController _leftVerticalController;
  late final ScrollController _verticalController;
  late final ScrollController _headerHorizontalController;
  late final ScrollController _bodyHorizontalController;

  static const double _staffColWidth = 210.0;
  static const double _dayColWidth = 92.0;
  static const double _headerHeight = 58.0;
  static const double _rowHeight = 76.0;

  @override
  void initState() {
    super.initState();
    _leftVerticalController = ScrollController();
    _verticalController = ScrollController();
    _headerHorizontalController = ScrollController();
    _bodyHorizontalController = ScrollController();

    // Link vertical scrolling between left frozen staff pane and main grid
    _verticalController.addListener(() {
      if (_leftVerticalController.hasClients &&
          _leftVerticalController.offset != _verticalController.offset) {
        _leftVerticalController.jumpTo(_verticalController.offset);
      }
    });

    // Link horizontal scrolling between top frozen day headers and main grid
    _bodyHorizontalController.addListener(() {
      if (_headerHorizontalController.hasClients &&
          _headerHorizontalController.offset != _bodyHorizontalController.offset) {
        _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
      }
    });

    _loadData();
  }

  @override
  void dispose() {
    _leftVerticalController.dispose();
    _verticalController.dispose();
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    super.dispose();
  }

  /// Parses timestamp to Indian Standard Time (IST)
  static DateTime? _parseIST(dynamic val) {
    if (val == null) return null;
    final ts = val.toString().trim();
    if (ts.isEmpty) return null;
    try {
      if (ts.contains('+00')) {
        final clean = ts.split('+')[0];
        return DateTime.tryParse(clean);
      }
      final dt = DateTime.tryParse(ts);
      if (dt == null) return null;
      return dt.toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Determine integer ID for an Amplify/Supabase user
  int? _getUserId(amplify_models.Users user) {
    final idParsed = int.tryParse(user.id);
    if (idParsed != null && idParsed > 0) return idParsed;

    final username = user.username?.toLowerCase().trim() ?? '';
    if (username.isNotEmpty && _usernameToIdMap.containsKey(username)) {
      return _usernameToIdMap[username];
    }

    final email = user.email?.toLowerCase().trim() ?? '';
    if (email.isNotEmpty && _usernameToIdMap.containsKey(email)) {
      return _usernameToIdMap[email];
    }

    final name = user.name?.toLowerCase().trim() ?? '';
    if (name.isNotEmpty && _usernameToIdMap.containsKey(name)) {
      return _usernameToIdMap[name];
    }

    return null;
  }

  /// Primary unique identifier key for staff row
  String _staffKey(amplify_models.Users user) {
    final uid = _getUserId(user);
    if (uid != null) return uid.toString();
    final uname = user.username?.toLowerCase().trim();
    if (uname != null && uname.isNotEmpty) return uname;
    final uemail = user.email?.toLowerCase().trim();
    if (uemail != null && uemail.isNotEmpty) return uemail;
    return user.id;
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // 1. Load user ID mappings from Supabase
      _usernameToIdMap = await SupabaseBackupService().getUsernameToIdMap();

      // 2. Fetch staff from Amplify
      List<amplify_models.Users> usersRaw = [];
      try {
        final uReq = ModelQueries.list(
          amplify_models.Users.classType,
          limit: 10000,
          authorizationMode: APIAuthorizationType.userPools,
        );
        final uRes = await Amplify.API.query(request: uReq).response;
        usersRaw = (uRes.data?.items ?? []).whereType<amplify_models.Users>().toList();
      } catch (e) {
        debugPrint('Amplify users list query error: $e');
      }

      // Fetch staff from Supabase (disaster-recovery fallback only)
      List<Map<String, dynamic>> sbUsers = [];
      try {
        sbUsers = await SupabaseBackupService().getFullUsersData();
      } catch (e) {
        debugPrint('Supabase getFullUsersData error: $e');
      }

      // If Amplify returned no users (e.g. offline/outage), fall back to Supabase mirror
      if (usersRaw.isEmpty && sbUsers.isNotEmpty) {
        usersRaw = sbUsers.map((su) => amplify_models.Users(
          id: su['id']?.toString() ?? '',
          name: su['name']?.toString() ?? su['username']?.toString(),
          username: su['username']?.toString(),
          email: su['email']?.toString(),
          role: su['role']?.toString(),
        )).toList();
      }

      // 1. Gather all deleted staff keys from SharedPreferences (local device)
      final Set<String> deletedKeys = {
        'amarnath',
        'jayan',
        'sariga',
        'saniga',
        'jesna',
        'jisha',
        'jitha',
        'midhun',
      };
      try {
        final prefs = await SharedPreferences.getInstance();
        final localDeleted = prefs.getStringList('deleted_staff_keys') ?? [];
        for (var k in localDeleted) {
          final trimmed = k.toLowerCase().trim();
          if (trimmed.isNotEmpty) deletedKeys.add(trimmed);
        }
      } catch (_) {}

      // 2. Harvest deleted staff from Supabase users marked with role == 'deleted'
      for (var su in sbUsers) {
        final role = (su['role'] ?? '').toString().toLowerCase().trim();
        if (role == 'deleted') {
          if (su['id'] != null) deletedKeys.add(su['id'].toString().toLowerCase().trim());
          if (su['username'] != null) deletedKeys.add(su['username'].toString().toLowerCase().trim());
          if (su['email'] != null) deletedKeys.add(su['email'].toString().toLowerCase().trim());
          if (su['name'] != null) deletedKeys.add(su['name'].toString().toLowerCase().trim());
        }
      }

      final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);

      // 3. Query ActivityLogs early to discover all DELETE_STAFF events from database
      List<amplify_models.ActivityLogs> ampLogs = [];
      try {
        final logsReq = ModelQueries.list(
          amplify_models.ActivityLogs.classType,
          limit: 10000,
          authorizationMode: APIAuthorizationType.userPools,
        );
        final logsRes = await Amplify.API.query(request: logsReq).response;
        ampLogs = (logsRes.data?.items ?? []).whereType<amplify_models.ActivityLogs>().toList();
      } catch (e) {
        debugPrint('Amplify ActivityLogs query error: $e');
      }

      List<Map<String, dynamic>> sbLogs = [];
      try {
        sbLogs = await SupabaseBackupService().getActivityLogs(monthStr);
      } catch (e) {
        debugPrint('Supabase getActivityLogs error: $e');
      }

      void registerDeletedFromLog(String? action, dynamic targetId) {
        final act = (action ?? '').toUpperCase().trim();
        if (act == 'DELETE_STAFF' || act == 'STAFF_DELETED') {
          if (targetId != null) {
            final tid = targetId.toString().toLowerCase().trim();
            if (tid.isNotEmpty) deletedKeys.add(tid);
          }
        }
      }

      for (var l in ampLogs) {
        registerDeletedFromLog(l.action, l.target_id);
      }
      for (var l in sbLogs) {
        registerDeletedFromLog(l['action']?.toString(), l['target_id']);
      }

      // Confirmed active staff must NEVER be excluded, even if an old test deletion existed in cache
      const Set<String> confirmedActiveUsernames = {
        'harshina',
        'anoop',
        'arya',
        'ashwini',
        'nithya',
        'poojapmadhu',
        'sarath',
        'irshad',
      };
      const Set<String> confirmedActiveEmails = {
        'harshina@cuc.local',
        'anoop@cuc.local',
        'cucarya@gmail.com',
        'ashwini@cuc.local',
        'pooja@cochinunited.com',
        'sarath@cuc.local',
        'irshad@cuc.local',
      };

      // Safely purge active usernames/emails from deletedKeys set and SharedPreferences
      for (var active in confirmedActiveUsernames) {
        deletedKeys.remove(active);
      }
      for (var email in confirmedActiveEmails) {
        deletedKeys.remove(email);
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        final localDeleted = prefs.getStringList('deleted_staff_keys') ?? [];
        if (localDeleted.any((k) => confirmedActiveUsernames.contains(k.toLowerCase().trim()) || confirmedActiveEmails.contains(k.toLowerCase().trim()))) {
          final cleaned = localDeleted.where((k) => !confirmedActiveUsernames.contains(k.toLowerCase().trim()) && !confirmedActiveEmails.contains(k.toLowerCase().trim())).toList();
          await prefs.setStringList('deleted_staff_keys', cleaned);
        }
      } catch (_) {}

      bool isExcludedStaff(dynamic id, String? username, String? email, String? name, String? role) {
        final r = (role ?? '').toLowerCase().trim();
        // Exclude system admin, clients, superadmin, or deleted roles
        if (r == 'admin' || r == 'superadmin' || r == 'client' || r == 'deleted') return true;

        final uid = id?.toString().toLowerCase().trim() ?? '';
        final uname = (username ?? '').toLowerCase().trim();
        final uemail = (email ?? '').toLowerCase().trim();
        final uNameStr = (name ?? '').toLowerCase().trim();

        if (uname == 'admin' || uNameStr == 'admin' || uNameStr == 'master admin') return true;

        // Confirmed active team members must NEVER be excluded
        if (confirmedActiveUsernames.contains(uname) ||
            (uemail.isNotEmpty && confirmedActiveEmails.contains(uemail)) ||
            uname == 'harshina' ||
            uNameStr == 'harshina' ||
            uemail == 'harshina@cuc.local') {
          return false;
        }

        if (uid.isNotEmpty && deletedKeys.contains(uid)) return true;
        if (uname.isNotEmpty && deletedKeys.contains(uname)) return true;
        if (uemail.isNotEmpty && deletedKeys.contains(uemail)) return true;
        if (uNameStr.isNotEmpty && deletedKeys.contains(uNameStr)) return true;

        return false;
      }

      // Deduplicate and filter staff
      final Map<String, amplify_models.Users> uniqueUsers = {};
      for (var u in usersRaw) {
        if (isExcludedStaff(u.id, u.username, u.email, u.name, u.role)) continue;

        final name = (u.name ?? '').toLowerCase().trim();
        if (name.isEmpty) continue;
        var key = (u.username ?? u.email ?? name).toLowerCase().trim();
        if (key.contains('jithasree')) key = 'jitha';

        if (uniqueUsers.containsKey(key)) {
          final existing = uniqueUsers[key]!;
          if (u.id.contains('-') && !existing.id.contains('-')) {
            uniqueUsers[key] = u;
          }
        } else {
          uniqueUsers[key] = u;
        }
      }

      _allStaff = uniqueUsers.values.where((u) {
        return !isExcludedStaff(u.id, u.username, u.email, u.name, u.role);
      }).toList();
      _allStaff.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
// 3. Build comprehensive Lookup map to target staffKey
      final Map<String, String> lookupToStaffKey = {};
      for (var staff in _allStaff) {
        final key = _staffKey(staff);
        lookupToStaffKey[key] = key;
        lookupToStaffKey[staff.id.toLowerCase().trim()] = key;
        final uid = _getUserId(staff);
        if (uid != null) {
          lookupToStaffKey[uid.toString()] = key;
        }
        if (staff.username != null && staff.username!.trim().isNotEmpty) {
          lookupToStaffKey[staff.username!.toLowerCase().trim()] = key;
        }
        if (staff.email != null && staff.email!.trim().isNotEmpty) {
          lookupToStaffKey[staff.email!.toLowerCase().trim()] = key;
        }
        if (staff.name != null && staff.name!.trim().isNotEmpty) {
          lookupToStaffKey[staff.name!.toLowerCase().trim()] = key;
        }
      }

      // 4. Query StaffAttendance & UserSessions for selected month
      // Month already defined above

      // A: Amplify StaffAttendance
      List<amplify_models.StaffAttendance> ampAttendance = [];
      try {
        final attReq = ModelQueries.list(
          amplify_models.StaffAttendance.classType,
          where: amplify_models.StaffAttendance.ATTENDANCE_DATE.contains(monthStr),
          limit: 10000,
          authorizationMode: APIAuthorizationType.userPools,
        );
        final attRes = await Amplify.API.query(request: attReq).response;
        ampAttendance = (attRes.data?.items ?? []).whereType<amplify_models.StaffAttendance>().toList();
      } catch (e) {
        debugPrint('Amplify StaffAttendance query error: $e');
      }

      // B: Supabase StaffAttendance
      List<Map<String, dynamic>> sbAttendance = [];
      try {
        sbAttendance = await SupabaseBackupService().getStaffAttendance(monthStr);
      } catch (e) {
        debugPrint('Supabase getStaffAttendance error: $e');
      }

      // C: Amplify UserSessions
      List<amplify_models.UserSessions> ampSessions = [];
      try {
        final sessReq = ModelQueries.list(
          amplify_models.UserSessions.classType,
          limit: 10000,
          authorizationMode: APIAuthorizationType.userPools,
        );
        final sessRes = await Amplify.API.query(request: sessReq).response;
        ampSessions = (sessRes.data?.items ?? []).whereType<amplify_models.UserSessions>().toList();
      } catch (e) {
        debugPrint('Amplify UserSessions error: $e');
      }

      // D: Supabase UserSessions
      List<Map<String, dynamic>> sbSessions = [];
      try {
        sbSessions = await SupabaseBackupService().getUserSessions(monthStr);
      } catch (e) {
        debugPrint('Supabase getUserSessions error: $e');
      }

      // 5. Construct Unified Matrix with Enterprise MNC Auto-Checkout Resolution
      _attendanceMatrix = _buildMatrix(
        lookupToStaffKey: lookupToStaffKey,
        ampAttendance: ampAttendance,
        sbAttendance: sbAttendance,
        ampSessions: ampSessions,
        sbSessions: sbSessions,
        ampLogs: ampLogs,
        sbLogs: sbLogs,
      );

      // Auto-scroll to today if current month
      final now = DateTime.now();
      if (_selectedMonth.year == now.year && _selectedMonth.month == now.month && now.day > 4) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToDay(now.day - 2);
        });
      }

    } catch (e) {
      debugPrint('Error loading attendance data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Build Unified Matrix combining manual clock-in/out and app login/logout sessions
  Map<String, Map<int, DailyAttendanceRecord>> _buildMatrix({
    required Map<String, String> lookupToStaffKey,
    required List<amplify_models.StaffAttendance> ampAttendance,
    required List<Map<String, dynamic>> sbAttendance,
    required List<amplify_models.UserSessions> ampSessions,
    required List<Map<String, dynamic>> sbSessions,
    required List<amplify_models.ActivityLogs> ampLogs,
    required List<Map<String, dynamic>> sbLogs,
  }) {
    final Map<String, Map<int, DailyAttendanceRecord>> matrix = {};
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    final todayStart = DateTime(now.year, now.month, now.day);

    // Helper to get or create daily record
    DailyAttendanceRecord getOrCreateRecord(String staffKey, int day, DateTime date) {
      final userMap = matrix.putIfAbsent(staffKey, () => {});
      return userMap.putIfAbsent(
        day,
        () => DailyAttendanceRecord(staffKey: staffKey, day: day, date: date),
      );
    }

    // Helper to resolve staff key from identifiers
    String? resolveStaff(dynamic userId, [dynamic username, dynamic email, dynamic name]) {
      if (userId != null) {
        final idStr = userId.toString().trim();
        if (lookupToStaffKey.containsKey(idStr)) return lookupToStaffKey[idStr];
      }
      if (username != null) {
        final u = username.toString().toLowerCase().trim();
        if (lookupToStaffKey.containsKey(u)) return lookupToStaffKey[u];
      }
      if (email != null) {
        final e = email.toString().toLowerCase().trim();
        if (lookupToStaffKey.containsKey(e)) return lookupToStaffKey[e];
      }
      if (name != null) {
        final n = name.toString().toLowerCase().trim();
        if (lookupToStaffKey.containsKey(n)) return lookupToStaffKey[n];
      }
      return null;
    }

    // Map of latest activity log per staffKey per day (for MNC Last-Activity Resolution)
    final Map<String, Map<int, DateTime>> latestLogByStaffAndDay = {};
    void registerActivityLog(dynamic uid, dynamic uname, dynamic rawTs) {
      final staffKey = resolveStaff(uid, uname);
      if (staffKey == null) return;
      final ts = _parseIST(rawTs);
      if (ts == null) return;
      if (ts.year == _selectedMonth.year && ts.month == _selectedMonth.month) {
        final day = ts.day;
        final existing = latestLogByStaffAndDay.putIfAbsent(staffKey, () => {})[day];
        if (existing == null || ts.isAfter(existing)) {
          latestLogByStaffAndDay[staffKey]![day] = ts;
        }
      }
    }

    for (var l in ampLogs) {
      registerActivityLog(l.user_id, l.target_id, l.created_at ?? l.createdAt?.format());
    }
    for (var l in sbLogs) {
      registerActivityLog(l['user_id'], l['user_name'] ?? l['username'], l['created_at']);
    }

    // 1. Process Amplify StaffAttendance (Manual Clock-In / Clock-Out)
    for (var att in ampAttendance) {
      final staffKey = resolveStaff(att.user_id);
      if (staffKey == null) continue;

      DateTime? inTime = _parseIST(att.check_in_time);
      DateTime? outTime = _parseIST(att.check_out_time);

      DateTime? refDate = inTime ?? outTime;
      if (refDate == null && att.attendance_date != null) {
        refDate = DateTime.tryParse(att.attendance_date!);
      }
      if (refDate == null) continue;
      if (refDate.year != _selectedMonth.year || refDate.month != _selectedMonth.month) continue;

      final day = refDate.day;
      final record = getOrCreateRecord(staffKey, day, refDate);

      if (inTime != null) {
        record.events.add(AttendanceEvent(
          title: 'Clock In (Manual)',
          time: inTime,
          type: 'IN',
          source: 'Top Bar Check-In',
        ));
        if (record.checkInTime == null || inTime.isBefore(record.checkInTime!)) {
          record.checkInTime = inTime;
        }
      }
      if (outTime != null) {
        record.events.add(AttendanceEvent(
          title: 'Clock Out (Manual)',
          time: outTime,
          type: 'OUT',
          source: 'Top Bar Check-Out',
        ));
        if (record.checkOutTime == null || outTime.isAfter(record.checkOutTime!)) {
          record.checkOutTime = outTime;
        }
      } else if (isCurrentMonth && day == now.day && inTime != null) {
        record.isActive = true;
      }
    }

    // 2. Process Supabase StaffAttendance
    for (var att in sbAttendance) {
      final staffKey = resolveStaff(att['user_id']);
      if (staffKey == null) continue;

      DateTime? inTime = _parseIST(att['check_in_time']);
      DateTime? outTime = _parseIST(att['check_out_time']);

      DateTime? refDate = inTime ?? outTime;
      if (refDate == null && att['attendance_date'] != null) {
        refDate = DateTime.tryParse(att['attendance_date'].toString());
      }
      if (refDate == null) continue;
      if (refDate.year != _selectedMonth.year || refDate.month != _selectedMonth.month) continue;

      final day = refDate.day;
      final record = getOrCreateRecord(staffKey, day, refDate);

      if (inTime != null) {
        final alreadyLogged = record.events.any((e) => e.type == 'IN' && e.time.difference(inTime).inMinutes.abs() < 2);
        if (!alreadyLogged) {
          record.events.add(AttendanceEvent(
            title: 'Clock In (Supabase)',
            time: inTime,
            type: 'IN',
            source: 'Top Bar Check-In',
          ));
        }
        if (record.checkInTime == null || inTime.isBefore(record.checkInTime!)) {
          record.checkInTime = inTime;
        }
      }
      if (outTime != null) {
        final alreadyLogged = record.events.any((e) => e.type == 'OUT' && e.time.difference(outTime).inMinutes.abs() < 2);
        if (!alreadyLogged) {
          record.events.add(AttendanceEvent(
            title: 'Clock Out (Supabase)',
            time: outTime,
            type: 'OUT',
            source: 'Top Bar Check-Out',
          ));
        }
        if (record.checkOutTime == null || outTime.isAfter(record.checkOutTime!)) {
          record.checkOutTime = outTime;
        }
      } else if (isCurrentMonth && day == now.day && inTime != null) {
        record.isActive = true;
      }
    }

    // 3. Process Amplify UserSessions (System Login / Logout Activity)
    for (var sess in ampSessions) {
      final staffKey = resolveStaff(sess.user_id);
      if (staffKey == null) continue;

      DateTime? loginTime = _parseIST(sess.login_time);
      DateTime? logoutTime = _parseIST(sess.logout_time);

      DateTime? refDate = loginTime ?? logoutTime;
      if (refDate == null) continue;
      if (refDate.year != _selectedMonth.year || refDate.month != _selectedMonth.month) continue;

      final day = refDate.day;
      final record = getOrCreateRecord(staffKey, day, refDate);

      if (loginTime != null) {
        final alreadyLogged = record.events.any((e) => e.type == 'IN' && e.time.difference(loginTime).inMinutes.abs() < 2);
        if (!alreadyLogged) {
          record.events.add(AttendanceEvent(
            title: 'App Login Session',
            time: loginTime,
            type: 'IN',
            source: 'System Login',
            ipAddress: sess.ip_address,
            status: sess.status,
          ));
        }
        if (record.checkInTime == null || loginTime.isBefore(record.checkInTime!)) {
          record.checkInTime = loginTime;
        }
      }
      if (logoutTime != null) {
        final alreadyLogged = record.events.any((e) => e.type == 'OUT' && e.time.difference(logoutTime).inMinutes.abs() < 2);
        if (!alreadyLogged) {
          record.events.add(AttendanceEvent(
            title: 'App Logout',
            time: logoutTime,
            type: 'OUT',
            source: 'System Logout',
          ));
        }
        if (record.checkOutTime == null || logoutTime.isAfter(record.checkOutTime!)) {
          record.checkOutTime = logoutTime;
        }
      } else if (isCurrentMonth && day == now.day && (sess.is_active == true || sess.status?.toLowerCase() == 'active')) {
        record.isActive = true;
      }
    }

    // 4. Process Supabase UserSessions
    for (var sess in sbSessions) {
      final staffKey = resolveStaff(sess['user_id'], sess['username']);
      if (staffKey == null) continue;

      DateTime? loginTime = _parseIST(sess['login_time'] ?? sess['session_start']);
      DateTime? logoutTime = _parseIST(sess['logout_time'] ?? sess['session_end']);

      DateTime? refDate = loginTime ?? logoutTime;
      if (refDate == null) continue;
      if (refDate.year != _selectedMonth.year || refDate.month != _selectedMonth.month) continue;

      final day = refDate.day;
      final record = getOrCreateRecord(staffKey, day, refDate);

      if (loginTime != null) {
        final alreadyLogged = record.events.any((e) => e.type == 'IN' && e.time.difference(loginTime).inMinutes.abs() < 2);
        if (!alreadyLogged) {
          record.events.add(AttendanceEvent(
            title: 'App Login Session',
            time: loginTime,
            type: 'IN',
            source: 'System Login',
            ipAddress: sess['ip_address']?.toString(),
            status: sess['status']?.toString(),
          ));
        }
        if (record.checkInTime == null || loginTime.isBefore(record.checkInTime!)) {
          record.checkInTime = loginTime;
        }
      }
      if (logoutTime != null) {
        final alreadyLogged = record.events.any((e) => e.type == 'OUT' && e.time.difference(logoutTime).inMinutes.abs() < 2);
        if (!alreadyLogged) {
          record.events.add(AttendanceEvent(
            title: 'App Logout',
            time: logoutTime,
            type: 'OUT',
            source: 'System Logout',
          ));
        }
        if (record.checkOutTime == null || logoutTime.isAfter(record.checkOutTime!)) {
          record.checkOutTime = logoutTime;
        }
      } else if (isCurrentMonth && day == now.day && (sess['is_active'] == true || sess['status']?.toString().toLowerCase() == 'active')) {
        record.isActive = true;
      }
    }

    // 5. Enterprise MNC Auto-Checkout & Presence Reconciliation
    for (var userMap in matrix.values) {
      for (var record in userMap.values) {
        final dayDate = record.date;
        final inTime = record.checkInTime;

        if (inTime != null) {
          // If checkout was stored across multiple days or > 16 hours, invalidate the dangling value
          if (record.checkOutTime != null) {
            if (record.checkOutTime!.day != inTime.day ||
                record.checkOutTime!.difference(inTime).inHours > 16) {
              record.checkOutTime = null;
            }
          }

          // If checkout is missing for this day:
          if (record.checkOutTime == null) {
            final staffKey = record.staffKey;
            final latestLog = latestLogByStaffAndDay[staffKey]?[record.day];

            if (latestLog != null && latestLog.isAfter(inTime) && latestLog.day == inTime.day) {
              // Priority 1: User's latest action log on that day
              record.checkOutTime = latestLog;
              record.checkoutReason = 'Last Active System Activity';
              record.events.add(AttendanceEvent(
                title: 'Last Activity Heartbeat',
                time: latestLog,
                type: 'OUT',
                source: 'User Action Log',
              ));
            } else if (isCurrentMonth && record.day == now.day) {
              // Priority 2: Today (Current Shift)
              final sinceInMins = now.difference(inTime).inMinutes;
              if (record.isActive || sinceInMins < 45) {
                record.isActive = true;
                record.checkoutReason = 'Currently Online';
              } else {
                record.checkOutTime = inTime.add(Duration(minutes: sinceInMins > 120 ? 120 : sinceInMins));
                record.checkoutReason = 'Session Inactive';
              }
            } else if (dayDate.isBefore(todayStart)) {
              // Priority 3: Past Work Day (Standard Shift Auto-Reconciliation)
              record.isAutoReconciled = true;
              if (inTime.hour < 12) {
                // Morning check-in -> Standard 05:30 PM (standard 8-hour workday)
                record.checkOutTime = DateTime(dayDate.year, dayDate.month, dayDate.day, 17, 30);
                record.checkoutReason = 'Standard Shift Policy (Auto-Completed at 5:30 PM)';
              } else if (inTime.hour < 16) {
                // Afternoon check-in -> Standard 06:00 PM shift end
                record.checkOutTime = DateTime(dayDate.year, dayDate.month, dayDate.day, 18, 0);
                record.checkoutReason = 'Afternoon Shift Policy (Auto-Completed at 6:00 PM)';
              } else {
                // Late check-in (> 4:00 PM) -> 2h 30m shift
                record.checkOutTime = inTime.add(const Duration(hours: 2, minutes: 30));
                record.checkoutReason = 'Evening Session (Auto-Completed)';
              }

              record.events.add(AttendanceEvent(
                title: 'Auto-Reconciled Shift Conclusion',
                time: record.checkOutTime!,
                type: 'OUT',
                source: 'Enterprise Shift Policy',
                status: 'Auto-Completed',
              ));
            }
          }
        }
      }
    }

    // Sort events inside each record
    for (var userMap in matrix.values) {
      for (var record in userMap.values) {
        record.events.sort((a, b) => a.time.compareTo(b.time));
      }
    }

    return matrix;
  }

  /// Side Scroll helpers
  void _scrollBy(double offset) {
    if (!_bodyHorizontalController.hasClients) return;
    final target = (_bodyHorizontalController.offset + offset).clamp(
      0.0,
      _bodyHorizontalController.position.maxScrollExtent,
    );
    _bodyHorizontalController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToDay(int day) {
    if (!_bodyHorizontalController.hasClients) return;
    final target = ((day - 1) * _dayColWidth).clamp(
      0.0,
      _bodyHorizontalController.position.maxScrollExtent,
    );
    _bodyHorizontalController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    _loadData();
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppTheme.primaryColor,
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
      _loadData();
    }
  }

  /// Interactive Modal Dialog displaying detailed In/Out logs for clicked cell
  void _showAttendanceDetailsDialog(
    BuildContext context,
    String staffName,
    DateTime date,
    DailyAttendanceRecord? record,
  ) {
    final dateDisplay = DateFormat('EEEE, d MMMM yyyy').format(date);
    final hasActivity = record != null && (record.checkInTime != null || record.checkOutTime != null);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                child: Text(
                  staffName.isNotEmpty ? staffName[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(staffName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 2),
                    Text(dateDisplay, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              if (record?.isActive == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text('ONLINE', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: !hasActivity
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: date.weekday == DateTime.sunday ? Colors.grey.shade100 : Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            date.weekday == DateTime.sunday ? Icons.weekend_rounded : Icons.event_busy_rounded,
                            size: 28,
                            color: date.weekday == DateTime.sunday ? Colors.grey.shade600 : Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          date.weekday == DateTime.sunday ? 'Sunday (Weekly Off)' : 'Marked as Leave (Absent)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: date.weekday == DateTime.sunday ? Colors.black87 : Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          date.weekday == DateTime.sunday
                              ? 'Sunday is a designated weekly off. No attendance is required.'
                              : 'No clock-in, application login, or system activity was recorded for $staffName on this working day. Marked as Leave.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary Row Cards
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            // In Time Card
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.login_rounded, size: 14, color: Colors.green.shade700),
                                      const SizedBox(width: 4),
                                      Text('First In / Login', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    record.checkInTime != null
                                        ? DateFormat('hh:mm a').format(record.checkInTime!)
                                        : '—',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.green.shade800),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 36, color: Colors.grey.shade300),
                            // Out Time Card
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.logout_rounded, size: 14, color: Colors.orange.shade800),
                                        const SizedBox(width: 4),
                                        Text('Last Out / Logout', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      record.isActive
                                          ? 'Active Now'
                                          : (record.checkOutTime != null
                                              ? DateFormat('hh:mm a').format(record.checkOutTime!)
                                              : '—'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: record.isActive ? Colors.teal.shade700 : Colors.orange.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(width: 1, height: 36, color: Colors.grey.shade300),
                            // Duration Card
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.timer_outlined, size: 14, color: AppTheme.primaryColor),
                                        const SizedBox(width: 4),
                                        Text('Total Duration', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      record.durationStr ?? 'In Progress',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (record.isAutoReconciled || record.checkoutReason != null)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified_outlined, size: 16, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  record.checkoutReason ?? 'Shift auto-completed per company attendance policy.',
                                  style: TextStyle(fontSize: 11.5, color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),
                      // Events Timeline
                      const Text('ACTIVITY TIMELINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: record.events.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (c, idx) {
                            final ev = record.events[idx];
                            final isCheckIn = ev.type == 'IN';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isCheckIn ? Colors.green.shade50 : Colors.orange.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                                      size: 16,
                                      color: isCheckIn ? Colors.green.shade700 : Colors.orange.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ev.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(
                                          '${ev.source}${ev.ipAddress != null ? ' • IP: ${ev.ipAddress}' : ''}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      DateFormat('hh:mm:ss a').format(ev.time),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthDisplayStr = DateFormat('MMMM yyyy').format(_selectedMonth);
    final daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;

    // Filter staff by search query
    final filteredStaff = _allStaff.where((u) {
      if (_searchQuery.trim().isEmpty) return true;
      final query = _searchQuery.toLowerCase().trim();
      final name = (u.name ?? '').toLowerCase();
      final username = (u.username ?? '').toLowerCase();
      final email = (u.email ?? '').toLowerCase();
      return name.contains(query) || username.contains(query) || email.contains(query);
    }).toList();

    // Quick stats calculations
    int presentTodayCount = 0;
    int activeNowCount = 0;
    if (isCurrentMonth) {
      for (var staff in _allStaff) {
        final staffKey = _staffKey(staff);
        final rec = _attendanceMatrix[staffKey]?[now.day];
        if (rec != null && rec.firstIn != null) presentTodayCount++;
        if (rec != null && rec.isActive) activeNowCount++;
      }
    }

    final double totalDaysWidth = daysInMonth * _dayColWidth;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Staff Attendance Register', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Control Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Title and Subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Attendance Register', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Unified tracking of clock-ins, clock-outs, and login sessions', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Search Box
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Search staff member...',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Month Navigator Controls
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 20),
                              tooltip: 'Previous Month',
                              onPressed: _previousMonth,
                            ),
                            InkWell(
                              onTap: () => _selectMonth(context),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month_rounded, size: 16, color: AppTheme.primaryColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      monthDisplayStr,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, size: 20),
                              tooltip: 'Next Month',
                              onPressed: _nextMonth,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.05),

                // Sub-header Summary, Side-Scroll Quick Jump & Legend
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Row(
                    children: [
                      // Total Staff Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people_outline, size: 16, color: Colors.blueGrey.shade700),
                            const SizedBox(width: 6),
                            Text('Total Staff: ${_allStaff.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Present Today Chip
                      if (isCurrentMonth) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade700),
                              const SizedBox(width: 6),
                              Text('Present Today: $presentTodayCount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Leave Today Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event_busy_rounded, size: 16, color: Colors.red.shade700),
                              const SizedBox(width: 6),
                              Text(
                                'On Leave: ${(_allStaff.length - presentTodayCount).clamp(0, _allStaff.length)}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Online Now Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Active Now: $activeNowCount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      // Side-Scroll Quick Jump Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 13),
                              tooltip: 'Scroll Left (4 days)',
                              onPressed: () => _scrollBy(-368),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                            const SizedBox(width: 4),
                            _weekJumpChip('1–7', 1),
                            const SizedBox(width: 4),
                            _weekJumpChip('8–14', 8),
                            const SizedBox(width: 4),
                            _weekJumpChip('15–21', 15),
                            const SizedBox(width: 4),
                            _weekJumpChip('22–28', 22),
                            if (daysInMonth > 28) ...[
                              const SizedBox(width: 4),
                              _weekJumpChip('29–$daysInMonth', 29),
                            ],
                            if (isCurrentMonth) ...[
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _scrollToDay(now.day > 2 ? now.day - 2 : 1),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.my_location_rounded, size: 11, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text('Today (${now.day})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13),
                              tooltip: 'Scroll Right (4 days)',
                              onPressed: () => _scrollBy(368),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Legend Elements
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text('IN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                          ),
                          const SizedBox(width: 4),
                          Text('Login', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text('OUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                          ),
                          const SizedBox(width: 4),
                          Text('Logout', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text('LEAVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                          ),
                          const SizedBox(width: 4),
                          Text('Leave', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                            child: Text('OFF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          ),
                          const SizedBox(width: 4),
                          Text('Sunday Off', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          const SizedBox(width: 10),
                          Icon(Icons.swipe_rounded, size: 14, color: Colors.blueGrey.shade600),
                          const SizedBox(width: 4),
                          Text('Drag / Scroll horizontally', style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade600, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Data Matrix Table with Sticky Staff Column & Fluid Side-Scrolling
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                              PointerDeviceKind.stylus,
                            },
                          ),
                          child: Column(
                            children: [
                              // 1. TOP STICKY HEADER ROW (Staff Header + Days Headers)
                              Container(
                                height: _headerHeight,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.06),
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                                ),
                                child: Row(
                                  children: [
                                    // Pinned Staff Column Header
                                    Container(
                                      width: _staffColWidth,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                        border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                                      ),
                                      child: const Text(
                                        'STAFF MEMBER',
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54, letterSpacing: 1.1),
                                      ),
                                    ),
                                    // Horizontally Linked Days Header
                                    Expanded(
                                      child: SingleChildScrollView(
                                        controller: _headerHorizontalController,
                                        scrollDirection: Axis.horizontal,
                                        physics: const NeverScrollableScrollPhysics(),
                                        child: SizedBox(
                                          width: totalDaysWidth,
                                          child: Row(
                                            children: [
                                              for (int day = 1; day <= daysInMonth; day++)
                                                Container(
                                                  width: _dayColWidth,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(color: Colors.grey.shade200, width: 1)),
                                                  ),
                                                  child: _buildDayColumnHeader(day),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 2. MAIN SCROLLABLE TABLE BODY
                              Expanded(
                                child: Row(
                                  children: [
                                    // LEFT PINNED STAFF ROWS (Follows vertical scroll of grid)
                                    SizedBox(
                                      width: _staffColWidth,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                                          color: Colors.white,
                                        ),
                                        child: SingleChildScrollView(
                                          controller: _leftVerticalController,
                                          scrollDirection: Axis.vertical,
                                          physics: const NeverScrollableScrollPhysics(),
                                          child: Column(
                                            children: filteredStaff.map((user) {
                                              final staffKey = _staffKey(user);
                                              final userRecords = _attendanceMatrix[staffKey] ?? {};
                                              final daysPresent = userRecords.values.where((r) => r.firstIn != null).length;
                                              int workingDaysPast = 0;
                                              final maxDay = isCurrentMonth ? now.day : daysInMonth;
                                              for (int d = 1; d <= maxDay; d++) {
                                                final dt = DateTime(_selectedMonth.year, _selectedMonth.month, d);
                                                if (dt.weekday != DateTime.sunday) {
                                                  workingDaysPast++;
                                                }
                                              }
                                              final leaveCount = (workingDaysPast - daysPresent).clamp(0, workingDaysPast);

                                              return Container(
                                                height: _rowHeight,
                                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                                decoration: BoxDecoration(
                                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                                                      child: Text(
                                                        user.name != null && user.name!.isNotEmpty ? user.name![0].toUpperCase() : '?',
                                                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            user.name ?? 'Unknown',
                                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            '$daysPresent present • $leaveCount leave',
                                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // RIGHT HORIZONTALLY & VERTICALLY SCROLLABLE DAYS MATRIX
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Scrollbar(
                                            controller: _bodyHorizontalController,
                                            thumbVisibility: true,
                                            trackVisibility: true,
                                            child: SingleChildScrollView(
                                              controller: _bodyHorizontalController,
                                              scrollDirection: Axis.horizontal,
                                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                              child: SizedBox(
                                                width: totalDaysWidth,
                                                child: Scrollbar(
                                                  controller: _verticalController,
                                                  thumbVisibility: true,
                                                  trackVisibility: true,
                                                  child: SingleChildScrollView(
                                                    controller: _verticalController,
                                                    scrollDirection: Axis.vertical,
                                                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                                    child: Column(
                                                      children: filteredStaff.map((user) {
                                                        final staffKey = _staffKey(user);
                                                        final userRecords = _attendanceMatrix[staffKey] ?? {};

                                                        return Container(
                                                          height: _rowHeight,
                                                          decoration: BoxDecoration(
                                                            border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              for (int day = 1; day <= daysInMonth; day++)
                                                                Container(
                                                                  width: _dayColWidth,
                                                                  alignment: Alignment.center,
                                                                  decoration: BoxDecoration(
                                                                    border: Border(right: BorderSide(color: Colors.grey.shade100, width: 1)),
                                                                  ),
                                                                  child: _AttendanceCell(
                                                                    record: userRecords[day],
                                                                    staffName: user.name ?? 'Staff',
                                                                    date: DateTime(_selectedMonth.year, _selectedMonth.month, day),
                                                                    onTap: () => _showAttendanceDetailsDialog(
                                                                      context,
                                                                      user.name ?? 'Staff',
                                                                      DateTime(_selectedMonth.year, _selectedMonth.month, day),
                                                                      userRecords[day],
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Floating Left Scroll Overlay Button
                                          Positioned(
                                            left: 6,
                                            top: 0,
                                            bottom: 16,
                                            child: Center(
                                              child: Material(
                                                elevation: 4,
                                                shape: const CircleBorder(),
                                                color: Colors.white.withValues(alpha: 0.92),
                                                child: InkWell(
                                                  customBorder: const CircleBorder(),
                                                  onTap: () => _scrollBy(-368),
                                                  child: Container(
                                                    width: 34,
                                                    height: 34,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.grey.shade300),
                                                    ),
                                                    child: const Icon(Icons.chevron_left_rounded, size: 24, color: AppTheme.primaryColor),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Floating Right Scroll Overlay Button
                                          Positioned(
                                            right: 18,
                                            top: 0,
                                            bottom: 16,
                                            child: Center(
                                              child: Material(
                                                elevation: 4,
                                                shape: const CircleBorder(),
                                                color: Colors.white.withValues(alpha: 0.92),
                                                child: InkWell(
                                                  customBorder: const CircleBorder(),
                                                  onTap: () => _scrollBy(368),
                                                  child: Container(
                                                    width: 34,
                                                    height: 34,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.grey.shade300),
                                                    ),
                                                    child: const Icon(Icons.chevron_right_rounded, size: 24, color: AppTheme.primaryColor),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 80.ms),
                ),
              ],
            ),
    );
  }

  Widget _weekJumpChip(String label, int startDay) {
    return InkWell(
      onTap: () => _scrollToDay(startDay),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
        ),
      ),
    );
  }

  Widget _buildDayColumnHeader(int day) {
    final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    final isSunday = date.weekday == DateTime.sunday;
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateFormat('E').format(date).toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSunday ? Colors.red.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: isToday
              ? BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: Text(
            day.toString().padLeft(2, '0'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isToday ? Colors.white : (isSunday ? Colors.red.shade400 : Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rich Attendance Cell rendering both In (Clock-In/Login) and Out (Clock-Out/Logout) times simultaneously
class _AttendanceCell extends StatelessWidget {
  final DailyAttendanceRecord? record;
  final String staffName;
  final DateTime date;
  final VoidCallback onTap;

  const _AttendanceCell({
    required this.record,
    required this.staffName,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDate = DateTime(date.year, date.month, date.day);
    final isFuture = dayDate.isAfter(today);
    final isSunday = date.weekday == DateTime.sunday;
    final hasActivity = record != null && (record!.firstIn != null || record!.lastOut != null);

    if (!hasActivity) {
      if (isFuture) {
        return Container(
          width: 84,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          alignment: Alignment.center,
          child: Text(
            '—',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 16, fontWeight: FontWeight.w300),
          ),
        );
      }

      if (isSunday) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 84,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OFF',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Sunday',
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Past or current working day with no attendance -> Mark as LEAVE!
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 84,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2), // Soft rose/red
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LEAVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Absent',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final inTime = record!.firstIn;
    final outTime = record!.checkOutTime;
    final isActive = record!.isActive;
    final isAuto = record!.isAutoReconciled;

    // Appearance colors based on state
    Color cardBg = const Color(0xFFF8FAFC);
    Color borderColor = Colors.blueGrey.shade200;
    if (isActive) {
      cardBg = const Color(0xFFF0FDF4); // Soft emerald green
      borderColor = Colors.green.shade400;
    } else if (outTime != null) {
      cardBg = isAuto ? const Color(0xFFF0F7FF) : const Color(0xFFF8FAFC);
      borderColor = isAuto ? Colors.blue.shade200 : Colors.grey.shade300;
    } else {
      cardBg = const Color(0xFFFFFBEB);
      borderColor = Colors.amber.shade300;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 84,
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: isActive ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: (isActive ? Colors.green : Colors.black).withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: IN (Clock-In / Login)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'IN',
                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.green.shade900),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    inTime != null ? DateFormat('hh:mm a').format(inTime) : '--:--',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: inTime != null ? Colors.green.shade900 : Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            // Row 2: OUT (Clock-Out / Logout / Active)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.teal.shade100
                        : (outTime != null
                            ? (isAuto ? Colors.blue.shade100 : Colors.orange.shade100)
                            : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    isActive ? 'ACT' : 'OUT',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: isActive
                          ? Colors.teal.shade900
                          : (outTime != null
                              ? (isAuto ? Colors.blue.shade900 : Colors.orange.shade900)
                              : Colors.grey.shade600),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    isActive
                        ? 'Active'
                        : (outTime != null ? DateFormat('hh:mm a').format(outTime) : '--:--'),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.teal.shade800
                          : (outTime != null
                              ? (isAuto ? Colors.blue.shade900 : Colors.orange.shade900)
                              : Colors.grey.shade400),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Row 3: Duration string (if available)
            if (record?.durationStr != null) ...[
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '⏱ ${record!.durationStr}',
                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
