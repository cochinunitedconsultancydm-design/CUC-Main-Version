import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:intl/intl.dart';
import '../models/ModelProvider.dart';
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
      final tReq = ModelQueries.list(Tasks.classType, where: Tasks.STATUS.ne('Completed'));
      final tRes = await Amplify.API.query(request: tReq).response;
      final tasksRes = tRes.data?.items.whereType<Tasks>() ?? [];
      
      for (var t in tasksRes) {
        if (t.due_date != null) {
          try {
            final date = DateTime.parse(t.due_date.toString()).toLocal();
            final diff = date.difference(now).inDays;
            if (diff <= 7) {
              items.add({
                'title': t.title ?? 'Task',
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
      final lReq = ModelQueries.list(ClientLicenses.classType, where: ClientLicenses.STATUS.eq('Active'));
      final lRes = await Amplify.API.query(request: lReq).response;
      final licenseRes = lRes.data?.items.whereType<ClientLicenses>() ?? [];
      
      for (var l in licenseRes) {
        if (l.expiry_date != null) {
          try {
            final date = DateTime.parse(l.expiry_date.toString()).toLocal();
            final diff = date.difference(now).inDays;
            if (diff <= 30) {
              String clientName = l.manual_client_name ?? 'Unknown Client';
              items.add({
                'title': '$clientName - License',
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
      final dReq = ModelQueries.list(DscRecords.classType);
      final dRes = await Amplify.API.query(request: dReq).response;
      final dscRes = dRes.data?.items.whereType<DscRecords>() ?? [];
      
      for (var d in dscRes) {
        if (d.dsc_expiry_date != null) {
          try {
            final date = DateTime.parse(d.dsc_expiry_date.toString()).toLocal();
            final diff = date.difference(now).inDays;
            if (diff <= 30) {
              items.add({
                'title': '${d.client_name ?? 'Unknown Client'} - DSC',
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
      debugPrint('Error fetching reminders: $e');
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
                border: Border.all(color: color.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
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
