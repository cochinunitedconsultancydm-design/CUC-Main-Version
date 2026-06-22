import 'package:amplify_api/amplify_api.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';

class UpcomingDeadlinesWidget extends StatelessWidget {
  final bool isWide;
  final String? filterByAuthorities;
  final void Function(Map<String, dynamic> item)? onItemTap;

  const UpcomingDeadlinesWidget({
    super.key, 
    required this.isWide, 
    this.filterByAuthorities,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchDeadlines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final deadlines = snapshot.data!;
        if (deadlines.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upcoming Payment Deadlines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: deadlines.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = deadlines[index];
                final invoiceNo = b['invoice_no'] ?? '-';
                final clientName = b['client_name'] ?? 'Unknown';
                final amount = b['amount'] ?? '0/-';
                final deadlineStr = b['data']?['payment_deadline']?.toString() ?? '';
                
                Color statusColor = Colors.grey;
                try {
                  final parts = deadlineStr.split('/');
                  if (parts.length == 3) {
                    // Check against today without time (to ensure accurate day difference)
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                    final daysDiff = d.difference(today).inDays;
                    if (daysDiff < 0) {
                      statusColor = Colors.red;
                    } else if (daysDiff <= 3) {
                      statusColor = Colors.orange;
                    } else {
                      statusColor = Colors.green;
                    }
                  }
                } catch (_) {}

                return InkWell(
                  onTap: onItemTap != null ? () => onItemTap!(b) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(isWide ? 16 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(color: statusColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$invoiceNo - $clientName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Deadline', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(deadlineStr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: statusColor)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDeadlines() async {
    var req = ModelQueries.list(Billings.classType, where: Billings.STATUS.ne('Received'));
    
    if (filterByAuthorities != null && filterByAuthorities!.isNotEmpty) {
      req = ModelQueries.list(Billings.classType, where: Billings.STATUS.ne('Received').and(Billings.AUTHORITIES.contains(filterByAuthorities!)));
    }

    final res = await Amplify.API.query(request: req).response;
    final all = res.data?.items.whereType<Billings>() ?? [];
    
    final List<Map<String, dynamic>> withDeadlines = [];
    for (var b in all) {
      Map<String, dynamic>? data;
      if (b.data != null) {
        try {
          data = jsonDecode(b.data!);
        } catch (_) {}
      }
      if (data != null && data['payment_deadline'] != null && data['payment_deadline'].toString().isNotEmpty) {
        withDeadlines.add({
          'id': b.id,
          'invoice_no': b.invoice_no,
          'client_name': b.client_name,
          'amount': b.amount,
          'data': data,
          'status': b.status,
          'authorities': b.authorities,
        });
      }
    }

    withDeadlines.sort((a, b) {
      final d1Str = a['data']['payment_deadline'].toString();
      final d2Str = b['data']['payment_deadline'].toString();
      try {
        final p1 = d1Str.split('/');
        final p2 = d2Str.split('/');
        final d1 = DateTime(int.parse(p1[2]), int.parse(p1[1]), int.parse(p1[0]));
        final d2 = DateTime(int.parse(p2[2]), int.parse(p2[1]), int.parse(p2[0]));
        return d1.compareTo(d2);
      } catch (_) {
        return 0;
      }
    });

    return withDeadlines;
  }
}
