import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../services/supabase_backup_service.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  List<Map<String, dynamic>> _allRawSessions = [];
  List<Map<String, dynamic>> _allRawLogs = [];
  List<Map<String, dynamic>> _displaySessions = [];
  List<Map<String, dynamic>> _displayLogs = [];
  List<Map<String, dynamic>> _peakActivity = [];
  bool _isLoading = true;
  int _activeTab = 1; // Default to Logs (index 1) as seen in Security & Audit

  dynamic _selectedStaffKey;
  List<Map<String, dynamic>> _staffList = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Map<int, String> _idToNameMap = {};
  Map<String, String> _usernameToNameMap = {};
  Map<String, String> _emailToNameMap = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    await _fetchStaffList();
    await Future.wait([
      _fetchLogs(),
      _fetchSessions(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchStaffList() async {
    try {
      // 1. Fetch from Amplify
      List<amplify_models.Users> amplifyUsers = [];
      try {
        final req = ModelQueries.list(
          amplify_models.Users.classType,
          limit: 10000,
          authorizationMode: APIAuthorizationType.userPools,
        );
        final res = await Amplify.API.query(request: req).response;
        amplifyUsers = (res.data?.items ?? []).whereType<amplify_models.Users>().toList();
      } catch (e) {
        debugPrint('Amplify staff fetch fallback: $e');
        try {
          final req = ModelQueries.list(amplify_models.Users.classType, limit: 10000);
          final res = await Amplify.API.query(request: req).response;
          amplifyUsers = (res.data?.items ?? []).whereType<amplify_models.Users>().toList();
        } catch (_) {}
      }

      // 2. Fetch from Supabase
      List<Map<String, dynamic>> supabaseUsers = [];
      try {
        supabaseUsers = await SupabaseBackupService().getFullUsersData();
      } catch (e) {
        debugPrint('Supabase staff fetch error: $e');
      }

      // 3. Username to ID map from Supabase
      Map<String, int> usernameToId = {};
      try {
        usernameToId = await SupabaseBackupService().getUsernameToIdMap();
      } catch (_) {}

      // Build mapping structures
      final Map<int, String> idToName = {1: 'Master Admin'};
      final Map<String, String> usernameToName = {'admin': 'Master Admin'};
      final Map<String, String> emailToName = {'admin@cuc.local': 'Master Admin'};
      final Map<String, Map<String, dynamic>> unifiedStaffMap = {};

      // Process Supabase users
      for (var su in supabaseUsers) {
        final int? id = su['id'] is int ? su['id'] : int.tryParse(su['id']?.toString() ?? '');
        final String name = (su['name'] ?? su['username'] ?? '').toString().trim();
        final String username = (su['username'] ?? '').toString().trim().toLowerCase();
        final String email = (su['email'] ?? '').toString().trim().toLowerCase();
        if (name.isEmpty && username.isEmpty) continue;

        final displayName = (username == 'admin' || email == 'admin@cuc.local')
            ? 'Master Admin'
            : (name.isNotEmpty ? name : username);

        if (id != null) idToName[id] = displayName;
        if (username.isNotEmpty) usernameToName[username] = displayName;
        if (email.isNotEmpty) emailToName[email] = displayName;

        final key = username.isNotEmpty ? username : (email.isNotEmpty ? email : 'id_$id');
        unifiedStaffMap[key] = {
          'key': key,
          'name': displayName,
          'username': username,
          'email': email,
          'supabaseId': id,
          'amplifyId': null,
        };
      }

      // Merge Amplify users
      for (var u in amplifyUsers) {
        final name = (u.name ?? u.username ?? '').trim();
        final username = (u.username ?? '').trim().toLowerCase();
        final email = (u.email ?? '').trim().toLowerCase();
        if (name.isEmpty && username.isEmpty) continue;

        final displayName = (username == 'admin' || email == 'admin@cuc.local')
            ? 'Master Admin'
            : (name.isNotEmpty ? name : username);

        if (username.isNotEmpty) usernameToName[username] = displayName;
        if (email.isNotEmpty) emailToName[email] = displayName;

        final matchedSupabaseId = usernameToId[username] ?? usernameToId[email];
        if (matchedSupabaseId != null) {
          idToName[matchedSupabaseId] = displayName;
        }

        final key = username.isNotEmpty ? username : (email.isNotEmpty ? email : u.id);
        if (unifiedStaffMap.containsKey(key)) {
          unifiedStaffMap[key]!['amplifyId'] = u.id;
          if (unifiedStaffMap[key]!['name'] == null ||
              unifiedStaffMap[key]!['name'].toString().isEmpty ||
              unifiedStaffMap[key]!['name'] == username) {
            unifiedStaffMap[key]!['name'] = displayName;
          }
        } else {
          unifiedStaffMap[key] = {
            'key': key,
            'name': displayName,
            'username': username,
            'email': email,
            'supabaseId': matchedSupabaseId,
            'amplifyId': u.id,
          };
        }
      }

      final staffList = unifiedStaffMap.values.toList();
      staffList.sort((a, b) =>
          (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase()));

      if (mounted) {
        setState(() {
          _idToNameMap = idToName;
          _usernameToNameMap = usernameToName;
          _emailToNameMap = emailToName;
          _staffList = staffList;
        });
      }
    } catch (e) {
      debugPrint('Staff fetch error: $e');
    }
  }

  String _resolveStaffName({int? userId, String? details, String? username, String? targetId}) {
    // 1. Try extracting [User: ...] from details
    if (details != null && details.isNotEmpty) {
      final userMatch = RegExp(r'\[User:\s*([^\]]+)\]', caseSensitive: false).firstMatch(details);
      if (userMatch != null) {
        final tagUser = userMatch.group(1)?.trim() ?? '';
        if (tagUser.isNotEmpty) {
          final tagLower = tagUser.toLowerCase();
          if (tagLower == 'admin' || tagLower == 'admin@cuc.local') {
            return 'Master Admin';
          }
          if (_usernameToNameMap.containsKey(tagLower)) {
            return _usernameToNameMap[tagLower]!;
          }
          if (_emailToNameMap.containsKey(tagLower)) {
            return _emailToNameMap[tagLower]!;
          }
          return tagUser;
        }
      }
    }

    // 2. Try targetId if provided and looks like a staff name or username
    if (targetId != null && targetId.isNotEmpty) {
      final tLower = targetId.toLowerCase().trim();
      if (tLower != 'system' && tLower != 'null' && !tLower.startsWith('http') && tLower != 'unknown') {
        if (tLower == 'admin' || tLower == 'admin@cuc.local') {
          return 'Master Admin';
        }
        if (_usernameToNameMap.containsKey(tLower)) {
          return _usernameToNameMap[tLower]!;
        }
        if (_emailToNameMap.containsKey(tLower)) {
          return _emailToNameMap[tLower]!;
        }
        final staffMatch = _staffList.firstWhere(
          (s) => (s['name'] ?? '').toString().toLowerCase() == tLower || (s['username'] ?? '').toString().toLowerCase() == tLower,
          orElse: () => {},
        );
        if (staffMatch.isNotEmpty && staffMatch['name'] != null) {
          return staffMatch['name'].toString();
        }
        return targetId;
      }
    }

    // 3. Try looking up numeric userId
    if (userId != null && userId != 0) {
      if (userId == 1) return 'Master Admin';
      if (_idToNameMap.containsKey(userId)) {
        return _idToNameMap[userId]!;
      }
    }

    // 4. Try username if provided
    if (username != null && username.isNotEmpty) {
      final uLower = username.toLowerCase().trim();
      if (uLower == 'admin' || uLower == 'admin@cuc.local') {
        return 'Master Admin';
      }
      if (_usernameToNameMap.containsKey(uLower)) {
        return _usernameToNameMap[uLower]!;
      }
      if (_emailToNameMap.containsKey(uLower)) {
        return _emailToNameMap[uLower]!;
      }
      return username;
    }

    return 'System';
  }

  Future<void> _fetchLogs() async {
    try {
      // 1. Fetch from Amplify
      List<amplify_models.ActivityLogs> amplifyLogs = [];
      try {
        final req = ModelQueries.list(
          amplify_models.ActivityLogs.classType,
          limit: 10000,
          authorizationMode: APIAuthorizationType.userPools,
        );
        final res = await Amplify.API.query(request: req).response;
        amplifyLogs = (res.data?.items ?? []).whereType<amplify_models.ActivityLogs>().toList();
      } catch (e) {
        debugPrint('Amplify logs fetch error: $e');
        try {
          final req = ModelQueries.list(amplify_models.ActivityLogs.classType, limit: 10000);
          final res = await Amplify.API.query(request: req).response;
          amplifyLogs = (res.data?.items ?? []).whereType<amplify_models.ActivityLogs>().toList();
        } catch (_) {}
      }

      // 2. Fetch from Supabase
      List<Map<String, dynamic>> supabaseLogs = [];
      try {
        supabaseLogs = await SupabaseBackupService().getActivityLogs();
      } catch (e) {
        debugPrint('Supabase logs fetch error: $e');
      }

      // 3. Convert to unified list and deduplicate
      final List<Map<String, dynamic>> unifiedLogs = [];
      final Set<String> seenIds = {};

      for (var l in amplifyLogs) {
        final id = l.id;
        seenIds.add(id);
        final String? displayTime = (l.created_at != null && l.created_at!.isNotEmpty)
            ? l.created_at
            : l.createdAt?.getDateTimeInUtc().add(const Duration(hours: 5, minutes: 30)).toIso8601String();
        final resolvedName = _resolveStaffName(
          userId: l.user_id,
          details: l.details,
          targetId: l.target_id,
        );
        unifiedLogs.add({
          'id': id,
          'user_id': l.user_id,
          'action': l.action ?? '',
          'target_type': l.target_type ?? '',
          'target_id': l.target_id ?? '',
          'details': l.details ?? '',
          'created_at': displayTime,
          'user_name': resolvedName,
        });
      }

      for (var s in supabaseLogs) {
        final id = s['id']?.toString() ?? '';
        if (id.isNotEmpty && seenIds.contains(id)) continue;
        if (id.isNotEmpty) seenIds.add(id);

        final int? uid = s['user_id'] is int ? s['user_id'] : int.tryParse(s['user_id']?.toString() ?? '');
        final displayTime = s['created_at']?.toString() ?? s['timestamp']?.toString();
        final details = s['details']?.toString() ?? '';
        final username = s['username']?.toString();
        final targetId = s['target_id']?.toString();
        final resolvedName = _resolveStaffName(
          userId: uid,
          details: details,
          username: username,
          targetId: targetId,
        );

        unifiedLogs.add({
          'id': id,
          'user_id': uid,
          'action': s['action']?.toString() ?? '',
          'target_type': s['target_type']?.toString() ?? '',
          'target_id': targetId ?? '',
          'details': details,
          'created_at': displayTime,
          'user_name': resolvedName,
        });
      }

      // Chronological forward pass: resolve any 'LOGOUT' showing 'System' to the preceding active staff member
      unifiedLogs.sort((a, b) {
        final tA = a['created_at'] != null ? parseToIST(a['created_at'].toString()) : DateTime(2000);
        final tB = b['created_at'] != null ? parseToIST(b['created_at'].toString()) : DateTime(2000);
        return tA.compareTo(tB);
      });

      String lastActiveStaff = '';
      for (var log in unifiedLogs) {
        final action = (log['action'] ?? '').toString().toUpperCase();
        final currentStaff = (log['user_name'] ?? '').toString();

        if (action == 'LOGIN' && currentStaff.isNotEmpty && currentStaff != 'System') {
          lastActiveStaff = currentStaff;
        } else if (action == 'LOGOUT') {
          if ((currentStaff.isEmpty || currentStaff == 'System') && lastActiveStaff.isNotEmpty) {
            log['user_name'] = lastActiveStaff;
          }
          lastActiveStaff = '';
        } else if (currentStaff.isNotEmpty && currentStaff != 'System') {
          lastActiveStaff = currentStaff;
        }
      }

      // Sort chronological descending (most recent first) for UI display
      unifiedLogs.sort((a, b) {
        final tA = a['created_at'] != null ? parseToIST(a['created_at'].toString()) : DateTime(2000);
        final tB = b['created_at'] != null ? parseToIST(b['created_at'].toString()) : DateTime(2000);
        return tB.compareTo(tA);
      });

      _allRawLogs = unifiedLogs;
      _applyFilter();
    } catch (e) {
      debugPrint('Logs fetch error: $e');
    }
  }

  Future<void> _fetchSessions() async {
    try {
      List<amplify_models.UserSessions> fetchedSessions = [];
      try {
        final req = ModelQueries.list(
          amplify_models.UserSessions.classType,
          limit: 10000,
          authorizationMode: APIAuthorizationType.userPools,
        );
        final res = await Amplify.API.query(request: req).response;
        fetchedSessions = (res.data?.items ?? []).whereType<amplify_models.UserSessions>().toList();
      } catch (_) {
        final req = ModelQueries.list(amplify_models.UserSessions.classType, limit: 10000);
        final res = await Amplify.API.query(request: req).response;
        fetchedSessions = (res.data?.items ?? []).whereType<amplify_models.UserSessions>().toList();
      }

      fetchedSessions.sort((a, b) {
        final dtA = parseToIST(a.login_time);
        final dtB = parseToIST(b.login_time);
        return dtB.compareTo(dtA);
      });

      _allRawSessions = fetchedSessions.map((r) {
        final resolvedName = _resolveStaffName(userId: r.user_id);
        return {
          'id': r.id,
          'user_id': r.user_id,
          'login_time': r.login_time,
          'logout_time': r.logout_time,
          'is_active': r.is_active,
          'user_name': resolvedName,
          'role': null,
        };
      }).toList();

      _applyFilter();
    } catch (e) {
      debugPrint('Sessions error: $e');
    }
  }

  void _applyFilter() {
    Map<String, dynamic>? selectedStaff;
    if (_selectedStaffKey != null) {
      selectedStaff = _staffList.firstWhere(
        (s) => s['key'] == _selectedStaffKey,
        orElse: () => {},
      );
    }

    final query = _searchQuery.trim().toLowerCase();

    // Filter Logs
    _displayLogs = _allRawLogs.where((l) {
      if (selectedStaff != null && selectedStaff.isNotEmpty) {
        if (!_matchesStaff(l, selectedStaff)) return false;
      }
      if (query.isNotEmpty) {
        final uName = (l['user_name'] ?? '').toString().toLowerCase();
        final action = (l['action'] ?? '').toString().toLowerCase();
        final target = (l['target_type'] ?? '').toString().toLowerCase();
        final details = (l['details'] ?? '').toString().toLowerCase();
        if (!uName.contains(query) &&
            !action.contains(query) &&
            !target.contains(query) &&
            !details.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Filter Sessions
    _displaySessions = _allRawSessions.where((s) {
      if (selectedStaff != null && selectedStaff.isNotEmpty) {
        if (!_matchesStaff(s, selectedStaff)) return false;
      }
      if (query.isNotEmpty) {
        final uName = (s['user_name'] ?? '').toString().toLowerCase();
        if (!uName.contains(query)) return false;
      }
      return true;
    }).toList();

    _calculatePeakActivity();
    if (mounted) setState(() {});
  }

  bool _matchesStaff(Map<String, dynamic> item, Map<String, dynamic> staff) {
    final staffName = (staff['name'] ?? '').toString().toLowerCase();
    final staffUsername = (staff['username'] ?? '').toString().toLowerCase();
    final staffEmail = (staff['email'] ?? '').toString().toLowerCase();
    final staffSupabaseId = staff['supabaseId'];

    // 1. Match by numeric user_id
    final itemUserId = item['user_id'];
    if (staffSupabaseId != null && itemUserId != null) {
      if (itemUserId == staffSupabaseId || itemUserId.toString() == staffSupabaseId.toString()) {
        return true;
      }
    }

    // 2. Match by user_name
    final itemUserName = (item['user_name'] ?? '').toString().toLowerCase();
    if (staffName.isNotEmpty && itemUserName == staffName) return true;
    if (staffUsername.isNotEmpty && itemUserName == staffUsername) return true;
    if (staffEmail.isNotEmpty && itemUserName == staffEmail) return true;

    // Special case for Master Admin / admin
    if ((staffUsername == 'admin' || staffName.contains('admin')) &&
        (itemUserName == 'master admin' || itemUserName.contains('admin'))) {
      return true;
    }

    // 3. Match by details tags
    final details = (item['details'] ?? '').toString().toLowerCase();
    if (staffName.isNotEmpty && details.contains('[user: $staffName]')) return true;
    if (staffUsername.isNotEmpty && details.contains('[user: $staffUsername]')) return true;
    if (staffEmail.isNotEmpty && details.contains(staffEmail)) return true;

    return false;
  }

  void _calculatePeakActivity() {
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
    final Map<int, int> hoursMap = {};
    for (var l in _displayLogs) {
      final timeStr = l['created_at']?.toString();
      if (timeStr != null) {
        final dt = parseToIST(timeStr);
        if (dt.isAfter(twentyFourHoursAgo)) {
          hoursMap[dt.hour] = (hoursMap[dt.hour] ?? 0) + 1;
        }
      }
    }
    _peakActivity = hoursMap.entries.map((e) => <String, dynamic>{'hour': e.key, 'count': e.value}).toList();
  }

  static DateTime parseToIST(String? ts) {
    if (ts == null || ts.isEmpty) return DateTime.now();
    try {
      // In CUC, activity logs and user sessions are generated using DateTime.now()
      // which records literal Indian Standard Time (IST) wall-clock numbers (e.g. 09:18:30).
      // Remote databases (PostgreSQL timestamptz / Amplify) append '+00:00' or 'Z' to these numbers.
      // Stripping the UTC offset ensures the true Indian Standard Time is displayed without an artificial +5:30 shift.
      String clean = ts.trim();
      if (clean.contains('+')) {
        clean = clean.split('+')[0];
      }
      if (clean.endsWith('Z') || clean.endsWith('z')) {
        clean = clean.substring(0, clean.length - 1);
      }
      final parsed = DateTime.tryParse(clean);
      if (parsed != null) {
        return DateTime(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
          parsed.millisecond,
        );
      }
      return DateTime.parse(ts);
    } catch (_) {
      return DateTime.now();
    }
  }

  String _formatDuration(DateTime login, DateTime? logout) {
    final end = logout ?? DateTime.now();
    final diff = end.difference(login);
    if (diff.isNegative) return '0m';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 16,
                spacing: 16,
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tabButton(0, 'Sessions', Icons.history_toggle_off_rounded),
                        _tabButton(1, 'Logs', Icons.assignment_rounded),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildSearchField(),
                      _buildStaffDropdown(),
                      IconButton(
                        onPressed: _fetchData,
                        icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withAlpha(20),
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (isWide && _activeTab == 1) _buildPeakActivityCard() else const SizedBox.shrink(),
              if (isWide && _activeTab == 1) const SizedBox(height: 24),

              SizedBox(
                height: 600,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _activeTab == 0
                        ? _buildSessionsList(isWide)
                        : _buildLogsList(isWide),
              ),
            ],
          ),
        ).animate().fadeIn();
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: 200,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() => _searchQuery = val);
          _applyFilter();
        },
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search logs...',
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.mutedTextColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _applyFilter();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStaffDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: _selectedStaffKey,
          hint: const Text('All Staff', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryColor),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All Staff', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            ..._staffList.map((s) => DropdownMenuItem<dynamic>(
                  value: s['key'],
                  child: Text(s['name'] ?? 'Unknown', style: const TextStyle(fontSize: 13)),
                )),
          ],
          onChanged: (val) {
            setState(() => _selectedStaffKey = val);
            _applyFilter();
          },
        ),
      ),
    );
  }

  Widget _tabButton(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppTheme.primaryColor : AppTheme.mutedTextColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.mutedTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList(bool isWide) {
    if (_displaySessions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                _selectedStaffKey != null ? 'No sessions found for selected staff member' : 'No user sessions recorded',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          if (isWide)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text('STAFF MEMBER',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('LOGIN TIME',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('LOGOUT TIME',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('DURATION',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('STATUS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                ],
              ),
            ),
          if (isWide) const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Expanded(
            child: ListView.builder(
              itemCount: _displaySessions.length,
              itemBuilder: (context, index) {
                final s = _displaySessions[index];

                final loginTime = parseToIST(s['login_time']?.toString());
                final logoutTime = s['logout_time'] != null ? parseToIST(s['logout_time']?.toString()) : null;
                final isStale = DateTime.now().difference(loginTime).inHours >= 16;
                final isActive = (s['is_active'] == true) && (logoutTime == null) && !isStale;
                final duration = _formatDuration(loginTime, logoutTime ?? (isStale ? loginTime : null));

                final userColor = Colors.primaries[s['user_name'].toString().hashCode % Colors.primaries.length];

                if (!isWide) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: userColor.withValues(alpha: 0.15),
                      child: Text(
                        (s['user_name']?.toString().isNotEmpty == true) ? s['user_name'][0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: userColor),
                      ),
                    ),
                    title: Text(s['user_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${DateFormat('dd MMM, HH:mm').format(loginTime)} • $duration',
                        style: const TextStyle(fontSize: 12, color: AppTheme.mutedTextColor)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'OFFLINE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.grey),
                      ),
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: userColor.withValues(alpha: 0.15),
                              child: Text(
                                (s['user_name']?.toString().isNotEmpty == true) ? s['user_name'][0].toUpperCase() : '?',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: userColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s['user_name'] ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(loginTime),
                          style: const TextStyle(fontSize: 13, color: AppTheme.textColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          logoutTime != null ? DateFormat('dd MMM yyyy, hh:mm a').format(logoutTime) : '--',
                          style: TextStyle(
                            fontSize: 13,
                            color: logoutTime != null ? AppTheme.textColor.withValues(alpha: 0.7) : Colors.grey.shade400,
                            fontStyle: logoutTime == null ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(duration, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isActive ? Colors.green.withValues(alpha: 0.3) : Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? Colors.green : Colors.grey.shade500),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isActive ? 'ACTIVE' : 'OFFLINE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildLogsList(bool isWide) {
    if (_displayLogs.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                _selectedStaffKey != null ? 'No logs found for selected staff member' : 'No activity logs found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          if (isWide)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text('STAFF MEMBER',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('ACTION',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('TARGET',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('DETAILS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('TIME',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor)),
                  ),
                ],
              ),
            ),
          if (isWide) const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Expanded(
            child: ListView.builder(
              itemCount: _displayLogs.length,
              itemBuilder: (context, index) {
                final l = _displayLogs[index];

                final time = parseToIST(l['created_at']?.toString());

                Color actionColor = Colors.blue;
                final act = l['action'].toString();
                if (act.contains('DELETE')) actionColor = Colors.red;
                if (act.contains('CREATE')) actionColor = Colors.green;
                if (act.contains('UPDATE') || act.contains('STATUS')) actionColor = Colors.orange;

                final userColor = Colors.primaries[l['user_name'].toString().hashCode % Colors.primaries.length];

                if (!isWide) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: actionColor.withValues(alpha: 0.15),
                      child: Icon(_getLogIcon(l['target_type']), color: actionColor, size: 18),
                    ),
                    title: Text(l['user_name'] ?? 'System', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l['action']} • ${l['target_type']}'),
                        Text(l['details'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
                      ],
                    ),
                    trailing: Text(DateFormat('HH:mm').format(time), style: const TextStyle(fontSize: 11)),
                  );
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: userColor.withValues(alpha: 0.15),
                              child: Text(
                                (l['user_name']?.toString().isNotEmpty == true) ? l['user_name'][0].toUpperCase() : '?',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: userColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l['user_name'] ?? 'System',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: actionColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: actionColor.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            l['action'],
                            style: TextStyle(color: actionColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(l['target_type'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          l['details'] ?? '',
                          style: const TextStyle(fontSize: 13, color: AppTheme.mutedTextColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(time),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.right,
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
    );
  }

  Widget _buildPeakActivityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Peak Activity (Last 24h)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${_displayLogs.length} Actions Logged', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (i) {
                final activity = (_peakActivity as List).firstWhere(
                  (p) => (double.tryParse(p['hour'].toString()) ?? -1).toInt() == i,
                  orElse: () => <String, dynamic>{'count': 0},
                ) as Map<String, dynamic>;
                final count = int.tryParse(activity['count'].toString()) ?? 0;
                final maxHeight = _peakActivity.isEmpty
                    ? 1
                    : _peakActivity.fold(1, (max, p) => int.parse(p['count'].toString()) > max ? int.parse(p['count'].toString()) : max);
                final heightFactor = (count / maxHeight).clamp(0.1, 1.0);

                return Expanded(
                  child: Tooltip(
                    message: '$i:00 - $count actions',
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 12,
                        height: count > 0 ? (100 * heightFactor) : 4.0,
                        decoration: BoxDecoration(
                          color: count > 0
                              ? AppTheme.primaryColor.withValues(alpha: heightFactor * 0.7 + 0.3)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
              Text('12:00', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
              Text('23:59', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLogIcon(String? type) {
    switch (type) {
      case 'Invoice':
        return Icons.receipt_long_rounded;
      case 'Client':
        return Icons.person_rounded;
      case 'Work':
        return Icons.work_rounded;
      case 'Task':
        return Icons.task_alt_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
