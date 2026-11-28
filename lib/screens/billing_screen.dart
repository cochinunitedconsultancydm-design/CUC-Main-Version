import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
import 'package:printing/printing.dart';
import '../models/billing.dart';
import '../services/billing_service.dart';
import '../services/client_service.dart';
import '../services/excel_service.dart';
import '../services/logging_service.dart';
import '../services/invoice_pdf_service.dart';
import '../services/deal_service.dart';
import '../services/auth_service.dart';
import '../utils/number_to_words.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/compact_date_range_picker.dart';
import '../services/razorpay_service.dart';
import '../services/supabase_backup_service.dart';
import '../services/meta_service.dart';
import '../services/receipt_service.dart';
class BillingScreen extends StatefulWidget {
  final String? initialStatusFilter;
  final String? initialTypeFilter;
  const BillingScreen({super.key, this.initialStatusFilter, this.initialTypeFilter});
  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _billingService = BillingService();
  
  final _excel = ExcelService();
  final _log = LoggingService();

  List<Billing> _billings = [];
  bool _isAdmin = false;
  bool _isAmarnath = false;
  String _currentUserName = '';
  String _currentUserRole = '';
  bool _isLoading = true;
  bool _isFetchingMore = false;
  final int _limit = 50;
  int _offset = 0;
  bool _hasMore = true;
  String _searchTerm = '';
  Timer? _debounce;
  Timer? _razorpayAutoSyncTimer;
  bool _isAutoCheckingRazorpay = false;
  final FocusNode _searchFocusNode = FocusNode();
  String _statusFilter = 'All';
  String _typeFilter = 'All';
  String _sortBy = 'Newest First';
  DateTime? _startDate;
  DateTime? _endDate;

  int _totalInvoices = 0;
  int _totalPaid = 0;
  int _totalPending = 0;
  int _totalPendingInvoices = 0;

  static const List<String> _editReasonCategories = [
    'Price / Amount Correction',
    'Client Information / Address Update',
    'Scope / Items Modification',
    'Payment Terms / Due Date Adjustment',
    'Discount / Advance Revision',
    'Quotation Negotiation Update',
    'Typo or Billing Mistake',
    'Other (Specify Reason Below)',
  ];

  static const staffMapping = {
    'Sarath': 'A',
    'Jesna': 'B',
    'Soumya': 'C',
    'Nithya': 'D',
    'Irshad': 'E',
    'Construction & Supervising': 'F',
    'Aswini': 'G',
    'Ashwini': 'G',
    'Harshina': 'H',
    'Darshana': 'I',
    'Jitha': 'J',
    'Sariga': 'K',
    'Anoop': 'AN',
    'Arya': 'AR',
    'Pooja': 'P',
    'Jayan & Midhun': 'VP',
  };

