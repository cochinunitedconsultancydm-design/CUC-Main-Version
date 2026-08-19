import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ModelProvider.dart';
import '../theme.dart';
import '../widgets/premium_app_bar.dart';

class HrAttendanceChartScreen extends StatefulWidget {
  const HrAttendanceChartScreen({Key? key}) : super(key: key);

  @override
  State<HrAttendanceChartScreen> createState() => _HrAttendanceChartScreenState();
}

class _HrAttendanceChartScreenState extends State<HrAttendanceChartScreen> {
  bool _isLoading = true;
  List<Users> _staffList = [];
  List<String> _dates = [];
  Map<String, Map<String, StaffAttendance>> _attendanceByDate = {};
  
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    try {
      // 1. Get staff
      final uReq = ModelQueries.list(Users.classType, limit: 10000);
      final uRes = await Amplify.API.query(request: uReq).response;
      var usersResRaw = (uRes.data?.items ?? []).whereType<Users>().toList() ?? [];
      
      final Map<String, Users> uniqueUsers = {};
      for (var u in usersResRaw) {
        if (u.role == 'client' || u.role == 'admin') continue;
        final name = (u.name ?? '').toLowerCase().trim();
        if (name.isEmpty) continue;
        var firstName = name.split(' ')[0];
        if (firstName == 'jithasree') firstName = 'jitha';
        
        if (uniqueUsers.containsKey(firstName)) {
          final existing = uniqueUsers[firstName]!;
          if (u.id.contains('-') && !existing.id.contains('-')) {
            uniqueUsers[firstName] = u;
          }
        } else {
          uniqueUsers[firstName] = u;
        }
      }
      final staffList = uniqueUsers.values.toList();
      staffList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

      // 2. Get attendance for the current month up to today
      final now = DateTime.now();
      final currentDay = now.day;
      
      List<String> dates = [];
      Map<String, Map<String, StaffAttendance>> attendanceByDate = {};
      List<Future<void>> futures = [];
      
      for (int i = 1; i <= currentDay; i++) {
        final date = DateTime(now.year, now.month, i);
        // Format to yyyy-mm-dd safely
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        dates.add(dateStr);
        
        futures.add(() async {
          try {
            final aReq = ModelQueries.list(
              StaffAttendance.classType,
              where: StaffAttendance.ATTENDANCE_DATE.eq(dateStr)
            , limit: 10000);
            final aRes = await Amplify.API.query(request: aReq).response;
            var attendanceRes = (aRes.data?.items ?? []).whereType<StaffAttendance>().toList() ?? [];
            
            final Map<String, StaffAttendance> dailyMap = {};
            for (var a in attendanceRes) {
              dailyMap[a.user_id.toString()] = a;
            }
            attendanceByDate[dateStr] = dailyMap;
          } catch (e) {
            debugPrint('Error fetching attendance for $dateStr: $e');
          }
        }());
      }
      await Future.wait(futures);

      if (mounted) {
        setState(() {
          _staffList = staffList;
          _dates = dates.reversed.toList();
          _attendanceByDate = attendanceByDate;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading chart data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: const PremiumAppBar(
        title: Text('Attendance Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _staffList.isEmpty
              ? const Center(child: Text('No staff found.'))
              : _buildTable(),
    );
  }

  Widget _buildTable() {
    return Container(
      margin: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                scrollDirection: Axis.vertical,
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith((states) => AppTheme.primaryColor.withOpacity(0.05)),
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 60,
                    columns: [
                      const DataColumn(label: Text('Staff Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor))),
                      for (var date in _dates)
                        DataColumn(
                          label: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEE').format(DateTime.parse(date)),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMM dd').format(DateTime.parse(date)),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                    ],
                    rows: [
                      for (var staff in _staffList)
                        DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                    child: Text(staff.name?[0].toUpperCase() ?? '?', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    staff.name ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                            ),
                            for (var date in _dates)
                              (() {
                                final dateObj = DateTime.parse(date);
                                final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                final isFuture = dateObj.isAfter(today);
                                
                                return DataCell(
                                  Center(
                                    child: isFuture
                                        ? Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
                                            child: const Icon(Icons.remove, color: Colors.grey, size: 20),
                                          )
                                        : _attendanceByDate[date]?.containsKey(staff.id.toString()) == true
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${_attendanceByDate[date]![staff.id.toString()]!.check_in_time ?? '--'} - ${_attendanceByDate[date]![staff.id.toString()]!.check_out_time ?? '--'}',
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                                                  ),
                                                ],
                                              )
                                            : Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                                                child: const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                                              ),
                                  ),
                                );
                              })(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
        ),
      ),
    );
  }
}
