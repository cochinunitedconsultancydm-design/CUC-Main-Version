import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../services/logging_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  // Tab 1: Staff Directory State
  List<Map<String, dynamic>> _staff = [];
  bool _isLoadingDirectory = true;

  // Tab 2: Time Tracker State
  String _timeTrackerPeriod = 'Today';
  String _timeTrackerSort = 'Name (A-Z)';
  DateTimeRange? _customDateRange;
  
  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  // ==========================================
  // SHARED UTILITIES
  // ==========================================
  void _msg(String t, bool ok) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(t), backgroundColor: ok ? Colors.green : Colors.redAccent,
  ));

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.purple;
      case 'manager': return Colors.indigo;
      case 'accountant': return Colors.teal;
      case 'delivery': return Colors.orange;
      default: return AppTheme.primaryColor;
    }
  }

  // ==========================================
  // TAB 1: STAFF DIRECTORY
  // ==========================================
  Future<void> _fetchStaff() async {
    if (!mounted) return;
    setState(() => _isLoadingDirectory = true);
    try {
      final uReq = ModelQueries.list(amplify_models.Users.classType);
      final uRes = await Amplify.API.query(request: uReq).response;
      var usersRes = uRes.data?.items.whereType<amplify_models.Users>().toList() ?? [];
      
      usersRes.sort((a, b) {
        int r = (a.role ?? '').compareTo(b.role ?? '');
        if (r != 0) return r;
        return (a.name ?? '').compareTo(b.name ?? '');
      });
      
      final sReq = ModelQueries.list(amplify_models.UserSessions.classType);
      final sRes = await Amplify.API.query(request: sReq).response;
      var sessionsRes = sRes.data?.items.whereType<amplify_models.UserSessions>().toList() ?? [];
      
      sessionsRes.sort((a, b) {
        final dateA = a.login_time != null ? DateTime.tryParse(a.login_time!) ?? DateTime(2000) : DateTime(2000);
        final dateB = b.login_time != null ? DateTime.tryParse(b.login_time!) ?? DateTime(2000) : DateTime(2000);
        return dateB.compareTo(dateA);
      });

      final List<Map<String, dynamic>> combined = [];
      for (var u in usersRes) {
        final userSessions = sessionsRes.where((s) => s.user_id?.toString() == u.id.toString()).toList();
        final session = userSessions.isNotEmpty ? userSessions.first : null;
        
        combined.add({
          'id': u.id,
          'name': u.name,
          'username': u.username,
          'email': u.email,
          'role': u.role,
          'last_login': session?.login_time,
          'is_active': session?.is_active ?? false,
        });
      }

      if (!mounted) return;
      setState(() {
        _staff = combined;
      });
    } catch (e) {
      _msg('Failed: $e', false);
    } finally {
      if (mounted) setState(() => _isLoadingDirectory = false);
    }
  }

  void _showForm([Map<String, dynamic>? user]) {
    final name = TextEditingController(text: user?['name']);
    final username = TextEditingController(text: user?['username']);
    final email = TextEditingController(text: user?['email']);
    final password = TextEditingController();
    String role = user?['role'] ?? 'staff';

    InputDecoration inputDec(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
    }

    Widget roleChip(String label, String value, bool isSelected, Color color, Function(String) onSelect) {
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(value),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(20) : Colors.grey.shade50,
              border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user == null ? 'Add Staff Member' : 'Edit Staff', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(controller: name, decoration: inputDec('Full Name', Icons.person_outline_rounded)),
                  const SizedBox(height: 16),
                  TextField(controller: username, decoration: inputDec('Username', Icons.alternate_email_rounded)),
                  const SizedBox(height: 16),
                  TextField(controller: email, decoration: inputDec('Email Address', Icons.email_outlined), keyboardType: TextInputType.emailAddress),
                  if (user == null) ...[
                    const SizedBox(height: 16),
                    TextField(controller: password, decoration: inputDec('Initial Password', Icons.lock_outline_rounded), obscureText: true),
                  ],
                  const SizedBox(height: 32),
                  const Text('Access Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      roleChip('Admin', 'admin', role == 'admin', Colors.purple, (v) => setModalState(() => role = v)),
                      const SizedBox(width: 12),
                      roleChip('Manager', 'manager', role == 'manager', Colors.indigo, (v) => setModalState(() => role = v)),
                      const SizedBox(width: 12),
                      roleChip('Accountant', 'accountant', role == 'accountant', Colors.teal, (v) => setModalState(() => role = v)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      roleChip('Staff', 'staff', role == 'staff', AppTheme.primaryColor, (v) => setModalState(() => role = v)),
                      const SizedBox(width: 12),
                      roleChip('Delivery', 'delivery', role == 'delivery', Colors.orange, (v) => setModalState(() => role = v)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          foregroundColor: Colors.grey.shade700,
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (name.text.isEmpty || username.text.isEmpty || email.text.isEmpty || (user == null && password.text.isEmpty)) {
                            _msg('Please fill all fields', false);
                            return;
                          }
                          try {
                            if (user == null) {
                              final newUser = amplify_models.Users(
                                name: name.text,
                                username: username.text,
                                email: email.text,
                                password: password.text,
                                role: role,
                              );
                              await Amplify.API.mutate(request: ModelMutations.create(newUser)).response;
                              await LoggingService().logAction(action: 'CREATE_STAFF', targetType: 'Staff', targetId: username.text, details: 'Added new staff member: ${name.text}');
                            } else {
                              final req = ModelQueries.list(amplify_models.Users.classType, where: amplify_models.Users.ID.eq(user['id'].toString()));
                              final res = await Amplify.API.query(request: req).response;
                              if (res.data?.items.isNotEmpty == true) {
                                final existing = res.data!.items.first!;
                                final updated = existing.copyWith(
                                  name: name.text,
                                  username: username.text,
                                  email: email.text,
                                  role: role,
                                );
                                await Amplify.API.mutate(request: ModelMutations.update(updated)).response;
                                await LoggingService().logAction(action: 'UPDATE_STAFF', targetType: 'Staff', targetId: username.text, details: 'Updated staff member: ${name.text}');
                              }
                            }
                            if (mounted) Navigator.pop(context);
                            _fetchStaff();
                            _msg('Saved successfully', true);
                          } catch (e) {
                            _msg('Error: $e', false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(user == null ? 'Create Member' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword(Map<String, dynamic> user) {
    final passController = TextEditingController();
    bool isSaving = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Reset Password for ${user['name']}'),
          content: TextField(
            controller: passController,
            decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
            obscureText: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (passController.text.trim().isEmpty) return;
                setModalState(() => isSaving = true);
                try {
                  final req = ModelQueries.list(amplify_models.Users.classType, where: amplify_models.Users.ID.eq(user['id'].toString()));
                  final res = await Amplify.API.query(request: req).response;
                  if (res.data?.items.isNotEmpty == true) {
                    final existing = res.data!.items.first!;
                    final updated = existing.copyWith(password: passController.text);
                    await Amplify.API.mutate(request: ModelMutations.update(updated)).response;
                  }
                  await LoggingService().logAction(action: 'RESET_PASSWORD', targetType: 'Staff', targetId: user['username'], details: 'Reset password for ${user['name']}');
                  if (mounted) Navigator.pop(context);
                  _msg('Password reset successfully for ${user['name']}', true);
                } catch (e) {
                  _msg('Error: $e', false);
                } finally {
                  if (mounted) setModalState(() => isSaving = false);
                }
              },
              child: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(dynamic id) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Remove this staff member?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(c, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
      ],
    ));
    if (ok == true) {
      try {
        final req = ModelQueries.list(amplify_models.Users.classType, where: amplify_models.Users.ID.eq(id.toString()));
        final res = await Amplify.API.query(request: req).response;
        if (res.data?.items.isNotEmpty == true) {
          await Amplify.API.mutate(request: ModelMutations.delete(res.data!.items.first!)).response;
        }
        await LoggingService().logAction(action: 'DELETE_STAFF', targetType: 'Staff', targetId: id.toString(), details: 'Deleted staff member');
        _fetchStaff();
        _msg('Removed', true);
      } catch (e) { _msg('Error: $e', false); }
    }
  }

  String _getLastLoginText(dynamic lastLogin) {
    if (lastLogin == null) return 'Never logged in';
    final date = DateTime.parse(lastLogin.toString()).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 5) return 'Active now';
    if (diff.inHours < 24) return 'Active ${DateFormat('HH:mm').format(date)}';
    return 'Last seen ${DateFormat('dd MMM').format(date)}';
  }

  Widget _actionBtn(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color),
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: color.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildDirectoryTab(bool isWide) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Directory Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Add Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor, 
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _isLoadingDirectory ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _staff.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = _staff[index];
                final role = s['role']?.toString() ?? 'staff';
                final color = _getRoleColor(role);
                final isActive = s['is_active'] == true;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 16),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: color.withAlpha(25),
                              child: Text(s['name']?[0] ?? '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    s['name'] ?? 'No Name',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(role.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('@${s['username']} • ${s['email'] ?? 'No Email'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        if (isWide)
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_filled_rounded, size: 14, color: isActive ? Colors.green : Colors.grey.shade400),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getLastLoginText(s['last_login']),
                                      style: TextStyle(fontSize: 13, color: isActive ? Colors.green : Colors.grey.shade600, fontWeight: isActive ? FontWeight.bold : FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _actionBtn(Icons.lock_reset_rounded, Colors.orange, 'Reset Password', () => _resetPassword(s)),
                            const SizedBox(width: 8),
                            _actionBtn(Icons.edit_rounded, Colors.blueGrey, 'Edit', () => _showForm(s)),
                            const SizedBox(width: 8),
                            _actionBtn(Icons.delete_outline_rounded, Colors.redAccent, 'Delete', () => _delete(s['id'])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05, end: 0);
              },
            ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: TIME TRACKER
  // ==========================================
  Future<DateTimeRange?> _showCompactDateRangePicker() async {
    DateTime start = _customDateRange?.start ?? DateTime.now();
    DateTime end = _customDateRange?.end ?? DateTime.now();

    return await showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Select Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(start), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context, 
                          initialDate: start, 
                          firstDate: DateTime(2020), 
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor)),
                            child: child!,
                          ),
                        );
                        if (d != null) {
                          setDialogState(() {
                            start = d;
                            if (end.isBefore(start)) end = start;
                          });
                        }
                      },
                    ),
                    const Divider(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(end), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context, 
                          initialDate: end, 
                          firstDate: start, 
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor)),
                            child: child!,
                          ),
                        );
                        if (d != null) setDialogState(() => end = d);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, DateTimeRange(start: start, end: end)), 
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                  child: const Text('Apply'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<List<Map<String, dynamic>>> _fetchStaffTimeStats() async {
    final uReq = ModelQueries.list(amplify_models.Users.classType);
    final uRes = await Amplify.API.query(request: uReq).response;
    var usersRes = uRes.data?.items.whereType<amplify_models.Users>().toList() ?? [];
    usersRes = usersRes.where((u) => u.role != 'admin').toList();
    usersRes.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    
    final today = DateTime.now();
    DateTime startDate;
    DateTime? endDate;
    
    switch (_timeTrackerPeriod) {
      case 'This Week':
        startDate = today.subtract(Duration(days: today.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'This Month':
        startDate = DateTime(today.year, today.month, 1);
        break;
      case 'All Time':
        startDate = DateTime(2000, 1, 1);
        break;
      case 'Custom':
        startDate = _customDateRange?.start ?? DateTime(today.year, today.month, today.day);
        if (_customDateRange != null) {
          endDate = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
        }
        break;
      case 'Today':
      default:
        startDate = DateTime(today.year, today.month, today.day);
        break;
    }
    
    final sReq = ModelQueries.list(amplify_models.UserSessions.classType);
    final sRes = await Amplify.API.query(request: sReq).response;
    var allSessions = sRes.data?.items.whereType<amplify_models.UserSessions>().toList() ?? [];
    
    var sessionsRes = allSessions.where((s) {
      if (s.login_time == null) return false;
      final t = DateTime.tryParse(s.login_time!);
      if (t == null) return false;
      if (t.isBefore(startDate)) return false;
      if (endDate != null && t.isAfter(endDate)) return false;
      return true;
    }).toList();
    
    sessionsRes.sort((a, b) {
      final dateA = a.login_time != null ? DateTime.tryParse(a.login_time!) ?? DateTime(2000) : DateTime(2000);
      final dateB = b.login_time != null ? DateTime.tryParse(b.login_time!) ?? DateTime(2000) : DateTime(2000);
      return dateB.compareTo(dateA); // descending
    });
        
    final List<Map<String, dynamic>> combined = [];
    for (var u in usersRes) {
      int totalActive = 0;
      int totalIdle = 0;
      bool isCurrentlyActive = false;
      String currentStatus = 'Offline';
      String? lastLogin;
      String? lastLogout;

      final userSessions = sessionsRes.where((s) => s.user_id?.toString() == u.id.toString()).toList();
      
      if (userSessions.isNotEmpty) {
        lastLogin = userSessions.first.login_time;
        lastLogout = userSessions.first.logout_time;
        isCurrentlyActive = userSessions.first.is_active ?? false;
        currentStatus = isCurrentlyActive ? (userSessions.first.status ?? 'Active') : 'Offline';
        
        for (var s in userSessions) {
          totalActive += s.active_seconds ?? 0;
          totalIdle += s.idle_seconds ?? 0;
        }
      }

      combined.add({
        'id': u.id,
        'name': u.name,
        'username': u.username,
        'role': u.role,
        'login_time': lastLogin,
        'logout_time': lastLogout,
        'is_active': isCurrentlyActive,
        'status': currentStatus,
        'active_seconds': totalActive,
        'idle_seconds': totalIdle,
      });
    }
    
    combined.sort((a, b) {
      if (_timeTrackerSort == 'Status (Online First)') {
        if (a['is_active'] != b['is_active']) return a['is_active'] ? -1 : 1;
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      } else if (_timeTrackerSort == 'Most Active Time') {
        int aTime = (a['active_seconds'] ?? 0) as int;
        int bTime = (b['active_seconds'] ?? 0) as int;
        if (aTime != bTime) return bTime.compareTo(aTime);
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      } else {
        return (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase());
      }
    });
    
    return combined;
  }

  Widget _buildTimeTrackerTab(bool isWide) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Time Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _timeTrackerPeriod,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                    items: ['Today', 'This Week', 'This Month', 'All Time', 'Custom'].map((String value) {
                      String displayText = value;
                      if (value == 'Custom' && _timeTrackerPeriod == 'Custom' && _customDateRange != null) {
                        if (_customDateRange!.start.isAtSameMomentAs(_customDateRange!.end)) {
                          displayText = 'On ${DateFormat('MMM dd').format(_customDateRange!.start)}';
                        } else {
                          displayText = '${DateFormat('MMM dd').format(_customDateRange!.start)} - ${DateFormat('MMM dd').format(_customDateRange!.end)}';
                        }
                      }
                      
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          displayText, 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)
                        ),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      if (val == 'Custom') {
                        final picked = await _showCompactDateRangePicker();
                        if (picked != null) {
                          setState(() {
                            _customDateRange = picked;
                            _timeTrackerPeriod = 'Custom';
                          });
                        }
                      } else if (val != null) {
                        setState(() {
                          _timeTrackerPeriod = val;
                          _customDateRange = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _timeTrackerSort,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.sort_rounded, color: AppTheme.primaryColor, size: 18),
                    items: ['Name (A-Z)', 'Most Active Time', 'Status (Online First)'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _timeTrackerSort = val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                  tooltip: 'Refresh',
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchStaffTimeStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              
              final users = snapshot.data ?? [];
              if (users.isEmpty) return const Center(child: Text('No staff found.'));
              
              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final u = users[index];
                  final bool isActive = u['is_active'] == true;
                  final String status = u['status'];
                  
                  Color statusColor = Colors.grey;
                  if (status == 'Active') {
                    statusColor = Colors.green;
                  } else if (status == 'Minimized') statusColor = Colors.orange;
                  else if (status == 'Idle') statusColor = Colors.redAccent;
                  
                  final activeMins = (u['active_seconds'] as int) ~/ 60;
                  final idleMins = (u['idle_seconds'] as int) ~/ 60;
                  final totalMins = activeMins + idleMins;
                  final double activeRatio = totalMins > 0 ? activeMins / totalMins : 0;

                  final lastLogin = u['login_time'] != null ? DateFormat('HH:mm').format(DateTime.parse(u['login_time']).toLocal()) : '--:--';
                  final lastLogout = u['logout_time'] != null ? DateFormat('HH:mm').format(DateTime.parse(u['logout_time']).toLocal()) : (isActive ? 'Active' : '--:--');

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: statusColor.withValues(alpha: 0.1),
                                child: Text(u['name']?[0] ?? '?', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(u['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(u['role'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: AppTheme.mutedTextColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Status', style: TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        if (isWide)
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Latest Session', style: TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
                                const SizedBox(height: 4),
                                Text('$lastLogin - $lastLogout', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                              ],
                            ),
                          ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Active: ${activeMins}m', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
                                  Text('Idle: ${idleMins}m', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: (activeRatio * 100).toInt() == 0 && totalMins == 0 ? 1 : (activeRatio * 100).toInt(),
                                      child: Container(height: 6, color: totalMins == 0 ? Colors.grey.shade200 : Colors.green),
                                    ),
                                    if (totalMins > 0)
                                      Expanded(
                                        flex: ((1 - activeRatio) * 100).toInt(),
                                        child: Container(height: 6, color: Colors.orange),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MAIN BUILD - TABS
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;

        return DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Staff Hub', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                      const SizedBox(height: 6),
                      Text('Manage directory and monitor live tracking', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                  Container(
                    width: 320,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: Colors.grey.shade600,
                      dividerColor: Colors.transparent,
                      labelPadding: EdgeInsets.zero,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(child: Center(child: Text('Directory'))),
                        Tab(child: Center(child: Text('Time Tracker'))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildDirectoryTab(isWide),
                    _buildTimeTrackerTab(isWide),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(),
        );
      },
    );
  }
}