  @override
  void initState() { 
    super.initState();
    if (widget.initialStatusFilter != null) _statusFilter = widget.initialStatusFilter!;
    if (widget.initialTypeFilter != null) _typeFilter = widget.initialTypeFilter!;
    _initRole();
    _fetchBillings(refresh: true); 

    // Automatically check status of pending Razorpay payment links periodically (every 45s)
    _razorpayAutoSyncTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted) _autoCheckPendingRazorpayLinks();
    });
  }

  Future<void> _initRole() async {
    final isAdmin = await AuthService().isAdmin();
    final userName = await AuthService().getUserName();
    final role = await AuthService().getUserRole();
    final isAmarnath = userName?.toLowerCase().trim() == 'amarnath';
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isAmarnath = isAmarnath;
        _currentUserName = userName ?? '';
        _currentUserRole = role ?? 'staff';
      });
    }
  }

  @override
  void dispose() {
    _razorpayAutoSyncTimer?.cancel();
    _debounce?.cancel();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getFullAuthorityName(String? auth, [String? invNo, dynamic data]) {
    String? cleanAuth = auth?.trim();

    // Check if data payload has 'created_by'
    if ((cleanAuth == null || cleanAuth.isEmpty || cleanAuth.toLowerCase() == 'admin') && data != null) {
      String? cb;
      if (data is Map) {
        cb = data['created_by']?.toString().trim();
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) cb = decoded['created_by']?.toString().trim();
        } catch (_) {}
      }
      if (cb != null && cb.isNotEmpty && cb.toLowerCase() != 'admin') {
        cleanAuth = cb;
      }
    }

    // Fallback for bills created by Harshina that defaulted to Admin
    if ((cleanAuth == null || cleanAuth.isEmpty || cleanAuth.toLowerCase() == 'admin') && invNo != null) {
      const knownHarshinaInvoices = {'AA-049', 'AA-050', 'AA-051', 'CC-056'};
      if (knownHarshinaInvoices.contains(invNo.trim().toUpperCase())) {
        cleanAuth = 'H - Harshina';
      }
    }

    if (cleanAuth != null && cleanAuth.isNotEmpty) {
      final clean = cleanAuth;
      
      // If already formatted as "K - Sariga", format nicely as "Sariga (K)"
      if (clean.contains('-')) {
        final parts = clean.split('-');
        final prefix = parts.first.trim();
        final name = parts.last.trim();
        if (name.isNotEmpty && prefix.isNotEmpty) {
          return '$name ($prefix)';
        }
        return name.isNotEmpty ? name : clean;
      }
      
      final upper = clean.toUpperCase();
      // Match letter code or name against staffMapping
      for (final entry in staffMapping.entries) {
        if (entry.value.toUpperCase() == upper || entry.key.toUpperCase() == upper) {
          return '${entry.key} (${entry.value})';
        }
      }
      for (final entry in staffMapping.entries) {
        if (upper.contains(entry.key.toUpperCase()) || entry.key.toUpperCase().contains(upper)) {
          return '${entry.key} (${entry.value})';
        }
      }
      
      if (clean == 'CUC') return 'Cochin United Consultancy';
      if (clean == 'AA') return 'Aakrithi';
      
      return clean;
    }
    
    // Check if invoice number prefix maps to a staff or firm
    if (invNo != null && invNo.isNotEmpty) {
      final prefix = invNo.split(RegExp(r'[ \-]')).first.toUpperCase();
      for (final entry in staffMapping.entries) {
        if (entry.value.toUpperCase() == prefix) {
          return '${entry.key} (${entry.value})';
        }
      }
      if (prefix == 'CUC' || prefix == 'CC') return 'Cochin United Consultancy';
      if (prefix == 'AA') return 'Aakrithi';
    }
    
    return 'Admin';
  }

  String _getStaffDisplayName(String? auth, [String? invNo, dynamic data]) {
    String? cleanAuth = auth?.trim();

    // Check if data payload has 'created_by'
    if ((cleanAuth == null || cleanAuth.isEmpty || cleanAuth.toLowerCase() == 'admin') && data != null) {
      String? cb;
      if (data is Map) {
        cb = data['created_by']?.toString().trim();
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) cb = decoded['created_by']?.toString().trim();
        } catch (_) {}
      }
      if (cb != null && cb.isNotEmpty && cb.toLowerCase() != 'admin') {
        cleanAuth = cb;
      }
    }

    // Fallback for bills created by Harshina that defaulted to Admin
    if ((cleanAuth == null || cleanAuth.isEmpty || cleanAuth.toLowerCase() == 'admin') && invNo != null) {
      const knownHarshinaInvoices = {'AA-049', 'AA-050', 'AA-051', 'CC-056'};
      if (knownHarshinaInvoices.contains(invNo.trim().toUpperCase())) {
        cleanAuth = 'H - Harshina';
      }
    }

    if (cleanAuth != null && cleanAuth.isNotEmpty) {
      final clean = cleanAuth;
      
      // If it's formatted as "K - Sariga", extract the full staff name
      if (clean.contains('-')) {
        final parts = clean.split('-');
        final namePart = parts.last.trim();
        if (namePart.isNotEmpty) {
          return namePart.toUpperCase();
        }
      }
      
      final upper = clean.toUpperCase();
      // Match letter code or name against staffMapping
      for (final entry in staffMapping.entries) {
        if (entry.value.toUpperCase() == upper || entry.key.toUpperCase() == upper) {
          return entry.key.toUpperCase();
        }
      }
      for (final entry in staffMapping.entries) {
        if (upper.contains(entry.key.toUpperCase()) || entry.key.toUpperCase().contains(upper)) {
          return entry.key.toUpperCase();
        }
      }
      
      return clean.toUpperCase();
    }
    
    if (invNo != null && invNo.isNotEmpty) {
      final prefix = invNo.split(RegExp(r'[ \-]')).first.toUpperCase();
      for (final entry in staffMapping.entries) {
        if (entry.value.toUpperCase() == prefix) {
          return entry.key.toUpperCase();
        }
      }
    }
    
    return '';
  }

  String _getStaffPrefix(String? auth, [String? invNo, dynamic data]) => _getStaffDisplayName(auth, invNo, data);

  Future<void> _fetchStats() async {
    try {
      final stats = await _billingService.fetchStats();
      if (mounted) {
        setState(() {
          _totalInvoices = stats['total']!;
          _totalPaid = stats['paid']!;
          _totalPending = stats['pending']!;
          _totalPendingInvoices = stats['pendingInvoices'] ?? stats['pending']!;
        });
      }
    } catch (_) {}
  }

  Future<void> _syncClientBalance(String clientName) async {
    await _billingService.syncClientBalance(clientName);
  }

  Future<void> _fetchBillings({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _hasMore = true;
      _billings.clear();
      _fetchStats();
    }
    if (!_hasMore) return;
    
    if (refresh) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isFetchingMore = true);
    }
    
    try {
      final fetched = await _billingService.fetchBillings(
        limit: _limit,
        offset: _offset,
        statusFilter: _statusFilter,
        typeFilter: _typeFilter,
        startDate: _startDate,
        endDate: _endDate,
        sortBy: _sortBy,
        searchTerm: _searchTerm,
      );
      
      if (mounted) {
        setState(() { 
          if (refresh) {
            _billings = fetched;
          } else {
            _billings.addAll(fetched);
          }
          _offset += fetched.length;
          if (fetched.length < _limit) _hasMore = false;
        });
      }
    } catch (e) { _msg('Failed: $e', false); }
    finally { 
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    }
  }

  Future<void> _autoCheckPendingRazorpayLinks() async {
    if (_isAutoCheckingRazorpay || !mounted) return;
    _isAutoCheckingRazorpay = true;
    try {
      final pendingWithLinks = _billings.where((b) {
        final isPaid = b.status == 'Received' || b.data?['payment_received'] == true || b.data?['payment_received'] == 'true';
        final hasLink = b.data?['razorpay_link_id'] != null || b.data?['payment_link_id'] != null;
        return !isPaid && hasLink;
      }).toList();

      int newlySynced = 0;
      for (final b in pendingWithLinks) {
        final updated = await _billingService.syncRazorpayPaymentForBilling(b);
        if (updated) newlySynced++;
      }

      if (newlySynced > 0 && mounted) {
        _msg('Auto-synced $newlySynced newly paid invoice(s) into Bills & Accounts/Expenses!', true);
        _fetchBillings(refresh: false);
      }
    } catch (_) {
    } finally {
      _isAutoCheckingRazorpay = false;
    }
  }

  Future<void> _markPaid(Billing b) async {
    double grandTotal = NumberToWords.parseCurrency(b.grandTotal.isNotEmpty ? b.grandTotal : (b.amount ?? '0'));
    double previouslyReceived = NumberToWords.parseCurrency(b.data?['advance_received']?.toString() ?? '0');
    double currentBalance = grandTotal - previouslyReceived;
    
    if (currentBalance <= 0) {
      _msg('This invoice is already fully paid.', true);
      return;
    }

    bool isFullPayment = true;
    bool sendReceipt = true;
    final receivedController = TextEditingController(text: currentBalance.toStringAsFixed(0));
    String dialogDiscount = b.data?['discount']?.toString() ?? '0';
    double newBalance = 0;

    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(
      builder: (context, setState) {
        double receivedAmount = double.tryParse(receivedController.text) ?? 0;
        double discountAmount = double.tryParse(dialogDiscount) ?? 0;
        newBalance = currentBalance - receivedAmount - discountAmount;
        if (newBalance < 0) newBalance = 0;

        return AlertDialog(
          title: const Text('Confirm Payment', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Outstanding Balance: ₹${NumberToWords.formatIndianCurrency(currentBalance).replaceAll('/-', '')}'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Full Payment Received?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                value: isFullPayment,
                activeThumbColor: Colors.green,
                onChanged: (val) {
                  setState(() {
                    isFullPayment = val;
                    if (val) {
                      receivedController.text = currentBalance.toStringAsFixed(0);
                    } else {
                      receivedController.clear();
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: dialogDiscount),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount Allowed (₹)', border: OutlineInputBorder(), isDense: true),
                onChanged: (val) {
                  setState(() {
                    dialogDiscount = val;
                  });
                },
              ),
              if (!isFullPayment) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: receivedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount Received (₹)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 12),
              ] else const SizedBox(height: 12),
              Text('Remaining Balance: ₹${NumberToWords.formatIndianCurrency(newBalance).replaceAll('/-', '')}', style: TextStyle(color: newBalance > 0 ? Colors.orange.shade700 : Colors.green.shade700, fontWeight: FontWeight.bold)),
              const Divider(height: 20),
              SwitchListTile(
                title: const Text('Send Receipt via WhatsApp & Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Sends official PDF receipt to client & cochinunitedconsultancydm@gmail.com', style: TextStyle(fontSize: 11)),
                value: sendReceipt,
                activeThumbColor: const Color(0xFF25D366),
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => sendReceipt = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirm')),
          ],
        );
      }
    ));

    if (ok == true) {
      try {
        double newlyReceived = double.tryParse(receivedController.text) ?? 0;
        double discountGiven = double.tryParse(dialogDiscount) ?? 0;
        
        if (newlyReceived <= 0 && discountGiven <= 0) return;

        // Log payment in accounting
        if (newlyReceived > 0) {
          await _logAccountingEntry(b, newlyReceived);
        }

        double totalReceived = previouslyReceived + newlyReceived;
        double updatedBalance = grandTotal - totalReceived - discountGiven;
        if (updatedBalance < 0) updatedBalance = 0;

        bool isPaid = updatedBalance <= 0;

        final prefs = await SharedPreferences.getInstance();
        final currentUserName = prefs.getString('user_name') ?? 'Unknown User';

        final d = Map<String, dynamic>.from(b.data ?? {});
        d['payment_received'] = isPaid;
        d['advance_received'] = NumberToWords.formatIndianCurrency(totalReceived);
        d['balance_due'] = updatedBalance > 0 ? NumberToWords.formatIndianCurrency(updatedBalance) : '0/-';
        if (isPaid) {
          d['payment_date'] = DateTime.now().toIso8601String();
          d['marked_paid_by'] = currentUserName;
        }
        if (newlyReceived > 0) d['payment_recorded_by'] = currentUserName;
        if (discountGiven > 0) d['discount_given_by'] = currentUserName;

        await _billingService.updateBilling(b.id!, {
          'status': isPaid ? 'Received' : (totalReceived > 0 ? 'Part Payment' : 'Pending'),
          'data': d,
        });
        
        // Update Client balance in database
        if (b.clientName != null && b.clientName!.isNotEmpty) {
           await _syncClientBalance(b.clientName!);
        }

        _fetchBillings(refresh: true); 
        _msg('Payment recorded successfully', true);
        await _log.logAction(action: 'INVOICE_PAYMENT', targetType: 'Invoice', targetId: b.invoiceNo ?? '', details: 'Recorded payment of ₹$newlyReceived');

        if (sendReceipt) {
          unawaited(ReceiptService().sendReceiptAutomatically(
            billing: b,
            paidAmount: newlyReceived > 0 ? newlyReceived : currentBalance,
            forceSend: true,
          ));
        }
      } catch (e) { 
        _msg('Failed: $e', false); 
      }
    }
  }

  Future<void> _sendReceiptViaWhatsAppAndEmail(Billing b) async {
    final clientName = b.clientName ?? '';
    final dataMap = b.data ?? {};

    // Resolve initial phone
    String initialPhone = '';
    for (final key in ['client_phone', 'phone', 'customer_phone', 'phone_number']) {
      final val = dataMap[key]?.toString().trim() ?? '';
      if (val.isNotEmpty) {
        initialPhone = val;
        break;
      }
    }
    if (initialPhone.isEmpty && clientName.isNotEmpty) {
      initialPhone = (await _billingService.getClientPhone(clientName)) ?? '';
    }

    // Resolve initial email
    String initialEmail = '';
    for (final key in ['client_email', 'email', 'customer_email', 'mail']) {
      final val = dataMap[key]?.toString().trim() ?? '';
      if (val.isNotEmpty && val.contains('@')) {
        initialEmail = val;
        break;
      }
    }
    if (initialEmail.isEmpty && clientName.isNotEmpty) {
      initialEmail = (await _billingService.getClientEmail(clientName)) ?? '';
    }

    final phoneCtrl = TextEditingController(text: initialPhone);
    final emailCtrl = TextEditingController(text: initialEmail);
    bool isSending = false;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Send Payment Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoice: ${b.invoiceNo ?? "N/A"} • Client: $clientName', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text('Amount: ${b.amount ?? "₹0"}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Receipt PDF will be automatically generated and sent via WhatsApp and Email (with PDF attachment to both client and cochinunitedconsultancydm@gmail.com).', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Client WhatsApp Number',
                      prefixIcon: Icon(Icons.chat_rounded, color: Colors.green),
                      hintText: 'e.g. 919876543210',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Client Email Address',
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.blue),
                      hintText: 'e.g. client@example.com',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSending ? null : () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: isSending
                    ? null
                    : () async {
                        setDialogState(() => isSending = true);
                        try {
                          final result = await ReceiptService().sendReceiptAutomatically(
                            billing: b,
                            targetPhone: phoneCtrl.text.trim(),
                            targetEmail: emailCtrl.text.trim(),
                            forceSend: true,
                          );
                          if (mounted) Navigator.pop(dialogCtx);
                          if (result.success) {
                            _msg('Receipt sent successfully via WhatsApp & Email!', true);
                          } else {
                            _msg('Result: ${result.message}', false);
                          }
                        } catch (e) {
                          if (mounted) Navigator.pop(dialogCtx);
                          _msg('Failed to send receipt: $e', false);
                        }
                      },
                icon: isSending
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(isSending ? 'Sending Receipt...' : 'Send Receipt Now'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(Billing b, String status, {String? approvedAmount, String? partPayment}) async {
    try {
      final updates = <String, dynamic>{'status': status};
      if (approvedAmount != null || partPayment != null) {
        final d = Map<String, dynamic>.from(b.data ?? {});
        if (approvedAmount != null) d['approved_amount'] = approvedAmount;
        
        if (partPayment != null && partPayment.isNotEmpty) {
          double advance = double.tryParse(partPayment) ?? 0;
          if (advance > 0) {
            // Log payment in accounting
            await _logAccountingEntry(b, advance);

            double currentAdvance = double.tryParse(d['advance_received']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
            double totalAdvance = currentAdvance + advance;
            d['advance_received'] = NumberToWords.formatIndianCurrency(totalAdvance);
            
            double approved = double.tryParse(d['approved_amount']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
            if (approved == 0) {
               approved = double.tryParse(b.amount?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
            }
            double balance = approved - totalAdvance;
            if (balance < 0) balance = 0;
            d['balance_due'] = balance > 0 ? NumberToWords.formatIndianCurrency(balance) : '0/-';
          }
        }
        updates['data'] = d;
      }
      await _billingService.updateBilling(b.id!, updates);
      _fetchBillings(refresh: true);
      _msg('Status updated to $status', true);
      await _log.logAction(action: 'INVOICE_STATUS_UPDATED', targetType: 'Invoice', targetId: b.invoiceNo ?? '', details: 'Status changed to $status');
    } catch (e) {
      _msg('Failed: $e', false);
    }
  }

  Future<void> _logAccountingEntry(Billing b, double amount) async {
    try {
      final uname = await AuthService().getUserName();
      await _billingService.logAccountingEntryForPayment(
        billing: b,
        paidAmount: amount,
        recorderName: uname,
        paymentMode: 'Manual Payment Entry',
      );
    } catch (e) {
      debugPrint('Failed to log accounting entry: $e');
    }
  }

  Future<void> _syncOldBillsToAccounting() async {
    setState(() => _isLoading = true);
    _msg('Starting sync of old bills to accounting...', true);
    try {
      final uid = await AuthService().getUserId();
      final uname = await AuthService().getUserName();
      
      final allBillings = await _billingService.fetchBillings(limit: 1000, offset: 0); 
      
      final req = ModelQueries.list(CompanyBills.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      final existingBills = (res.data?.items ?? []).whereType<CompanyBills>().toList() ?? [];
      
      int added = 0;
      
      for (final b in allBillings) {
        double amountToLog = 0;
        
        String creatorName = uname ?? '';
        if (b.authorities != null && b.authorities!.isNotEmpty) {
          final parts = b.authorities!.split('-');
          if (parts.length > 1) {
            creatorName = parts.last.trim();
          } else {
            creatorName = b.authorities!.trim();
          }
        }
        
        final bool isPaid = b.data?['payment_received'] == true || b.data?['payment_received'] == 'true';
        if (isPaid) {
           amountToLog = double.tryParse(b.amount?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
        } 
        else if (b.data?['advance_received'] != null) {
           amountToLog = double.tryParse(b.data!['advance_received'].toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
        }
        
        if (amountToLog > 0) {
          double totalAmount = double.tryParse(b.amount?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
          String paymentType = (amountToLog >= totalAmount) ? 'Full Payment' : 'Part Payment';
          
          final targetTitle = '${b.type ?? 'Invoice'} Payment ($paymentType) - ${b.invoiceNo ?? ''}';
          final exists = existingBills.any((eb) => eb.title == targetTitle || eb.title == '${b.type ?? 'Invoice'} Payment - ${b.invoiceNo ?? ''}');
          
          if (!exists) {
            DateTime parsedDate = DateTime.now();
            if (b.date != null && b.date!.isNotEmpty) {
              try {
                parsedDate = DateFormat('dd/MM/yyyy').parseLoose(b.date!);
              } catch (_) {}
            }
            
            final bill = CompanyBills(
              category: 'Client Payment',
              title: targetTitle,
              amount: -amountToLog.abs(),
              bill_date: parsedDate.toIso8601String(),
              status: 'Paid',
              description: 'Payment from ${b.clientName ?? 'Client'}. Auto-logged from Billing.',
              spent_by: int.tryParse(uid?.toString() ?? ''),
              spent_by_name: creatorName,
            );
            
            await BackupAwareApi().create(bill);
            added++;
          }
        }
      }
      _msg('Sync complete! Added $added old payments to accounting.', true);
    } catch (e) {
      _msg('Failed to sync: $e', false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markInterested(Billing b) async {
    final controller = TextEditingController(text: b.data?['approved_amount']?.toString() ?? b.amount?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '');
    final partPaymentController = TextEditingController();
    bool includePartPayment = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Approve Quotation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter the approved amount for this quotation:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Approved Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Add Part Payment / Advance?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                value: includePartPayment,
                activeThumbColor: Colors.teal,
                onChanged: (val) {
                  setModalState(() {
                    includePartPayment = val;
                    if (!val) partPaymentController.clear();
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              if (includePartPayment) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: partPaymentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Part Payment (₹)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(c, true), 
              child: const Text('Confirm')
            ),
          ],
        )
      )
    );

    if (ok == true) {
      await _updateStatus(b, 'Interested', approvedAmount: controller.text, partPayment: includePartPayment ? partPaymentController.text : null);
    }
  }

  Future<void> _deleteBilling(Billing b) async {
    if (!_isAdmin) {
      _msg('Permission Denied: Only Admin can delete invoices', false);
      return;
    }
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      content: Text('Are you sure you want to delete invoice ${b.invoiceNo}?\nThis action cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(c, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Delete'),
        ),
      ],
    ));
    if (ok == true) {
      try {
        await _billingService.deleteBilling(b.id!);
        if (b.clientName != null && b.clientName!.isNotEmpty) {
           await _syncClientBalance(b.clientName!);
        }
        _fetchBillings(refresh: true); _msg('Invoice deleted', true);
        await _log.logAction(action: 'INVOICE_DELETED', targetType: 'Invoice', targetId: b.invoiceNo ?? '', details: 'Deleted invoice');
      } catch (e) { _msg('Failed: $e', false); }
    }
  }

  Future<void> _duplicateBilling(Billing b) async {
    final auth = b.authorities ?? '';
    String nextNo = '';
    final prefix = b.type == 'QUOTATION' ? 'CC-' : 'AA-';
    final next = await _billingService.getNextInvoiceNo(prefix);
    if (next != null) {
      nextNo = next;
    } else {
      nextNo = '${prefix}001';
    }

    final duplicated = Billing(
      clientName: b.clientName,
      invoiceNo: nextNo,
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      amount: b.amount,
      type: b.type,
      category: b.category,
      authorities: b.authorities,
      status: 'Pending',
      data: Map<String, dynamic>.from(b.data ?? {})
        ..remove('payment_received')
        ..remove('advance_received')
        ..remove('payment_date')
        ..remove('balance_due'),
    );

    _openCreator(duplicated);
  }

  Future<void> _convertToInvoice(Billing b) async {
    final auth = b.authorities ?? '';
    String nextNo = '';
    final prefix = 'AA-';
    final next = await _billingService.getNextInvoiceNo(prefix);
    if (next != null) {
      nextNo = next;
    } else {
      nextNo = '${prefix}001';
    }

    final converted = Billing(
      clientName: b.clientName,
      invoiceNo: nextNo,
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      amount: b.amount,
      type: 'INVOICE',
      category: b.category,
      authorities: b.authorities,
      status: 'Pending',
      data: Map<String, dynamic>.from(b.data ?? {})
        ..remove('payment_received')
        ..remove('payment_date')
        ..remove('quotation_terms'),
    );

    _openCreator(converted);
  }

  double _getPayableAmount(Billing b) {
    try {
      if (b.data?['balance_due'] != null && b.data!['balance_due'].toString().trim().isNotEmpty) {
        final bal = NumberToWords.parseCurrency(b.data!['balance_due'].toString());
        if (bal > 0) return bal;
      }
      final grandTotal = NumberToWords.parseCurrency(b.grandTotal.isNotEmpty ? b.grandTotal : (b.amount ?? '0'));
      final previouslyReceived = NumberToWords.parseCurrency(
        b.data?['advance_received']?.toString() ?? b.data?['received_amount']?.toString() ?? '0'
      );
      final discount = NumberToWords.parseCurrency(b.data?['discount']?.toString() ?? '0');
      final balance = grandTotal - previouslyReceived - discount;
      if (balance > 0) return balance;
      if (grandTotal > 0) return grandTotal;
      return NumberToWords.parseCurrency(b.amount ?? '0');
    } catch (_) {
      return NumberToWords.parseCurrency(b.amount ?? '0');
    }
  }

  Future<void> _showRazorpayPaymentLinkDialog(Billing b) async {
    if (b.clientName == null || b.clientName!.isEmpty) {
      _msg('Client name is required to generate payment link.', false);
      return;
    }

    String phone = '';

    // 1. Check all potential phone fields directly stored in b.data
    if (b.data != null) {
      for (final key in [
        'client_phone',
        'phone',
        'mobile',
        'client_mobile',
        'contact',
        'customer_phone',
        'whatsapp',
        'whatsapp_number',
        'phone_number'
      ]) {
        final val = b.data![key]?.toString().trim() ?? '';
        final digits = val.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 10) {
          phone = val;
          break;
        }
      }
    }

    // 2. Automatically resolve client phone via BillingService if empty
    if (phone.isEmpty && b.clientName != null && b.clientName!.trim().isNotEmpty) {
      phone = await _billingService.getClientPhone(b.clientName!) ?? '';
    }

    // 3. Clean phone format for input box (extract 10-digit standard Indian mobile or clean digits)
    var displayPhone = phone.trim();
    final digitsOnly = displayPhone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length == 10) {
      displayPhone = digitsOnly;
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      displayPhone = digitsOnly.substring(2);
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('0')) {
      displayPhone = digitsOnly.substring(1);
    }

    // Resolve client email if available
    String clientEmail = '';
    if (b.data != null) {
      for (final key in ['client_email', 'email', 'customer_email']) {
        final val = b.data![key]?.toString().trim() ?? '';
        if (val.contains('@')) {
          clientEmail = val;
          break;
        }
      }
    }

    double payableAmt = _getPayableAmount(b);
    if (payableAmt <= 0) {
      payableAmt = NumberToWords.parseCurrency(b.amount ?? '0');
    }

    String initialAmountStr = '';
    if (payableAmt > 0) {
      initialAmountStr = payableAmt % 1 == 0 ? payableAmt.toInt().toString() : payableAmt.toStringAsFixed(2);
    }

    final amountController = TextEditingController(text: initialAmountStr);
    final phoneController = TextEditingController(text: displayPhone);
    String existingLink = b.data?['razorpay_payment_link']?.toString() ?? '';

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        bool isGenerating = false;
        bool autoSendViaHook = true;
        String? generatedUrl = existingLink.isNotEmpty ? existingLink : null;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C2340).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.payment_rounded, color: Color(0xFF0C2340), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Razorpay Payment Link', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C2340))),
                              Text('Send instant online payment link via WhatsApp', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('INVOICE / BILL', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(b.invoiceNo ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CLIENT', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(b.clientName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Payment Amount (₹)',
                        prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Client WhatsApp Phone Number',
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                        hintText: 'e.g. 9876543210',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => setModalState(() => autoSendViaHook = !autoSendViaHook),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: autoSendViaHook ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: autoSendViaHook ? const Color(0xFF86EFAC) : Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: autoSendViaHook ? const Color(0xFFDCFCE7) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                autoSendViaHook ? Icons.bolt_rounded : Icons.chat_bubble_outline_rounded,
                                color: autoSendViaHook ? const Color(0xFF16A34A) : Colors.grey.shade700,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    autoSendViaHook ? 'Auto-Send via WhatsApp Hook (API)' : 'Open via WhatsApp App (wa.me)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: autoSendViaHook ? const Color(0xFF15803D) : const Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    autoSendViaHook
                                        ? 'Dispatches directly to client in background via Meta API'
                                        : 'Opens WhatsApp desktop/web app with pre-filled message',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: autoSendViaHook ? const Color(0xFF166534) : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: autoSendViaHook,
                              activeColor: const Color(0xFF16A34A),
                              onChanged: (val) => setModalState(() => autoSendViaHook = val),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (generatedUrl != null && generatedUrl.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link_rounded, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SelectableText(
                                generatedUrl,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade900),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.green),
                              tooltip: 'Copy Link',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: generatedUrl));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment link copied to clipboard!'), duration: Duration(seconds: 2)));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.green),
                              tooltip: 'Open in WhatsApp App',
                              onPressed: () async {
                                final enteredPhone = phoneController.text.trim();
                                final amtFormatted = amountController.text.trim();
                                final message = "*Cochin United Consultancy*\n"
                                    "Payment Request for Invoice: *${b.invoiceNo ?? ''}*\n\n"
                                    "Dear *${b.clientName ?? 'Client'}*,\n"
                                    "Please use the secure link below to complete your payment of *₹$amtFormatted*:\n\n"
                                    "🔗 *Payment Link:* $generatedUrl\n\n"
                                    "Accepted Payment Modes:\n"
                                    "✅ UPI (Google Pay, PhonePe, Paytm, BHIM)\n"
                                    "✅ Debit / Credit Cards\n"
                                    "✅ Net Banking\n\n"
                                    "Thank you for choosing Cochin United Consultancy!";
                                await WhatsAppCloudService.launchWhatsAppApp(phone: enteredPhone, message: message);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isGenerating ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        if (generatedUrl != null && generatedUrl.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: isGenerating ? null : () async {
                              setModalState(() => isGenerating = true);
                              try {
                                final isPaid = await _billingService.syncRazorpayPaymentForBilling(b);
                                if (isPaid) {
                                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                                  _msg('Payment verified! Invoice marked as Paid / Received.', true);
                                  _fetchBillings(refresh: true);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Payment not completed yet on Razorpay.'),
                                      backgroundColor: Colors.orange,
                                    ));
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status check note: $e')));
                              } finally {
                                if (mounted) setModalState(() => isGenerating = false);
                              }
                            },
                            icon: const Icon(Icons.sync_rounded, size: 16),
                            label: const Text('Check Status'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0284C7),
                              side: const BorderSide(color: Color(0xFF38BDF8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: isGenerating ? null : () async {
                              final enteredPhone = phoneController.text.trim();
                              final amtFormatted = amountController.text.trim();
                              final message = "*Cochin United Consultancy*\n"
                                  "Payment Request for Invoice: *${b.invoiceNo ?? ''}*\n\n"
                                  "Dear *${b.clientName ?? 'Client'}*,\n"
                                  "Please use the secure link below to complete your payment of *₹$amtFormatted*:\n\n"
                                  "🔗 *Payment Link:* $generatedUrl\n\n"
                                  "Accepted Payment Modes:\n"
                                  "✅ UPI (Google Pay, PhonePe, Paytm, BHIM)\n"
                                  "✅ Debit / Credit Cards\n"
                                  "✅ Net Banking\n\n"
                                  "Thank you for choosing Cochin United Consultancy!";
                              await WhatsAppCloudService.launchWhatsAppApp(phone: enteredPhone, message: message);
                            },
                            icon: const Icon(Icons.open_in_new_rounded, size: 16),
                            label: const Text('Open App'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF334155),
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: isGenerating ? null : () async {
                            final enteredAmount = double.tryParse(amountController.text.replaceAll(',', '').trim()) ?? 0;
                            final enteredPhone = phoneController.text.trim();

                            if (enteredAmount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red));
                              return;
                            }
                            if (enteredPhone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter client WhatsApp number'), backgroundColor: Colors.red));
                              return;
                            }

                            setModalState(() => isGenerating = true);

                            try {
                              final linkResult = await RazorpayService().createPaymentLink(
                                amount: enteredAmount,
                                invoiceNo: b.invoiceNo ?? 'INV',
                                clientName: b.clientName ?? 'Valued Client',
                                clientPhone: enteredPhone,
                                clientEmail: clientEmail.isNotEmpty ? clientEmail : null,
                                billingId: b.id,
                              );

                              final updatedData = Map<String, dynamic>.from(b.data ?? {});
                              updatedData['razorpay_payment_link'] = linkResult.shortUrl;
                              updatedData['razorpay_link_id'] = linkResult.id;
                              if (enteredPhone.isNotEmpty) {
                                updatedData['client_phone'] = enteredPhone;
                              }
                              await _billingService.updateBilling(b.id, {'data': updatedData});

                              final amtFormatted = NumberToWords.formatIndianCurrency(linkResult.amount).replaceAll('/-', '');
                              final message = "*Cochin United Consultancy*\n"
                                  "Payment Request for Invoice: *${b.invoiceNo ?? ''}*\n\n"
                                  "Dear *${b.clientName ?? 'Client'}*,\n"
                                  "Please use the secure link below to complete your payment of *₹$amtFormatted*:\n\n"
                                  "🔗 *Payment Link:* ${linkResult.shortUrl}\n\n"
                                  "Accepted Payment Modes:\n"
                                  "✅ UPI (Google Pay, PhonePe, Paytm, BHIM)\n"
                                  "✅ Debit / Credit Cards\n"
                                  "✅ Net Banking\n\n"
                                  "Thank you for choosing Cochin United Consultancy!";

                              await Clipboard.setData(ClipboardData(text: linkResult.shortUrl));

                              if (autoSendViaHook) {
                                // Auto-send directly through WhatsApp Cloud API Hook
                                final sendResult = await WhatsAppCloudService().sendMessage(
                                  toPhone: enteredPhone,
                                  message: message,
                                );

                                if (sendResult.success) {
                                  await LoggingService().logAction(
                                    action: 'PAYMENT_LINK_SENT_VIA_HOOK',
                                    targetType: 'Invoice',
                                    targetId: b.invoiceNo ?? b.id ?? '',
                                    details: 'Sent Razorpay payment link of ₹${linkResult.amount} for ${b.invoiceNo} automatically to $enteredPhone via WhatsApp Hook (Message ID: ${sendResult.messageId ?? "N/A"})',
                                  );

                                  if (mounted) {
                                    Navigator.pop(context);
                                    _msg('✅ Payment link automatically sent to $enteredPhone via WhatsApp Hook!', true);
                                    _fetchBillings();
                                  }
                                } else {
                                  // Graceful fallback to WhatsApp App
                                  await LoggingService().logAction(
                                    action: 'PAYMENT_LINK_HOOK_FALLBACK',
                                    targetType: 'Invoice',
                                    targetId: b.invoiceNo ?? b.id ?? '',
                                    details: 'WhatsApp Hook note: ${sendResult.error}. Opening WhatsApp App fallback for $enteredPhone',
                                  );

                                  await WhatsAppCloudService.launchWhatsAppApp(
                                    phone: enteredPhone,
                                    message: message,
                                  );

                                  if (mounted) {
                                    Navigator.pop(context);
                                    _msg('WhatsApp Hook note (${sendResult.error}). Opened in WhatsApp App.', true);
                                    _fetchBillings();
                                  }
                                }
                              } else {
                                // Manual send via WhatsApp App
                                await WhatsAppCloudService.launchWhatsAppApp(
                                  phone: enteredPhone,
                                  message: message,
                                );

                                await LoggingService().logAction(
                                  action: 'PAYMENT_LINK_SENT_APP',
                                  targetType: 'Invoice',
                                  targetId: b.invoiceNo ?? b.id ?? '',
                                  details: 'Opened Razorpay payment link of ₹${linkResult.amount} in WhatsApp App for $enteredPhone',
                                );

                                if (mounted) {
                                  Navigator.pop(context);
                                  _msg('Payment link opened in WhatsApp App!', true);
                                  _fetchBillings();
                                }
                              }
                            } catch (e) {
                              setModalState(() => isGenerating = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
                              }
                            }
                          },
                          icon: isGenerating
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Icon(autoSendViaHook ? Icons.bolt_rounded : Icons.send_rounded, size: 18),
                          label: Text(isGenerating ? 'Processing...' : (autoSendViaHook ? 'Auto-Send via Hook' : 'Open in WhatsApp')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _shareViaWhatsApp(Billing b) async {
    if (b.clientName == null || b.clientName!.isEmpty) return;

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.chat_rounded, color: Colors.green),
            SizedBox(width: 10),
            Text('Share via WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose an option to send to ${b.clientName}:', style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.payment_rounded, color: Color(0xFF0284C7)),
              ),
              title: const Text('Razorpay Payment Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Generate online payment link & send on WhatsApp', style: TextStyle(fontSize: 12)),
              onTap: () => Navigator.pop(ctx, 'payment_link'),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.green),
              ),
              title: const Text('Invoice Summary Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Send invoice details & attached note', style: TextStyle(fontSize: 12)),
              onTap: () => Navigator.pop(ctx, 'invoice_summary'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );

    if (choice == 'payment_link') {
      await _showRazorpayPaymentLinkDialog(b);
      return;
    } else if (choice != 'invoice_summary') {
      return;
    }

    try {
      final phone = await _billingService.getClientPhone(b.clientName!);
      if (phone == null || phone.isEmpty) {
        _msg('No phone number found for ${b.clientName}.', false);
        return;
      }
      final typeStr = b.type == 'QUOTATION' ? 'Quotation' : 'Invoice';
      final text = "Hello ${b.clientName},\n\nPlease find your $typeStr (${b.invoiceNo}) for ₹${b.amount} attached.\n\nThank you,\nCochin United Consultancy";
      
      // Auto-send via WhatsApp Cloud API Hook first
      final res = await WhatsAppCloudService().sendMessage(
        toPhone: phone,
        message: text,
      );

      if (res.success) {
        await LoggingService().logAction(
          action: 'INVOICE_SUMMARY_SENT_VIA_HOOK',
          targetType: 'Invoice',
          targetId: b.invoiceNo ?? b.id ?? '',
          details: 'Sent $typeStr summary automatically to $phone via WhatsApp Hook',
        );
        _msg('✅ $typeStr summary sent automatically via WhatsApp Hook to $phone!', true);
      } else {
        await WhatsAppCloudService.launchWhatsAppApp(
          phone: phone,
          message: text,
        );
        _msg('WhatsApp Hook (${res.error}). Opened in WhatsApp App.', true);
      }
    } catch (e) {
      _msg('Failed to send WhatsApp message: $e', false);
    }
  }

  Future<void> _showClientLedger(String clientName) async {
    try {
      final items = await _billingService.getClientLedger(clientName);
      final req = ModelQueries.list(Clients.classType, where: Clients.NAME.eq(clientName), limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      final clientObj = (res.data?.items ?? []).isNotEmpty ? res.data!.items.first : null;
      
      String totalBal = '0/-';
      if (clientObj != null && clientObj.balance_due != null) {
         totalBal = clientObj.balance_due.toString();
      }

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(clientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 4),
                        const Text('Billing Ledger & History', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Outstanding', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(totalBal, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.orange)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final b = items[index];
                    final isPaid = b.data?['payment_received'] == true;
                    return ListTile(
                      title: Text('${b.invoiceNo ?? '-'}  •  ₹${b.amount ?? '0'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${b.date ?? '-'}  •  ${b.type ?? 'INVOICE'}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isPaid ? Colors.green : (b.status == 'Interested' ? Colors.teal : (b.status == 'Not Interested' ? Colors.blueGrey : (b.status == 'Part Payment' ? Colors.indigo : Colors.orange)))).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(isPaid ? 'PAID' : (b.status == 'Interested' ? 'INTERESTED' : (b.status == 'Not Interested' ? 'NOT INT' : (b.status == 'Part Payment' ? 'PARTIAL' : 'PENDING'))), 
                          style: TextStyle(color: isPaid ? Colors.green : (b.status == 'Interested' ? Colors.teal : (b.status == 'Not Interested' ? Colors.blueGrey : (b.status == 'Part Payment' ? Colors.indigo : Colors.orange))), fontWeight: FontWeight.bold, fontSize: 10))
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        )
      );
    } catch (e) {
      _msg('Failed to load ledger: $e', false);
    }
  }

  Future<void> _generateReceipt(Billing b) async {
    final auths = b.authorities ?? '';
    final category = b.category ?? 'Consultancy';
    final items = List<Map<String, dynamic>>.from(b.items ?? []);
    final d = b.data ?? {};
    final amtInWords = b.amountInWords.isEmpty ? NumberToWords.convert(NumberToWords.parseCurrency(b.amount ?? '0').round()) : b.amountInWords;
    
    await InvoicePdfService.printInvoice(
      type: b.type ?? 'INVOICE',
      category: category,
      clientName: b.clientName ?? '',
      clientAddress: d['client_address'] ?? '',
      date: b.date ?? '',
      invoiceNo: b.invoiceNo ?? '',
      authorities: auths,
      items: items,
      totalAmount: b.amount ?? '0/-',
      amountInWords: amtInWords,
      outstandingAmount: '0/-',
      advanceReceived: b.amount ?? '0/-',
      grandTotal: b.amount ?? '0/-',
      balanceDue: '0/-',
      quotationTerms: d['quotation_terms'] != null ? List<String>.from(d['quotation_terms']) : null,
      isReceipt: true,
    );
  }

  Future<void> _downloadInvoice(Billing b) async {
    try {
      final auths = b.authorities ?? '';
      final category = b.category ?? 'Consultancy';
      final items = List<Map<String, dynamic>>.from(b.items);
      final d = b.data ?? {};
      final amtInWords = b.amountInWords.isEmpty
          ? NumberToWords.convert(NumberToWords.parseCurrency(b.amount ?? '0').round())
          : b.amountInWords;

      await InvoicePdfService.printInvoice(
        type: b.type ?? 'INVOICE',
        category: category,
        clientName: b.clientName ?? '',
        clientAddress: d['client_address'] ?? '',
        date: b.date ?? '',
        invoiceNo: b.invoiceNo ?? '',
        authorities: auths,
        items: items,
        totalAmount: b.amount ?? '0/-',
        amountInWords: amtInWords,
        outstandingAmount: b.outstandingAmount,
        advanceReceived: d['advance_received'] ?? '',
        discount: d['discount'] ?? '',
        grandTotal: b.grandTotal.isNotEmpty ? b.grandTotal : (b.amount ?? '0/-'),
        balanceDue: d['balance_due'] ?? '',
        quotationTerms: d['quotation_terms'] != null ? List<String>.from(d['quotation_terms']) : null,
        isReceipt: false,
        isToSameAsClient: d['is_to_same_as_client'] ?? true,
        customTo: d['custom_to'] ?? '',
      );
    } catch (e) {
      _msg('Failed to generate PDF: $e', false);
    }
  }

  bool _canEditBilling(Billing? b) {
    if (b == null) return true; // Can create new
    if (_isAdmin) return true;
    final editReq = b.data?['edit_request'];
    if (editReq != null && editReq['status'] == 'APPROVED') {
      final reqUser = (editReq['requested_by'] ?? '').toString().toLowerCase().trim();
      final current = _currentUserName.toLowerCase().trim();
      if (reqUser.isNotEmpty && (reqUser == current || current.contains(reqUser) || reqUser.contains(current))) {
        return true;
      }
    }
    return false;
  }

  void _showRequestEditDialog(Billing b) {
    String selectedCategory = _editReasonCategories.first;
    final detailsController = TextEditingController();
    bool isSubmitting = false;

    final existingReq = b.data?['edit_request'];
    final bool hasPending = existingReq != null && existingReq['status'] == 'PENDING';
    final bool wasRejected = existingReq != null && existingReq['status'] == 'REJECTED';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.edit_calendar_rounded, color: Colors.blue.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Request Edit Permission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${b.invoiceNo ?? "Bill"} • ${b.clientName ?? ""}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasPending)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade300)),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded, color: Colors.amber.shade900, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A request by ${existingReq['requested_by']} is already pending admin review.\nReason: ${existingReq['reason_category']}',
                              style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (wasRejected)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined, color: Colors.red.shade900, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Previous request was rejected: ${existingReq['review_remarks'] ?? "No remarks provided"}\nYou may submit a new request below.',
                              style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Text('Defined Reason *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: _editReasonCategories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Detailed Explanation *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Explain what needs to be changed and why (minimum 5 characters)...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This request will be sent to the Admin with an option to Approve or Not Approve.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final details = detailsController.text.trim();
                        if (details.length < 5) {
                          _msg('Please enter a detailed explanation (minimum 5 characters)', false);
                          return;
                        }
                        setModalState(() => isSubmitting = true);
                        try {
                          final d = Map<String, dynamic>.from(b.data ?? {});
                          d['edit_request'] = {
                            'requested_by': _currentUserName.isNotEmpty ? _currentUserName : 'staff',
                            'requested_by_name': _currentUserName.isNotEmpty ? _currentUserName : 'Staff Member',
                            'requested_at': DateTime.now().toIso8601String(),
                            'reason_category': selectedCategory,
                            'reason_details': details,
                            'status': 'PENDING',
                          };
                          await _billingService.updateBilling(b.id!, {'data': d});
                          await _log.logAction(
                            action: 'INVOICE_EDIT_REQUESTED',
                            targetType: 'Invoice',
                            targetId: b.invoiceNo ?? '',
                            details: 'Staff $_currentUserName requested edit. Reason: $selectedCategory - $details',
                          );
                          if (mounted) Navigator.pop(context);
                          _fetchBillings(refresh: true);
                          _msg('Edit request submitted to Admin for approval', true);
                        } catch (e) {
                          _msg('Failed to submit request: $e', false);
                        } finally {
                          if (mounted) setModalState(() => isSubmitting = false);
                        }
                      },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: isSubmitting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAdminReviewDialog(Billing b) {
    final editReq = b.data?['edit_request'];
    if (editReq == null) return;

    final remarksCtrl = TextEditingController();
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.admin_panel_settings_rounded, color: Colors.purple),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Review Bill Edit Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${b.invoiceNo ?? "Bill"} • ${b.clientName ?? ""}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Requested By: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${editReq['requested_by']}', style: TextStyle(fontSize: 13, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (editReq['requested_at'] != null)
                              Text(
                                DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.tryParse(editReq['requested_at']) ?? DateTime.now()),
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Reason: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Expanded(child: Text('${editReq['reason_category']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Details / Explanation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
                          child: Text('${editReq['reason_details'] ?? "No details provided"}', style: const TextStyle(fontSize: 12, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Admin Remarks (Mandatory for rejection):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: remarksCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter approval notes or reason for rejection...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              OutlinedButton.icon(
                onPressed: isProcessing
                    ? null
                    : () async {
                        final remarks = remarksCtrl.text.trim();
                        if (remarks.isEmpty) {
                          _msg('Please enter a rejection reason in Admin Remarks', false);
                          return;
                        }
                        setModalState(() => isProcessing = true);
                        try {
                          final d = Map<String, dynamic>.from(b.data ?? {});
                          d['edit_request'] = {
                            ...?editReq,
                            'status': 'REJECTED',
                            'reviewed_by': _currentUserName,
                            'reviewed_at': DateTime.now().toIso8601String(),
                            'review_remarks': remarks,
                          };
                          await _billingService.updateBilling(b.id!, {'data': d});
                          await _log.logAction(
                            action: 'INVOICE_EDIT_REJECTED',
                            targetType: 'Invoice',
                            targetId: b.invoiceNo ?? '',
                            details: 'Admin $_currentUserName rejected edit request for ${b.invoiceNo}. Remarks: $remarks',
                          );
                          if (mounted) Navigator.pop(context);
                          _fetchBillings(refresh: true);
                          _msg('Edit request marked as NOT APPROVED', true);
                        } catch (e) {
                          _msg('Error rejecting request: $e', false);
                        } finally {
                          if (mounted) setModalState(() => isProcessing = false);
                        }
                      },
                icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                label: const Text('Not Approve (Reject)', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
              ElevatedButton.icon(
                onPressed: isProcessing
                    ? null
                    : () async {
                        setModalState(() => isProcessing = true);
                        try {
                          final d = Map<String, dynamic>.from(b.data ?? {});
                          d['edit_request'] = {
                            ...?editReq,
                            'status': 'APPROVED',
                            'reviewed_by': _currentUserName,
                            'reviewed_at': DateTime.now().toIso8601String(),
                            'review_remarks': remarksCtrl.text.trim(),
                          };
                          await _billingService.updateBilling(b.id!, {'data': d});
                          await _log.logAction(
                            action: 'INVOICE_EDIT_APPROVED',
                            targetType: 'Invoice',
                            targetId: b.invoiceNo ?? '',
                            details: 'Admin $_currentUserName approved edit request for ${b.invoiceNo} for staff ${editReq['requested_by']}',
                          );
                          if (mounted) Navigator.pop(context);
                          _fetchBillings(refresh: true);
                          _msg('Edit request APPROVED! Staff can now edit this bill.', true);
                        } catch (e) {
                          _msg('Error approving request: $e', false);
                        } finally {
                          if (mounted) setModalState(() => isProcessing = false);
                        }
                      },
                icon: const Icon(Icons.check_circle_rounded, size: 16),
                label: const Text('Approve Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPendingRequestsListDialog() {
    final pending = _billings.where((b) => b.data?['edit_request']?['status'] == 'PENDING').toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.pending_actions_rounded, color: Colors.amber),
            const SizedBox(width: 10),
            Text('Pending Edit Requests (${pending.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: pending.isEmpty
              ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No pending edit requests.')))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: pending.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final b = pending[idx];
                    final req = b.data!['edit_request'];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      title: Text('${b.invoiceNo ?? "Bill"} - ${b.clientName ?? ""}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text('Requested by: ${req['requested_by']} • ${req['reason_category']}', style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('"${req['reason_details'] ?? ""}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                            tooltip: 'Approve',
                            onPressed: () {
                              Navigator.pop(context);
                              _showAdminReviewDialog(b);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_rounded, color: Colors.red, size: 24),
                            tooltip: 'Not Approve / Reject',
                            onPressed: () {
                              Navigator.pop(context);
                              _showAdminReviewDialog(b);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildStaffEditRequestButton(Billing b, {bool isSmall = false}) {
    final editReq = b.data?['edit_request'];
    final status = editReq?['status'];

    if (status == 'PENDING') {
      return IconButton(
        onPressed: () => _showRequestEditDialog(b),
        icon: Icon(Icons.hourglass_top_rounded, color: Colors.amber.shade800, size: isSmall ? 20 : 22),
        tooltip: 'Edit Request Pending Admin Approval (Click to view)',
        constraints: isSmall ? const BoxConstraints() : null,
        padding: isSmall ? const EdgeInsets.all(8) : null,
      );
    } else if (status == 'REJECTED') {
      return IconButton(
        onPressed: () => _showRequestEditDialog(b),
        icon: Icon(Icons.edit_off_rounded, color: Colors.redAccent, size: isSmall ? 20 : 22),
        tooltip: 'Edit Request Rejected (Click to re-request)',
        constraints: isSmall ? const BoxConstraints() : null,
        padding: isSmall ? const EdgeInsets.all(8) : null,
      );
    } else {
      return IconButton(
        onPressed: () => _showRequestEditDialog(b),
        icon: Icon(Icons.edit_calendar_rounded, color: Colors.grey.shade400, size: isSmall ? 20 : 22),
        tooltip: 'Request Edit Permission',
        constraints: isSmall ? const BoxConstraints() : null,
        padding: isSmall ? const EdgeInsets.all(8) : null,
      );
    }
  }

  Widget _buildEditRequestTag(Billing b) {
    final req = b.data?['edit_request'];
    if (req == null) return const SizedBox();
    final status = req['status']?.toString();
    final requestedBy = req['requested_by'] ?? 'Staff';

    Color tagColor = Colors.grey;
    String tagLabel = '';
    IconData tagIcon = Icons.info_outline;

    if (status == 'PENDING') {
      tagColor = Colors.amber.shade800;
      tagLabel = 'Edit Req: $requestedBy';
      tagIcon = Icons.hourglass_top_rounded;
    } else if (status == 'APPROVED') {
      tagColor = Colors.green.shade700;
      tagLabel = 'Edit Approved';
      tagIcon = Icons.check_circle_outline;
    } else if (status == 'REJECTED') {
      tagColor = Colors.red.shade700;
      tagLabel = 'Edit Rejected';
      tagIcon = Icons.cancel_outlined;
    } else {
      return const SizedBox();
    }

    return InkWell(
      onTap: _isAdmin && status == 'PENDING' 
          ? () => _showAdminReviewDialog(b) 
          : () => _showRequestEditDialog(b),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: tagColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: tagColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tagIcon, size: 12, color: tagColor),
            const SizedBox(width: 4),
            Text(
              tagLabel,
              style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _msg(String t, bool ok) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(t), behavior: SnackBarBehavior.floating, backgroundColor: ok ? Colors.green.shade600 : Colors.redAccent,
  ));

  void _openCreator([Billing? b, bool forceReadOnly = false]) {
    final canEdit = _canEditBilling(b);
    final isReadOnly = forceReadOnly || (b != null && !canEdit);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => InvoiceCreatorPage(
        billing: b,
        isReadOnly: isReadOnly,
        canEdit: canEdit,
        onRequestEdit: b != null ? () => _showRequestEditDialog(b) : null,
        onSaved: (dynamic id) {
          _fetchBillings(refresh: true);
          Navigator.pop(context);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _openCreator,
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () => _searchFocusNode.requestFocus(),
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 900;
        final filtered = _billings.where((b) {
          if (_searchTerm.trim().isEmpty) return true;
          final query = _searchTerm.toLowerCase().trim();
          final cName = b.clientName?.toLowerCase() ?? '';
          final invNo = b.invoiceNo?.toLowerCase() ?? '';
          final amt = b.amount?.toLowerCase() ?? '';
          final staffStr = _getFullAuthorityName(b.authorities, b.invoiceNo, b.data).toLowerCase();
          final dataStr = b.data?.toString().toLowerCase() ?? '';
          return cName.contains(query) || invNo.contains(query) || amt.contains(query) || staffStr.contains(query) || dataStr.contains(query);
        }).toList();
        
        final paidCount = _billings.where((b) => b.data?['payment_received'] == true).length;
        final pendingCount = _billings.length - paidCount;

        return Padding(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Responsive Header
            if (isWide)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: [
                        if (Navigator.canPop(context))
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => Navigator.pop(context),
                              style: IconButton.styleFrom(backgroundColor: Colors.white, elevation: 2, shadowColor: Colors.black12),
                            ),
                          ),
                        const Text('Invoicing & Billing', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2, color: Color(0xFF1E293B))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      _statBadge(
                        '$_totalInvoices Total',
                        Colors.blue,
                        isSelected: _statusFilter == 'All' && _typeFilter == 'All',
                        onTap: () {
                          setState(() {
                            _statusFilter = 'All';
                            _typeFilter = 'All';
                          });
                          _fetchBillings(refresh: true);
                        },
                      ),
                      _statBadge(
                        '$_totalPaid Paid',
                        Colors.green,
                        isSelected: _statusFilter == 'Paid' && _typeFilter == 'Invoice',
                        onTap: () {
                          setState(() {
                            if (_statusFilter == 'Paid' && _typeFilter == 'Invoice') {
                              _statusFilter = 'All';
                              _typeFilter = 'All';
                            } else {
                              _statusFilter = 'Paid';
                              _typeFilter = 'Invoice';
                            }
                          });
                          _fetchBillings(refresh: true);
                        },
                      ),
                      _statBadge(
                        '$_totalPendingInvoices Pending Invoices',
                        Colors.orange,
                        isSelected: (_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice',
                        onTap: () {
                          setState(() {
                            if ((_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice') {
                              _statusFilter = 'All';
                              _typeFilter = 'All';
                            } else {
                              _statusFilter = 'Pending';
                              _typeFilter = 'Invoice';
                            }
                          });
                          _fetchBillings(refresh: true);
                        },
                      ),
                      if (_billings.any((b) => b.data?['edit_request']?['status'] == 'PENDING'))
                        InkWell(
                          onTap: _showPendingRequestsListDialog,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade400),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pending_actions_rounded, size: 14, color: Colors.amber.shade900),
                                const SizedBox(width: 4),
                                Text(
                                  '${_billings.where((b) => b.data?['edit_request']?['status'] == 'PENDING').length} Edit Requests',
                                  style: TextStyle(color: Colors.amber.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ]),
                  ]),
                    Expanded(child: Wrap(alignment: WrapAlignment.end, crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, runSpacing: 8, children: [
                      ElevatedButton.icon(
                        icon: Icon(
                          (_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice'
                              ? Icons.filter_alt_rounded
                              : Icons.pending_actions_rounded,
                          size: 18,
                        ),
                        label: Text(
                          (_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice'
                              ? 'Pending Invoices (Active)'
                              : 'Pending Invoices',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice'
                              ? Colors.orange.shade700
                              : Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: (_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice' ? 3 : 1,
                        ),
                        onPressed: () {
                          setState(() {
                            if ((_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice') {
                              _statusFilter = 'All';
                              _typeFilter = 'All';
                            } else {
                              _statusFilter = 'Pending';
                              _typeFilter = 'Invoice';
                            }
                          });
                          _fetchBillings(refresh: true);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sync_rounded, size: 18),
                        label: const Text('Sync Old Bills'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          await _syncOldBillsToAccounting();
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_download, size: 18),
                        label: const Text('Sync from Supabase'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          _msg('Importing missing & updated billings...', true);
                          await SupabaseBackupService().importMissingBillings();
                          _msg('Sync complete.', true);
                          _fetchBillings(refresh: true);
                        },
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _typeFilter,
                            icon: const Icon(Icons.filter_alt_outlined, size: 20, color: Colors.indigo),
                            items: ['All', 'Invoice', 'Pending Invoice', 'Quotation'].map((s) => DropdownMenuItem(value: s, child: Text(s == 'All' ? 'All Types' : s, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  if (v == 'Pending Invoice') {
                                    _typeFilter = 'Invoice';
                                    _statusFilter = 'Pending';
                                  } else {
                                    _typeFilter = v;
                                  }
                                });
                                _fetchBillings(refresh: true);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: (_statusFilter == 'Pending Invoices') ? 'Pending Invoices' : _statusFilter,
                            icon: const Icon(Icons.fact_check_outlined, size: 20, color: Colors.teal),
                            items: ['All', 'Pending Invoices', 'Paid', 'Pending', 'Overdue', 'Interested', 'Not Interested'].map((s) => DropdownMenuItem(value: s, child: Text(s == 'All' ? 'All Statuses' : s, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  if (v == 'Pending Invoices') {
                                    _statusFilter = 'Pending Invoices';
                                    _typeFilter = 'Invoice';
                                  } else {
                                    _statusFilter = v;
                                  }
                                });
                                _fetchBillings(refresh: true);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            icon: const Icon(Icons.sort_rounded, size: 20, color: Colors.blue),
                            items: ['Newest First', 'Oldest First', 'Highest Amount', 'Lowest Amount', 'Invoice No (A-Z)', 'Invoice No (Z-A)', 'Legal First', 'Consultancy First']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _sortBy = v);
                                _fetchBillings(refresh: true);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _actionBtn(Icons.date_range_rounded, 'Filter by Date', _startDate != null ? Colors.blue : Colors.grey, () async {
                         final picked = await showCompactDateRangePicker(
                           context: context,
                           firstDate: DateTime(2020),
                           lastDate: DateTime.now(),
                           initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
                         );
                         if (picked != null) {
                           setState(() { _startDate = picked.start; _endDate = picked.end; });
                           _fetchBillings(refresh: true);
                         } else if (_startDate != null) {
                           setState(() { _startDate = null; _endDate = null; });
                           _fetchBillings(refresh: true);
                         }
                      }),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 240,
                        height: 45,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                          child: TextField(
                            focusNode: _searchFocusNode,
                            onChanged: (v) {
                              setState(() => _searchTerm = v);
                              if (_debounce?.isActive ?? false) _debounce!.cancel();
                              _debounce = Timer(const Duration(milliseconds: 500), () {
                                _fetchBillings(refresh: true);
                              });
                            },
                            decoration: const InputDecoration(hintText: 'Search (Ctrl+F)', prefixIcon: Icon(Icons.search_rounded, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    _actionBtn(Icons.refresh_rounded, 'Refresh', Colors.blue, _fetchBillings),
                    const SizedBox(width: 8),
                    _actionBtn(Icons.file_download_rounded, 'Export', Colors.green, () async { 
                      try { final p = await _excel.exportBillings(_billings); if (p != null) _msg('Exported to $p', true); } catch (e) { _msg('$e', false); }
                    }),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openCreator(), icon: const Icon(Icons.add_rounded, size: 20), label: const Text('Create Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ])),
                ],
              )
            else ...[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    if (Navigator.canPop(context))
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(backgroundColor: Colors.white, elevation: 2, shadowColor: Colors.black12),
                        ),
                      ),
                    const Text('Invoicing & Billing', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1.2, color: Color(0xFF1E293B))),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  _statBadge(
                    '$_totalInvoices Total',
                    Colors.blue,
                    isSelected: _statusFilter == 'All' && _typeFilter == 'All',
                    onTap: () {
                      setState(() {
                        _statusFilter = 'All';
                        _typeFilter = 'All';
                      });
                      _fetchBillings(refresh: true);
                    },
                  ),
                  _statBadge(
                    '$_totalPaid Paid',
                    Colors.green,
                    isSelected: _statusFilter == 'Paid' && _typeFilter == 'Invoice',
                    onTap: () {
                      setState(() {
                        if (_statusFilter == 'Paid' && _typeFilter == 'Invoice') {
                          _statusFilter = 'All';
                          _typeFilter = 'All';
                        } else {
                          _statusFilter = 'Paid';
                          _typeFilter = 'Invoice';
                        }
                      });
                      _fetchBillings(refresh: true);
                    },
                  ),
                  _statBadge(
                    '$_totalPendingInvoices Pending Invoices',
                    Colors.orange,
                    isSelected: (_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice',
                    onTap: () {
                      setState(() {
                        if ((_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice') {
                          _statusFilter = 'All';
                          _typeFilter = 'All';
                        } else {
                          _statusFilter = 'Pending';
                          _typeFilter = 'Invoice';
                        }
                      });
                      _fetchBillings(refresh: true);
                    },
                  ),
                  if (_billings.any((b) => b.data?['edit_request']?['status'] == 'PENDING'))
                    InkWell(
                      onTap: _showPendingRequestsListDialog,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade400),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pending_actions_rounded, size: 14, color: Colors.amber.shade900),
                            const SizedBox(width: 4),
                            Text(
                              '${_billings.where((b) => b.data?['edit_request']?['status'] == 'PENDING').length} Edit Requests',
                              style: TextStyle(color: Colors.amber.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ]),
              ]),
              const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      height: 45,
                      width: MediaQuery.of(context).size.width < 600 ? double.infinity : 200,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: (_statusFilter == 'Pending Invoices') ? 'Pending Invoices' : _statusFilter,
                          isExpanded: true,
                          items: ['All', 'Pending Invoices', 'Paid', 'Pending', 'Overdue', 'Interested', 'Not Interested'].map((s) => DropdownMenuItem(value: s, child: Text(s == 'All' ? 'All Statuses' : s, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                if (v == 'Pending Invoices') {
                                  _statusFilter = 'Pending Invoices';
                                  _typeFilter = 'Invoice';
                                } else {
                                  _statusFilter = v;
                                }
                              });
                              _fetchBillings(refresh: true);
                            }
                          },
                        ),
                      ),
                    ),
                    _actionBtn(Icons.date_range_rounded, 'Filter by Date', _startDate != null ? Colors.blue : Colors.grey, () async {
                   final picked = await showCompactDateRangePicker(
                     context: context,
                     firstDate: DateTime(2020),
                     lastDate: DateTime.now(),
                     initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
                   );
                   if (picked != null) {
                     setState(() { _startDate = picked.start; _endDate = picked.end; });
                     _fetchBillings(refresh: true);
                   } else if (_startDate != null) {
                     setState(() { _startDate = null; _endDate = null; });
                     _fetchBillings(refresh: true);
                   }
                }),
                const SizedBox(width: 8),
                _actionBtn(Icons.refresh_rounded, 'Refresh', Colors.blue, () => _fetchBillings(refresh: true)),
                const SizedBox(width: 8),
                _actionBtn(Icons.sync_rounded, 'Sync Payments', const Color(0xFF0284C7), () async {
                  _msg('Checking online payments on Razorpay...', true);
                  int syncedCount = 0;
                  for (var b in _billings) {
                    bool isPaid = b.status == 'Received' || b.data?['payment_received'] == true;
                    if (!isPaid && (b.data?['razorpay_link_id'] != null || b.data?['payment_link_id'] != null)) {
                      final updated = await _billingService.syncRazorpayPaymentForBilling(b);
                      if (updated) syncedCount++;
                    }
                  }
                  if (syncedCount > 0) {
                    _msg('Successfully synced $syncedCount paid invoice(s) into Bills & Accounts/Expenses!', true);
                    _fetchBillings(refresh: true);
                  } else {
                    _msg('Online payments are up to date.', true);
                  }
                }),
                const SizedBox(width: 8),
                _actionBtn(Icons.file_download_rounded, 'Export', Colors.green, () async { 
                  try { final p = await _excel.exportBillings(_billings); if (p != null) _msg('Exported to $p', true); } catch (e) { _msg('$e', false); }
                }),
              ]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                      child: TextField(
                        focusNode: _searchFocusNode,
                        onChanged: (v) {
                          setState(() => _searchTerm = v);
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce = Timer(const Duration(milliseconds: 500), () {
                            _fetchBillings(refresh: true);
                          });
                        },
                        decoration: const InputDecoration(hintText: 'Search...', prefixIcon: Icon(Icons.search_rounded, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          isExpanded: true,
                          icon: const Icon(Icons.sort_rounded, size: 20, color: Colors.blue),
                          items: ['Newest First', 'Oldest First', 'Highest Amount', 'Lowest Amount', 'Invoice No (A-Z)', 'Invoice No (Z-A)', 'Legal First', 'Consultancy First']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _sortBy = v);
                              _fetchBillings(refresh: true);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openCreator(), icon: const Icon(Icons.add_rounded, size: 20), label: const Text('CREATE INVOICE', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          const SizedBox(height: 24),
          // List
          Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator())
            : filtered.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  ((_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice')
                      ? Icons.check_circle_outline_rounded
                      : Icons.receipt_long_rounded,
                  size: 80,
                  color: ((_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice')
                      ? Colors.green.shade200
                      : Colors.grey.shade200,
                ),
                const SizedBox(height: 16),
                Text(
                  ((_statusFilter == 'Pending' || _statusFilter == 'Pending Invoices') && _typeFilter == 'Invoice')
                      ? 'No pending invoices! All invoices are settled.'
                      : 'No records found',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ]))
            : Card(
                margin: EdgeInsets.zero,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length + (_hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    if (i == filtered.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: _isFetchingMore
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : TextButton.icon(
                                onPressed: () => _fetchBillings(),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                label: const Text('Load More Invoices', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                        ),
                      );
                    }
                    return _buildInvoiceCard(filtered[i], i, isWide);
                  },
                ),
              ),
          ),
        ]).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
      );
    },
  )));
}

  Widget _statBadge(String text, Color color, {bool isSelected = false, VoidCallback? onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? color : color.withValues(alpha: 0.25),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : color.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _actionBtn(IconData icon, String tooltip, Color color, VoidCallback onTap) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22)),
    ),
  );

  Widget _buildInvoiceCard(Billing b, int i, bool isWide) {
    final isPaid = b.data?['payment_received'] == true;
    bool isOverdue = false;
    if (!isPaid && b.type != 'QUOTATION' && b.date != null && b.date!.isNotEmpty) {
      try {
        final parts = b.date!.split('/');
        if (parts.length == 3) {
          final d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          if (DateTime.now().difference(d).inDays > 30) {
            isOverdue = true;
          }
        }
      } catch (_) {}
    }
    final typeColor = b.type == 'QUOTATION' ? Colors.purple : const Color(0xFF2563EB);
    final staffName = _getStaffDisplayName(b.authorities, b.invoiceNo, b.data);
    
    final innerContent = isWide 
      ? Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
            child: Icon(b.type == 'QUOTATION' ? Icons.request_quote_rounded : Icons.receipt_long_rounded, color: typeColor, size: 26)),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(b.invoiceNo ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              const SizedBox(width: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(b.type ?? 'INVOICE', style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
              if (b.category != null) ...[
                const SizedBox(width: 8),
                Text(b.category!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
              if (staffName.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.35), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_rounded, size: 11, color: Colors.orange),
                      const SizedBox(width: 3.5),
                      Text(
                        staffName,
                        style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
              if (b.data != null && b.data!['edit_count'] != null && b.data!['edit_count'] > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    'Edited (${b.data!['edit_count']})',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                  )
                ),
              ],
              if (b.data != null && b.data!['marked_paid_by'] != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    'Paid By: ${b.data!['marked_paid_by'].split(' ').first}',
                    style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                  )
                ),
              ],
              if (b.data != null && b.data!['discount_given_by'] != null) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Discount Amount: ${b.data!['discount'] ?? '0'}',
                  triggerMode: TooltipTriggerMode.tap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      'Discount By: ${b.data!['discount_given_by'].split(' ').first}',
                      style: const TextStyle(color: Colors.pink, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                    )
                  ),
                ),
              ],
              if (b.data != null && b.data!['edit_request'] != null) ...[
                const SizedBox(width: 8),
                _buildEditRequestTag(b),
              ],
            ]),
            const SizedBox(height: 6),
            InkWell(
              onTap: b.clientName != null ? () => _showClientLedger(b.clientName!) : null,
              child: Text(
                b.clientName ?? 'Unnamed Client', 
                style: TextStyle(fontSize: 14, color: Colors.blue.shade700, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, decorationColor: Colors.blue.shade200)
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Issued by: ${_getFullAuthorityName(b.authorities, b.invoiceNo, b.data)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ])),

          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('REG NO', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(b.data?['client_reg_no']?.toString().isNotEmpty == true ? b.data!['client_reg_no'].toString() : '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 90,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('INVOICE DATE', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(b.date ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
              if (b.data?['payment_deadline'] != null && b.data!['payment_deadline'].toString().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('Due: ${b.data!['payment_deadline']}', style: TextStyle(color: Colors.red.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ]),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('AMOUNT', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(b.amount ?? '0/-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              if (b.type == 'QUOTATION' && (b.data?['approved_amount']?.isNotEmpty ?? false) && b.data!['approved_amount'] != '0/-' && b.data!['approved_amount'] != '0') ...[
                const SizedBox(height: 2),
                Text('Appr: ${b.data!['approved_amount']}', style: TextStyle(color: Colors.green.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
              if (!isPaid && (b.data?['balance_due']?.isNotEmpty ?? false) && b.data!['balance_due'] != '0/-') ...[
                const SizedBox(height: 2),
                Text('Bal: ${b.data!['balance_due']}', style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
              ]
            ]),
          ),
          const SizedBox(width: 24),
          Container(
            width: 100, height: 36, alignment: Alignment.center, 
            decoration: BoxDecoration(
              color: (isPaid ? Colors.green : (b.status == 'Interested' ? Colors.teal : (b.status == 'Not Interested' ? Colors.blueGrey : (isOverdue ? Colors.red : Colors.orange)))).withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text(isPaid ? 'PAID' : (b.status == 'Interested' ? 'INTERESTED' : (b.status == 'Not Interested' ? 'NOT INTERESTED' : (isOverdue ? 'OVERDUE' : 'PENDING'))), 
              style: TextStyle(color: isPaid ? Colors.green.shade700 : (b.status == 'Interested' ? Colors.teal.shade700 : (b.status == 'Not Interested' ? Colors.blueGrey.shade700 : (isOverdue ? Colors.red.shade700 : Colors.orange.shade700))), fontSize: 10, fontWeight: FontWeight.w900)
            )
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 450,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _downloadInvoice(b),
                  icon: const Icon(Icons.download_rounded, color: Color(0xFF2563EB), size: 22),
                  tooltip: 'Download / Print PDF',
                ),
                IconButton(onPressed: () => _shareViaWhatsApp(b), icon: const Icon(Icons.chat_rounded, color: Colors.green), tooltip: 'Share via WhatsApp'),
                if (!isPaid) IconButton(onPressed: () => _showRazorpayPaymentLinkDialog(b), icon: const Icon(Icons.payment_rounded, color: Color(0xFF0284C7)), tooltip: 'Send Razorpay Payment Link (WhatsApp)'),
                if (!isPaid && b.type != 'QUOTATION') IconButton(onPressed: () => _markPaid(b), icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green), tooltip: 'Mark Paid'),
                if (!isPaid) IconButton(onPressed: () => _setPaymentDeadlineDialog(context, b), icon: const Icon(Icons.schedule_rounded, color: Colors.redAccent), tooltip: 'Set Deadline'),
                if (isPaid) ...[
                  IconButton(onPressed: () => _generateReceipt(b), icon: const Icon(Icons.receipt_rounded, color: Colors.teal), tooltip: 'Generate Receipt PDF'),
                  IconButton(onPressed: () => _sendReceiptViaWhatsAppAndEmail(b), icon: const Icon(Icons.mark_email_read_rounded, color: Colors.green), tooltip: 'Send Receipt (WhatsApp & Email)'),
                ],
                if (b.type == 'QUOTATION') ...[
                  IconButton(onPressed: () => _markInterested(b), icon: Icon(Icons.check_circle_outline_rounded, color: b.status == 'Interested' ? Colors.teal : Colors.grey.shade400, size: 22), tooltip: 'Interested'),
                  IconButton(onPressed: () => _updateStatus(b, 'Not Interested'), icon: Icon(Icons.cancel_outlined, color: b.status == 'Not Interested' ? Colors.red.shade300 : Colors.grey.shade400, size: 22), tooltip: 'Not Interested'),
                ],
                IconButton(onPressed: () => _duplicateBilling(b), icon: Icon(Icons.copy_rounded, color: Colors.blue.shade300, size: 22), tooltip: 'Duplicate'),
                if (_canEditBilling(b))
                  IconButton(onPressed: () => _openCreator(b), icon: Icon(Icons.edit_note_rounded, color: _isAdmin ? Colors.grey.shade700 : Colors.green.shade700, size: 28), tooltip: _isAdmin ? 'Edit Invoice' : 'Edit (Approved)'),
                if (!_canEditBilling(b))
                  _buildStaffEditRequestButton(b),
                if (_isAdmin && b.data?['edit_request']?['status'] == 'PENDING')
                  IconButton(
                    onPressed: () => _showAdminReviewDialog(b),
                    icon: const Icon(Icons.pending_actions_rounded, color: Colors.amber, size: 24),
                    tooltip: 'Review Edit Request',
                  ),
                if (_isAdmin)
                  IconButton(onPressed: () => _deleteBilling(b), icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withValues(alpha: 0.5), size: 24), tooltip: 'Delete'),
              ]
            ),
          ),
        ])
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                      child: Icon(b.type == 'QUOTATION' ? Icons.request_quote_rounded : Icons.receipt_long_rounded, color: typeColor, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.invoiceNo ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(b.type ?? 'INVOICE', style: TextStyle(color: typeColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
                            if (staffName.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.orange.withValues(alpha: 0.35), width: 0.8),
                                ),
                                child: Text(
                                  staffName,
                                  style: const TextStyle(color: Colors.orange, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                ),
                              ),
                            if (b.data != null && b.data!['edit_request'] != null)
                              _buildEditRequestTag(b),
                          ],
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(b.amount ?? '0/-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                if (b.type == 'QUOTATION' && (b.data?['approved_amount']?.isNotEmpty ?? false) && b.data!['approved_amount'] != '0/-' && b.data!['approved_amount'] != '0') ...[
                  const SizedBox(height: 2),
                  Text('Appr: ${b.data!['approved_amount']}', style: TextStyle(color: Colors.green.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
                Text(b.date ?? '-', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                if (b.data?['payment_deadline'] != null && b.data!['payment_deadline'].toString().isNotEmpty)
                  Text('Due: ${b.data!['payment_deadline']}', style: TextStyle(color: Colors.red.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
              ]),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: b.clientName != null ? () => _showClientLedger(b.clientName!) : null,
            child: Text(
              b.clientName ?? 'Unnamed Client', 
              style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, decorationColor: Colors.blue.shade200)
            ),
          ),
          if (b.data?['client_reg_no']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text('Reg No: ${b.data!['client_reg_no']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(Icons.badge_outlined, size: 11, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'By: ${_getFullAuthorityName(b.authorities, b.invoiceNo, b.data)}',
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), alignment: Alignment.center, decoration: BoxDecoration(
                color: (isPaid ? Colors.green : (b.status == 'Interested' ? Colors.teal : (b.status == 'Not Interested' ? Colors.blueGrey : (b.status == 'Part Payment' ? Colors.indigo : (isOverdue ? Colors.red : Colors.orange))))).withValues(alpha: 0.1), 
                borderRadius: BorderRadius.circular(6)
              ),
                child: Text(isPaid ? 'PAID' : (b.status == 'Interested' ? 'INTERESTED' : (b.status == 'Not Interested' ? 'NOT INT' : (b.status == 'Part Payment' ? 'PARTIAL' : (isOverdue ? 'OVERDUE' : 'PENDING')))), 
                  style: TextStyle(color: isPaid ? Colors.green.shade700 : (b.status == 'Interested' ? Colors.teal.shade700 : (b.status == 'Not Interested' ? Colors.blueGrey.shade700 : (b.status == 'Part Payment' ? Colors.indigo.shade700 : (isOverdue ? Colors.red.shade700 : Colors.orange.shade700)))), fontSize: 9, fontWeight: FontWeight.w900))),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(onPressed: () => _downloadInvoice(b), icon: const Icon(Icons.download_rounded, color: Color(0xFF2563EB), size: 20), tooltip: 'Download / Print PDF', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      IconButton(onPressed: () => _shareViaWhatsApp(b), icon: const Icon(Icons.chat_rounded, color: Colors.green, size: 20), tooltip: 'WhatsApp', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      if (!isPaid) IconButton(onPressed: () => _showRazorpayPaymentLinkDialog(b), icon: const Icon(Icons.payment_rounded, color: Color(0xFF0284C7), size: 20), tooltip: 'Payment Link', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      if (!isPaid && b.type != 'QUOTATION') IconButton(onPressed: () => _markPaid(b), icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20), tooltip: 'Mark Paid', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      if (!isPaid) IconButton(onPressed: () => _setPaymentDeadlineDialog(context, b), icon: const Icon(Icons.schedule_rounded, color: Colors.redAccent, size: 20), tooltip: 'Set Deadline', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      if (isPaid) ...[
                        IconButton(onPressed: () => _generateReceipt(b), icon: const Icon(Icons.receipt_rounded, color: Colors.teal, size: 20), tooltip: 'Receipt', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                        IconButton(onPressed: () => _sendReceiptViaWhatsAppAndEmail(b), icon: const Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 20), tooltip: 'Send Receipt (WhatsApp & Email)', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      ],
                      if (b.type == 'QUOTATION') ...[
                        IconButton(onPressed: () => _markInterested(b), icon: Icon(Icons.check_circle_outline_rounded, color: b.status == 'Interested' ? Colors.teal : Colors.grey.shade400, size: 18), tooltip: 'Interested', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                        IconButton(onPressed: () => _updateStatus(b, 'Not Interested'), icon: Icon(Icons.cancel_outlined, color: b.status == 'Not Interested' ? Colors.red.shade300 : Colors.grey.shade400, size: 18), tooltip: 'Not Interested', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      ],
                      IconButton(onPressed: () => _duplicateBilling(b), icon: Icon(Icons.copy_rounded, color: Colors.blue.shade300, size: 20), tooltip: 'Duplicate', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      if (_canEditBilling(b))
                        IconButton(onPressed: () => _openCreator(b), icon: Icon(Icons.edit_note_rounded, color: _isAdmin ? Colors.grey.shade700 : Colors.green.shade700, size: 24), tooltip: _isAdmin ? 'Edit' : 'Edit (Approved)', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      if (!_canEditBilling(b))
                        _buildStaffEditRequestButton(b, isSmall: true),
                      if (_isAdmin && b.data?['edit_request']?['status'] == 'PENDING')
                        IconButton(onPressed: () => _showAdminReviewDialog(b), icon: const Icon(Icons.pending_actions_rounded, color: Colors.amber, size: 20), tooltip: 'Review Edit Request', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                      if (_isAdmin)
                        IconButton(onPressed: () => _deleteBilling(b), icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withValues(alpha: 0.5), size: 20), tooltip: 'Delete', constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ]);

    return InkWell(
        onTap: () => _openCreator(b),
        child: Padding(padding: const EdgeInsets.all(18), child: innerContent),
    ).animate().fadeIn(delay: (30 * i).ms, duration: 400.ms).slideX(begin: 0.02, end: 0);
  }

  Future<void> _setPaymentDeadlineDialog(BuildContext context, Billing b) async {
    final currentDeadline = b.data?['payment_deadline']?.toString() ?? '';
    final controller = TextEditingController(text: currentDeadline);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Set Payment Deadline', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Deadline Date (dd/mm/yyyy)',
            hintText: 'e.g. 15/06/2026',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      )
    );

    if (result == true) {
      try {
        final d = Map<String, dynamic>.from(b.data ?? {});
        d['payment_deadline'] = controller.text;
        await _billingService.updateBilling(b.id!, {'data': d});
        setState(() {
          final index = _billings.indexWhere((element) => element.id == b.id);
          if (index != -1) {
            _billings[index] = Billing(
              id: b.id,
              clientName: b.clientName,
              invoiceNo: b.invoiceNo,
              date: b.date,
              amount: b.amount,
              type: b.type,
              category: b.category,
              authorities: b.authorities,
              status: b.status,
              data: d,
            );
          }
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deadline updated successfully')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

}

// ─── PREMIUM INVOICE CREATOR PAGE ───
class InvoiceCreatorPage extends StatefulWidget {
  final Billing? billing;
  final bool isReadOnly;
  final bool canEdit;
  final VoidCallback? onRequestEdit;
  final void Function(dynamic id) onSaved;

  const InvoiceCreatorPage({
    super.key,
    this.billing,
    this.isReadOnly = false,
    this.canEdit = true,
    this.onRequestEdit,
    required this.onSaved,
  });

  @override
  State<InvoiceCreatorPage> createState() => _InvoiceCreatorPageState();
}

class _InvoiceCreatorPageState extends State<InvoiceCreatorPage> {
  late String _type, _category, _authorities, _status;
  late TextEditingController _clientName, _clientAddress, _date, _invoiceNo, _outstanding, _advanceReceived, _deadlineDate, _approvedAmount, _discount;
  bool _isToSameAsClient = true;
  late TextEditingController _customToCtrl;
  List<String> _selectedClientCompanies = [];
  List<Deals> _clientDeals = [];
  String? _selectedDealId;
  late List<Map<String, dynamic>> _items;
  late List<TextEditingController> _itemDescControllers;
  late List<TextEditingController> _itemAmountControllers;
  late List<String> _quotationTerms;
  late List<TextEditingController> _termControllers;
  List<String> _staffs = [];
  List<Map<String, String>> _pastItems = [];
  String _totalAmount = '0/-', _amountInWords = 'Zero', _grandTotal = '', _balanceDue = '';
  final _log = LoggingService();
  final _billingService = BillingService();
  bool _isAdmin = false;
  bool _isAmarnath = false;
  String _currentUserName = '';
  
  Future<void> _initRole() async {
    final isAdmin = await AuthService().isAdmin();
    final userName = await AuthService().getUserName();
    final isAmarnath = userName?.toLowerCase().trim() == 'amarnath';
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isAmarnath = isAmarnath;
        _currentUserName = userName ?? '';
      });
    }
  }
  int _pdfBuildCount = 0;
  Uint8List? _cachedPdf;
  bool _isGeneratingPdf = false;

  Future<Uint8List> _debouncedPdfBuild(PdfPageFormat format) async {
    _pdfBuildCount++;
    final currentCount = _pdfBuildCount;
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (currentCount != _pdfBuildCount) {
      if (_cachedPdf != null) return _cachedPdf!;
      while (_isGeneratingPdf) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_cachedPdf != null) return _cachedPdf!;
      }
    }
    
    _isGeneratingPdf = true;
    final bytes = await InvoicePdfService.generateInvoicePdf(
      type: _type, 
      category: _category, 
      clientName: _clientName.text, 
      clientAddress: _clientAddress.text, 
      date: _date.text, 
      invoiceNo: _invoiceNo.text, 
      authorities: _authorities, 
      items: _items, 
      totalAmount: _totalAmount, 
      amountInWords: _amountInWords, 
      outstandingAmount: _outstanding.text, 
      advanceReceived: _advanceReceived.text,
      discount: _discount.text,
      grandTotal: _grandTotal,
      balanceDue: _balanceDue,
      quotationTerms: _quotationTerms,
      isToSameAsClient: _isToSameAsClient,
      customTo: _customToCtrl.text,
    );
    _cachedPdf = bytes;
    _isGeneratingPdf = false;
    return bytes;
  }

  static const cats = ['Consultancy', 'Legal'];

  @override
  void initState() {
    super.initState();
    _initRole();
    final b = widget.billing;
    _type = b?.type ?? 'INVOICE';
    _status = b?.status ?? 'Pending';
    _category = cats.contains(b?.category) ? b!.category! : cats.first;
    _clientName = TextEditingController(text: b?.clientName);
    _clientAddress = TextEditingController(text: b?.data?['client_address'] ?? '');
    _isToSameAsClient = b?.data?['is_to_same_as_client'] ?? true;
    _customToCtrl = TextEditingController(text: b?.data?['custom_to'] ?? '');
    _customToCtrl.addListener(() => setState(() {}));
    _date = TextEditingController(text: b?.date != null && b!.date!.isNotEmpty ? b.date : DateFormat('dd/MM/yyyy').format(DateTime.now()));
    _deadlineDate = TextEditingController(text: b?.data?['payment_deadline']?.toString() ?? '');
    _invoiceNo = TextEditingController(text: b?.invoiceNo);
    _outstanding = TextEditingController(text: b?.outstandingAmount);
    _advanceReceived = TextEditingController(text: b?.data?['advance_received']?.toString() ?? '');
    _discount = TextEditingController(text: b?.data?['discount']?.toString() ?? '');
    _approvedAmount = TextEditingController(text: b?.data?['approved_amount']?.toString() ?? '');
    _authorities = b?.authorities ?? '';
    _items = List<Map<String, dynamic>>.from(b?.items?.map((e) => Map<String, dynamic>.from(e)) ?? [{'description': '', 'amount': '', 'isHeading': false}]);
    
    for (var item in _items) {
      if (!item.containsKey('isHeading')) {
        item['isHeading'] = item['amount']?.toString().trim().isEmpty ?? true;
      }
    }

    // Initialize quotation terms
    _quotationTerms = List<String>.from(b?.data?['quotation_terms'] ?? _getDefaultTerms(_category));
    _termControllers = _quotationTerms.map((t) => TextEditingController(text: t)).toList();

    // Initialize item controllers
    _itemDescControllers = _items.map((item) => TextEditingController(text: item['description'].toString())).toList();
    _itemAmountControllers = _items.map((item) => TextEditingController(text: item['amount'].toString())).toList();

    // Add listeners for real-time preview updates
    _clientName.addListener(() => setState(() {}));
    _clientAddress.addListener(() => setState(() {}));
    _date.addListener(() => setState(() {}));
    _deadlineDate.addListener(() => setState(() {}));
    _invoiceNo.addListener(() => setState(() {}));
    _outstanding.addListener(() {
      _calc();
      setState(() {});
    });
    _advanceReceived.addListener(() {
      _calc();
      setState(() {});
    });
    _discount.addListener(() {
      _calc();
      setState(() {});
    });

    for (var controller in _itemDescControllers) {
      controller.addListener(() {
        _calc();
        setState(() {});
      });
    }
    for (var controller in _itemAmountControllers) {
      controller.addListener(() {
        _calc();
        setState(() {});
      });
    }
    for (var controller in _termControllers) {
      controller.addListener(() => setState(() {}));
    }

    if (b != null) {
      _totalAmount = b.amount ?? '0/-';
      _amountInWords = b.amountInWords;
      _grandTotal = b.grandTotal;
      _balanceDue = b.data?['balance_due']?.toString() ?? '';
      _selectedDealId = b.data?['workfile_id']?.toString();
      
      // Resolve staff name from prefix if it's old/placeholder
      if (_authorities.isEmpty || _authorities.length <= 2) {
        final prefix = _authorities.isNotEmpty ? _authorities : (widget.billing!.invoiceNo?.split(RegExp(r'[ \-]')).first ?? '');
        if (prefix.isNotEmpty) {
           _authorities = prefix; // Will be refined after _fetchStaffs
        }
      }
      _fetchClientCompanies();
    } else {
      _generateInvoiceNo();
    }

    _fetchStaffs();
    _fetchPastItems();
  }

  Future<void> _fetchClientDeals() async {
    if (_clientName.text.isEmpty) {
      if (mounted) setState(() { _clientDeals = []; _selectedDealId = null; });
      return;
    }
    try {
      final req = ModelQueries.list(Deals.classType, where: Deals.CLIENT_NAME.eq(_clientName.text), limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      if (mounted) {
        setState(() {
          final rawDeals = res.data?.items.whereType<Deals>().toList() ?? [];
          _clientDeals = rawDeals.where((d) {
            final isCrm = (d.pipeline ?? '').toLowerCase() == 'crm' || (d.pipeline ?? '').toLowerCase() == 'lead';
            if (isCrm && d.is_won != true) return false;
            return true;
          }).toList();
          if (_clientDeals.length == 1) {
            _selectedDealId = _clientDeals.first.id;
          } else if (_clientDeals.isNotEmpty && !_clientDeals.any((d) => d.id == _selectedDealId)) {
            _selectedDealId = null;
          } else if (_clientDeals.isEmpty) {
            _selectedDealId = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching client deals: $e');
    }
  }

    Future<void> _fetchClientCompanies() async {
      _fetchClientDeals();
      if (_clientName.text.isEmpty) return;
      try {
        final clients = await ClientService().searchClients(_clientName.text);
        if (clients.isNotEmpty) {
          final c = clients.firstWhere((client) => client['name'] == _clientName.text, orElse: () => clients.first);
          if (mounted) {
            setState(() {
              _selectedClientCompanies = (c['companies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            });
          }
        }
      } catch (e) {
        debugPrint('Error fetching client companies: $e');
      }
    }

  Future<void> _fetchPastItems() async {
    try {
      final req = ModelQueries.list(Billings.classType, limit: 100);
      final res = await Amplify.API.query(request: req).response;
      final Set<String> seen = {};
      final List<Map<String, String>> items = [];
      final billingsList = (res.data?.items ?? []).whereType<Billings>().toList() ?? [];
      billingsList.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      
      for (var row in billingsList) {
        final dataStr = row.data;
        if (dataStr != null) {
          Map<String, dynamic> dataMap = {};
          try {
            dataMap = jsonDecode(dataStr);
          } catch (_) {}
          final list = dataMap['items'] as List<dynamic>?;
          if (list != null) {
             for (var item in list) {
               final numStr = dataMap['balance_due']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0';
               final bal = double.tryParse(numStr) ?? 0;
               final desc = item['description']?.toString() ?? '';
               final amt = item['amount']?.toString() ?? '';
               if (desc.isNotEmpty && !seen.contains(desc)) {
                 seen.add(desc);
                 items.add({'description': desc, 'amount': amt});
               }
             }
          }
        }
      }
      if (mounted) setState(() => _pastItems = items);
    } catch (e) {
      debugPrint('Failed to fetch past items: $e');
    }
  }

  Future<void> _fetchStaffs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserName = (prefs.getString('user_name') ?? _currentUserName).trim();
      final isCurrentUserAdmin = _isAdmin || currentUserName.toLowerCase() == 'admin';

      final users = await DealService().getAllUsers();
      final List<String> fetchedStaffs = users
          .map((u) => u['name'].toString())
          .where((name) {
            final lower = name.toLowerCase().trim();
            // Don't include admin in staff dropdown unless the current logged in user is admin
            if (lower == 'admin' && !isCurrentUserAdmin) return false;
            return !lower.contains('master admin') && 
                   !lower.contains('jayan') && 
                   !lower.contains('midhun');
          })
          .toList();

      setState(() {
        _staffs = fetchedStaffs.map((name) {
          final n = name.trim();
          final matchKey = _BillingScreenState.staffMapping.keys.firstWhere(
            (k) => n.toLowerCase().contains(k.toLowerCase()) || k.toLowerCase().contains(n.toLowerCase()),
            orElse: () => ''
          );
          if (matchKey.isNotEmpty) {
            return '${_BillingScreenState.staffMapping[matchKey]} - $matchKey';
          }
          return n;
        }).toSet().toList();

        if (isCurrentUserAdmin && !_staffs.any((s) => s.toLowerCase() == 'admin')) {
          _staffs.add('Admin');
        }

        if (widget.billing == null && _authorities.isEmpty) {
          // 1. First attempt: direct match of current user against _staffs
          String matched = '';
          if (currentUserName.isNotEmpty) {
            matched = _staffs.firstWhere(
              (s) {
                final sName = s.contains('-') ? s.split('-').last.trim().toLowerCase() : s.toLowerCase();
                final uName = currentUserName.toLowerCase();
                return sName == uName || sName.contains(uName) || uName.contains(sName);
              },
              orElse: () => '',
            );
          }

          // 2. Second attempt: match via staffMapping keys
          if (matched.isEmpty && currentUserName.isNotEmpty) {
            final matchKey = _BillingScreenState.staffMapping.keys.firstWhere(
              (k) => currentUserName.toLowerCase().contains(k.toLowerCase()) || k.toLowerCase().contains(currentUserName.toLowerCase()),
              orElse: () => ''
            );
            if (matchKey.isNotEmpty) {
              matched = _staffs.firstWhere(
                (s) => s.toLowerCase().contains(matchKey.toLowerCase()),
                orElse: () => '${_BillingScreenState.staffMapping[matchKey]} - $matchKey',
              );
            }
          }

          if (matched.isNotEmpty) {
            if (!_staffs.contains(matched)) _staffs.add(matched);
            _authorities = matched;
          } else if (currentUserName.isNotEmpty && !isCurrentUserAdmin) {
            final matchKey = _BillingScreenState.staffMapping.keys.firstWhere(
              (k) => currentUserName.toLowerCase().contains(k.toLowerCase()) || k.toLowerCase().contains(currentUserName.toLowerCase()),
              orElse: () => ''
            );
            final formatted = matchKey.isNotEmpty 
                ? '${_BillingScreenState.staffMapping[matchKey]} - $matchKey' 
                : currentUserName;
            if (!_staffs.contains(formatted)) _staffs.add(formatted);
            _authorities = formatted;
          } else if (_staffs.isNotEmpty) {
            _authorities = _staffs.first;
          }
        } else if (widget.billing != null) {
          final invPrefix = widget.billing!.invoiceNo?.split(RegExp(r'[ \-]')).first ?? '';
          final existingAuth = _authorities.isEmpty ? invPrefix : _authorities;
          
          if (existingAuth.isNotEmpty) {
            final match = _BillingScreenState.staffMapping.keys.firstWhere(
              (k) => k.toLowerCase() == existingAuth.toLowerCase() || 
                     existingAuth.toLowerCase().contains(k.toLowerCase()) ||
                     _BillingScreenState.staffMapping[k] == existingAuth.toUpperCase(), 
              orElse: () => ''
            );
            if (match.isNotEmpty) {
              _authorities = '${_BillingScreenState.staffMapping[match]} - $match';
            } else {
              _authorities = existingAuth;
            }
          }

          if (_authorities.isEmpty) {
            _authorities = widget.billing!.authorities ?? (_staffs.isNotEmpty ? _staffs.first : '');
          }
        }
      });
    } catch (e) {
      debugPrint('StaffFetchErr: $e');
    }
  }

  @override
  void dispose() {
    _clientName.dispose();
    _clientAddress.dispose();
    _date.dispose();
    _deadlineDate.dispose();
    _invoiceNo.dispose();
    _outstanding.dispose();
    _advanceReceived.dispose();
    _discount.dispose();
    _approvedAmount.dispose();
    for (var c in _itemDescControllers) {
      c.dispose();
    }
    for (var c in _itemAmountControllers) {
      c.dispose();
    }
    for (var c in _termControllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _getDefaultTerms(String category) {
    if (_type == 'INVOICE') {
      return [
        'For any clarifications or queries regarding the bill, or to report an error or omission, please contact us at cochinunitedconsultancydm@gmail.com',
      ];
    }
    
    return [
      'The validity of this quotation is only for one month from the date of issue.',
      'This quotation is not comprehensive. Inspection charges, additional consultation, statutory fees, and any additional work required as per instructions from authorities are excluded from this quotation and will be charged separately, if required.',
      'Any increase in government fees or additional expenses during the application process must be borne by you.',
      'We are not liable for delays caused by changes in government regulations, system failures, network issues, or unforeseen circumstances beyond our control.',
      'If additional documents or steps are required, your cooperation and support will be necessary, and any extra expenses incurred must be reimbursed by you.',
      'Please regularly follow up on the application process and promptly share any required OTPs.',
      'In case of any unethical practices or misbehavior by our staff, please contact our Client Relationship Manager immediately.',
    ];
  }

  String _getPrefix() {
    if (_category == 'Legal') {
      return _type == 'QUOTATION' ? 'CLP-' : 'LLP-';
    }
    return _type == 'QUOTATION' ? 'CC-' : 'AA-';
  }

  Future<void> _generateInvoiceNo([bool force = false]) async {
    if (widget.billing != null && !force) return;
    
    try {
      final prefix = _getPrefix();
      final next = await _billingService.getNextInvoiceNo(prefix);
      if (next != null) {
        setState(() => _invoiceNo.text = next);
      } else {
        setState(() => _invoiceNo.text = "${prefix}001");
      }
    } catch (e) { 
      debugPrint('GenErr: $e');
      final prefix = _getPrefix();
      if (mounted) setState(() => _invoiceNo.text = "${prefix}001");
    }
  }

  Future<bool> _isInvoiceNoDuplicate(String no) async {
    try {
      final req = ModelQueries.list(Billings.classType, where: Billings.INVOICE_NO.eq(no), limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      return (res.data?.items.where((i) => i!.id != widget.billing?.id.toString()).isNotEmpty) ?? false;
    } catch (e) {
      return false;
    }
  }

  void _calc() {
    double t = 0;
    for (int i = 0; i < _items.length; i++) {
      _items[i]['description'] = _itemDescControllers[i].text;
      _items[i]['amount'] = _itemAmountControllers[i].text;
      t += NumberToWords.parseCurrency(_itemAmountControllers[i].text);
    }
    // Sync terms
    for (int i = 0; i < _quotationTerms.length; i++) {
      _quotationTerms[i] = _termControllers[i].text;
    }
    double o = NumberToWords.parseCurrency(_outstanding.text);
    double adv = NumberToWords.parseCurrency(_advanceReceived.text);
    double disc = NumberToWords.parseCurrency(_discount.text);
    double g = t + o;
    setState(() {
      _totalAmount = t > 0 ? NumberToWords.formatIndianCurrency(t) : '0/-';
      _amountInWords = t > 0 ? NumberToWords.convert(t.round()) : 'Zero';
      _grandTotal = g > t ? NumberToWords.formatIndianCurrency(g) : '';
      _balanceDue = (adv > 0 || disc > 0) ? NumberToWords.formatIndianCurrency(g - adv - disc) : '';
    });
  }

  Future<void> _syncClientBalance(String clientName) async {
    await _billingService.syncClientBalance(clientName);
  }

  Future<void> _save() async {
    if (_clientName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a client first'), backgroundColor: Colors.orange));
      return;
    }

    if (_type != 'QUOTATION' && _selectedDealId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a Work File before creating an invoice. If the client has no Work Files, please create one first.'), 
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (_invoiceNo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice number is required'), backgroundColor: Colors.orange));
      return;
    }

    final isDuplicate = await _isInvoiceNoDuplicate(_invoiceNo.text);
    if (isDuplicate) {
      if (widget.billing == null || widget.billing!.id == null) {
        // If this is a new bill, auto-assign the next available number instead of failing
        final newNo = await _billingService.getNextInvoiceNo(_getPrefix());
        setState(() { _invoiceNo.text = newNo ?? ''; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Original invoice number was taken. Auto-assigned to ${newNo ?? ''}'), 
          backgroundColor: Colors.green
        ));
      } else {
        // If editing an existing bill, warn them
        final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Duplicate Invoice Number'),
            content: Text('An invoice with number "${_invoiceNo.text}" already exists. Save anyway?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save Anyway')),
            ],
          ),
        );
        if (confirm != true) return;
      }
    }

    if (widget.isReadOnly) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot save: Viewing in Read-Only mode')));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserName = prefs.getString('user_name') ?? (_currentUserName.isNotEmpty ? _currentUserName : 'Unknown User');
      final isCurrentUserAdmin = _isAdmin || currentUserName.toLowerCase() == 'admin';

      String? discountBy = widget.billing?.data?['discount_given_by'];
      final currentDiscountText = widget.billing?.data?['discount']?.toString() ?? '';
      if (_discount.text != currentDiscountText && _discount.text.isNotEmpty && _discount.text != '0' && _discount.text != '0/-') {
         discountBy = currentUserName;
      }

      final d = {
        'items': _items, 
        'outstanding_amount': _outstanding.text, 
        'amount_in_words': _amountInWords, 
        'grand_total': _grandTotal, 
        'balance_due': _balanceDue,
        'advance_received': _advanceReceived.text,
        'client_address': _clientAddress.text, 
        'is_to_same_as_client': _isToSameAsClient,
        'custom_to': _customToCtrl.text,
        'quotation_terms': _quotationTerms,
        'payment_deadline': _deadlineDate.text,
        'approved_amount': _approvedAmount.text,
        'discount': _discount.text,
        'workfile_id': _selectedDealId,
        'created_by': widget.billing?.data?['created_by'] ?? (currentUserName.isNotEmpty ? currentUserName : 'Unknown User'),
        if (discountBy != null) 'discount_given_by': discountBy,
        'payment_received': (NumberToWords.parseCurrency(_advanceReceived.text) > 0 && NumberToWords.parseCurrency(_advanceReceived.text) >= NumberToWords.parseCurrency(_grandTotal.isEmpty ? _totalAmount : _grandTotal)) || (widget.billing?.data?['payment_received'] == true), 
        'payment_date': widget.billing?.data?['payment_date'],
        'edit_count': (widget.billing?.data?['edit_count'] ?? 0) + (widget.billing != null && widget.billing!.id != null ? 1 : 0),
        'marked_paid_by': widget.billing?.data?['marked_paid_by'],
      };

      if (widget.billing?.data?['edit_request'] != null) {
        final req = Map<String, dynamic>.from(widget.billing!.data!['edit_request']);
        if (req['status'] == 'APPROVED') {
          req['status'] = 'COMPLETED';
          req['completed_at'] = DateTime.now().toIso8601String();
          req['completed_by'] = currentUserName;
        }
        d['edit_request'] = req;
      }
      
      if (d['payment_received'] == true && widget.billing?.data?['payment_received'] != true) {
        d['marked_paid_by'] = currentUserName;
      }
      
      String saveAuth = _authorities.trim();
      if (saveAuth.isEmpty) {
        saveAuth = currentUserName.isNotEmpty && !isCurrentUserAdmin ? currentUserName : 'Admin';
      }

      dynamic savedId;
      if (widget.billing == null || widget.billing!.id == null) { 
        final nextId = await _billingService.getNextBillingId();
        final newBilling = Billings(
          id: nextId,
          invoice_no: _invoiceNo.text,
          client_name: _clientName.text,
          date: _date.text,
          amount: _totalAmount,
          type: _type,
          category: _category,
          authorities: saveAuth,
          status: _status,
          data: jsonEncode(d),
        );
        final res = await BackupAwareApi().create(newBilling);
        if (res.errors.isNotEmpty) {
          throw Exception(res.errors.map((e) => e.message).join(', '));
        }
        if (res.data == null) {
          throw Exception('Failed to write billing: empty response data');
        }
        savedId = res.data?.id;
        await _log.logAction(action: 'INVOICE_CREATED', targetType: 'Invoice', targetId: _invoiceNo.text, details: 'Created for ${_clientName.text}');
      }
      else { 
        savedId = widget.billing!.id!;
        final updateBilling = Billings(
          id: savedId.toString(),
          invoice_no: _invoiceNo.text,
          client_name: _clientName.text,
          date: _date.text,
          amount: _totalAmount,
          type: _type,
          category: _category,
          authorities: saveAuth,
          status: _status,
          created_at: widget.billing?.createdAt,
          data: jsonEncode(d),
        );
        final res = await BackupAwareApi().update(updateBilling);
        if (res.errors.isNotEmpty) {
          throw Exception(res.errors.map((e) => e.message).join(', '));
        }
        await _log.logAction(action: 'INVOICE_UPDATED', targetType: 'Invoice', targetId: _invoiceNo.text, details: 'Updated for ${_clientName.text}');
      }
      // Update client's balance in the clients table
      if (_clientName.text.isNotEmpty) {
        await _syncClientBalance(_clientName.text);
      }

      widget.onSaved(savedId);
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.redAccent)); }
  }

  Future<void> _print() async {
    _calc();
    await InvoicePdfService.printInvoice(
      type: _type, 
      category: _category, 
      clientName: _clientName.text, 
      clientAddress: _clientAddress.text, 
      date: _date.text, 
      invoiceNo: _invoiceNo.text, 
      authorities: _authorities, 
      items: _items, 
      totalAmount: _totalAmount, 
      amountInWords: _amountInWords, 
      outstandingAmount: _outstanding.text, 
      advanceReceived: _advanceReceived.text,
      discount: _discount.text,
      grandTotal: _grandTotal,
      balanceDue: _balanceDue,
      quotationTerms: _quotationTerms,
      isToSameAsClient: _isToSameAsClient,
      customTo: _customToCtrl.text,
    );
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 950;
        final bool canPrint = _type == 'QUOTATION' || _selectedDealId != null;
        
        final formPanel = Container(
          width: isMobile ? double.infinity : 460,
          decoration: BoxDecoration(
            color: Colors.white, 
            boxShadow: isMobile ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(10, 0))]
          ),
          child: Column(children: [
            // Header
            Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
              child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                          child: const Text('CUC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))),
                        const SizedBox(width: 12),
                        Text(widget.isReadOnly ? 'View ${widget.billing?.type ?? "Bill"}' : 'Billing', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                      ]),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.isReadOnly ? 'Close' : 'Cancel', style: const TextStyle(color: Colors.grey, fontSize: 13))),
                        if (!widget.isReadOnly)
                          ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save_rounded, size: 14), label: const Text('Save', style: TextStyle(fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                        if (widget.isReadOnly && widget.onRequestEdit != null)
                          ElevatedButton.icon(onPressed: widget.onRequestEdit, icon: const Icon(Icons.edit_calendar_rounded, size: 14), label: const Text('Request Edit', style: TextStyle(fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                        ElevatedButton.icon(onPressed: _print, icon: const Icon(Icons.print_rounded, size: 14), label: const Text('Print / Download', style: TextStyle(fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                      ]),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                          child: const Text('CUC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))),
                        const SizedBox(width: 12),
                        Text(widget.isReadOnly ? 'View ${widget.billing?.type ?? "Bill"}' : 'Billing', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                        if (widget.isReadOnly) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.amber.shade300)),
                            child: Text('VIEW ONLY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.amber.shade900)),
                          ),
                        ],
                      ]),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.isReadOnly ? 'Close' : 'Cancel', style: const TextStyle(color: Colors.grey, fontSize: 13))),
                        if (!widget.isReadOnly)
                          ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save_rounded, size: 14), label: const Text('Save', style: TextStyle(fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                        if (widget.isReadOnly && widget.onRequestEdit != null)
                          ElevatedButton.icon(onPressed: widget.onRequestEdit, icon: const Icon(Icons.edit_calendar_rounded, size: 14), label: const Text('Request Edit', style: TextStyle(fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                        ElevatedButton.icon(onPressed: _print, icon: const Icon(Icons.print_rounded, size: 14), label: const Text('Print / Download', style: TextStyle(fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                      ]),
                    ],
                  ),
            ),
            // Form Content
            Expanded(child: SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 16 : 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (widget.isReadOnly) ...[
                _buildReadOnlyBanner(),
                const SizedBox(height: 16),
              ],
              IgnorePointer(
                ignoring: widget.isReadOnly,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [Icon(Icons.description_rounded, color: Colors.white, size: 18), SizedBox(width: 10), Text('Invoice Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)), Spacer(), Text('Items', style: TextStyle(color: Colors.white70, fontSize: 11))]),
              ),
              const SizedBox(height: 24),
              // Meta Row
              if (isMobile) ...[
                _buildSelector('CATEGORY', _category, cats, (v) {
                  setState(() {
                    _category = v;
                    if (_type == 'QUOTATION') {
                      _quotationTerms = _getDefaultTerms(_category);
                      _termControllers = _quotationTerms.map((t) => TextEditingController(text: t)).toList();
                    }
                  });
                }),
                const SizedBox(height: 16),
                _buildSelector('DOCUMENT TYPE', _type, ['INVOICE', 'QUOTATION'], (v) {
                  setState(() {
                    if (_type != v) {
                      _type = v;
                      _quotationTerms = _getDefaultTerms(_category);
                      _termControllers = _quotationTerms.map((t) => TextEditingController(text: t)).toList();
                      _generateInvoiceNo(true);
                    }
                  });
                }),
                if (_type == 'QUOTATION') ...[
                   const SizedBox(height: 16),
                   _buildSelector('QUOTATION STATUS', _status, ['Pending', 'Interested', 'Not Interested'], (v) => setState(() => _status = v)),
                ]
              ] else Row(
                children: [
                  Expanded(child: _buildSelector('CATEGORY', _category, cats, (v) {
                    setState(() {
                      if (_category != v) {
                        _category = v;
                        if (_type == 'QUOTATION') {
                          _quotationTerms = _getDefaultTerms(_category);
                          _termControllers = _quotationTerms.map((t) => TextEditingController(text: t)).toList();
                        }
                        if (widget.billing == null || widget.billing!.id == null) _generateInvoiceNo(true);
                      }
                    });
                  })),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSelector('DOCUMENT TYPE', _type, ['INVOICE', 'QUOTATION'], (v) {
                    setState(() {
                      if (_type != v) {
                        _type = v;
                        _quotationTerms = _getDefaultTerms(_category);
                        _termControllers = _quotationTerms.map((t) => TextEditingController(text: t)).toList();
                        if (widget.billing == null || widget.billing!.id == null) _generateInvoiceNo(true);
                      }
                    });
                  })),
                  if (_type == 'QUOTATION') ...[
                    const SizedBox(width: 16),
                    Expanded(child: _buildSelector('STATUS', _status, ['Pending', 'Interested', 'Not Interested'], (v) => setState(() => _status = v))),
                  ]
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle('Client Details'),
              _buildClientAutocomplete(isMobile),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _clientDeals.any((d) => d.id == _selectedDealId) ? _selectedDealId : null,
                decoration: InputDecoration(
                  labelText: _type == 'QUOTATION' ? 'Select Work File (Optional)' : 'Select Work File (Required for Invoice)',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB))),
                ),
                items: _clientDeals.map((deal) {
                  return DropdownMenuItem<String>(
                    value: deal.id,
                    child: Text(
                      '${deal.name ?? 'Unnamed Deal'}${deal.register_no != null && deal.register_no!.isNotEmpty ? ' (File No: ${deal.register_no})' : ''}', 
                      overflow: TextOverflow.ellipsis
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedDealId = val),
                icon: const Icon(Icons.work_outline_rounded, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              _buildField('Address', _clientAddress, 'Complete billing address...', lines: 3),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: _isToSameAsClient,
                    onChanged: (v) => setState(() => _isToSameAsClient = v),
                    activeColor: const Color(0xFF2563EB),
                  ),
                  const Expanded(child: Text('Use Client Name & Address for "TO"', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
                ],
              ),
              if (_selectedClientCompanies.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Or Select Company:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedClientCompanies.map((comp) {
                    String cName = comp;
                    String cAddr = '';
                    if (comp.contains('|||')) {
                      final parts = comp.split('|||');
                      cName = parts[0];
                      if (parts.length > 1) cAddr = parts[1];
                      if (parts.length > 2) cAddr += '\n${parts[2]}';
                    }
                    return ActionChip(
                      label: Text(cName, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      onPressed: () {
                        setState(() {
                          _isToSameAsClient = false;
                          _customToCtrl.text = cAddr.isNotEmpty ? '$cName\n$cAddr' : cName;
                        });
                      }
                    );
                  }).toList(),
                ),
              ],
              if (!_isToSameAsClient) ...[
                const SizedBox(height: 12),
                _buildField('Custom "TO" Details', _customToCtrl, 'First line bold (Name)\nOther lines normal (Address)', lines: 4),
              ],
              const SizedBox(height: 20),
              if (isMobile) ...[
                _buildField('Date', _date, 'dd/mm/yyyy', readOnly: !(_isAdmin || _isAmarnath), onTap: (_isAdmin || _isAmarnath) ? () => _pickDate(_date) : null),
                const SizedBox(height: 16),
                _buildField('Payment Deadline', _deadlineDate, 'dd/mm/yyyy', readOnly: !(_isAdmin || _isAmarnath), onTap: (_isAdmin || _isAmarnath) ? () => _pickDate(_deadlineDate) : null),
                const SizedBox(height: 16),
                _buildField('Invoice No', _invoiceNo, 'e.g. AA-001', readOnly: !(_isAdmin || _isAmarnath)),
              ] else Row(
                children: [
                  Expanded(child: _buildField('Date', _date, 'dd/mm/yyyy', readOnly: !(_isAdmin || _isAmarnath), onTap: (_isAdmin || _isAmarnath) ? () => _pickDate(_date) : null)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Payment Deadline', _deadlineDate, 'dd/mm/yyyy', readOnly: !(_isAdmin || _isAmarnath), onTap: (_isAdmin || _isAmarnath) ? () => _pickDate(_deadlineDate) : null)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Invoice No', _invoiceNo, 'e.g. AA-001', readOnly: !(_isAdmin || _isAmarnath))),
                ],
              ),
              const SizedBox(height: 20),
              _buildSelector('STAFF', _authorities, _staffs, (v) { 
                setState(() => _authorities = v); 
              }),
              
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _sectionTitle('${_type == 'QUOTATION' ? 'Quotation' : 'Invoice'} Terms'),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _quotationTerms.add('');
                      _termControllers.add(TextEditingController()..addListener(() => setState(() {})));
                    });
                  }, 
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18), 
                  label: const Text('Add Point'), 
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB))
                ),
              ]),
              const SizedBox(height: 12),
              ..._termControllers.asMap().entries.map((e) => _buildTermRow(e.key)),

              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _sectionTitle('Line Items'),
                Row(
                  children: [
                    TextButton.icon(onPressed: () {
                      setState(() {
                        _items.add({'description': '', 'amount': '', 'isHeading': true});
                        _itemDescControllers.add(TextEditingController()..addListener(() { _calc(); setState(() {}); }));
                        _itemAmountControllers.add(TextEditingController()..addListener(() { _calc(); setState(() {}); }));
                      });
                    }, icon: const Icon(Icons.title_rounded, size: 18), label: const Text('Add Heading'), style: TextButton.styleFrom(foregroundColor: Colors.teal)),
                    TextButton.icon(onPressed: () {
                      setState(() {
                        _items.add({'description': '', 'amount': '', 'isHeading': false});
                        _itemDescControllers.add(TextEditingController()..addListener(() { _calc(); setState(() {}); }));
                        _itemAmountControllers.add(TextEditingController()..addListener(() { _calc(); setState(() {}); }));
                      });
                    }, icon: const Icon(Icons.add_circle_outline_rounded, size: 18), label: const Text('Add Item'), style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB))),
                  ],
                ),
              ]),
              const SizedBox(height: 12),
              ..._items.asMap().entries.map((e) => _buildItemRow(e.key, e.value)),
              if (_items.isEmpty) _emptyItems(),
              const SizedBox(height: 32),
              _sectionTitle('Summary & Outstanding'),
              Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  _summaryRow('Subtotal', _totalAmount, isBold: true),
                  const Divider(height: 24),
                  _buildField('Previous Outstanding', _outstanding, '0/-', onChanged: (_) => _calc(), isCurrency: true),
                  if (_grandTotal.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _summaryRow('Grand Total', _grandTotal, isPrimary: true),
                  ],
                  if (_type == 'QUOTATION') ...[
                    const SizedBox(height: 16),
                    _buildField('Approved Amount', _approvedAmount, '0/-', isCurrency: true),
                  ],
                  const SizedBox(height: 16),
                  _buildField('Advance / Received', _advanceReceived, '0/-', onChanged: (_) => _calc(), isCurrency: true),
                  const SizedBox(height: 16),
                  _buildField('Discount', _discount, '0/-', onChanged: (_) => _calc(), isCurrency: true),
                  if (_balanceDue.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _summaryRow('Balance Due', _balanceDue, isBold: true, color: Colors.orange.shade700),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Authorized Signature', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Image.asset('assets/sign.png', height: 40, fit: BoxFit.contain, opacity: const AlwaysStoppedAnimation(0.7)),
                  ]),
                ]),
              ),
            ])),
            const SizedBox(height: 100),
          ]))),
            // Footer Actions
            if (!widget.isReadOnly)
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade100))),
                child: isMobile
                  ? Column(
                      children: [
                        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _save, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Save Progress'))),
                        if (canPrint) ...[
                          const SizedBox(height: 12),
                          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _print, icon: const Icon(Icons.print_rounded, size: 18), label: const Text('Finalize & Print'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                        ]
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _save, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Save Progress')))),
                        if (canPrint) ...[
                          const SizedBox(width: 16),
                          Expanded(child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _print, icon: const Icon(Icons.print_rounded, size: 18), label: const Text('Finalize & Print'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))),
                        ]
                      ],
                    ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade100))),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _print,
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Print / Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            // Version Footer
            Container(padding: const EdgeInsets.symmetric(vertical: 12), width: double.infinity, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade50))), child: Text('Billing Software v1.0', style: TextStyle(color: Colors.grey.shade400, fontSize: 10))),
          ]),
        );

        final previewPanel = Container(
          color: const Color(0xFFF1F5F9), 
          child: Center(
            child: PdfPreview(
              build: (format) => _debouncedPdfBuild(format),
              canChangePageFormat: false, 
              canChangeOrientation: false, 
              canDebug: false, 
              actions: const [],
            ),
          ),
        );

        if (isMobile) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: PremiumAppBar(
                title: Text(widget.isReadOnly ? 'View ${widget.billing?.type ?? "Bill"}' : 'Invoice Creator', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20)),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'DETAILS', icon: Icon(Icons.edit_note_rounded, size: 20)),
                    Tab(text: 'PREVIEW', icon: Icon(Icons.remove_red_eye_rounded, size: 20)),
                  ],
                  labelColor: Color(0xFF2563EB),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF2563EB),
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                ),
              ),
              body: TabBarView(children: [formPanel, previewPanel]),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Row(children: [formPanel, Expanded(child: previewPanel)]),
        );
      },
    );
  }

  Widget _buildReadOnlyBanner() {
    final editReq = widget.billing?.data?['edit_request'];
    final status = editReq?['status'];

    Color bannerColor = Colors.blue.shade50;
    Color borderColor = Colors.blue.shade200;
    Color textColor = Colors.blue.shade900;
    IconData icon = Icons.visibility_rounded;
    String title = 'View-Only Mode';
    String message = 'You are currently viewing this bill in read-only mode. You can view all line items, terms, and print/download the PDF.';

    if (status == 'PENDING') {
      bannerColor = Colors.amber.shade50;
      borderColor = Colors.amber.shade300;
      textColor = Colors.amber.shade900;
      icon = Icons.hourglass_top_rounded;
      title = 'Edit Request Pending Admin Approval';
      message = 'Requested by ${editReq['requested_by']}: ${editReq['reason_category']}.\n"${editReq['reason_details']}"';
    } else if (status == 'REJECTED') {
      bannerColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      textColor = Colors.red.shade900;
      icon = Icons.cancel_outlined;
      title = 'Edit Request Not Approved (Rejected)';
      message = 'Admin Remarks: ${editReq['review_remarks'] ?? "No reason given"}. You can submit a new request if needed.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                const SizedBox(height: 3),
                Text(message, style: TextStyle(fontSize: 12, color: textColor, height: 1.3)),
              ],
            ),
          ),
          if (widget.onRequestEdit != null && status != 'PENDING') ...[
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: widget.onRequestEdit,
              icon: const Icon(Icons.edit_calendar_rounded, size: 14),
              label: const Text('Request Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1.5)));

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? initialDate;
    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
      }
    } catch (_) {}
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _formatCurrencyField(TextEditingController controller) {
    double val = NumberToWords.parseCurrency(controller.text);
    if (val > 0) {
      setState(() => controller.text = NumberToWords.formatIndianCurrency(val));
      _calc();
    }
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {int lines = 1, ValueChanged<String>? onChanged, bool isCurrency = false, Widget? suffix, bool readOnly = false, VoidCallback? onTap}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
    const SizedBox(height: 6),
    Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && isCurrency) _formatCurrencyField(controller);
      },
      child: TextField(
        onTap: onTap,
        controller: controller, maxLines: lines, onChanged: onChanged,
        readOnly: onTap != null ? true : readOnly,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint, 
          hintStyle: TextStyle(color: Colors.grey.shade300), 
          filled: true, 
          fillColor: readOnly ? Colors.grey.shade100 : const Color(0xFFF8FAFC), 
          suffixIcon: suffix ?? (onTap != null ? Icon(Icons.calendar_month, color: Colors.grey.shade400, size: 20) : null),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)), 
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)), 
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB)))
        ),
      ),
    ),
  ]);

  void _showQuickCreateClientDialog() {
    final nameCtrl = TextEditingController(text: _clientName.text);
    final emailCtrl = TextEditingController();
    List<TextEditingController> phoneControllers = [TextEditingController()];
    final workCtrl = TextEditingController();
    final fileNoCtrl = TextEditingController();
    final fileDateCtrl = TextEditingController();
    final dobCtrl = TextEditingController();
    final careOfCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    bool isContacted = false;
    bool isSaving = false;
    List<Map<String, TextEditingController>> companyControllers = [];

    Widget buildPremiumField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
      return TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC5A028)),),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          insetPadding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 550,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFC5A028).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.person_add_rounded, color: Color(0xFFC5A028), size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Create New Client', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            Text('Add client details directly into the database', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                
                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildPremiumField(nameCtrl, 'Full Name', Icons.person_outline),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  ...phoneControllers.asMap().entries.map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(child: buildPremiumField(e.value, 'Phone Number', Icons.phone_outlined)),
                                        if (e.key > 0)
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                            onPressed: () => setDialogState(() => phoneControllers.removeAt(e.key))
                                          )
                                      ]
                                    )
                                  )),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () => setDialogState(() => phoneControllers.add(TextEditingController())),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Add Phone Number', style: TextStyle(fontSize: 12)),
                                    ),
                                  )
                                ]
                              )
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: buildPremiumField(emailCtrl, 'Email Address', Icons.email_outlined)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        buildPremiumField(workCtrl, 'Type of Work', Icons.work_outline),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: buildPremiumField(fileNoCtrl, 'File No', Icons.folder_outlined)),
                            const SizedBox(width: 16),
                            Expanded(child: buildPremiumField(fileDateCtrl, 'File Date', Icons.calendar_today_outlined)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: buildPremiumField(dobCtrl, 'Date of Birth', Icons.cake_outlined)),
                            const SizedBox(width: 16),
                            Expanded(child: buildPremiumField(careOfCtrl, 'Managed By (C/O)', Icons.supervisor_account_outlined)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: CheckboxListTile(
                            title: const Text('Client Contacted?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                            value: isContacted,
                            activeColor: const Color(0xFFC5A028),
                            onChanged: (val) => setDialogState(() => isContacted = val ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildPremiumField(addressCtrl, 'Full Address', Icons.location_on_outlined, maxLines: 3),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Companies', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                        ),
                        const SizedBox(height: 8),
                        ...companyControllers.asMap().entries.map((e) {
                          int idx = e.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      buildPremiumField(e.value['name']!, 'Company Name', Icons.business),
                                      const SizedBox(height: 8),
                                      buildPremiumField(e.value['address']!, 'Company Address', Icons.location_on_outlined, maxLines: 2),
                                      const SizedBox(height: 8),
                                      buildPremiumField(e.value['phone']!, 'Company Phone Number', Icons.phone_outlined),
                                    ]
                                  )
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => setDialogState(() => companyControllers.removeAt(idx)),
                                )
                              ]
                            )
                          );
                        }),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => setDialogState(() => companyControllers.add({'name': TextEditingController(), 'address': TextEditingController(), 'phone': TextEditingController()})),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Company', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          foregroundColor: const Color(0xFF64748B),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isSaving ? null : () async {
                          if (nameCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required'), backgroundColor: Colors.redAccent));
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          try {
                            final newClient = Clients(
                              name: nameCtrl.text,
                              email: emailCtrl.text,
                              phone: phoneControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join(', '),
                              type_of_work: workCtrl.text,
                              file_no: fileNoCtrl.text,
                              file_date: fileDateCtrl.text,
                              dob: dobCtrl.text,
                              managed_by: careOfCtrl.text,
                              is_contacted: isContacted,
                              address: addressCtrl.text,
                              companies: companyControllers.map((c) {
                                final name = c['name']!.text.trim();
                                final addr = c['address']!.text.trim();
                                final phone = c['phone']!.text.trim();
                                return '$name|||$addr|||$phone';
                              }).where((c) => !c.startsWith('|||')).toList(),
                            );
                            await BackupAwareApi().create(newClient);
                            if (mounted) {
                              setState(() {
                                _clientName.text = newClient.name ?? '';
                                _clientAddress.text = newClient.address ?? '';
                              });
                              _fetchClientDeals();
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client created successfully'), backgroundColor: Colors.green));
                            }
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
                          } finally {
                            if (mounted) setDialogState(() => isSaving = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC5A028),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                            : const Text('Save Client', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClientSelectionDialog() async {
    final clients = await ClientService().getAllClients();
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = clients.where((c) => (c['name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();
            
            return AlertDialog(
              title: const Text('Select Client', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search clients...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) {
                        setDialogState(() => searchQuery = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final c = filtered[idx];
                          return ListTile(
                            title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(c['phone'] ?? ''),
                            onTap: () {
                              setState(() {
                                _clientName.text = c['name'] ?? '';
                                _clientAddress.text = c['address'] ?? '';
                                _outstanding.text = c['balance_due']?.toString() ?? '';
                                _selectedClientCompanies = (c['companies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                                _calc();
                              });
                              _fetchClientDeals();
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildClientAutocomplete(bool isMobile) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Client Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          InkWell(
            onTap: _showQuickCreateClientDialog,
            child: const Text('+ New Client', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
        ],
      ),
      const SizedBox(height: 6),
      InkWell(
        onTap: _showClientSelectionDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _clientName.text.isEmpty ? 'Select a client...' : _clientName.text,
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w500,
                    color: _clientName.text.isEmpty ? Colors.grey.shade400 : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildSelector(String label, String value, List<String> items, ValueChanged<String> onChanged) {
    // Create a safe copy of items and ensure the current value is included to prevent DropdownButton crashes
    final List<String> safeItems = List.from(items);
    if (value.isNotEmpty && !safeItems.contains(value)) {
      safeItems.add(value);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
      const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: DropdownButton<String>(
          value: value.isEmpty ? (safeItems.isNotEmpty ? safeItems.first : null) : value, 
          isExpanded: true, 
          underline: const SizedBox(), 
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
          items: safeItems.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
          onChanged: (v) => onChanged(v!),
        ),
      ),
    ]);
  }

  void _moveItem(int idx, int dir) {
    if (idx + dir < 0 || idx + dir >= _items.length) return;
    setState(() {
      final item = _items.removeAt(idx);
      final desc = _itemDescControllers.removeAt(idx);
      final amt = _itemAmountControllers.removeAt(idx);
      _items.insert(idx + dir, item);
      _itemDescControllers.insert(idx + dir, desc);
      _itemAmountControllers.insert(idx + dir, amt);
    });
  }

  Widget _buildItemRow(int idx, Map<String, dynamic> item) {
    bool isHeading = item['isHeading'] == true;
    
    return Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: isHeading ? Colors.teal.shade50 : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isHeading ? Colors.teal.shade200 : Colors.grey.shade100)),
    child: Column(children: [
      Row(children: [
        Container(width: 24, height: 24, decoration: BoxDecoration(color: isHeading ? Colors.teal.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(6)), child: Center(child: Text(isHeading ? 'H' : '${idx + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isHeading ? Colors.teal.shade700 : Colors.grey.shade400)))),
        const Spacer(),
        if (idx > 0) IconButton(onPressed: () => _moveItem(idx, -1), icon: const Icon(Icons.arrow_upward_rounded, size: 18, color: Colors.blueGrey)),
        if (idx < _items.length - 1) IconButton(onPressed: () => _moveItem(idx, 1), icon: const Icon(Icons.arrow_downward_rounded, size: 18, color: Colors.blueGrey)),
        IconButton(onPressed: () => setState(() { 
          _items.removeAt(idx); 
          _itemDescControllers[idx].dispose();
          _itemAmountControllers[idx].dispose();
          _itemDescControllers.removeAt(idx);
          _itemAmountControllers.removeAt(idx);
          _calc(); 
        }), icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent)),
      ]),
      Autocomplete<Map<String, String>>(
        displayStringForOption: (option) => option['description'] ?? '',
        optionsBuilder: (textEditingValue) {
          if (textEditingValue.text.isEmpty) return const Iterable<Map<String, String>>.empty();
          return _pastItems.where((option) => option['description']!.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        },
        onSelected: (option) {
          setState(() {
            _itemDescControllers[idx].text = option['description'] ?? '';
            _items[idx]['description'] = option['description'];
            if ((option['amount'] ?? '').isNotEmpty) {
              _itemAmountControllers[idx].text = option['amount'] ?? '';
              _items[idx]['amount'] = option['amount'];
            }
            _calc();
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          if (controller.text.isEmpty && _itemDescControllers[idx].text.isNotEmpty) {
            controller.text = _itemDescControllers[idx].text;
          }
          controller.addListener(() {
            if (_itemDescControllers[idx].text != controller.text) {
               _itemDescControllers[idx].text = controller.text;
               _items[idx]['description'] = controller.text;
            }
          });
          return TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: isHeading ? TextAlign.center : TextAlign.start,
            style: TextStyle(fontWeight: isHeading ? FontWeight.bold : FontWeight.normal, color: isHeading ? Colors.teal.shade900 : Colors.black87),
            decoration: InputDecoration(hintText: isHeading ? 'Enter Heading Title...' : 'Item description...', border: InputBorder.none, hintStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey.shade400)),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 300,
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text(option['description'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      trailing: Text('₹${option['amount'] ?? '0'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      if (!isHeading) ...[
        const Divider(),
        Row(children: [
          const Icon(Icons.currency_rupee_rounded, size: 16, color: Colors.grey),
          Expanded(child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                double a = NumberToWords.parseCurrency(item['amount'].toString());
                if (a > 0) setState(() => item['amount'] = NumberToWords.formatIndianCurrency(a));
                _calc();
              }
            },
            child: TextField(
              decoration: const InputDecoration(hintText: 'Amount', border: InputBorder.none), 
              controller: _itemAmountControllers[idx], 
              onChanged: (v) { 
                _items[idx]['amount'] = v; 
                _calc(); 
              },
              onSubmitted: (v) { 
                double a = NumberToWords.parseCurrency(v); 
                setState(() => _itemAmountControllers[idx].text = NumberToWords.formatIndianCurrency(a)); 
                _calc(); 
              },
            ),
          )),
        ]),
      ],
    ]),
  ).animate().slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _emptyItems() => Container(width: double.infinity, padding: const EdgeInsets.all(32), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid)), child: const Column(children: [Icon(Icons.add_shopping_cart_rounded, color: Colors.grey, size: 32), SizedBox(height: 12), Text('No items added yet', style: TextStyle(color: Colors.grey))]));

  Widget _summaryRow(String label, String value, {bool isBold = false, bool isPrimary = false, Color? color}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(fontSize: 14, color: color ?? (isPrimary ? const Color(0xFF2563EB) : Colors.grey.shade600), fontWeight: isBold ? FontWeight.w800 : FontWeight.w500)),
    Text(value, style: TextStyle(fontSize: isPrimary ? 20 : 16, fontWeight: FontWeight.w900, color: color ?? (isPrimary ? const Color(0xFF2563EB) : const Color(0xFF1E293B)))),
  ]);

  Widget _buildTermRow(int idx) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
    child: Row(
      children: [
        const Text('•', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _termControllers[idx],
            onChanged: (v) => _quotationTerms[idx] = v,
            maxLines: null,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(hintText: 'Enter term...', border: InputBorder.none, isDense: true),
          ),
        ),
        IconButton(
          onPressed: () => setState(() {
            _quotationTerms.removeAt(idx);
            _termControllers[idx].dispose();
            _termControllers.removeAt(idx);
          }),
          icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
        ),
      ],
    ),
  );
}

