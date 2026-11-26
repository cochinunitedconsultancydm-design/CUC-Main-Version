import 'package:amplify_api/amplify_api.dart';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:intl/intl.dart';
import '../models/ModelProvider.dart';
import '../models/billing.dart';
import '../utils/number_to_words.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
import 'razorpay_service.dart';

class BillingService {
  Future<List<Billing>> getPendingBillings() async {
    try {
      var req = ModelQueries.list(Billings.classType, limit: 10000);
      List<Billings> all = [];
      while (true) {
        final res = await Amplify.API.query(request: req).response;
        all.addAll((res.data?.items ?? []).whereType<Billings>() ?? []);
        if (res.data?.hasNextResult ?? false) {
          req = res.data!.requestForNextResult!;
        } else {
          break;
        }
      }

      var allList = all.toList()..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      return allList.map((m) => Billing.fromMap(m.toMap())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, int>> fetchStats() async {
    final req = ModelQueries.list(Billings.classType, limit: 10000);
    final res = await Amplify.API.query(request: req).response;
    final all = (res.data?.items ?? []).whereType<Billings>() ?? [];
    
    int total = all.length;
    int paid = 0;
    int pendingInvoices = 0;
    
    for (var b in all) {
      bool isQuotation = b.type == 'QUOTATION';
      bool isPaid = b.status == 'Received';
      if (!isPaid && b.data != null) {
        try {
          final dataMap = jsonDecode(b.data!);
          if (dataMap['payment_received'] == true || dataMap['payment_received'] == 'true') {
            isPaid = true;
          }
        } catch (_) {}
      }
      
      if (isPaid) {
        paid++;
      } else {
        if (!isQuotation) {
          pendingInvoices++;
        }
      }
    }
    
    return {
      'total': total,
      'paid': paid,
      'pending': total - paid,
      'pendingInvoices': pendingInvoices,
    };
  }

  Future<void> syncClientBalance(String clientName) async {
    if (clientName.isEmpty) return;
    
    final req = ModelQueries.list(Billings.classType, where: Billings.CLIENT_NAME.eq(clientName), limit: 10000);
    final res = await Amplify.API.query(request: req).response;
    final all = (res.data?.items ?? []).whereType<Billings>() ?? [];
    
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
    
    final cReq = ModelQueries.list(Clients.classType, where: Clients.NAME.eq(clientName), limit: 10000);
    final cRes = await Amplify.API.query(request: cReq).response;
    if (cRes.data?.items.isNotEmpty == true) {
      final client = cRes.data!.items.first!;
      final updated = client.copyWith(balance_due: finalBalance);
      await BackupAwareApi().update(updated);
    }
  }

  static Map<String, Map<String, String>>? _clientDetailsCacheV2;
  static DateTime? _cacheTimeV2;

  Future<Map<String, Map<String, String>>> _getClientDetailsMap() async {
    if (_clientDetailsCacheV2 != null && _cacheTimeV2 != null && DateTime.now().difference(_cacheTimeV2!).inMinutes < 15) {
      return _clientDetailsCacheV2!;
    }
    try {
      _clientDetailsCacheV2 = {};
      String? nextToken;
      do {
        final doc = '''
          query ListClients(\$nextToken: String) {
            listClients(nextToken: \$nextToken, limit: 1000) {
              items {
                name
                phone
                email
                companies
                case_number
                file_no
                registration_number
              }
              nextToken
            }
          }
        ''';
        final req = GraphQLRequest<String>(
          document: doc, 
          variables: nextToken != null ? {'nextToken': nextToken} : {}
        );
        final res = await Amplify.API.query(request: req).response;
        if (res.data != null) {
          final data = jsonDecode(res.data!);
          final items = data['listClients']?['items'] as List? ?? [];
          for (var item in items) {
            final name = item['name']?.toString().trim();
            final phone = item['phone']?.toString().trim() ?? '';
            final email = item['email']?.toString().trim() ?? '';
            if (name != null && name.isNotEmpty) {
              String regNo = item['registration_number']?.toString() ?? item['case_number']?.toString() ?? '';
              String fileNo = item['file_no']?.toString() ?? '';
              if (regNo == fileNo && !regNo.startsWith('CUC-')) {
                regNo = ''; // Don't show file no as reg no
              }
              final clientData = {
                'phone': phone,
                'email': email,
                'reg_no': regNo,
              };
              _clientDetailsCacheV2![name] = clientData;
              _clientDetailsCacheV2![name.toLowerCase()] = clientData;

              // Also index companies if present
              final comps = item['companies'] as List?;
              if (comps != null) {
                for (final comp in comps) {
                  final parts = comp.toString().split('|||');
                  if (parts.isNotEmpty) {
                    final compName = parts[0].trim();
                    if (compName.isNotEmpty) {
                      final compPhone = parts.length > 2 && parts[2].trim().isNotEmpty ? parts[2].trim() : phone;
                      final compData = {
                        'phone': compPhone,
                        'email': email,
                        'reg_no': regNo,
                      };
                      _clientDetailsCacheV2![compName] = compData;
                      _clientDetailsCacheV2![compName.toLowerCase()] = compData;
                    }
                  }
                }
              }
            }
          }
          nextToken = data['listClients']?['nextToken']?.toString();
        } else {
          break;
        }
      } while (nextToken != null);

      _cacheTimeV2 = DateTime.now();
      return _clientDetailsCacheV2!;
    } catch (e) {
      print('Error fetching clients raw: $e');
      return _clientDetailsCacheV2 ?? {};
    }
  }


  Future<List<Billing>> fetchBillings({
    required int limit,
    required int offset,
    String statusFilter = 'All',
    String typeFilter = 'All',
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'Newest First',
    String searchTerm = '',
  }) async {
    var req = ModelQueries.list(Billings.classType, limit: 10000);
    List<Billings> all = [];
    while (true) {
      final res = await Amplify.API.query(request: req).response;
      all.addAll((res.data?.items ?? []).whereType<Billings>() ?? []);
      if (res.data?.hasNextResult ?? false) {
        req = res.data!.requestForNextResult!;
      } else {
        break;
      }
    }
    
    // Sort descending by ID or date (using ID for now as original code used order by id)
    var allList = all.toList()..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));

    final clientDetails = await _getClientDetailsMap();

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

      if (statusFilter == 'All') {
        match = true;
      } else if (statusFilter == 'Paid' && isPaid) {
        match = true;
      } else if (statusFilter == 'Pending' && isPending) {
        match = true;
      } else if (statusFilter == 'Pending Invoices' && isPending && b.type != 'QUOTATION') {
        match = true;
      } else if (statusFilter == 'Overdue' && isPending) {
        match = true;
      } else if (statusFilter == 'Interested' && b.status == 'Interested') {
        match = true;
      } else if (statusFilter == 'Not Interested' && b.status == 'Not Interested') {
        match = true;
      }
      
      if (match && typeFilter != 'All') {
        if (typeFilter == 'Quotation' && b.type != 'QUOTATION') {
          match = false;
        } else if (typeFilter == 'Invoice' && b.type == 'QUOTATION') {
          match = false;
        } else if (typeFilter == 'Pending Invoice' && (b.type == 'QUOTATION' || !isPending)) {
          match = false;
        }
      }
      
      if (match && searchTerm.isNotEmpty) {
        final query = searchTerm.toLowerCase();
        final cName = b.client_name?.toLowerCase() ?? '';
        final invNo = b.invoice_no?.toLowerCase() ?? '';
        final dataStr = b.data?.toLowerCase() ?? '';
        final amt = b.amount?.toLowerCase() ?? '';
        final phone = clientDetails[b.client_name]?['phone']?.toLowerCase() ?? '';
        if (!cName.contains(query) && 
            !invNo.contains(query) &&
            !dataStr.contains(query) &&
            !amt.contains(query) &&
            !phone.contains(query)) {
          match = false;
        }
      }

      if (match) filtered.add(b);
    }

    var billings = filtered.map((m) {
      final map = m.toMap();
      map['created_at'] = m.created_at ?? m.createdAt?.toString();
      
      final clientNameKey = m.client_name?.trim() ?? '';
      final clientInfo = clientDetails[clientNameKey] ??
          clientDetails[clientNameKey.toLowerCase()] ??
          clientDetails.entries.firstWhere(
            (e) => (clientNameKey.isNotEmpty &&
                (e.key.toLowerCase().contains(clientNameKey.toLowerCase()) ||
                 clientNameKey.toLowerCase().contains(e.key.toLowerCase()))),
            orElse: () => const MapEntry('', {}),
          ).value;

      String phone = clientInfo['phone'] ?? '';
      String regNo = clientInfo['reg_no'] ?? '';
      String email = clientInfo['email'] ?? '';
      String dataStr = map['data']?.toString() ?? '{}';
      try {
        var dataMap = jsonDecode(dataStr);
        if (dataMap is Map) {
          if (phone.isNotEmpty) {
            dataMap['client_phone'] = phone;
          } else if (dataMap['client_phone'] != null && dataMap['client_phone'].toString().trim().isNotEmpty) {
            phone = dataMap['client_phone'].toString().trim();
          }
          if (regNo.isNotEmpty) dataMap['client_reg_no'] = regNo;
          if (email.isNotEmpty && (dataMap['client_email'] == null || dataMap['client_email'].toString().isEmpty)) {
            dataMap['client_email'] = email;
          }
          map['data'] = jsonEncode(dataMap);
        }
      } catch(_) {
        map['data'] = jsonEncode({'client_phone': phone, 'client_reg_no': regNo, 'client_email': email});
      }
      
      return Billing.fromMap(map);
    }).toList();

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

    int compareByDate(Billing a, Billing b, bool descending) {
      DateTime dateA = DateTime.fromMillisecondsSinceEpoch(0);
      DateTime dateB = DateTime.fromMillisecondsSinceEpoch(0);
      
      // Use INVOICE DATE exclusively for chronological sorting
      if (a.date != null && a.date!.isNotEmpty) {
        try {
          var dateStr = a.date!.replaceAll('-', '/');
          final p = dateStr.split('/');
          if (p.length == 3) dateA = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        } catch (_) {}
      }
      if (dateA.millisecondsSinceEpoch == 0 && a.createdAt != null) {
        try { dateA = DateTime.parse(a.createdAt!); } catch (_) {}
      }

      if (b.date != null && b.date!.isNotEmpty) {
        try {
          var dateStr = b.date!.replaceAll('-', '/');
          final p = dateStr.split('/');
          if (p.length == 3) dateB = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        } catch (_) {}
      }
      if (dateB.millisecondsSinceEpoch == 0 && b.createdAt != null) {
        try { dateB = DateTime.parse(b.createdAt!); } catch (_) {}
      }
      
      int comp = descending ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
      if (comp == 0) {
        // Fallback to true creation time!
        DateTime createA = DateTime.fromMillisecondsSinceEpoch(0);
        DateTime createB = DateTime.fromMillisecondsSinceEpoch(0);
        try { if (a.createdAt != null) createA = DateTime.parse(a.createdAt!.toString()); } catch (_) {}
        try { if (b.createdAt != null) createB = DateTime.parse(b.createdAt!.toString()); } catch (_) {}
        
        int createComp = descending ? createB.compareTo(createA) : createA.compareTo(createB);
        if (createComp != 0) return createComp;

        // Ultimate fallback to ID which is sequential
        int idA = int.tryParse(a.id) ?? 0;
        int idB = int.tryParse(b.id) ?? 0;
        return descending ? idB.compareTo(idA) : idA.compareTo(idB);
      }
      return comp;
    }

    // Apply sorting
    billings.sort((a, b) {
      if (sortBy == 'Newest First' || sortBy == 'Oldest First') {
        return compareByDate(a, b, sortBy == 'Newest First');
      }
      else if (sortBy == 'Legal First') {
        if (a.category == b.category) return compareByDate(a, b, true);
        return a.category == 'Legal' ? -1 : 1;
      }
      else if (sortBy == 'Consultancy First') {
        if (a.category == b.category) return compareByDate(a, b, true);
        return a.category == 'Consultancy' ? -1 : 1;
      }
      else if (sortBy == 'Highest Amount' || sortBy == 'Lowest Amount') {
        double amtA = NumberToWords.parseCurrency(a.amount ?? '0');
        double amtB = NumberToWords.parseCurrency(b.amount ?? '0');
        return sortBy == 'Highest Amount' ? amtB.compareTo(amtA) : amtA.compareTo(amtB);
      }
      else if (sortBy == 'Invoice No (A-Z)' || sortBy == 'Invoice No (Z-A)') {
        String invA = a.invoiceNo ?? '';
        String invB = b.invoiceNo ?? '';
        return sortBy == 'Invoice No (A-Z)' ? invA.compareTo(invB) : invB.compareTo(invA);
      }
      return 0;
    });

    // Apply pagination AFTER filtering
    final paginated = billings.skip(offset).take(limit).toList();
    return paginated;
  }

