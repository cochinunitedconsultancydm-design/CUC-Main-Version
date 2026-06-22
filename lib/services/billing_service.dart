import 'package:amplify_api/amplify_api.dart';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:intl/intl.dart';
import '../models/ModelProvider.dart';
import '../models/billing.dart';
import '../utils/number_to_words.dart';

class BillingService {
  Future<Map<String, int>> fetchStats() async {
    final req = ModelQueries.list(Billings.classType);
    final res = await Amplify.API.query(request: req).response;
    final all = res.data?.items.whereType<Billings>() ?? [];
    
    int total = all.length;
    int paid = 0;
    
    for (var b in all) {
      if (b.status == 'Received') {
        paid++;
        continue;
      }
      if (b.data != null) {
        try {
          final dataMap = jsonDecode(b.data!);
          if (dataMap['payment_received'] == true || dataMap['payment_received'] == 'true') {
            paid++;
          }
        } catch (_) {}
      }
    }
    
    return {
      'total': total,
      'paid': paid,
      'pending': total - paid,
    };
  }

  Future<void> syncClientBalance(String clientName) async {
    if (clientName.isEmpty) return;
    
    final req = ModelQueries.list(Billings.classType, where: Billings.CLIENT_NAME.eq(clientName));
    final res = await Amplify.API.query(request: req).response;
    final all = res.data?.items.whereType<Billings>() ?? [];
    
    double totalDue = 0;
    for (var b in all) {
      bool isPending = b.status == 'Pending';
      if (!isPending && b.data != null) {
        try {
          final dataMap = jsonDecode(b.data!);
          if (dataMap['payment_received'] == false || dataMap['payment_received'] == 'false' || dataMap['payment_received'] == null) {
            isPending = true;
          }
        } catch (_) {
          isPending = true;
        }
      }
      
      if (isPending && b.data != null) {
        try {
          final dataMap = jsonDecode(b.data!);
          String balStr = dataMap['balance_due']?.toString() ?? '0';
          totalDue += NumberToWords.parseCurrency(balStr);
        } catch (_) {}
      }
    }
    
    String finalBalance = totalDue > 0 ? NumberToWords.formatIndianCurrency(totalDue) : '0/-';
    
    final cReq = ModelQueries.list(Clients.classType, where: Clients.NAME.eq(clientName));
    final cRes = await Amplify.API.query(request: cReq).response;
    if (cRes.data?.items.isNotEmpty == true) {
      final client = cRes.data!.items.first!;
      final updated = client.copyWith(balance_due: finalBalance);
      await Amplify.API.mutate(request: ModelMutations.update(updated).response);
    }
  }

  Future<List<Billing>> fetchBillings({
    required int limit,
    required int offset,
    String statusFilter = 'All',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final req = ModelQueries.list(Billings.classType);
    final res = await Amplify.API.query(request: req).response;
    var all = res.data?.items.whereType<Billings>() ?? [];
    
    // Sort descending by ID or date (using ID for now as original code used order by id)
    var allList = all.toList()..sort((a, b) => b.id.compareTo(a.id));

    List<Billings> filtered = [];
    
    for (var b in allList) {
      bool match = false;
      bool isPaid = b.status == 'Received';
      if (!isPaid && b.data != null) {
        try {
          final dataMap = jsonDecode(b.data!);
          if (dataMap['payment_received'] == true || dataMap['payment_received'] == 'true') {
            isPaid = true;
          }
        } catch (_) {}
      }
      
      bool isPending = b.status == 'Pending';
      if (!isPending && !isPaid && b.data != null) {
        try {
          final dataMap = jsonDecode(b.data!);
          if (dataMap['payment_received'] == false || dataMap['payment_received'] == 'false' || dataMap['payment_received'] == null) {
            isPending = true;
          }
        } catch (_) {
          isPending = true;
        }
      }

      if (statusFilter == 'All') match = true;
      else if (statusFilter == 'Paid' && isPaid) match = true;
      else if (statusFilter == 'Pending' && isPending) match = true;
      else if (statusFilter == 'Overdue' && isPending) match = true;
      else if (statusFilter == 'Interested' && b.status == 'Interested') match = true;
      else if (statusFilter == 'Not Interested' && b.status == 'Not Interested') match = true;
      
      if (match) filtered.add(b);
    }

    var billings = filtered.map((m) => Billing.fromMap(m.toMap())).toList();

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

    // Apply pagination AFTER filtering
    final paginated = billings.skip(offset).take(limit).toList();
    return paginated;
  }

  Future<void> updateBilling(dynamic id, Map<String, dynamic> updates) async {
    final req = ModelQueries.list(Billings.classType, where: Billings.ID.eq(id.toString()));
    final res = await Amplify.API.query(request: req).response;
    if (res.data?.items.isNotEmpty == true) {
      final b = res.data!.items.first!;
      var updated = b.copyWith(
        invoice_no: updates['invoice_no'] ?? b.invoice_no,
        client_name: updates['client_name'] ?? b.client_name,
        date: updates['date'] ?? b.date,
        amount: updates['amount']?.toString() ?? b.amount,
        type: updates['type'] ?? b.type,
        data: updates['data'] != null ? (updates['data'] is String ? updates['data'] : jsonEncode(updates['data'])) : b.data,
        category: updates['category'] ?? b.category,
        authorities: updates['authorities'] ?? b.authorities,
        status: updates['status'] ?? b.status,
      );
      await Amplify.API.mutate(request: ModelMutations.update(updated).response);
    }
  }

  Future<void> deleteBilling(dynamic id) async {
    final req = ModelQueries.list(Billings.classType, where: Billings.ID.eq(id.toString()));
    final res = await Amplify.API.query(request: req).response;
    if (res.data?.items.isNotEmpty == true) {
      final b = res.data!.items.first!;
      await Amplify.API.mutate(request: ModelMutations.delete(b).response);
    }
  }

  Future<String?> getNextInvoiceNo(String prefix) async {
    final req = ModelQueries.list(Billings.classType);
    final res = await Amplify.API.query(request: req).response;
    final all = res.data?.items.whereType<Billings>() ?? [];
    
    final matching = all.where((b) => b.invoice_no != null && b.invoice_no!.toLowerCase().startsWith(prefix.toLowerCase())).toList();
    matching.sort((a, b) => b.id.compareTo(a.id));
    
    if (matching.isNotEmpty) {
      final last = matching.first.invoice_no!;
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
    final req = ModelQueries.list(Clients.classType, where: Clients.NAME.eq(clientName));
    final res = await Amplify.API.query(request: req).response;
    if (res.data?.items.isNotEmpty == true) {
      return res.data!.items.first!.phone;
    }
    return null;
  }

  Future<List<Billing>> getClientLedger(String clientName) async {
    final req = ModelQueries.list(Billings.classType, where: Billings.CLIENT_NAME.eq(clientName));
    final res = await Amplify.API.query(request: req).response;
    var all = res.data?.items.whereType<Billings>() ?? [];
    
    var allList = all.toList()..sort((a, b) => b.id.compareTo(a.id));
    return allList.map((b) => Billing.fromMap(b.toMap())).toList();
  }
}
