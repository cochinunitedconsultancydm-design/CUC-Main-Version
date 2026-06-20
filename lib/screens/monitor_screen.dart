import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _peakActivity = [];
  bool _isLoading = true;
  int _activeTab = 0; // 0 for Sessions, 1 for Logs
  int? _selectedUserId;
  List<Map<String, dynamic>> _staffList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchStaffList(),
      _fetchSessions(),
      _fetchLogs(),
      _fetchPeakActivity(),
    ]);
  }

  Future<void> _fetchStaffList() async {
    try {
      final res = await _client.from('users').select('id, name').order('name');
      setState(() {
        _staffList = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      debugPrint('Staff fetch error: $e');
    }
  }

  Future<void> _fetchPeakActivity() async {
    try {
      // Direct SQL for grouping by hour isn't available in PostgREST, 
      // but we can fetch and group in Dart for the last 24h.
      final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
      final res = await _client
          .from('activity_logs')
          .select('created_at')
          .gt('created_at', twentyFourHoursAgo);
      
      final Map<int, int> hoursMap = {};
      for (var row in res) {
        final dt = DateTime.parse(row['created_at']).toLocal();
        hoursMap[dt.hour] = (hoursMap[dt.hour] ?? 0) + 1;
      }
      
      setState(() {
        _peakActivity = hoursMap.entries.map((e) => <String, dynamic>{'hour': e.key, 'count': e.value}).toList();
      });
    } catch (e) {
      debugPrint('Peak Activity error: $e');
    }
  }

  Future<void> _fetchLogs() async {
    try {
      var query = _client
          .from('activity_logs')
          .select('*, users(name)');
          
      if (_selectedUserId != null) {
        query = query.eq('user_id', _selectedUserId!);
      }
          
      final res = await query.order('created_at', ascending: false).limit(200);
          
      setState(() {
        _logs = List<Map<String, dynamic>>.from(res).map((r) {
          final user = r['users'] as Map<String, dynamic>?;
          return {
            ...r,
            'user_name': user?['name'] ?? 'System'
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Logs error: $e');
    }
  }

  Future<void> _fetchSessions() async {
    setState(() => _isLoading = true);
    try {
      var query = _client
          .from('user_sessions')
          .select('*, users(name, role)');
          
      if (_selectedUserId != null) {
        query = query.eq('user_id', _selectedUserId!);
      }
          
      final res = await query.order('login_time', ascending: false).limit(100);
          
      setState(() {
        _sessions = List<Map<String, dynamic>>.from(res).map((r) {
          final user = r['users'] as Map<String, dynamic>?;
          return {
            ...r,
            'user_name': user?['name'] ?? 'Unknown',
            'role': user?['role']
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Monitor error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDuration(DateTime login, DateTime? logout) {
    final end = logout ?? DateTime.now();
    final diff = end.difference(login);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStaffDropdown(),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _fetchData,
                        icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor, size: 20),
                        style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withAlpha(20), padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (isWide) _buildPeakActivityCard() else const SizedBox.shrink(),
              const SizedBox(height: 24),
        
              SizedBox(
                height: 600,
                child: _isLoading ? const Center(child: CircularProgressIndicator())
                : _activeTab == 0 ? _buildSessionsList(isWide) : _buildLogsList(isWide),
              ),
            ],
          ),
        ).animate().fadeIn();
      },
    );
  }

  Widget _buildStaffDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedUserId,
          hint: const Text('All Staff', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryColor),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Staff', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
            ..._staffList.map((s) => DropdownMenuItem<int>(
              value: s['id'] as int,
              child: Text(s['name'] ?? 'Unknown', style: const TextStyle(fontSize: 13)),
            )),
          ],
          onChanged: (val) {
            setState(() => _selectedUserId = val);
            _fetchData();
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
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppTheme.primaryColor : AppTheme.mutedTextColor),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? AppTheme.primaryColor : AppTheme.mutedTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList(bool isWide) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          if (isWide) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('STAFF MEMBER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
                Expanded(flex: 2, child: Text('LOGIN TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
                Expanded(flex: 2, child: Text('LOGOUT TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
                Expanded(flex: 1, child: Text('DURATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
                Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
              ],
            ),
          ),
          if (isWide) const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Expanded(
            child: ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final s = _sessions[index];
                final loginTime = DateTime.parse(s['login_time'].toString()).toLocal();
                final logoutTime = s['logout_time'] != null ? DateTime.parse(s['logout_time'].toString()).toLocal() : null;
                final isActive = s['is_active'] == true;
                final duration = _formatDuration(loginTime, logoutTime);

                final userColor = Colors.primaries[s['user_name'].toString().hashCode % Colors.primaries.length];

                if (!isWide) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: userColor.withOpacity(0.15),
                      child: Text(s['user_name']?[0] ?? '?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: userColor)),
                    ),
                    title: Text(s['user_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${DateFormat('dd MMM, HH:mm').format(loginTime)} • $duration', style: const TextStyle(fontSize: 12, color: AppTheme.mutedTextColor)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: (isActive ? Colors.green : Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(isActive ? 'ACTIVE' : 'OFFLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.grey)),
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
                            CircleAvatar(radius: 16, backgroundColor: userColor.withOpacity(0.15), child: Text(s['user_name']?[0] ?? '?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: userColor))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(s['user_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textColor))),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Text(DateFormat('dd MMM yyyy, hh:mm a').format(loginTime), style: const TextStyle(fontSize: 13, color: AppTheme.textColor, fontWeight: FontWeight.w500))),
                      Expanded(flex: 2, child: Text(logoutTime != null ? DateFormat('dd MMM yyyy, hh:mm a').format(logoutTime) : '--', style: TextStyle(fontSize: 13, color: logoutTime != null ? AppTheme.textColor.withOpacity(0.7) : Colors.grey.shade400, fontStyle: logoutTime == null ? FontStyle.italic : FontStyle.normal))),
                      Expanded(flex: 1, child: Text(duration, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.shade100, 
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isActive ? Colors.green.withOpacity(0.3) : Colors.grey.shade300)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? Colors.green : Colors.grey.shade500)),
                              const SizedBox(width: 6),
                              Text(isActive ? 'ACTIVE' : 'OFFLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade700 : Colors.grey.shade600), textAlign: TextAlign.center),
                            ]
                          )
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          if (isWide) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('STAFF MEMBER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
                Expanded(flex: 2, child: Text('ACTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
                Expanded(flex: 2, child: Text('TARGET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
                Expanded(flex: 3, child: Text('DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
                Expanded(flex: 2, child: Text('TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: AppTheme.mutedTextColor))),
              ],
            ),
          ),
          if (isWide) const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final l = _logs[index];
                final time = DateTime.parse(l['created_at'].toString()).toLocal();
                
                Color actionColor = Colors.blue;
                if (l['action'].toString().contains('DELETE')) actionColor = Colors.red;
                if (l['action'].toString().contains('CREATE')) actionColor = Colors.green;

                final userColor = Colors.primaries[l['user_name'].toString().hashCode % Colors.primaries.length];

                if (!isWide) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: actionColor.withOpacity(0.15),
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
                            CircleAvatar(radius: 16, backgroundColor: userColor.withOpacity(0.15), child: Text(l['user_name']?[0] ?? '?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: userColor))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(l['user_name'] ?? 'System', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: actionColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: actionColor.withOpacity(0.2))),
                          child: Text(l['action'], style: TextStyle(color: actionColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5), textAlign: TextAlign.center),
                        ),
                      ),
                      Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(left: 16), child: Text(l['target_type'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))),
                      Expanded(flex: 3, child: Text(l['details'] ?? '', style: const TextStyle(fontSize: 13, color: AppTheme.mutedTextColor), overflow: TextOverflow.ellipsis, maxLines: 2)),
                      Expanded(flex: 2, child: Text(DateFormat('dd MMM yyyy, hh:mm a').format(time), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.right)),
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
              Text('${_logs.length} Actions Logged', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
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
                  orElse: () => <String, dynamic>{'count': 0}
                ) as Map<String, dynamic>;
                final count = int.tryParse(activity['count'].toString()) ?? 0;
                final maxHeight = _peakActivity.isEmpty ? 1 : _peakActivity.fold(1, (max, p) => int.parse(p['count'].toString()) > max ? int.parse(p['count'].toString()) : max);
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
                        height: count > 0 ? (100 * heightFactor) : 4.0, // Small stub if empty
                        decoration: BoxDecoration(
                          color: count > 0 ? AppTheme.primaryColor.withOpacity(heightFactor * 0.7 + 0.3) : Colors.white.withOpacity(0.05),
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
              Text('00:00', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
              Text('12:00', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
              Text('23:59', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLogIcon(String? type) {
    switch (type) {
      case 'Invoice': return Icons.receipt_long_rounded;
      case 'Client': return Icons.person_rounded;
      case 'Work': return Icons.work_rounded;
      case 'Task': return Icons.task_alt_rounded;
      default: return Icons.info_outline_rounded;
    }
  }
}
