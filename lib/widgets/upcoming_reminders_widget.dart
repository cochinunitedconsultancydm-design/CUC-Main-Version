import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class UpcomingRemindersWidget extends StatefulWidget {
  final bool isWide;
  final VoidCallback? onNavigateToCalendar;

  const UpcomingRemindersWidget({
    super.key,
    required this.isWide,
    this.onNavigateToCalendar,
  });

  @override
  State<UpcomingRemindersWidget> createState() => _UpcomingRemindersWidgetState();
}

class _UpcomingRemindersWidgetState extends State<UpcomingRemindersWidget> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    try {
      final now = DateTime.now();
      final List<Map<String, dynamic>> items = [];

      // 1. Fetch Tasks (Overdue or Due in next 7 days)
      final tasksRes = await _client
          .from('tasks')
          .select('id, title, due_date, status')
          .neq('status', 'Completed');
      
      for (var t in tasksRes) {
        if (t['due_date'] != null) {
          try {
            final date = DateTime.parse(t['due_date'].toString()).toLocal();
            final diff = date.difference(now).inDays;
            if (diff <= 7) {
              items.add({
                'title': t['title'] ?? 'Task',
                'date': date,
                'type': 'Task',
                'color': AppTheme.primaryColor,
                'icon': Icons.assignment,
              });
            }
          } catch (_) {}
        }
      }

      // 2. Fetch Licenses Expiry (Expired or Expiring in next 30 days)
      final licenseRes = await _client
          .from('client_licenses')
          .select('id, expiry_date, manual_client_name, clients(name), license_types(name)')
          .eq('status', 'Active');
      
      for (var l in licenseRes) {
        if (l['expiry_date'] != null) {
          try {
            final date = DateTime.parse(l['expiry_date'].toString()).toLocal();
            final diff = date.difference(now).inDays;
            if (diff <= 30) {
              String clientName = l['manual_client_name'] ?? 'Unknown Client';
              if (l['clients'] != null) {
                final c = l['clients'];
                clientName = (c is List && c.isNotEmpty) ? c[0]['name'] : (c is Map ? c['name'] : clientName);
              }
              String licenseType = 'License';
              if (l['license_types'] != null) {
                final lt = l['license_types'];
                licenseType = (lt is List && lt.isNotEmpty) ? lt[0]['name'] : (lt is Map ? lt['name'] : licenseType);
              }
              items.add({
                'title': '$clientName - $licenseType',
                'date': date,
                'type': 'License',
                'color': Colors.purple,
                'icon': Icons.verified_user,
              });
            }
          } catch (_) {}
        }
      }

      // 3. Fetch DSC Expiry (Expired or Expiring in next 30 days)
      final dscRes = await _client
          .from('dsc_records')
          .select('id, client_name, dsc_expiry_date');
      
      for (var d in dscRes) {
        if (d['dsc_expiry_date'] != null) {
          try {
            final date = DateTime.parse(d['dsc_expiry_date'].toString()).toLocal();
            final diff = date.difference(now).inDays;
            if (diff <= 30) {
              items.add({
                'title': '${d['client_name']} - DSC',
                'date': date,
                'type': 'DSC',
                'color': Colors.teal,
                'icon': Icons.vpn_key,
              });
            }
          } catch (_) {}
        }
      }

      items.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

      if (mounted) {
        setState(() {
          _reminders = items.take(10).toList(); // Top 10 upcoming
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching reminders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reminders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Upcoming Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            if (widget.onNavigateToCalendar != null)
              TextButton(
                onPressed: widget.onNavigateToCalendar,
                child: const Text('View Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reminders.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final r = _reminders[index];
            final date = r['date'] as DateTime;
            final isOverdue = date.isBefore(DateTime.now());
            final days = date.difference(DateTime.now()).inDays;
            final color = r['color'] as Color;

            String timeText;
            Color timeColor;
            if (isOverdue) {
              timeText = 'Overdue by ${days.abs()} days';
              timeColor = Colors.red;
            } else if (days == 0) {
              timeText = 'Today';
              timeColor = Colors.orange;
            } else {
              timeText = 'In $days days';
              timeColor = Colors.green;
            }

            return Container(
              padding: EdgeInsets.all(widget.isWide ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(r['icon'] as IconData, color: color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(r['type'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(timeText, style: TextStyle(fontSize: 11, color: timeColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(DateFormat('dd MMM yyyy').format(date), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
