import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/client_license.dart';
import '../models/license_billing.dart';
import '../services/excel_service.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;

class LicenseManagementScreen extends StatefulWidget {
  final String? initialFilter;
  const LicenseManagementScreen({super.key, this.initialFilter});

  @override
  State<LicenseManagementScreen> createState() => _LicenseManagementScreenState();
}

class _LicenseManagementScreenState extends State<LicenseManagementScreen> {
  // final _client = Supabase.instance.client;
  final _excel = ExcelService();
  List<ClientLicense> _licenses = [];
  List<Map<String, dynamic>> _licenseTypes = [];
  
  static const Map<int, String> _fallbackLicenseTypes = {
    2: 'Rent',
    4: 'FSSAI',
    5: 'Labour Registration',
    6: 'Insurance',
    7: 'Corporation License',
    8: 'PCC',
    9: 'Driving License',
    10: 'Passport',
    11: 'Health Card of Employees',
    12: 'DSC',
  };

  final Map<int, List<LicenseBilling>> _billings = {};
  bool _isLoading = true;
  String _searchTerm = '';
  String _filterType = 'All';

  Widget _headerAction(IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLicenseCard(ClientLicense l, bool isWide) {
    final displayName = l.clientName ?? l.manualClientName ?? '-';
    final bool isExpired = (l.expiryDate != null && l.expiryDate!.isBefore(DateTime.now())) || l.status == 'Expired';
    final bool isExpiringSoon = l.expiryDate != null && l.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          if (expanded) _fetchDetails(l.id!);
        },
        tilePadding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 8),
        leading: isWide ? Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.green)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.shield_outlined,
            color: isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.green),
          ),
        ) : null,
        title: Text(
          displayName, 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWide ? 16 : 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'File: ${l.fileNo ?? "N/A"} • ${l.licenseTypeName ?? "License"}', 
          style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isExpired ? 'Expired' : (isExpiringSoon ? 'Expiring' : 'Active'),
                  style: TextStyle(
                    color: isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.green),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                Text(
                  l.expiryDate != null ? DateFormat('dd/MM').format(l.expiryDate!) : '-',
                  style: const TextStyle(fontSize: 10, color: AppTheme.mutedTextColor),
                ),
              ],
            ),
            const Icon(Icons.expand_more, color: AppTheme.mutedTextColor, size: 20),
          ],
        ),
        children: [
          _buildExpandedDetails(l, isExpired, isWide),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(ClientLicense l, bool isExpired, bool isWide) {
    final billings = _billings[l.id] ?? [];

    return Padding(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Billing Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              TextButton.icon(
                onPressed: () => _showBillingForm(l.id!),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (billings.isEmpty)
            const Text('No billing records found.', style: TextStyle(fontSize: 12, color: AppTheme.mutedTextColor))
          else
            ...billings.map((b) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('₹${b.amount}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: Text('${b.invoiceNo ?? "No Invoice"} • ${b.paymentDate != null ? DateFormat('dd/MM/yyyy').format(b.paymentDate!) : ""}', style: const TextStyle(fontSize: 11)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: b.status == 'Paid' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  b.status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: b.status == 'Paid' ? Colors.green : Colors.orange),
                ),
              ),
            )),
          const Divider(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            children: [
              if (isExpired) ...[
                ElevatedButton.icon(
                  onPressed: () => _renewLicense(l),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('RENEWED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _notInterested(l),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('NOT INTERESTED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100, 
                    foregroundColor: Colors.grey.shade700, 
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ] else ...[
                TextButton.icon(
                  onPressed: () => _renewLicense(l),
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.blue),
                  label: const Text('Renew License', style: TextStyle(color: Colors.blue)),
                ),
              ],
              TextButton.icon(
                onPressed: () => _showLicenseForm(l),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => _deleteLicense(l.id!),
                icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _filterType = widget.initialFilter ?? 'All';
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await _fetchLicenseTypes();
    await _fetchLicenses();
  }

  Future<void> _fetchLicenseTypes() async {
    try {
      final req = ModelQueries.list(amplify_models.LicenseTypes.classType);
      final res = await Amplify.API.query(request: req).response;
      final typesList = res.data?.items.whereType<amplify_models.LicenseTypes>().toList() ?? [];
      typesList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      setState(() {
        _licenseTypes = typesList.map((t) => {'id': t.id, 'name': t.name}).toList();
      });
    } catch (e) {
      debugPrint('Error fetching types: $e');
    }
    
    if (_licenseTypes.isEmpty) {
      setState(() {
        _licenseTypes = _fallbackLicenseTypes.entries.map((e) => {'id': e.key, 'name': e.value}).toList();
      });
    }
  }

  Future<void> _fetchLicenses() async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.ClientLicenses.classType);
      final res = await Amplify.API.query(request: req).response;
      
      final clientReq = ModelQueries.list(amplify_models.Clients.classType);
      final clientRes = await Amplify.API.query(request: clientReq).response;
      final clientsList = clientRes.data?.items.whereType<amplify_models.Clients>().toList() ?? [];
      
      final licenseList = res.data?.items.whereType<amplify_models.ClientLicenses>().toList() ?? [];
      licenseList.sort((a, b) => (DateTime.tryParse(a.expiry_date ?? '') ?? DateTime.now()).compareTo(DateTime.tryParse(b.expiry_date ?? '') ?? DateTime.now()));
      
      setState(() {
        _licenses = licenseList.map((row) {
          final client = clientsList.firstWhere((c) => c.id == row.client_id, orElse: () => amplify_models.Clients(name: 'Unknown'));
          final type = _licenseTypes.firstWhere((t) => t['id'] == row.license_type_id, orElse: () => {'name': null});
          
          return ClientLicense(
            id: int.tryParse(row.id), // Dynamic -> int for legacy compatibility
            clientId: row.client_id,
            clientName: client.name,
            licenseTypeId: row.license_type_id,
            licenseTypeName: type['name'],
            serviceDate: row.service_date != null ? DateTime.tryParse(row.service_date!) : null,
            expiryDate: row.expiry_date != null ? DateTime.tryParse(row.expiry_date!) : null,
            fileNo: row.file_no,
            notes: row.notes,
            status: row.status,
            manualClientName: row.manual_client_name,
          );
        }).toList();
      });
    } catch (e) {
      _showError('Failed to fetch licenses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDetails(int licenseId) async {
    try {
      final req = ModelQueries.list(amplify_models.LicenseBilling.classType, where: amplify_models.LicenseBilling.CLIENT_LICENSE_ID.eq(licenseId.toString()));
      final res = await Amplify.API.query(request: req).response;
      final billingList = res.data?.items.whereType<amplify_models.LicenseBilling>().toList() ?? [];
      
      setState(() {
        _billings[licenseId] = billingList.map((row) => LicenseBilling(
          id: int.tryParse(row.id) ?? 0,
          clientLicenseId: int.tryParse(row.client_license_id?.toString() ?? '') ?? 0,
          amount: row.amount ?? 0.0,
          invoiceNo: row.invoice_no,
          status: row.payment_status ?? 'Pending',
          paymentDate: row.payment_date != null ? DateTime.tryParse(row.payment_date!) : null,
        )).toList();
      });
    } catch (e) {
      debugPrint('Error fetching details for license $licenseId: $e');
    }
  }

  Future<void> _renewLicense(ClientLicense license) async {
    DateTime nextExpiry = license.expiryDate?.add(const Duration(days: 365)) ?? DateTime.now().add(const Duration(days: 365));
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Renew License'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select the new expiry date for ${license.fileNo ?? "this license"}.'),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('New Expiry Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(nextExpiry)),
                trailing: const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.2))),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: nextExpiry,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setModalState(() => nextExpiry = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              child: const Text('Renew Now'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        final updatedModel = amplify_models.ClientLicenses(
          id: license.id.toString(),
          status: 'Renewed'
        );
        await Amplify.API.mutate(request: ModelMutations.update(updatedModel)).response;
        
        final newLicense = amplify_models.ClientLicenses(
          client_id: license.clientId,
          license_type_id: license.licenseTypeId,
          service_date: DateTime.now().toIso8601String(),
          expiry_date: nextExpiry?.toIso8601String(),
          file_no: license.fileNo,
          notes: 'Renewal of ${license.fileNo}',
          status: 'Active',
          manual_client_name: license.manualClientName,
        );
        await Amplify.API.mutate(request: ModelMutations.create(newLicense)).response;
        _fetchLicenses();
        _showSuccess('License renewed successfully');
      } catch (e) {
        _showError('Renewal failed: $e');
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final path = await _excel.exportLicenses(_licenses);
      if (path != null) {
        _showSuccess('Exported successfully to $path');
      }
    } catch (e) {
      _showError('Export failed: $e');
    }
  }

  Future<void> _notInterested(ClientLicense license) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Not Interested'),
        content: Text('Are you sure you want to mark ${license.fileNo ?? "this license"} as "Not Interested"? This will archive the record.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final updatedModel = amplify_models.ClientLicenses(
          id: license.id.toString(),
          status: 'Not Interested'
        );
        await Amplify.API.mutate(request: ModelMutations.update(updatedModel)).response;
        _fetchLicenses();
        _showSuccess('License marked as Not Interested');
      } catch (e) {
        _showError('Action failed: $e');
      }
    }
  }

  Future<void> _deleteLicense(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this license record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Amplify.API.mutate(request: ModelMutations.deleteById(amplify_models.ClientLicenses.classType, amplify_models.ClientLicensesModelIdentifier(id: id.toString()))).response;
        _fetchLicenses();
        _showSuccess('License deleted successfully');
      } catch (e) {
        _showError('Delete failed: $e');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  Future<Map<String, dynamic>?> _showInvoicePicker() async {
    final searchCtrl = TextEditingController();
    List<Map<String, dynamic>> allBills = [];
    bool pickerLoading = true;

    try {
      final req = ModelQueries.list(amplify_models.Billings.classType);
      final res = await Amplify.API.query(request: req).response;
      final billList = res.data?.items.whereType<amplify_models.Billings>().toList() ?? [];
      billList.sort((a, b) => (b.createdAt?.getDateTimeInUtc() ?? DateTime.now()).compareTo(a.createdAt?.getDateTimeInUtc() ?? DateTime.now()));
      
      allBills = billList.take(50).map((b) => {
        'invoice_no': b.invoice_no,
        'amount': b.amount,
        'client_name': b.client_name,
      }).toList();
      pickerLoading = false;
    } catch (e) { 
      debugPrint('Error fetching invoices: $e'); 
      pickerLoading = false;
    }

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setPickerState) => AlertDialog(
          title: const Text('Select Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search invoice or client...', 
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setPickerState(() {}),
                ),
                const SizedBox(height: 16),
                if (pickerLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView(
                      shrinkWrap: true,
                      children: allBills.where((b) {
                        final s = searchCtrl.text.toLowerCase();
                        return (b['invoice_no']?.toString().toLowerCase().contains(s) ?? false) ||
                               (b['client_name']?.toString().toLowerCase().contains(s) ?? false);
                      }).isEmpty 
                        ? [const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No matches found', style: TextStyle(color: Colors.grey))))]
                        : allBills.where((b) {
                            final s = searchCtrl.text.toLowerCase();
                            return (b['invoice_no']?.toString().toLowerCase().contains(s) ?? false) ||
                                   (b['client_name']?.toString().toLowerCase().contains(s) ?? false);
                          }).map((b) => ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                              child: const Icon(Icons.receipt_long_rounded, size: 16, color: AppTheme.primaryColor),
                            ),
                            title: Text(b['invoice_no'] ?? 'DRAFT', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(b['client_name'] ?? 'Unknown Client', style: const TextStyle(fontSize: 11)),
                            trailing: Text(b['amount']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            onTap: () => Navigator.pop(context, b),
                          )).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBillingForm(int licenseId) {
    final amount = TextEditingController();
    final invNo = TextEditingController();
    String status = 'Paid';
    DateTime date = DateTime.now();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Add Billing Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async {
                  final bill = await _showInvoicePicker();
                  if (bill != null) {
                    setModalState(() {
                      // Remove all non-numeric characters except for the decimal point
                      String amtStr = (bill['amount']?.toString() ?? '').replaceAll(RegExp(r'[^0-9.]'), '');
                      amount.text = amtStr;
                      invNo.text = bill['invoice_no'] ?? '';
                    });
                  }
                },
                icon: const Icon(Icons.link_rounded, size: 16),
                label: const Text('Link Bill', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amount, 
                decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded)), 
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: invNo, 
                decoration: const InputDecoration(labelText: 'Invoice Number', prefixIcon: Icon(Icons.numbers_rounded)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status', prefixIcon: Icon(Icons.info_outline_rounded)),
                items: ['Pending', 'Paid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setModalState(() => status = v!),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Payment Date', style: TextStyle(fontSize: 12)),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(date)),
                trailing: const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryColor),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) setModalState(() => date = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (amount.text.trim().isEmpty) {
                  _showError('Please enter an amount');
                  return;
                }
                
                final double? amtVal = double.tryParse(amount.text.trim());
                if (amtVal == null) {
                  _showError('Invalid amount format');
                  return;
                }

                setModalState(() => isSaving = true);
                try {
                  final newBilling = amplify_models.LicenseBilling(
                    client_license_id: licenseId,
                    amount: amtVal,
                    invoice_no: invNo.text.trim(),
                    payment_status: status,
                    payment_date: date.toIso8601String(),
                  );
                  await Amplify.API.mutate(request: ModelMutations.create(newBilling)).response;
                  if (mounted) Navigator.pop(context);
                  _fetchDetails(licenseId);
                  _showSuccess('Billing record added successfully');
                } catch (e) { 
                  _showError('Failed to add billing: $e'); 
                  setModalState(() => isSaving = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLicenseForm([ClientLicense? license]) {
    final clientNameController = TextEditingController(text: license?.clientName ?? license?.manualClientName);
    final fileNoController = TextEditingController(text: license?.fileNo);
    final notesController = TextEditingController(text: license?.notes);
    int? selectedTypeId = license?.licenseTypeId;
    
    // Default to first type if adding new and types exist
    if (selectedTypeId == null && _licenseTypes.isNotEmpty) {
      selectedTypeId = _licenseTypes.first['id'] as int;
    }
    
    DateTime? serviceDate = license?.serviceDate;
    DateTime? expiryDate = license?.expiryDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(license == null ? 'Add New Licence' : 'Edit Licence'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: clientNameController, decoration: const InputDecoration(labelText: 'Client Name')),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedTypeId,
                    decoration: const InputDecoration(labelText: 'Licence Type'),
                    items: _licenseTypes.map((t) => DropdownMenuItem<int>(
                      value: t['id'] as int,
                      child: Text(t['name']),
                    )).toList(),
                    onChanged: (v) => setModalState(() => selectedTypeId = v),
                  ),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: fileNoController, decoration: const InputDecoration(labelText: 'File Number'))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Service Date', style: TextStyle(fontSize: 12)),
                          subtitle: Text(serviceDate == null ? 'Not set' : DateFormat('dd/MM/yyyy').format(serviceDate!)),
                          trailing: const Icon(Icons.calendar_today, size: 18),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: serviceDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setModalState(() => serviceDate = picked);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('Expiry Date', style: TextStyle(fontSize: 12)),
                          subtitle: Text(expiryDate == null ? 'Not set' : DateFormat('dd/MM/yyyy').format(expiryDate!)),
                          trailing: const Icon(Icons.calendar_today, size: 18),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setModalState(() => expiryDate = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (license == null) {
                    final newLic = amplify_models.ClientLicenses(
                      manual_client_name: clientNameController.text,
                      license_type_id: selectedTypeId,
                      file_no: fileNoController.text,
                      service_date: serviceDate?.toIso8601String(),
                      expiry_date: expiryDate?.toIso8601String(),
                      notes: notesController.text,
                      status: 'Active',
                    );
                    await Amplify.API.mutate(request: ModelMutations.create(newLic)).response;
                  } else {
                    final updateLic = amplify_models.ClientLicenses(
                      id: license.id.toString(),
                      manual_client_name: clientNameController.text,
                      license_type_id: selectedTypeId,
                      file_no: fileNoController.text,
                      service_date: serviceDate?.toIso8601String(),
                      expiry_date: expiryDate?.toIso8601String(),
                      notes: notesController.text,
                    );
                    await Amplify.API.mutate(request: ModelMutations.update(updateLic)).response;
                  }
                  if (mounted) Navigator.pop(context);
                  _fetchLicenses();
                  _showSuccess('Licence saved successfully');
                } catch (e) {
                  _showError('Save failed: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;
        final filtered = _licenses.where((l) {
          bool matchesSearch = (l.clientName?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false) ||
                               (l.manualClientName?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false) ||
                               (l.licenseTypeName?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false) ||
                               (l.fileNo?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false);
          
          if (!matchesSearch) return false;
          
          if (_filterType != 'All') {
            final isExpired = (l.expiryDate != null && l.expiryDate!.isBefore(DateTime.now())) || l.status == 'Expired';
            final isExpiringSoon = !isExpired && l.expiryDate != null && l.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
            final isActive = !isExpired && !isExpiringSoon;
            
            if (_filterType == 'Expired' && !isExpired) return false;
            if (_filterType == 'Expiring Soon' && !isExpiringSoon) return false;
            if (_filterType == 'Active' && !isActive) return false;
          }
          
          return true;
        }).toList();

        return Padding(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if (isWide)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Licences Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          onChanged: (val) => setState(() => _searchTerm = val),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filterType,
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Licenses')),
                              DropdownMenuItem(value: 'Active', child: Text('Active')),
                              DropdownMenuItem(value: 'Expiring Soon', child: Text('Expiring Soon')),
                              DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _filterType = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _headerAction(Icons.refresh_rounded, 'Refresh', AppTheme.primaryColor, _fetchInitialData),
                      const SizedBox(width: 8),
                      _headerAction(Icons.download_rounded, 'Export', Colors.green, _exportToExcel),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showLicenseForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Licence'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else ...[
              const Text('Licences Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchTerm = val),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterType,
                        isDense: true,
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(value: 'Active', child: Text('Active')),
                          DropdownMenuItem(value: 'Expiring Soon', child: Text('Expiring')),
                          DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _filterType = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _headerAction(Icons.refresh_rounded, 'Refresh', AppTheme.primaryColor, _fetchInitialData),
                  const SizedBox(width: 8),
                  _headerAction(Icons.download_rounded, 'Export', Colors.green, _exportToExcel),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLicenseForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('ADD NEW LICENCE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final license = filtered[index];
                      return _buildLicenseCard(license, isWide);
                    },
                  ),
            ),
          ],
        ).animate().fadeIn(),
      );
    },
  );
}



}
