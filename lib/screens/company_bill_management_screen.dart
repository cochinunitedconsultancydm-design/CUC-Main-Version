import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
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
  // final _client = Supabase.instance.client;
  List<CompanyBill> _bills = [];
  List<Map<String, dynamic>> _staffList = [];
  bool _isLoading = true;
  String _filterCategory = 'All';
  final List<String> _categories = ['All', 'Electricity', 'Water', 'Internet', 'Mobile Recharge', 'Rent', 'Salary', 'Stationery', 'Other'];

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
      billsList.sort((a, b) => (b.bill_date?.getDateTimeInUtc() ?? DateTime.now()).compareTo(a.bill_date?.getDateTimeInUtc() ?? DateTime.now()));
      
      final usersList = staffRes.data?.items.whereType<amplify_models.Users>().toList() ?? [];
      usersList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

      setState(() {
        _bills = billsList.map((m) => CompanyBill(
          id: m.id,
          category: m.category ?? 'Other',
          title: m.title ?? 'No Title',
          amount: m.amount ?? 0.0,
          billDate: m.bill_date?.getDateTimeInUtc() ?? DateTime.now(),
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

  void _showForm([CompanyBill? bill]) {
    final title = TextEditingController(text: bill?.title);
    final amount = TextEditingController(text: bill?.amount.toString());
    final desc = TextEditingController(text: bill?.description);
    String category = bill?.category ?? 'Electricity';
    DateTime selectedDate = bill?.billDate ?? DateTime.now();
    String status = bill?.status ?? 'Pending';
    dynamic selectedStaffId = bill?.spentBy;
    String? selectedStaffName = bill?.spentByName;

    InputDecoration inputDec(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
    }

    Widget statusChip(String label, bool isSelected, Function(String) onSelect) {
      final color = label == 'Paid' ? Colors.green : Colors.orange;
      final icon = label == 'Paid' ? Icons.check_circle_rounded : Icons.pending_actions_rounded;
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(label),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
              border: Border.all(color: isSelected ? color : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? color : Colors.grey,
                      fontSize: 13,
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
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.all(24),
          title: Text(bill == null ? 'Add Company Bill' : 'Edit Bill', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: inputDec('Category', Icons.category_rounded),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setModalState(() => category = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: title, decoration: inputDec('Title (e.g. March 2024)', Icons.title_rounded)),
                  const SizedBox(height: 16),
                  TextField(controller: amount, decoration: inputDec('Amount (₹)', Icons.currency_rupee_rounded), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  
                  // Date Picker styled like an input field
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bill Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('Payment Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                  const SizedBox(height: 16),
                  TextField(controller: desc, decoration: inputDec('Description', Icons.description_rounded), maxLines: 2),
                  const SizedBox(height: 16),
                  const Text('Attributed to Staff', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_search_rounded, size: 20, color: selectedStaffId == null ? Colors.grey : AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedStaffName ?? 'Select Staff Member (Default: Me)',
                              style: TextStyle(
                                fontSize: 14,
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
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              style: TextButton.styleFrom(foregroundColor: Colors.grey, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('Cancel')
            ),
            ElevatedButton(
              onPressed: () async {
                if (title.text.isEmpty || amount.text.isEmpty) {
                  _msg('Please enter title and amount', false);
                  return;
                }
                try {
                  final uid = await AuthService().getUserId();
                  final uname = await AuthService().getUserName();

                  final finalSpentBy = selectedStaffId ?? uid;
                  final finalSpentByName = selectedStaffName ?? uname;

                  final newBill = CompanyBill(
                    id: bill?.id,
                    category: category,
                    title: title.text,
                    amount: double.tryParse(amount.text) ?? 0,
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
                      bill_date: amplify_models.TemporalDate(newBill.billDate),
                      status: newBill.status,
                      description: newBill.description,
                      spent_by: newBill.spentBy?.toString(),
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
                      bill_date: amplify_models.TemporalDate(newBill.billDate),
                      status: newBill.status,
                      description: newBill.description,
                      spent_by: newBill.spentBy?.toString(),
                      spent_by_name: newBill.spentByName,
                    );
                    final req = ModelMutations.update(model);
                    await Amplify.API.mutate(request: req).response;
                  }
                  if (mounted) Navigator.pop(context);
                  _fetchBills();
                  _msg('Saved successfully', true);
                } catch (e) {
                  _msg('Error: $e', false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonthBills = _bills.where((b) => b.billDate.month == now.month && b.billDate.year == now.year).toList();
    final totalMonthly = thisMonthBills.fold(0.0, (sum, b) => sum + b.amount);
    final pendingCount = _bills.where((b) => b.status != 'Paid').length;

    final filteredBills = _filterCategory == 'All' 
        ? _bills 
        : _bills.where((b) => b.category == _filterCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PremiumAppBar(
        title: const Text('Company Bills', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
        actions: [
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
          // ─── SUMMARY HEADER ───
          _buildSummaryHeader(totalMonthly, pendingCount),
          
          // ─── CATEGORY FILTER ───
          _buildCategoryFilter(),
          
          // ─── BILL LIST ───
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : filteredBills.isEmpty
                    ? _buildEmptyState()
                    : Card(
                        margin: EdgeInsets.zero,
                        child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: filteredBills.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              return _buildBillCard(filteredBills[index], index);
                            },
                          ),
                      ),
          ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        label: const Text('NEW BILL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 4,
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSummaryHeader(double total, int pending) {
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
                Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
                  style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                const Text('Monthly Expenses', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  '₹${NumberFormat("#,##,###.##").format(total)}',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
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
        onTap: () => _showForm(bill),
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
                              'By ${bill.spentByName}', 
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
                    '₹${NumberFormat("#,##,###").format(bill.amount)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B)),
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