  Future<void> updateBilling(dynamic id, Map<String, dynamic> updates) async {
    final req = ModelQueries.get(Billings.classType, BillingsModelIdentifier(id: id.toString()));
    final res = await Amplify.API.query(request: req).response;
    if (res.data != null) {
      final b = res.data!;
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
      await BackupAwareApi().update(updated);
    }
  }

  Future<void> deleteBilling(dynamic id) async {
    await BackupAwareApi().deleteById(
        Billings.classType, 
        BillingsModelIdentifier(id: id.toString())
    );
  }

  Future<String?> getNextInvoiceNo(String prefix) async {
    var req = ModelQueries.list(Billings.classType, limit: 10000);
    List<Billings> all = [];
    while (true) {
      final res = await Amplify.API.query(request: req).response;
      all.addAll((res.data?.items ?? []).whereType<Billings>() ?? []);
      if (res.data?.hasNextResult ?? false) {
        req = res.data!.requestForNextResult!;
      } else {
        break;
      }
    }
    
    final matching = all.where((b) => b.invoice_no != null && 
b.invoice_no!.toLowerCase().startsWith(prefix.toLowerCase())).toList();
      
      int maxNum = 0;
      String? bestLast;
      for (var b in matching) {
        final match = RegExp(r'(\d+)$').firstMatch(b.invoice_no!.trim());
        if (match != null) {
          final num = int.tryParse(match.group(1)!);
          if (num != null && num > maxNum) {
            maxNum = num;
            bestLast = b.invoice_no!.trim();
          }
        }
      }

      if (bestLast != null) {
        final match = RegExp(r'(\d+)$').firstMatch(bestLast);
        final numStr = match!.group(1)!;
        final num = maxNum + 1;
        return bestLast.substring(0, bestLast.length - numStr.length) + num.toString().padLeft(numStr.length, '0');
      }
      return null;
  }

