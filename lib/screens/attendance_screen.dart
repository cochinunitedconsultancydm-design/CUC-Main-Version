import 'package:flutter/material.dart';
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
  final List<AttendanceEvent> events;

  DailyAttendanceRecord({
    required this.staffKey,
    required this.day,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.isActive = false,
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

  @override
  void initState() {
    super.initState();
    _loadData();
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

      // Fetch staff from Supabase (fallback/complement)
      List<Map<String, dynamic>> sbUsers = [];
      try {
        sbUsers = await SupabaseBackupService().getFullUsersData();
      } catch (e) {
        debugPrint('Supabase getFullUsersData error: $e');
      }

      Set<String> deletedKeys = {};
      try {
        final prefs = await SharedPreferences.getInstance();
        deletedKeys = (prefs.getStringList('deleted_staff_keys') ?? [])
            .map((k) => k.toLowerCase().trim())
            .toSet();
      } catch (_) {}

      // Deduplicate and filter staff
      final Map<String, amplify_models.Users> uniqueUsers = {};
      for (var u in usersRaw) {
        if ((u.role ?? '').toLowerCase().trim() == 'deleted') continue;
        final uid = u.id.toLowerCase().trim();
        final uname = (u.username ?? '').toLowerCase().trim();
        final uemail = (u.email ?? '').toLowerCase().trim();
        final uNameStr = (u.name ?? '').toLowerCase().trim();
        if (deletedKeys.contains(uid) ||
            (uname.isNotEmpty && deletedKeys.contains(uname)) ||
            (uemail.isNotEmpty && deletedKeys.contains(uemail)) ||
            (uNameStr.isNotEmpty && deletedKeys.contains(uNameStr))) {
          continue;
        }

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

      // Merge any staff present in Supabase but not in Amplify
      for (var su in sbUsers) {
        final role = (su['role'] ?? '').toString().toLowerCase().trim();
        if (role == 'deleted') continue;
        final name = (su['name'] ?? su['username'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        final username = (su['username'] ?? '').toString().trim().toLowerCase();
        final email = (su['email'] ?? '').toString().trim().toLowerCase();
        final idStr = (su['id'] ?? '').toString().trim();

        if (deletedKeys.contains(idStr.toLowerCase()) ||
            (username.isNotEmpty && deletedKeys.contains(username)) ||
            (email.isNotEmpty && deletedKeys.contains(email)) ||
            deletedKeys.contains(name.toLowerCase())) {
          continue;
        }

        var key = (username.isNotEmpty ? username : (email.isNotEmpty ? email : name)).toLowerCase();
        if (key.contains('jithasree')) key = 'jitha';

        if (!uniqueUsers.containsKey(key)) {
          uniqueUsers[key] = amplify_models.Users(
            id: idStr.isNotEmpty ? idStr : key,
            name: name,
            username: username.isNotEmpty ? username : null,
            email: email.isNotEmpty ? email : null,
            role: role.isNotEmpty ? role : 'Staff',
          );
        }
      }

      _allStaff = uniqueUsers.values.toList();
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
      final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);

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
        debugPrint('Amplify UserSessions query error: $e');
      }

      // D: Supabase UserSessions
      List<Map<String, dynamic>> sbSessions = [];
      try {
        sbSessions = await SupabaseBackupService().getUserSessions(monthStr);
      } catch (e) {
        debugPrint('Supabase getUserSessions error: $e');
      }

      // 5. Construct Unified Matrix
      _attendanceMatrix = _buildMatrix(
        lookupToStaffKey: lookupToStaffKey,
        ampAttendance: ampAttendance,
        sbAttendance: sbAttendance,
        ampSessions: ampSessions,
        sbSessions: sbSessions,
      );

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
  }) {
    final Map<String, Map<int, DailyAttendanceRecord>> matrix = {};
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;

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

    // Sort events inside each record
    for (var userMap in matrix.values) {
      for (var record in userMap.values) {
        record.events.sort((a, b) => a.time.compareTo(b.time));
      }
    }

    return matrix;
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
                        Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No Attendance Recorded', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'No manual clock-in or application login session was recorded for this day.',
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
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
      for (var staff in _allStaff) {
        final staffKey = _staffKey(staff);
        final rec = _attendanceMatrix[staffKey]?[now.day];
        if (rec != null && rec.firstIn != null) presentTodayCount++;
        if (rec != null && rec.isActive) activeNowCount++;
      }
    }

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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      const SizedBox(width: 32),
                      // Search Box
                      Expanded(
                        child: SizedBox(
                          height: 40,
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
                      const SizedBox(width: 24),
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

                // Sub-header Summary & Legend
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
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
                      if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) ...[
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
                      ],
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
                          Text('Clock-In / Login', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text('OUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                          ),
                          const SizedBox(width: 4),
                          Text('Clock-Out / Logout', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          const SizedBox(width: 14),
                          Icon(Icons.touch_app_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text('Click cell for full breakdown', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Data Matrix Table
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 10,
                              headingRowColor: WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.05)),
                              dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                if (states.contains(WidgetState.hovered)) return AppTheme.primaryColor.withValues(alpha: 0.02);
                                return null;
                              }),
                              dataRowMaxHeight: 76,
                              dataRowMinHeight: 76,
                              dividerThickness: 1,
                              horizontalMargin: 20,
                              columns: [
                                // Staff Member Column
                                const DataColumn(
                                  label: SizedBox(
                                    width: 200,
                                    child: Text(
                                      'STAFF MEMBER',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54, letterSpacing: 1.1),
                                    ),
                                  ),
                                ),
                                // Days Columns (01..31)
                                for (int day = 1; day <= daysInMonth; day++) ...[
                                  DataColumn(
                                    label: Container(
                                      width: 90,
                                      alignment: Alignment.center,
                                      child: _buildDayColumnHeader(day),
                                    ),
                                  ),
                                ],
                              ],
                              rows: filteredStaff.map((user) {
                                final staffKey = _staffKey(user);
                                final userRecords = _attendanceMatrix[staffKey] ?? {};
                                final daysPresent = userRecords.values.where((r) => r.firstIn != null).length;

                                return DataRow(
                                  cells: [
                                    // Staff Name Cell
                                    DataCell(
                                      SizedBox(
                                        width: 200,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 17,
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
                                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Colors.black87),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '$daysPresent days present',
                                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Attendance Days Cells
                                    for (int day = 1; day <= daysInMonth; day++)
                                      DataCell(
                                        Container(
                                          width: 90,
                                          alignment: Alignment.center,
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
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
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
    final hasActivity = record != null && (record!.firstIn != null || record!.lastOut != null);

    if (!hasActivity) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 86,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          alignment: Alignment.center,
          child: Text(
            '—',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18, fontWeight: FontWeight.w300),
          ),
        ),
      );
    }

    final inTime = record!.firstIn;
    final outTime = record!.lastOut;
    final isActive = record!.isActive;

    // Appearance colors based on state
    Color cardBg = const Color(0xFFF8FAFC);
    Color borderColor = Colors.blueGrey.shade200;
    if (isActive) {
      cardBg = const Color(0xFFF0FDF4); // Soft emerald green
      borderColor = Colors.green.shade400;
    } else if (outTime != null) {
      cardBg = const Color(0xFFF8FAFC); // Clean slate
      borderColor = Colors.grey.shade300;
    } else {
      cardBg = const Color(0xFFFFFBEB); // Soft amber for unclosed session
      borderColor = Colors.amber.shade300;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 86,
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
                        : (outTime != null ? Colors.orange.shade100 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    isActive ? 'ACT' : 'OUT',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: isActive
                          ? Colors.teal.shade900
                          : (outTime != null ? Colors.orange.shade900 : Colors.grey.shade600),
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
                          : (outTime != null ? Colors.orange.shade900 : Colors.grey.shade400),
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
