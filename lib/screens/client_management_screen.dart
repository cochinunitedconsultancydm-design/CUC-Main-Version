import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../models/client.dart';
import '../services/excel_service.dart';
import '../services/logging_service.dart';
import 'client_files_dialog.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  final _excel = ExcelService();
  List<Client> _clients = [];
  bool _isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.Clients.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      final clientsList = res.data?.items.whereType<amplify_models.Clients>().toList() ?? [];
      clientsList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      if (!mounted) return;
      setState(() {
        _clients = clientsList.map((m) => Client(
          id: m.id,
          name: m.name ?? '',
          email: m.email,
          phone: m.phone,
          address: m.address,
          typeOfWork: m.type_of_work,
          caseNumber: m.case_number,
          dob: m.dob,
          fileNo: m.file_no,
          fileDate: m.file_date,
          isContacted: m.is_contacted ?? false,
          balanceDue: m.balance_due,
        )).toList();
      });
    } catch (e) {
      _showError('Failed to fetch clients: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteClient(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this client?'),
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
        final req = ModelMutations.deleteById(amplify_models.Clients.classType, amplify_models.ClientsModelIdentifier(id: id));
        await Amplify.API.mutate(request: req).response;
        _fetchClients();
      } catch (e) {
        _showError('Delete failed: $e');
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final clientMaps = _clients.map((c) => c.toMap()).toList();
      final path = await _excel.exportClients(clientMaps);
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

  void _showClientFilesDialog(Client client) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => ClientFilesDialog(client: client),
    );
  }

  void _showClientForm([Client? client]) {
    final nameController = TextEditingController(text: client?.name);
    final emailController = TextEditingController(text: client?.email);
    final phoneController = TextEditingController(text: client?.phone);
    final workController = TextEditingController(text: client?.typeOfWork);
    final caseController = TextEditingController(text: client?.caseNumber);
    final fileNoController = TextEditingController(text: client?.fileNo);
    final fileDateController = TextEditingController(text: client?.fileDate);
    final dobController = TextEditingController(text: client?.dob);
    final addressController = TextEditingController(text: client?.address);
    bool isContacted = client?.isContacted ?? false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12))],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(client == null ? Icons.person_add : Icons.edit, color: AppTheme.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(client == null ? 'Add New Client' : 'Edit Client Profile', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              const Text("Enter client details and work information", style: TextStyle(color: AppTheme.mutedTextColor)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildFormField(nameController, 'Full Name', Icons.person, true),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildFormField(emailController, 'Email Address', Icons.email, false)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildFormField(phoneController, 'Phone Number', Icons.phone, true)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildFormField(workController, 'Type of Work', Icons.work, false)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildFormField(caseController, 'Case Number', Icons.gavel, false)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildFormField(fileNoController, 'File Number', Icons.folder, false)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildFormField(fileDateController, 'File Date', Icons.calendar_today, false)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildFormField(dobController, 'Date of Birth', Icons.cake, false)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: CheckboxListTile(
                              title: const Text('Contacted?', style: TextStyle(fontWeight: FontWeight.w500)),
                              value: isContacted,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (val) => setModalState(() => isContacted = val ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildFormField(addressController, 'Full Address', Icons.location_on, false, maxLines: 2),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final newClient = Client(
                          id: client?.id,
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          address: addressController.text,
                          typeOfWork: workController.text,
                          caseNumber: caseController.text,
                          fileDate: fileDateController.text,
                          fileNo: fileNoController.text,
                          isContacted: isContacted,
                          balanceDue: client?.balanceDue,
                        );
                        try {
                          if (client == null) {
                            final model = amplify_models.Clients(
                              name: newClient.name,
                              email: newClient.email,
                              phone: newClient.phone,
                              address: newClient.address,
                              type_of_work: newClient.typeOfWork,
                              case_number: newClient.caseNumber,
                              file_no: newClient.fileNo,
                              file_date: newClient.fileDate,
                              is_contacted: newClient.isContacted,
                            );
                            final req = ModelMutations.create(model);
                            await Amplify.API.mutate(request: req).response;
                          } else {
                            final model = amplify_models.Clients(
                              id: newClient.id,
                              name: newClient.name,
                              email: newClient.email,
                              phone: newClient.phone,
                              address: newClient.address,
                              type_of_work: newClient.typeOfWork,
                              case_number: newClient.caseNumber,
                              file_no: newClient.fileNo,
                              file_date: newClient.fileDate,
                              is_contacted: newClient.isContacted,
                            );
                            final req = ModelMutations.update(model);
                            await Amplify.API.mutate(request: req).response;
                          }
                          
                          if (context.mounted) Navigator.pop(context);
                          _fetchClients();
                          
                          await LoggingService().logAction(
                            action: client == null ? 'CLIENT_CREATED' : 'CLIENT_UPDATED',
                            targetType: 'Client',
                            targetId: nameController.text,
                            details: 'Client: ${nameController.text}',
                          );

                          _showSuccess('Client saved successfully');
                        } catch (e) {
                          _showError('Save failed: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Save Client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).scaleXY(begin: 0.95, end: 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildFormField(TextEditingController controller, String label, IconData icon, bool required, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
      ),
      validator: required ? (v) => v == null || v.isEmpty ? "Required" : null : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;
        final filtered = _clients.where((c) => 
          c.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          (c.phone?.contains(_searchTerm) ?? false) ||
          (c.fileNo?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false)
        ).toList();

        return Padding(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Premium Responsive Header
            if (isWide)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context))
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Client Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                          Text('Manage client profiles, files, and contact details', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          onChanged: (val) => setState(() => _searchTerm = val),
                          decoration: InputDecoration(
                            hintText: 'Search clients, files, phone...',
                            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _headerAction(Icons.refresh_rounded, 'Refresh', AppTheme.primaryColor, _fetchClients),
                      const SizedBox(width: 12),
                      _headerAction(Icons.download_rounded, 'Export to Excel', Colors.green, _exportToExcel),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showClientForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Client'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.1)
            else ...[
              // Narrow layout for Mobile/Tablet
              Row(
                children: [
                  if (Navigator.canPop(context))
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(backgroundColor: Colors.white, elevation: 2),
                      ),
                    ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                        Text('Manage client profiles and files', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 20),
              TextField(
                onChanged: (val) => setState(() => _searchTerm = val),
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ).animate().fadeIn().slideX(begin: 0.1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showClientForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Client'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _headerAction(Icons.refresh_rounded, 'Refresh', AppTheme.primaryColor, _fetchClients),
                  const SizedBox(width: 8),
                  _headerAction(Icons.download_rounded, 'Export', Colors.green, _exportToExcel),
                ],
              ).animate().fadeIn().slideY(begin: 0.1),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, right: 16), // Padding for scrollbar
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final client = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildClientCard(client, isWide)
                          .animate()
                          .fadeIn(delay: (50 * index).ms, duration: 400.ms)
                          .slideY(begin: 0.1),
                      );
                    },
                  ),
            ),
          ],
        ).animate().fadeIn(),
      );
    },
  );
}

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

  Widget _buildClientCard(Client c, bool isWide) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade100)),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppTheme.primaryColor)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWide ? 18 : 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          if (c.isContacted) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text("Contacted", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: c.balanceDue != null && c.balanceDue != "0/-" && c.balanceDue != "0" ? Colors.orange.shade50 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: c.balanceDue != null && c.balanceDue != "0/-" && c.balanceDue != "0" ? Colors.orange.shade200 : Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, size: 14, color: c.balanceDue != null && c.balanceDue != "0/-" && c.balanceDue != "0" ? Colors.orange.shade800 : Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  "Due: ${c.balanceDue ?? '0/-'}",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.balanceDue != null && c.balanceDue != "0/-" && c.balanceDue != "0" ? Colors.orange.shade800 : Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${c.typeOfWork ?? "No Type of Work"} • File: ${c.fileNo ?? "N/A"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _buildInfoPill(Icons.email_outlined, c.email?.isNotEmpty == true ? c.email! : 'No Email', isWide),
                _buildInfoPill(Icons.phone_outlined, c.phone?.isNotEmpty == true ? c.phone! : 'No Phone', isWide),
                _buildInfoPill(Icons.gavel_outlined, 'Case: ${c.caseNumber?.isNotEmpty == true ? c.caseNumber! : 'N/A'}', isWide),
                _buildInfoPill(Icons.calendar_today_outlined, 'File Date: ${c.fileDate?.isNotEmpty == true ? c.fileDate! : 'N/A'}', isWide),
                _buildInfoPill(Icons.cake_outlined, 'DOB: ${c.dob?.isNotEmpty == true ? c.dob! : 'N/A'}', isWide),
                _buildInfoPill(Icons.location_on_outlined, c.address?.isNotEmpty == true ? c.address! : 'No Address', isWide),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showClientFilesDialog(c),
                  icon: const Icon(Icons.folder_shared, size: 16),
                  label: const Text('Files Vault'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    side: BorderSide(color: Colors.blue.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _showClientForm(c),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _deleteClient(c.id.toString()),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, bool isWide) {
    return SizedBox(
      width: isWide ? 220 : double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.mutedTextColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
