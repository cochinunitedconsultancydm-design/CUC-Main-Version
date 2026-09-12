import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../services/supabase_backup_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = true;
  
  List<amplify_models.Users> _allStaff = [];
  List<amplify_models.StaffAttendance> _monthlyAttendance = [];
  Map<String, int> _usernameToIdMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Load user mappings
      _usernameToIdMap = await SupabaseBackupService().getUsernameToIdMap();

      // Fetch all staff
      final uReq = ModelQueries.list(amplify_models.Users.classType, limit: 10000, authorizationMode: APIAuthorizationType.userPools);
      final uRes = await Amplify.API.query(request: uReq).response;
      final usersRaw = (uRes.data?.items ?? []).whereType<amplify_models.Users>().toList();
      
      // Deduplicate and filter staff
      final Map<String, amplify_models.Users> uniqueUsers = {};
      for (var u in usersRaw) {
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
      
      _allStaff = uniqueUsers.values.toList();
      _allStaff.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

      // Fetch attendance for selected month
      final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);
      final attReq = ModelQueries.list(
        amplify_models.StaffAttendance.classType, 
        where: amplify_models.StaffAttendance.ATTENDANCE_DATE.contains(monthStr),
        limit: 10000,
        authorizationMode: APIAuthorizationType.userPools
      );
      final attRes = await Amplify.API.query(request: attReq).response;
      _monthlyAttendance = (attRes.data?.items ?? []).whereType<amplify_models.StaffAttendance>().toList();

    } catch (e) {
      debugPrint('Error loading attendance data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load data: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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

  int? _getUserId(amplify_models.Users user) {
    final username = user.username?.toLowerCase().trim() ?? '';
    final email = user.email?.toLowerCase().trim() ?? '';
    if (_usernameToIdMap.containsKey(username)) return _usernameToIdMap[username];
    if (_usernameToIdMap.containsKey(email)) return _usernameToIdMap[email];
    return null;
  }

  Map<int, Map<int, amplify_models.StaffAttendance>> _buildMatrix() {
    Map<int, Map<int, amplify_models.StaffAttendance>> matrix = {};
    for (var att in _monthlyAttendance) {
      if (att.user_id != null && att.attendance_date != null) {
        final dateParts = att.attendance_date!.split('-');
        if (dateParts.length == 3) {
          final day = int.tryParse(dateParts[2]);
          if (day != null) {
            matrix.putIfAbsent(att.user_id!, () => {})[day] = att;
          }
        }
      }
    }
    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    final monthDisplayStr = DateFormat('MMMM yyyy').format(_selectedMonth);
    final daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final matrix = _buildMatrix();

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
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Monthly Register', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Showing detailed attendance for $monthDisplayStr', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectMonth(context),
                      icon: const Icon(Icons.calendar_month_rounded, size: 20),
                      label: Text(monthDisplayStr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        foregroundColor: AppTheme.primaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1),

              // Data Matrix
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
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
                            columnSpacing: 16,
                            headingRowColor: WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.05)),
                            dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) return AppTheme.primaryColor.withValues(alpha: 0.02);
                              return null;
                            }),
                            dataRowMaxHeight: 70,
                            dataRowMinHeight: 70,
                            dividerThickness: 1,
                            horizontalMargin: 24,
                            columns: [
                              DataColumn(
                                label: Container(
                                  width: 180,
                                  alignment: Alignment.centerLeft,
                                  child: const Text('STAFF MEMBER', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black45, letterSpacing: 1.2)),
                                ),
                              ),
                              for (int day = 1; day <= daysInMonth; day++)
                                DataColumn(
                                  label: Container(
                                    width: 60,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(DateFormat('E').format(DateTime(_selectedMonth.year, _selectedMonth.month, day)).toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                                        const SizedBox(height: 2),
                                        Text(day.toString().padLeft(2, '0'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                            rows: _allStaff.map((user) {
                              final userId = _getUserId(user);
                              final userRecords = matrix[userId] ?? {};

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Container(
                                      width: 180,
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                            child: Text(user.name?[0] ?? '?', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(user.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  for (int day = 1; day <= daysInMonth; day++)
                                    DataCell(
                                      Container(
                                        width: 60,
                                        alignment: Alignment.center,
                                        child: _AttendanceCell(att: userRecords[day]),
                                      )
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ),
            ],
          ),
    );
  }
}


class _AttendanceCell extends StatefulWidget {
  final amplify_models.StaffAttendance? att;

  const _AttendanceCell({Key? key, required this.att}) : super(key: key);

  @override
  State<_AttendanceCell> createState() => _AttendanceCellState();
}

class _AttendanceCellState extends State<_AttendanceCell> {
  bool _showCheckOut = false;

  @override
  Widget build(BuildContext context) {
    if (widget.att == null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.remove, size: 16, color: Colors.grey.shade400),
      );
    }

    String inTime = '';
    String outTime = '';
    Color statusColor = Colors.orange;
    Color bgColor = Colors.orange.shade50;

    if (widget.att!.check_in_time != null) {
      inTime = DateFormat('HH:mm').format(DateTime.parse(widget.att!.check_in_time!).toLocal());
    }
    if (widget.att!.check_out_time != null) {
      outTime = DateFormat('HH:mm').format(DateTime.parse(widget.att!.check_out_time!).toLocal());
      statusColor = Colors.green;
      bgColor = Colors.green.shade50;
    }

    final hasBoth = inTime.isNotEmpty && outTime.isNotEmpty;
    final displayTime = _showCheckOut && outTime.isNotEmpty ? outTime : inTime;
    final isShowingCheckOut = _showCheckOut && outTime.isNotEmpty;
    final displayIcon = isShowingCheckOut ? Icons.logout_rounded : Icons.login_rounded;

    return GestureDetector(
      onTap: () {
        if (hasBoth) {
          setState(() {
            _showCheckOut = !_showCheckOut;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(color: statusColor.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (displayTime.isNotEmpty) 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(displayIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(displayTime, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor.withValues(alpha: 0.9))),
                ],
              ),
            if (inTime.isEmpty && outTime.isEmpty) 
              const Icon(Icons.help_outline, size: 16, color: Colors.grey),
            if (hasBoth)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: !_showCheckOut ? statusColor : statusColor.withValues(alpha: 0.3))),
                    const SizedBox(width: 4),
                    Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: _showCheckOut ? statusColor : statusColor.withValues(alpha: 0.3))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