  Future<String?> getClientPhone(String clientName) async {
    final clean = clientName.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // 1. Check client details cache
    try {
      final detailsMap = await _getClientDetailsMap();
      if (detailsMap[clientName]?['phone']?.isNotEmpty == true) {
        return detailsMap[clientName]!['phone'];
      }
      if (detailsMap[clean]?['phone']?.isNotEmpty == true) {
        return detailsMap[clean]!['phone'];
      }
      for (final entry in detailsMap.entries) {
        final k = entry.key.toLowerCase().trim();
        if ((k == clean || k.contains(clean) || clean.contains(k)) &&
            entry.value['phone']?.isNotEmpty == true) {
          return entry.value['phone'];
        }
      }
    } catch (_) {}

    // 2. Query Clients table directly with case-insensitive / partial match
    try {
      final req = ModelQueries.list(Clients.classType, limit: 1000);
      final res = await Amplify.API.query(request: req).response;
      final clients = (res.data?.items ?? []).whereType<Clients>().toList();

      // Exact normalized match
      for (final c in clients) {
        final cName = (c.name ?? '').trim().toLowerCase();
        if (cName == clean && c.phone != null && c.phone!.trim().isNotEmpty) {
          return c.phone!.trim();
        }
      }

      // Partial / contains match & companies
      for (final c in clients) {
        final cName = (c.name ?? '').trim().toLowerCase();
        if ((cName.contains(clean) || clean.contains(cName)) && c.phone != null && c.phone!.trim().isNotEmpty) {
          return c.phone!.trim();
        }
        if (c.companies != null) {
          for (final comp in c.companies!) {
            final parts = comp.split('|||');
            if (parts.isNotEmpty) {
              final compName = parts[0].trim().toLowerCase();
              if (compName == clean || compName.contains(clean) || clean.contains(compName)) {
                if (parts.length > 2 && parts[2].trim().isNotEmpty) return parts[2].trim();
                if (c.phone != null && c.phone!.trim().isNotEmpty) return c.phone!.trim();
              }
            }
          }
        }
      }
    } catch (_) {}

    // 3. Fallback: Search Contacts table
    try {
      final contactReq = ModelQueries.list(Contacts.classType, limit: 500);
      final contactRes = await Amplify.API.query(request: contactReq).response;
      final contacts = (contactRes.data?.items ?? []).whereType<Contacts>().toList();
      for (final c in contacts) {
        final cName = (c.name ?? '').trim().toLowerCase();
        if (cName == clean || cName.contains(clean) || clean.contains(cName)) {
          final p = c.personal_number?.trim() ?? c.official_number?.trim() ?? '';
          if (p.isNotEmpty) return p;
        }
      }
    } catch (_) {}

    return null;
  }

