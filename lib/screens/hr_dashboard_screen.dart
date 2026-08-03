import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/notification_bell.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import '../widgets/premium_app_bar.dart';

// HR Specific Screens
import 'staff_management_screen.dart';
import 'staff_chat_list_screen.dart';
import '../services/backup_aware_api.dart';
import 'hr_attendance_chart_screen.dart';

class HRDashboardScreen extends StatefulWidget {
  const HRDashboardScreen({super.key});

  @override
  State<HRDashboardScreen> createState() => _HRDashboardScreenState();
}

class _HRDashboardScreenState extends State<HRDashboardScreen> {
  bool _isLoading = true;
  String _userName = 'HR Manager';
  int _selectedIndex = 0;
  
  Map<String, dynamic> _stats = {
    'totalStaff': 0,
    'presentToday': 0,
    'absentees': 0,
  };
  List<Users> _staffList = [];
  List<StaffAttendance> _attendanceLogs = [];

  @override
  void initState() {
    super.initState();
    _cleanupFakeUsers().then((_) => _loadData());
    
    // Start realtime notifications
    AuthService().getUserId().then((id) {
      if (id != null) {
        NotificationService().startRealtimeListener(id);
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final name = await AuthService().getUserName();
      
      final uReq = ModelQueries.list(Users.classType, limit: 10000);
      final uRes = await Amplify.API.query(request: uReq).response;
      var usersResRaw = (uRes.data?.items ?? []).whereType<Users>().toList() ?? [];
      
      final Map<String, Users> uniqueUsers = {};
      for (var u in usersResRaw) {
        final name = (u.name ?? '').toLowerCase().trim();
        if (name.isEmpty) {
          uniqueUsers[u.id] = u;
          continue;
        }
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
      var usersRes = uniqueUsers.values.toList();
      
      // Exclude clients and admins (if desired, though usually HR manages all staff. Let's exclude clients)
      usersRes = usersRes.where((u) => u.role != 'client' && u.role != 'admin').toList();

      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final aReq = ModelQueries.list(
        StaffAttendance.classType,
        where: StaffAttendance.ATTENDANCE_DATE.eq(todayStr)
      );
      final aRes = await Amplify.API.query(request: aReq).response;
      var attendanceRes = (aRes.data?.items ?? []).whereType<StaffAttendance>().toList() ?? [];

      // Get unique users checked in today
      final presentUserIds = attendanceRes.map((a) => a.user_id.toString()).toSet();

      int presentCount = presentUserIds.length;
      int totalCount = usersRes.length;
      int absentCount = totalCount - presentCount;

      if (mounted) {
        setState(() {
          _userName = name ?? 'HR Manager';
          _stats = {
            'totalStaff': totalCount,
            'presentToday': presentCount,
            'absentees': absentCount > 0 ? absentCount : 0,
          };
          _staffList = usersRes;
          _staffList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
          _attendanceLogs = attendanceRes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading HR stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stats: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cleanupFakeUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final uReq = ModelQueries.list(Users.classType, limit: 10000);
      final uRes = await Amplify.API.query(request: uReq).response;
      var usersResRaw = (uRes.data?.items ?? []).whereType<Users>().toList() ?? [];
      
      final Map<String, Users> uniqueUsers = {};
      final List<Users> toDelete = [];
      
      for (var u in usersResRaw) {
        if (u.role == 'client') continue; // Don't delete clients here
        
        final name = (u.name ?? '').toLowerCase().trim();
        if (name.isEmpty) {
          toDelete.add(u);
          continue;
        }
        
        var firstName = name.split(' ')[0];
        if (firstName == 'jithasree') firstName = 'jitha';
        
        if (uniqueUsers.containsKey(firstName)) {
          final existing = uniqueUsers[firstName]!;
          if (u.id.contains('-') && !existing.id.contains('-')) {
            toDelete.add(existing);
            uniqueUsers[firstName] = u;
          } else {
            toDelete.add(u);
          }
        } else {
          uniqueUsers[firstName] = u;
        }
      }
      
      for (var u in toDelete) {
        await BackupAwareApi().delete(u);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cleaned up ${toDelete.length} duplicate test accounts!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint('Error cleaning up: $e');
    }
    
    await _loadData();
  }

  void _handleLogout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildSidebarItem(int index, IconData icon, String title, bool isWide) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          border: Border(right: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.white70, size: 22),
            if (isWide) ...[
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isWide) {
    return Material(
      color: const Color(0xFF13131A), // Deep dark slate
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Image.asset('assets/CUnitedGold.png', height: 40, fit: BoxFit.contain),
                  const SizedBox(width: 12),
                  const Text('Cochin United', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSidebarItem(0, Icons.dashboard_rounded, 'HR Home', isWide),
                  _buildSidebarItem(1, Icons.people_alt_rounded, 'Staff Directory', isWide),
                  _buildSidebarItem(2, Icons.chat_bubble_outline_rounded, 'Internal Chat', isWide),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                        const Text('HR Manager', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white54, size: 20),
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBody(bool isWide) {
    switch (_selectedIndex) {
      case 0: return _buildDashboardHome(isWide);
      case 1: return const StaffManagementScreen();
      case 2: return const StaffChatListScreen();
      default: return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildDashboardHome(bool isWide) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(isWide),
            const SizedBox(height: 24),
            
            _buildWelcomeBanner(isWide),
            const SizedBox(height: 32),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isWide ? 3 : 2,
              mainAxisSpacing: isWide ? 24 : 12,
              crossAxisSpacing: isWide ? 24 : 12,
              childAspectRatio: isWide ? 1.4 : 1.1,
              children: [
                _buildStatCard('Total Staff', _stats["totalStaff"].toString(), 'Active employees', Icons.people_alt_rounded, Colors.blue, isWide, onTap: () {
                  _showStaffDetails('Total Staff', _staffList);
                }),
                _buildStatCard('Present Today', _stats["presentToday"].toString(), 'Checked in', Icons.check_circle_rounded, Colors.green, isWide, onTap: () {
                  final presentIds = _attendanceLogs.map((a) => a.user_id.toString()).toSet();
                  final presentUsers = _staffList.where((u) => presentIds.contains(u.id.toString())).toList();
                  _showStaffDetails('Present Today', presentUsers);
                }),
                _buildStatCard('Absentees', _stats["absentees"].toString(), 'Not yet checked in', Icons.warning_rounded, Colors.orange, isWide, onTap: () {
                  final presentIds = _attendanceLogs.map((a) => a.user_id.toString()).toSet();
                  final absentUsers = _staffList.where((u) => !presentIds.contains(u.id.toString())).toList();
                  _showStaffDetails('Absentees', absentUsers);
                }),
              ].animate(interval: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1),
            ),
            
            const SizedBox(height: 40),
            const Text('Quick Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isWide ? 4 : 2,
              mainAxisSpacing: isWide ? 16 : 12,
              crossAxisSpacing: isWide ? 16 : 12,
              childAspectRatio: isWide ? 1.5 : 1.3,
              children: [
                _buildModuleItem('Staff Directory', Icons.badge_rounded, Colors.indigo, () => setState(() => _selectedIndex = 1)),
                _buildModuleItem('Internal Chat', Icons.chat_bubble_outline_rounded, Colors.green, () => setState(() => _selectedIndex = 2)),
                _buildModuleItem('Attendance Chart', Icons.bar_chart_rounded, Colors.purple, () => _showAttendanceChart()),
              ],
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 40),
            const Text('Today\'s Staff Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 16),
            _buildStaffActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffActivityList() {
    if (_staffList.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('No staff found.', style: TextStyle(color: Colors.grey)),
      ));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _staffList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final s = _staffList[index];
        final role = s.role?.toString() ?? 'staff';
        final color = role == 'hr' ? Colors.pink : (role == 'manager' ? Colors.indigo : (role == 'delivery' ? Colors.orange : AppTheme.primaryColor));
        
        final atts = _attendanceLogs.where((a) => a.user_id?.toString() == s.id.toString()).toList();
        atts.sort((a, b) => (b.attendance_date ?? '').compareTo(a.attendance_date ?? ''));
        final latestAtt = atts.isNotEmpty ? atts.first : null;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Text(s.name?[0] ?? '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(role.toUpperCase(), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Today', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  if (latestAtt != null) ...[
                    Text('${latestAtt.check_in_time ?? '--:--'} - ${latestAtt.check_out_time ?? '--:--'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ] else ...[
                    const Text('No records', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ]
                ],
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 800.ms);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 800;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFB),
          drawer: !isWide ? Drawer(
            backgroundColor: const Color(0xFF13131A),
            child: _buildSidebar(true),
          ) : null,
          appBar: !isWide ? PremiumAppBar(
            title: const Text('Cochin United (HR)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            actions: [
              const NotificationBell(),
              const SizedBox(width: 8),
            ],
          ) : null,
          body: Row(
            children: [
              if (isWide) _buildSidebar(true),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isWide ? 32 : 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildMainBody(isWide),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildGreeting(bool isWide) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Evening';
    if (hour < 12) greeting = 'Good Morning';
    else if (hour < 17) greeting = 'Good Afternoon';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: TextStyle(fontSize: isWide ? 28 : 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Text(
              _userName,
              style: TextStyle(fontSize: isWide ? 36 : 28, fontWeight: FontWeight.w900, color: AppTheme.primaryColor, height: 1.1),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
        if (isWide)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMM d, y').format(DateTime.now()),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildWelcomeBanner(bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 32 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
                  ),
                  child: const Text('HUMAN RESOURCES', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Staff & Operations Hub',
                  style: TextStyle(color: Colors.white, fontSize: isWide ? 28 : 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Monitor attendance, manage staff profiles, and oversee HR operations efficiently.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _cleanupFakeUsers,
                  icon: const Icon(Icons.cleaning_services, size: 16),
                  label: const Text('Clean Test Accounts'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.8),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 24),
            Icon(Icons.badge_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
          ]
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color, bool isWide, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isWide ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: color, size: 20),
                    ),
                  ],
                ),
                Text(value, style: TextStyle(fontSize: isWide ? 32 : 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStaffDetails(String title, List<Users> users) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 500,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Total: ${users.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 16),
                Expanded(
                  child: users.isEmpty
                      ? const Center(child: Text('No staff found in this category'))
                      : ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final role = user.role ?? 'staff';
                            
                            final atts = _attendanceLogs.where((a) => a.user_id?.toString() == user.id.toString()).toList();
                            atts.sort((a, b) => (b.attendance_date ?? '').compareTo(a.attendance_date ?? ''));
                            final latestAtt = atts.isNotEmpty ? atts.first : null;
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                child: Text(user.name?[0] ?? '?', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(user.name ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(role.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              trailing: latestAtt != null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text('Today', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        Text('${latestAtt.check_in_time ?? '--:--'} - ${latestAtt.check_out_time ?? '--:--'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                  : const Text('No records today', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAttendanceChart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HrAttendanceChartScreen()),
    );
  }

  Widget _buildModuleItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
