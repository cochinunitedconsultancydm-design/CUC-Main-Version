import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:intl/intl.dart';
import '../models/ModelProvider.dart';
import '../theme.dart';
import '../models/billing.dart';

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
  List<Map<String, dynamic>> _taskReminders = [];
  List<Map<String, dynamic>> _licenseReminders = [];
  List<Map<String, dynamic>> _dscReminders = [];
  List<Map<String, dynamic>> _billingReminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    try {
      final now = DateTime.now();
      
      final List<Map<String, dynamic>> tasks = [];
      final List<Map<String, dynamic>> licenses = [];
      final List<Map<String, dynamic>> dscs = [];
      final List<Map<String, dynamic>> bills = [];

      // 0. Fetch Clients to map client_id to name
      final clientReq = ModelQueries.list(Clients.classType, limit: 10000);
      final clientRes = await Amplify.API.query(request: clientReq).response;
      final clientsMap = { for (var c in (clientRes.data?.items ?? []).whereType<Clients>()) c.id.toString(): c.name ?? 'Unknown' };

      // 1. Fetch Tasks (Overdue or Due in next 7 days)
      final tReq = ModelQueries.list(Tasks.classType, where: Tasks.STATUS.ne('Completed'));
      final tRes = await Amplify.API.query(request: tReq).response;
      final tasksRes = (tRes.data?.items ?? []).whereType<Tasks>() ?? [];
      
      for (var t in tasksRes) {
        if (t.due_date != null) {
          try {
            final date = DateTime.parse(t.due_date.toString()).toLocal();
            final diff = date.difference(now).inDays;
            if (diff <= 7) {
              tasks.add({
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
      final licenseRes = (lRes.data?.items ?? []).whereType<ClientLicenses>() ?? [];
      
      for (var l in licenseRes) {
        if (l.expiry_date != null) {
          try {
            final date = DateTime.parse(l.expiry_date.toString()).toLocal();
            final diff = date.difference(now).inDays;
            if (diff <= 30) {
              String clientName = l.manual_client_name ?? clientsMap[l.client_id?.toString()] ?? 'Unknown Client';
              licenses.add({
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
      final dscRes = (dRes.data?.items ?? []).whereType<DscRecords>() ?? [];
      
      for (var d in dscRes) {
        if (d.dsc_expiry_date != null) {
          try {
            final date = DateTime.parse(d.dsc_expiry_date.toString()).toLocal();
            final diff = date.difference(now).inDays;
            if (diff <= 30) {
              dscs.add({
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

      // 4. Fetch Pending Bills/Receipts (Overdue or Due in next 15 days)
      final bReq = ModelQueries.list(Billings.classType, where: Billings.STATUS.ne('Paid').and(Billings.STATUS.ne('Receipt Generated')));
      final bRes = await Amplify.API.query(request: bReq).response;
      final billRes = (bRes.data?.items ?? []).whereType<Billings>() ?? [];
      
      for (var b in billRes) {
        if (b.date != null) {
          try {
            // Bills date is usually the issue date, assume it's pending if it's not paid. 
            // We'll show all unpaid bills that are generated.
            final date = DateFormat('dd/MM/yyyy').parse(b.date.toString());
            final billingModel = Billing.fromMap(b.toMap());
            
            bills.add({
              'title': '${billingModel.clientName ?? 'Unknown'} - ${billingModel.invoiceNo ?? ''}',
              'date': date, // Keeping date as issue date
              'type': billingModel.type == 'receipt' ? 'Receipt' : 'Bill',
              'color': Colors.redAccent,
              'icon': Icons.receipt_long,
            });
          } catch (_) {}
        }
      }

      tasks.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      licenses.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      dscs.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      bills.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

      if (mounted) {
        setState(() {
          _taskReminders = tasks.take(10).toList();
          _licenseReminders = licenses.take(10).toList();
          _dscReminders = dscs.take(10).toList();
          _billingReminders = bills.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching reminders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildReminderBox(String title, List<Map<String, dynamic>> items, Color headerColor) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.label_important, size: 16, color: headerColor),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: headerColor)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: headerColor, borderRadius: BorderRadius.circular(12)),
                  child: Text('${items.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final r = items[index];
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
                
                // For bills, usually the date is the issue date, so "Overdue" is natural since issue date is in the past.
                if (title == "Bills & Receipts") {
                   timeText = '${days.abs()} days ago';
                   timeColor = Colors.redAccent;
                }

                return Padding(
                  padding: EdgeInsets.all(widget.isWide ? 16 : 12),
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_taskReminders.isEmpty && _licenseReminders.isEmpty && _dscReminders.isEmpty && _billingReminders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dashboard Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            if (widget.onNavigateToCalendar != null)
              TextButton(
                onPressed: widget.onNavigateToCalendar,
                child: const Text('View Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReminderBox("Upcoming Tasks", _taskReminders, AppTheme.primaryColor),
        _buildReminderBox("License Renewals", _licenseReminders, Colors.purple),
        _buildReminderBox("DSC Expiry", _dscReminders, Colors.teal),
        _buildReminderBox("Bills & Receipts", _billingReminders, Colors.redAccent),
      ],
    );
  }
}