  Future<List<Billing>> getClientLedger(String clientName) async {
    var req = ModelQueries.list(Billings.classType, where: Billings.CLIENT_NAME.contains(clientName), limit: 10000);
    List<Billings> all = [];
    while (true) {
      final res = await Amplify.API.query(request: req).response;
      all.addAll((res.data?.items ?? []).whereType<Billings>() ?? []);
      if (res.data?.hasNextResult ?? false) {
        req = res.data!.requestForNextResult!;
      } else {
        break;
      }
    }
    
    // Filter locally to ensure it's actually the same client (handling cases where name has suffixes)
    final cNameLower = clientName.toLowerCase().trim();
    all = all.where((b) {
      final bNameLower = (b.client_name ?? '').toLowerCase().trim();
      return bNameLower.startsWith(cNameLower) || cNameLower.startsWith(bNameLower) || bNameLower == cNameLower;
    }).toList();

    var allList = all.toList()..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
    return allList.map((b) => Billing.fromMap(b.toMap())).toList();
  }

  Future<String> getNextBillingId() async {
    try {
      int maxId = 0;
      var req = ModelQueries.list(Billings.classType, limit: 10000);
      while (true) {
        final res = await Amplify.API.query(request: req).response;
        final all = (res.data?.items ?? []).whereType<Billings>() ?? [];
        for (var b in all) {
          final idVal = int.tryParse(b.id);
          if (idVal != null && idVal > maxId) {
            maxId = idVal;
          }
        }
        if (res.data?.hasNextResult ?? false) {
          req = res.data!.requestForNextResult!;
        } else {
          break;
        }
      }
      return (maxId > 0 ? maxId + 1 : 5000).toString();
    } catch (_) {
      return (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    }
  }

  /// Check online payment status for a billing item with a Razorpay link or order.
  /// If paid, automatically marks the bill as Received/Paid, sets payment_received=true,
  /// balance_due='0/-', syncs client balance, and saves across DynamoDB and Supabase.
  Future<bool> syncRazorpayPaymentForBilling(Billing billing) async {
    final data = billing.data != null ? Map<String, dynamic>.from(billing.data!) : <String, dynamic>{};
    final linkId = data['razorpay_link_id']?.toString() ?? data['payment_link_id']?.toString();

    if (linkId == null || linkId.isEmpty) return false;

    // If already marked as received, return true
    if (billing.status == 'Received' && data['payment_received'] == true) {
      return true;
    }

    try {
      final link = await RazorpayService().fetchPaymentLink(linkId);
      if (link != null && (link.status == 'paid' || link.status == 'partially_paid')) {
        await markBillingAsPaidFromRazorpay(
          billing: billing,
          paidAmount: link.amount,
          paymentId: link.id,
        );
        return true;
      }
    } catch (e) {
      safePrint('Error syncing Razorpay payment for billing ${billing.invoiceNo}: $e');
    }
    return false;
  }

  Future<void> markBillingAsPaidFromRazorpay({
    required Billing billing,
    required double paidAmount,
    String? paymentId,
  }) async {
    final data = billing.data != null ? Map<String, dynamic>.from(billing.data!) : <String, dynamic>{};
    data['payment_received'] = true;
    data['payment_date'] = DateTime.now().toIso8601String();
    data['marked_paid_by'] = 'Razorpay Auto-Sync';
    data['balance_due'] = '0/-';
    data['advance_received'] = paidAmount.toStringAsFixed(0);
    if (paymentId != null) {
      data['razorpay_payment_id'] = paymentId;
    }
    data['razorpay_paid_at'] = DateTime.now().toIso8601String();

    final model = Billings(
      id: billing.id.toString(),
      client_name: billing.clientName,
      invoice_no: billing.invoiceNo,
      date: billing.date,
      amount: billing.amount,
      type: billing.type,
      category: billing.category,
      authorities: billing.authorities,
      status: 'Received',
      data: jsonEncode(data),
    );

    await BackupAwareApi().update(model);
    if (billing.clientName != null && billing.clientName!.isNotEmpty) {
      try {
        await syncClientBalance(billing.clientName!);
      } catch (_) {}
    }
  }
}

