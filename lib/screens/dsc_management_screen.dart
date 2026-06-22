import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/dsc_record.dart';
import '../services/logging_service.dart';
import '../services/excel_service.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;

class DscManagementScreen extends StatefulWidget {
  const DscManagementScreen({super.key});

  @override
  State<DscManagementScreen> createState() => _DscManagementScreenState();
}

class _DscManagementScreenState extends State<DscManagementScreen> {
  // final _client = Supabase.instance.client;
  final _excel = ExcelService();
  List<DscRecord> _records = [];
  bool _isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.DscRecords.classType);
      final res = await Amplify.API.query(request: req).response;
      final recordsList = res.data?.items.whereType<amplify_models.DscRecords>().toList() ?? [];
      recordsList.sort((a, b) => (a.dsc_expiry_date ?? '').compareTo(b.dsc_expiry_date ?? ''));
      
      setState(() {
        _records = recordsList.map((row) => DscRecord(
          id: int.tryParse(row.id),
          clientName: row.client_name,
          emailId: row.email_id,
          phoneNo: row.phone_no,
          username: row.username,
          password: row.password,
          dscTakenDate: row.dsc_taken_date != null ? DateTime.tryParse(row.dsc_taken_date!) : null,
          dscExpiryDate: row.dsc_expiry_date != null ? DateTime.tryParse(row.dsc_expiry_date!) : null,
        )).toList();
      });
    } catch (e) {
      _showError('Failed to fetch Digital Signature records: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this Digital Signature record?'),
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
        await Amplify.API.mutate(request: ModelMutations.deleteById(amplify_models.DscRecords.classType, amplify_models.DscRecordsModelIdentifier(id: id.toString()))).response;
        _fetchRecords();
      } catch (e) {
        _showError('Delete failed: $e');
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final path = await _excel.exportDsc(_records);
      if (path != null) {
        _showSuccess('Exported successfully to $path');
      }
    } catch (e) {
      _showError('Export failed: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  void _showRecordForm([DscRecord? record]) {
    final clientNameController = TextEditingController(text: record?.clientName);
    final emailController = TextEditingController(text: record?.emailId);
    final phoneController = TextEditingController(text: record?.phoneNo);
    final usernameController = TextEditingController(text: record?.username);
    final passwordController = TextEditingController(text: record?.password);
    
    DateTime? takenDate = record?.dscTakenDate;
    DateTime? expiryDate = record?.dscExpiryDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(record == null ? 'Add Digital Signature' : 'Edit Digital Signature'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: clientNameController, decoration: const InputDecoration(labelText: 'Client Name')),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email ID')),
                  TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone No')),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username'))),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Taken Date', style: TextStyle(fontSize: 12)),
                          subtitle: Text(takenDate == null ? 'Not set' : DateFormat('dd/MM/yyyy').format(takenDate!)),
                          trailing: const Icon(Icons.calendar_today, size: 18),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: takenDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setModalState(() => takenDate = picked);
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
                              initialDate: expiryDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setModalState(() => expiryDate = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (record == null) {
                    final newDsc = amplify_models.DscRecords(
                      client_name: clientNameController.text,
                      email_id: emailController.text,
                      phone_no: phoneController.text,
                      username: usernameController.text,
                      password: passwordController.text,
                      dsc_taken_date: takenDate?.toIso8601String(),
                      dsc_expiry_date: expiryDate?.toIso8601String(),
                    );
                    await Amplify.API.mutate(request: ModelMutations.create(newDsc)).response;
                    await LoggingService().logAction(action: 'SIGNATURE_CREATED', targetType: 'Signature', targetId: clientNameController.text, details: 'Added new digital signature');
                  } else {
                    final updateDsc = amplify_models.DscRecords(
                      id: record.id.toString(),
                      client_name: clientNameController.text,
                      email_id: emailController.text,
                      phone_no: phoneController.text,
                      username: usernameController.text,
                      password: passwordController.text,
                      dsc_taken_date: takenDate?.toIso8601String(),
                      dsc_expiry_date: expiryDate?.toIso8601String(),
                    );
                    await Amplify.API.mutate(request: ModelMutations.update(updateDsc)).response;
                    await LoggingService().logAction(action: 'SIGNATURE_UPDATED', targetType: 'Signature', targetId: record.id.toString(), details: 'Updated signature for ${clientNameController.text}');
                  }
                  if (mounted) Navigator.pop(context);
                  _fetchRecords();
                  _showSuccess('Digital Signature record saved');
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
        final filtered = _records.where((r) => 
          (r.clientName?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false) ||
          (r.username?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false)
        ).toList();

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
                  const Text('Digital Signature', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1)),
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
                      IconButton(
                        onPressed: _fetchRecords,
                        icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor, size: 20),
                        tooltip: 'Refresh',
                        style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1), padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _exportToExcel,
                        icon: const Icon(Icons.download_rounded, color: Colors.green, size: 20),
                        tooltip: 'Export',
                        style: IconButton.styleFrom(backgroundColor: Colors.green.withValues(alpha: 0.1), padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showRecordForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Signature'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  ),
                ],
              )
            else ...[
              const Text('Digital Signature', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -1)),
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
                  IconButton(
                    onPressed: _fetchRecords,
                    icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor, size: 20),
                    tooltip: 'Refresh',
                    style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1), padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _exportToExcel,
                    icon: const Icon(Icons.download_rounded, color: Colors.green, size: 20),
                    tooltip: 'Export',
                    style: IconButton.styleFrom(backgroundColor: Colors.green.withValues(alpha: 0.1), padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRecordForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('ADD NEW SIGNATURE'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
                    itemBuilder: (context, index) => _buildDscCard(filtered[index], isWide),
                  ),
            ),
          ],
        ).animate().fadeIn(),
      );
    },
  );
}

  Widget _buildDscCard(DscRecord r, bool isWide) {
    final bool isExpired = r.dscExpiryDate != null && r.dscExpiryDate!.isBefore(DateTime.now());
    final bool isExpiringSoon = r.dscExpiryDate != null && r.dscExpiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
    final statusColor = isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.green);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.1))),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 8),
        leading: isWide ? Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.vpn_key_outlined, color: statusColor),
        ) : null,
        title: Text(r.clientName ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWide ? 16 : 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('User: ${r.username ?? "N/A"}', style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(isExpired ? 'Expired' : (isExpiringSoon ? 'Expiring' : 'Active'), style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
                Text(r.dscExpiryDate != null ? DateFormat('dd/MM').format(r.dscExpiryDate!) : '-', style: const TextStyle(fontSize: 10, color: AppTheme.mutedTextColor)),
              ],
            ),
            const Icon(Icons.expand_more, color: AppTheme.mutedTextColor, size: 20),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 0, isWide ? 24 : 16, isWide ? 24 : 16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 16),
                if (isWide) ...[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _buildDetailItem('Username', r.username ?? 'N/A', Icons.person_outline)),
                    Expanded(child: _buildDetailItem('Password', r.password ?? 'N/A', Icons.lock_outline)),
                    Expanded(child: _buildDetailItem('Email ID', r.emailId ?? 'N/A', Icons.email_outlined)),
                  ]),
                  const SizedBox(height: 16),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _buildDetailItem('Phone No', r.phoneNo ?? 'N/A', Icons.phone_outlined)),
                    Expanded(child: _buildDetailItem('Taken Date', r.dscTakenDate != null ? DateFormat('dd/MM/yyyy').format(r.dscTakenDate!) : 'N/A', Icons.calendar_today_outlined)),
                    Expanded(child: _buildDetailItem('Expiry Date', r.dscExpiryDate != null ? DateFormat('dd/MM/yyyy').format(r.dscExpiryDate!) : 'N/A', Icons.event_busy_outlined)),
                  ]),
                ] else ...[
                  _buildDetailItem('Username', r.username ?? 'N/A', Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildDetailItem('Password', r.password ?? 'N/A', Icons.lock_outline),
                  const SizedBox(height: 12),
                  _buildDetailItem('Email', r.emailId ?? 'N/A', Icons.email_outlined),
                  const SizedBox(height: 12),
                  _buildDetailItem('Phone', r.phoneNo ?? 'N/A', Icons.phone_outlined),
                  const SizedBox(height: 12),
                  _buildDetailItem('Taken', r.dscTakenDate != null ? DateFormat('dd/MM/yyyy').format(r.dscTakenDate!) : 'N/A', Icons.calendar_today_outlined),
                  const SizedBox(height: 12),
                  _buildDetailItem('Expiry', r.dscExpiryDate != null ? DateFormat('dd/MM/yyyy').format(r.dscExpiryDate!) : 'N/A', Icons.event_busy_outlined),
                ],
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    TextButton.icon(onPressed: () => _showRecordForm(r), icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('Edit')),
                    TextButton.icon(onPressed: () => _deleteRecord(r.id!), icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), label: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.mutedTextColor),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedTextColor, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
