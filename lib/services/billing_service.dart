import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/billing.dart';
import '../utils/number_to_words.dart';

class BillingService {
  final _client = Supabase.instance.client;

  Future<Map<String, int>> fetchStats() async {
    final totalRes = await _client.from('billings').select('id');
    final paidRes = await _client.from('billings').select('id').or("status.eq.Received,data->>payment_received.eq.true");
    
    final total = totalRes.length;
    final paid = paidRes.length;
    
    return {
      'total': total,
      'paid': paid,
      'pending': total - paid,
    };
  }

  Future<void> syncClientBalance(String clientName) async {
    if (clientName.isEmpty) return;
    
    final res = await _client
        .from('billings')
        .select('data')
        .eq('client_name', clientName)
        .or("status.eq.Pending,data->>payment_received.eq.false,data->>payment_received.is.null");
    
    double totalDue = 0;
    for (var row in res) {
      final data = row['data'] as Map<String, dynamic>?;
      String balStr = data?['balance_due']?.toString() ?? '0';
      totalDue += NumberToWords.parseCurrency(balStr);
    }
    
    String finalBalance = totalDue > 0 ? NumberToWords.formatIndianCurrency(totalDue) : '0/-';
    
    await _client
        .from('clients')
        .update({'balance_due': finalBalance})
        .eq('name', clientName);
  }

  Future<List<Billing>> fetchBillings({
    required int limit,
    required int offset,
    String statusFilter = 'All',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    dynamic query = _client.from('billings').select();

    if (statusFilter == 'Paid') {
      query = query.or("status.eq.Received,data->>payment_received.eq.true");
    } else if (statusFilter == 'Pending') {
      query = query.or("status.eq.Pending,data->>payment_received.eq.false,data->>payment_received.is.null");
    } else if (statusFilter == 'Overdue') {
      // PostgREST doesn't support complex date arithmetic easily in filters without RPC or careful string formatting.
      // For now, we'll filter Pending and then do manual filtering if needed, 
      // or use a simpler filter if the 'date' column was ISO. 
      // Since it's DD/MM/YYYY, it's hard to filter in DB without a function.
      query = query.or("status.eq.Pending,data->>payment_received.eq.false,data->>payment_received.is.null");
    } else if (statusFilter == 'Interested') {
      query = query.eq('status', 'Interested');
    } else if (statusFilter == 'Not Interested') {
      query = query.eq('status', 'Not Interested');
    }

    // Date filtering (Note: 'date' is stored as DD/MM/YYYY string, which is sub-optimal for DB filtering)
    // We'll fetch and filter in app if date range is specified, or use RPC.
    
    query = query.order('id', ascending: false).range(offset, offset + limit - 1);
    
    final response = await query;
    var billings = List<Map<String, dynamic>>.from(response).map((m) => Billing.fromMap(m)).toList();

    // Manual Overdue filtering if needed
    if (statusFilter == 'Overdue') {
      final now = DateTime.now();
      billings = billings.where((b) {
        if (b.date == null || b.date!.isEmpty) return false;
        try {
          final d = DateFormat('dd/MM/yyyy').parse(b.date!);
          return now.difference(d).inDays > 30;
        } catch (_) {
          return false;
        }
      }).toList();
    }

    // Manual date range filtering due to string format
    if (startDate != null && endDate != null) {
      billings = billings.where((b) {
        if (b.date == null || b.date!.isEmpty) return false;
        try {
          final d = DateFormat('dd/MM/yyyy').parse(b.date!);
          return d.isAfter(startDate.subtract(const Duration(days: 1))) && 
                 d.isBefore(endDate.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    return billings;
  }

  Future<void> updateBilling(int id, Map<String, dynamic> updates) async {
    await _client.from('billings').update(updates).eq('id', id);
  }

  Future<void> deleteBilling(int id) async {
    await _client.from('billings').delete().eq('id', id);
  }

  Future<String?> getNextInvoiceNo(String prefix) async {
    final res = await _client
        .from('billings')
        .select('invoice_no')
        .ilike('invoice_no', '$prefix%')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
    
    if (res != null) {
      final last = res['invoice_no'] as String;
      final match = RegExp(r'(\d+)$').firstMatch(last);
      if (match != null) {
        final numStr = match.group(1)!;
        final num = int.parse(numStr) + 1;
        return last.substring(0, last.length - numStr.length) + num.toString().padLeft(numStr.length, '0');
      }
    }
    return null;
  }

  Future<String?> getClientPhone(String clientName) async {
    final res = await _client
        .from('clients')
        .select('phone')
        .eq('name', clientName)
        .maybeSingle();
    return res?['phone']?.toString();
  }

  Future<List<Billing>> getClientLedger(String clientName) async {
    final res = await _client
        .from('billings')
        .select()
        .eq('client_name', clientName)
        .order('id', ascending: false);
    return List<Map<String, dynamic>>.from(res).map((m) => Billing.fromMap(m)).toList();
  }
}
