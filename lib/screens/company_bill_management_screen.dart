import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/company_bill.dart';
import '../services/auth_service.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../widgets/premium_app_bar.dart';
class CompanyBillManagementScreen extends StatefulWidget {
  const CompanyBillManagementScreen({super.key});

  @override
  State<CompanyBillManagementScreen> createState() => _CompanyBillManagementScreenState();
}

class _CompanyBillManagementScreenState extends State<CompanyBillManagementScreen> {
  List<CompanyBill> _bills = [];
  List<Map<String, dynamic>> _staffList = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;
  String _filterCategory = 'All';
  final List<String> _expenseCategories = ['Electricity', 'Water', 'Internet', 'Mobile Recharge', 'Rent', 'Salary', 'Stationery', 'Other'];
  final List<String> _incomeCategories = ['Client Payment', 'Consulting Fee', 'Refund', 'Commission', 'Other Income'];
  List<String> get _categories => ['All', ..._expenseCategories, ..._incomeCategories];

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.CompanyBills.classType);
      final res = await Amplify.API.query(request: req).response;
      final staffReq = ModelQueries.list(amplify_models.Users.classType);
      final staffRes = await Amplify.API.query(request: staffReq).response;
      
      final billsList = res.data?.items.whereType<amplify_models.CompanyBills>().toList() ?? [];
      billsList.sort((a, b) => (DateTime.tryParse(b.bill_date ?? '') ?? DateTime.now()).compareTo(DateTime.tryParse(a.bill_date ?? '') ?? DateTime.now()));
      
      final usersList = staffRes.data?.items.whereType<amplify_models.Users>().toList() ?? [];
      usersList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

      setState(() {
        _bills = billsList.map((m) => CompanyBill(
          id: m.id,
          category: m.category ?? 'Other',
          title: m.title ?? 'No Title',
          amount: m.amount ?? 0.0,
          billDate: m.bill_date != null ? DateTime.tryParse(m.bill_date!) ?? DateTime.now() : DateTime.now(),
          status: m.status ?? 'Pending',
          description: m.description,
          spentBy: m.spent_by,
          spentByName: m.spent_by_name,
          createdAt: m.createdAt?.getDateTimeInUtc(),
        )).toList();
        _staffList = usersList.map((u) => {
          'id': u.id,
          'name': u.name,
          'role': u.role,
        }).toList();
      });
    } catch (e) {
      _msg('Failed to fetch data: $e', false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _msg(String t, bool ok) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(t), backgroundColor: ok ? Colors.green : Colors.redAccent,
  ));

  Future<void> _showBillDialog([CompanyBill? bill]) async {
    final title = TextEditingController(text: bill?.title);
    final amount = TextEditingController(text: bill != null ? bill.amount.abs().toString() : '');
    final desc = TextEditingController(text: bill?.description);
    
    bool isIncoming = bill != null ? bill.amount < 0 : false;
    String linkedInvoiceNo = '';
    List<String> currentCategories = isIncoming ? _incomeCategories : _expenseCategories;
    
    List<amplify_models.Billings> availableInvoices = [];
    try {
      final req = ModelQueries.list(amplify_models.Billings.classType);
      final res = await Amplify.API.query(request: req).response;
      availableInvoices = res.data?.items.whereType<amplify_models.Billings>().where((b) {
         return b.status != 'Received' && (b.invoice_no != null && b.invoice_no!.isNotEmpty);
      }).toList() ?? [];
      
      // Sort newest first
      availableInvoices.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
    } catch (_) {}
    
    String category = bill?.category ?? currentCategories.first;
    if (!currentCategories.contains(category)) {
      category = currentCategories.first;
    }

    DateTime selectedDate = bill?.billDate ?? DateTime.now();
    String status = bill?.status ?? 'Pending';
    dynamic selectedStaffId = bill?.spentBy;
    String? selectedStaffName = bill?.spentByName;

    InputDecoration inputDec(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.7), size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      );
    }

    Widget statusChip(String label, bool isSelected, Function(String) onSelect) {
      final color = (label == 'Paid' || label == 'Income (Incoming)') ? Colors.green : (label == 'Pending' ? Colors.orange : AppTheme.primaryColor);
      final icon = label == 'Paid' ? Icons.check_circle_rounded 
                 : label == 'Pending' ? Icons.pending_actions_rounded
                 : label == 'Income (Incoming)' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(label),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
              border: Border.all(color: isSelected ? color.withOpacity(0.5) : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: isSelected ? color : Colors.grey.shade400),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? color : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: Icon(bill == null ? Icons.add_circle_outline_rounded : Icons.edit_note_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Text(bill == null ? 'Add Company Bill' : 'Edit Bill', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey(isIncoming),
                          initialValue: category,
                          decoration: inputDec('Category', Icons.category_rounded),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          items: currentCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setModalState(() => category = v!),
                        ),
                        const SizedBox(height: 24),
                        TextField(controller: title, decoration: inputDec('Title (e.g. March 2024)', Icons.title_rounded)),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 12),
                              child: Text('Transaction Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ),
                            Row(
                              children: [
                                statusChip('Expense (Outgoing)', !isIncoming, (v) {
                                  setModalState(() {
                                    isIncoming = false;
                                    currentCategories = _expenseCategories;
                                    if (!currentCategories.contains(category)) category = currentCategories.first;
                                  });
                                }),
                                const SizedBox(width: 12),
                                statusChip('Income (Incoming)', isIncoming, (v) {
                                  setModalState(() {
                                    isIncoming = true;
                                    currentCategories = _incomeCategories;
                                    if (!currentCategories.contains(category)) category = currentCategories.first;
                                  });
                                }),
                              ],
                            ),
                          ],
                        ),
                        if (isIncoming) ...[
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            decoration: inputDec('Connect to Bill / Invoice No (Optional)', Icons.link_rounded),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem(value: '', child: Text('None (Standalone Income)')),
                              ...availableInvoices.map((inv) {
                                final display = '${inv.invoice_no ?? ''} - ${inv.client_name ?? ''} (₹${inv.amount ?? ''})';
                                return DropdownMenuItem(value: inv.invoice_no, child: Text(display, overflow: TextOverflow.ellipsis));
                              }),
                            ],
                            onChanged: (val) {
                              linkedInvoiceNo = (val == null) ? '' : val.trim();
                              if (linkedInvoiceNo.isNotEmpty) {
                                title.text = 'Client Payment - $linkedInvoiceNo';
                                desc.text = 'Payment for Invoice $linkedInvoiceNo';
                              }
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        TextField(controller: amount, decoration: inputDec('Amount (₹)', Icons.currency_rupee_rounded), keyboardType: TextInputType.number),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) setModalState(() => selectedDate = picked);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor.withOpacity(0.7), size: 22),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Bill Date', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 12),
                              child: Text('Payment Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ),
                            Row(
                              children: [
                                statusChip('Pending', status == 'Pending', (v) => setModalState(() => status = v)),
                                const SizedBox(width: 12),
                                statusChip('Paid', status == 'Paid', (v) => setModalState(() => status = v)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextField(controller: desc, decoration: inputDec('Description', Icons.description_rounded), maxLines: 2),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 12),
                          child: Text('Attributed to Staff', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await _showStaffPicker();
                            if (result != null) {
                              setModalState(() {
                                selectedStaffId = result['id'];
                                selectedStaffName = result['name'];
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person_search_rounded, size: 22, color: selectedStaffId == null ? Colors.grey : AppTheme.primaryColor.withOpacity(0.7)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    selectedStaffName ?? 'Select Staff Member (Default: Me)',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: selectedStaffId == null ? Colors.grey : Colors.black,
                                      fontWeight: selectedStaffId == null ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(0, -4), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        child: const Text('Cancel')
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (title.text.isEmpty || amount.text.isEmpty) {
                            _msg('Please enter title and amount', false);
                            return;
                          }
                          try {
                            final uid = await AuthService().getUserId();
                            final uname = await AuthService().getUserName();
          
                            double parsedAmount = double.tryParse(amount.text) ?? 0;
                            if (isIncoming) parsedAmount = -parsedAmount.abs();
                            else parsedAmount = parsedAmount.abs();
          
                            final finalSpentBy = selectedStaffId ?? uid;
                            final finalSpentByName = selectedStaffName ?? uname;
          
                            final newBill = CompanyBill(
                              id: bill?.id,
                              category: category,
                              title: title.text,
                              amount: parsedAmount,
                              billDate: selectedDate,
                              status: status,
                              description: desc.text,
                              spentBy: finalSpentBy,
                              spentByName: finalSpentByName,
                            );
          
                            if (bill == null) {
                              final model = amplify_models.CompanyBills(
                                category: newBill.category,
                                title: newBill.title,
                                amount: newBill.amount,
                                bill_date: newBill.billDate.toIso8601String(),
                                status: newBill.status,
                                description: newBill.description,
                                spent_by: int.tryParse(newBill.spentBy?.toString() ?? ''),
                                spent_by_name: newBill.spentByName,
                              );
                              final req = ModelMutations.create(model);
                              await Amplify.API.mutate(request: req).response;
                            } else {
                              final model = amplify_models.CompanyBills(
                                id: newBill.id,
                                category: newBill.category,
                                title: newBill.title,
                                amount: newBill.amount,
                                bill_date: newBill.billDate.toIso8601String(),
                                status: newBill.status,
                                description: newBill.description,
                                spent_by: int.tryParse(newBill.spentBy?.toString() ?? ''),
                                spent_by_name: newBill.spentByName,
                              );
                              final req = ModelMutations.update(model);
                              await Amplify.API.mutate(request: req).response;
                            }
                            
                            // Link and update the Billing page if an invoice number was provided
                            if (linkedInvoiceNo.isNotEmpty && isIncoming) {
                              try {
                                final req = ModelQueries.list(amplify_models.Billings.classType, where: amplify_models.Billings.INVOICE_NO.eq(linkedInvoiceNo));
                                final res = await Amplify.API.query(request: req).response;
                                if (res.data != null && res.data!.items.isNotEmpty) {
                                  final b = res.data!.items.first!;
                                  
                                  Map<String, dynamic> oldData = {};
                                  if (b.data != null && b.data!.isNotEmpty) {
                                    try { oldData = jsonDecode(b.data!); } catch (_) {}
                                  }
                                  
                                  final amountStr = b.amount?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0';
                                  double totalAmount = double.tryParse(amountStr) ?? 0;
                                  
                                  double previouslyReceived = 0;
                                  if (oldData['advance_received'] != null) {
                                     previouslyReceived = double.tryParse(oldData['advance_received'].toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
                                  }
                                  double newlyReceived = parsedAmount.abs();
                                  
                                  double totalReceived = previouslyReceived + newlyReceived;
                                  double updatedBalance = totalAmount - totalReceived;
                                  if (updatedBalance < 0) updatedBalance = 0;
                                  
                                  bool isPaid = updatedBalance <= 0;
                                  
                                  oldData['payment_received'] = isPaid;
                                  oldData['advance_received'] = totalReceived.toStringAsFixed(0) + '/-';
                                  oldData['balance_due'] = updatedBalance > 0 ? updatedBalance.toStringAsFixed(0) + '/-' : '0/-';
                                  if (isPaid) oldData['payment_date'] = DateTime.now().toIso8601String();
                                  
                                  final updatedBill = b.copyWith(status: isPaid ? 'Received' : (totalReceived > 0 ? 'Part Payment' : 'Pending'), data: jsonEncode(oldData));
                                  await Amplify.API.mutate(request: ModelMutations.update(updatedBill)).response;
                                }
                              } catch (e) {
                                debugPrint('Error linking bill: $e');
                              }
                            }
                            
                            if (mounted) Navigator.pop(context);
                            _fetchBills();
                            _msg('Saved successfully', true);
                          } catch (e) {
                            _msg('Error: ', false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Save Bill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
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

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Remove this bill record?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(c, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
      ],
    ));
    if (ok == true) {
      try {
        final req = ModelMutations.deleteById(amplify_models.CompanyBills.classType, amplify_models.CompanyBillsModelIdentifier(id: id));
        await Amplify.API.mutate(request: req).response;
        _fetchBills();
        _msg('Removed', true);
      } catch (e) { _msg('Error: $e', false); }
    }
  }

  Future<String?> _getClientBalance(String clientName) async {
    try {
      final req = ModelQueries.list(amplify_models.Clients.classType, where: amplify_models.Clients.NAME.eq(clientName));
      final res = await Amplify.API.query(request: req).response;
      if (res.data != null && res.data!.items.isNotEmpty) {
        return res.data!.items.first!.balance_due;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _getInvoiceBalance(String invoiceNo) async {
    try {
      final req = ModelQueries.list(amplify_models.Billings.classType, where: amplify_models.Billings.INVOICE_NO.eq(invoiceNo));
      final res = await Amplify.API.query(request: req).response;
      if (res.data != null && res.data!.items.isNotEmpty) {
        final billingDataStr = res.data!.items.first!.data;
        if (billingDataStr != null) {
          final decoded = jsonDecode(billingDataStr);
          if (decoded['balance_due'] != null) {
             String balanceStr = decoded['balance_due'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
             return balanceStr.isEmpty ? '0' : balanceStr;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  void _showDetails(CompanyBill bill) {
    String? balance;
    String? clientName;
    String? invoiceNo;
    bool hasFetched = false;
    
    if (bill.category == 'Client Payment' && (bill.description?.contains('Payment from') ?? false)) {
      final match = RegExp(r'Payment from (.*?)\. Auto-logged').firstMatch(bill.description ?? '');
      if (match != null) {
         clientName = match.group(1);
      }
      final invMatch = RegExp(r'-\s*([A-Za-z0-9_-]+)$').firstMatch(bill.title);
      if (invMatch != null) {
         invoiceNo = invMatch.group(1);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          if (clientName != null && !hasFetched) {
            hasFetched = true;
            Future<void> fetchBal() async {
              String? b;
              if (invoiceNo != null) {
                b = await _getInvoiceBalance(invoiceNo!);
              }
              if (b == null || b == '0') {
                final cb = await _getClientBalance(clientName!);
                if (cb != null) b = cb;
              }
              if (mounted) setModalState(() => balance = b ?? '0');
            }
            fetchBal();
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Transaction Details', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  _detailRow(Icons.category_rounded, 'Category', bill.category),
                  _detailRow(Icons.currency_rupee_rounded, 'Amount', '${bill.amount < 0 ? '+' : '-'} \u20B9${NumberFormat("#,##,###").format(bill.amount.abs())}'),
                  _detailRow(Icons.calendar_month_rounded, 'Date', DateFormat('dd MMM yyyy').format(bill.billDate)),
                  if (bill.spentByName != null) _detailRow(Icons.person_rounded, 'By', bill.spentByName!),
                  
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Text(bill.description ?? 'No description provided.', style: const TextStyle(fontSize: 14)),
                  ),
                  
                  if (clientName != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withValues(alpha: 0.1))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_pin_rounded, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text('Customer Info', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.blue)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 6),
                          if (balance != null)
                            Row(
                              children: [
                                const Text('Balance to receive: ', style: TextStyle(color: Colors.black87)),
                                Text('\u20B9$balance', style: TextStyle(fontWeight: FontWeight.w900, color: balance == '0' ? Colors.green : Colors.orange.shade700, fontSize: 16)),
                              ],
                            )
                          else
                            const Text('Fetching balance...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context);
                  _showBillDialog(bill);
                },
              ),
            ],
          );
        }
      )
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = _startDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    final end = _endDate ?? DateTime(DateTime.now().year, DateTime.now().month + 1, 0, 23, 59, 59);

    final thisMonthBills = _bills.where((b) {
      return b.billDate.isAfter(start.subtract(const Duration(days: 1))) && 
             b.billDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
    final monthlyExpenses = thisMonthBills.where((b) => b.amount > 0).fold(0.0, (sum, b) => sum + b.amount);
    final monthlyIncome = thisMonthBills.where((b) => b.amount < 0).fold(0.0, (sum, b) => sum + b.amount.abs());
    final pendingCount = thisMonthBills.where((b) => b.status != 'Paid').length;

    final filteredBills = _filterCategory == 'All' 
        ? thisMonthBills 
        : thisMonthBills.where((b) => b.category == _filterCategory).toList();

    final incomeBills = filteredBills.where((b) => b.amount < 0).toList();
    final expenseBills = filteredBills.where((b) => b.amount >= 0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PremiumAppBar(
        title: const Text('Company Bills', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
        actions: [
          InkWell(
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: _startDate != null && _endDate != null 
                    ? DateTimeRange(start: _startDate!, end: _endDate!) 
                    : null,
                builder: (context, child) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
                      child: child,
                    ),
                  );
                },
              );
              if (range != null) {
                setState(() {
                  _startDate = range.start;
                  _endDate = range.end;
                });
              }
            }, 
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(_startDate != null ? 'Filtered' : 'Filter Date', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  if (_startDate != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() { _startDate = null; _endDate = null; }),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                    )
                  ]
                ]
              )
            )
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _fetchBills, 
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20)
            )
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
          // â”€â”€â”€ SUMMARY HEADER â”€â”€â”€
          _buildSummaryHeader(monthlyIncome, monthlyExpenses, pendingCount),
          
          // â”€â”€â”€ CATEGORY FILTER â”€â”€â”€
          _buildCategoryFilter(),
          
          // â”€â”€â”€ BILL LIST â”€â”€â”€
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // â”€â”€â”€ INCOME COLUMN â”€â”€â”€
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Text('INCOME', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.green, letterSpacing: 1.2), textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: incomeBills.isEmpty
                                  ? _buildEmptyState()
                                  : Card(
                                      margin: EdgeInsets.zero,
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        itemCount: incomeBills.length,
                                        separatorBuilder: (_, _) => const Divider(height: 1),
                                        itemBuilder: (context, index) => _buildBillCard(incomeBills[index], index),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // â”€â”€â”€ EXPENDITURE COLUMN â”€â”€â”€
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Text('EXPENDITURE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red, letterSpacing: 1.2), textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: expenseBills.isEmpty
                                  ? _buildEmptyState()
                                  : Card(
                                      margin: EdgeInsets.zero,
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        itemCount: expenseBills.length,
                                        separatorBuilder: (_, _) => const Divider(height: 1),
                                        itemBuilder: (context, index) => _buildBillCard(expenseBills[index], index),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBillDialog(),
        label: const Text('NEW BILL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 4,
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSummaryHeader(double income, double expenses, int pending) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _startDate != null 
                          ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'.toUpperCase()
                          : DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
                      style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.calendar_month_rounded, color: Colors.white60, size: 12),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Income', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(
                            '\u20B9${NumberFormat("#,##,###").format(income)}',
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Expenses', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(
                            '\u20B9${NumberFormat("#,##,###").format(expenses)}',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Text(pending.toString(), style: const TextStyle(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.w900)),
                const Text('PENDING', style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _filterCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _filterCategory = cat),
              avatar: Icon(_getCategoryIcon(cat), size: 14, color: isSelected ? Colors.white : Colors.blueGrey),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF2563EB),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200),
              ),
              showCheckmark: false,
              elevation: isSelected ? 4 : 0,
              shadowColor: Colors.blue.withValues(alpha: 0.3),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildBillCard(CompanyBill bill, int index) {
    final isPaid = bill.status == 'Paid';
    final color = _getCategoryColor(bill.category);

    return InkWell(
        onTap: () => _showDetails(bill),
        onLongPress: () => _delete(bill.id.toString()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getCategoryIcon(bill.category), color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(bill.billDate), style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        if (bill.spentByName != null) ...[
                          const SizedBox(width: 8),
                          Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${bill.amount < 0 ? "Received by" : "Spent by"} ${bill.spentByName}', 
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontStyle: FontStyle.italic),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${bill.amount < 0 ? "+" : "-"} \u20B9${NumberFormat("#,##,###").format(bill.amount.abs())}',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: bill.amount < 0 ? Colors.green.shade700 : Colors.red.shade600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bill.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'No bills found in this category',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electricity': return Icons.electrical_services_rounded;
      case 'Water': return Icons.water_drop_rounded;
      case 'Internet': return Icons.wifi_rounded;
      case 'Mobile Recharge': return Icons.phonelink_ring_rounded;
      case 'Rent': return Icons.home_work_rounded;
      case 'Salary': return Icons.payments_rounded;
      case 'Stationery': return Icons.edit_note_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Electricity': return Colors.amber.shade700;
      case 'Water': return Colors.blue.shade600;
      case 'Internet': return Colors.purple.shade600;
      case 'Mobile Recharge': return Colors.pink.shade600;
      case 'Rent': return Colors.teal.shade600;
      case 'Salary': return Colors.green.shade600;
      case 'Stationery': return Colors.orange.shade600;
      default: return Colors.blueGrey;
    }
  }

  Future<Map<String, dynamic>?> _showStaffPicker() async {
    final searchCtrl = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(_staffList);

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setPickerState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Search Staff Member', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Type name to search...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) {
                      setPickerState(() {
                        filtered = _staffList.where((s) => 
                          (s['name'] ?? '').toString().toLowerCase().contains(v.toLowerCase())
                        ).toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty && searchCtrl.text.isNotEmpty) 
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No results found', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    Container(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: (searchCtrl.text.isEmpty ? filtered.length + 1 : filtered.length),
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (searchCtrl.text.isEmpty && index == 0) {
                            return ListTile(
                              leading: const CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Icon(Icons.person_outline, color: Colors.white, size: 18)),
                              title: const Text('Default (Me)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                              onTap: () => Navigator.pop(context, {'id': null, 'name': null}),
                            );
                          }
                          final s = filtered[searchCtrl.text.isEmpty ? index - 1 : index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              child: Text(s['name']?[0] ?? '?', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                            title: Text(s['name'] ?? 'Unknown'),
                            subtitle: Text(s['role']?.toString().toUpperCase() ?? '', style: const TextStyle(fontSize: 10)),
                            onTap: () => Navigator.pop(context, {
                              'id': s['id'],
                              'name': s['name']
                            }),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}
