import 'dart:convert';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../models/client.dart';
import '../services/excel_service.dart';
import '../services/logging_service.dart';
import '../services/billing_service.dart';
import '../models/billing.dart';
import 'client_files_dialog.dart';
import 'client_merge_dialog.dart';
import 'global_merge_dialog.dart';
import '../models/deal.dart';
import 'deal_detail_screen.dart';

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
  String _currentSort = 'Name (A-Z)';

  void _applySort() {
    switch (_currentSort) {
      case 'Name (A-Z)':
        _clients.sort((a, b) => a.name.trim().toLowerCase().compareTo(b.name.trim().toLowerCase()));
        break;
      case 'Name (Z-A)':
        _clients.sort((a, b) => b.name.trim().toLowerCase().compareTo(a.name.trim().toLowerCase()));
        break;
      case 'Due (High-Low)':
        _clients.sort((a, b) => _parseDue(b.balanceDue).compareTo(_parseDue(a.balanceDue)));
        break;
    }
  }

  double _parseDue(String? due) {
    if (due == null || due.isEmpty) return 0.0;
    final clean = due.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

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
      var clientsList = (res.data?.items ?? []).whereType<amplify_models.Clients>().toList();
      
      int maxRegNo = 0;
      for (var c in clientsList) {
        if (c.case_number != null && c.case_number!.startsWith('CUC-')) {
          final match = RegExp(r'\d+').firstMatch(c.case_number!);
          if (match != null) {
            final num = int.tryParse(match.group(0)!) ?? 0;
            if (num > maxRegNo) maxRegNo = num;
          }
        }
      }

      var unassignedClients = clientsList.where((c) => c.case_number == null || !c.case_number!.startsWith('CUC-')).toList();
      if (unassignedClients.isNotEmpty) {
        unassignedClients.sort((a, b) => (a.createdAt?.toString() ?? '').compareTo(b.createdAt?.toString() ?? ''));
        for (var c in unassignedClients) {
          maxRegNo++;
          final newRegNo = 'CUC-${maxRegNo.toString().padLeft(4, '0')}';
          final updated = c.copyWith(case_number: newRegNo);
          await BackupAwareApi().update(updated);
          final index = clientsList.indexWhere((element) => element.id == c.id);
          if (index != -1) clientsList[index] = updated;
        }
      }

      final reqLogs = ModelQueries.list(amplify_models.ActivityLogs.classType, where: amplify_models.ActivityLogs.ACTION.eq('CLIENT_CREATED'));
      final resLogs = await Amplify.API.query(request: reqLogs).response;
      final logsList = resLogs.data?.items.whereType<amplify_models.ActivityLogs>().toList() ?? [];

      final reqUsers = ModelQueries.list(amplify_models.Users.classType);
      final resUsers = await Amplify.API.query(request: reqUsers).response;
      final usersList = resUsers.data?.items.whereType<amplify_models.Users>().toList() ?? [];

      final Map<int, String> userNames = {};
      for (var u in usersList) {
        if (u.id != null) {
          userNames[int.tryParse(u.id) ?? 0] = u.name ?? 'Unknown';
        }
      }

      final Map<String, String> clientCreators = {};
      for (var log in logsList) {
        if (log.target_id != null && log.user_id != null) {
          clientCreators[log.target_id!] = userNames[log.user_id!] ?? 'Unknown';
        }
      }

      clientsList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      if (!mounted) return;
      setState(() {
        _clients = clientsList.map((m) {
          final rawCompanies = m.companies ?? [];
          final actualCompanies = rawCompanies.where((c) => !c.startsWith('BANK_ACCOUNT|||') && !c.startsWith('CUSTOM_FIELD|||')).toList();
          final bankAccounts = rawCompanies.where((c) => c.startsWith('BANK_ACCOUNT|||'));
          final bankAccount = bankAccounts.isNotEmpty ? bankAccounts.first.split('|||').last : null;
          final customFields = rawCompanies.where((c) => c.startsWith('CUSTOM_FIELD|||')).map((c) => c.replaceFirst('CUSTOM_FIELD|||', '')).toList();
          
          return Client(
            id: m.id,
            name: m.name ?? '',
            email: m.email,
            phone: m.phone,
            address: (m.address?.trim().toLowerCase() == 'false') ? '' : m.address,
            typeOfWork: m.type_of_work,
            caseNumber: m.case_number,
            dob: m.dob,
            fileNo: m.file_no,
            fileDate: m.file_date,
            isContacted: m.is_contacted ?? false,
            balanceDue: m.balance_due,
            bankAccountDetails: bankAccount,
            customFields: customFields.isNotEmpty ? customFields : null,
            companies: actualCompanies.isNotEmpty ? actualCompanies : null,
            registrationNumber: m.registration_number,
            createdBy: clientCreators[m.id] ?? 'System/Legacy',
          );
        }).toList();
        _applySort();
      });
    } catch (e) {
      _showError('Failed to fetch clients: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<String>> _fetchAdditionalFileNumbers(Client c) async {
    List<String> files = [];
    try {
      // Fetch Works / Deals
      final reqWorks = ModelQueries.list(amplify_models.Deals.classType, where: amplify_models.Deals.CLIENT_NAME.contains(c.name));
      final resWorks = await Amplify.API.query(request: reqWorks).response;
      final deals = resWorks.data?.items.whereType<amplify_models.Deals>().toList() ?? [];
      for (var d in deals) {
        if (d.register_no != null && d.register_no!.trim().isNotEmpty && d.register_no!.toLowerCase() != 'null') {
          files.add('Work (${d.work_type ?? "N/A"}): ${d.register_no}');
        }
      }

      // Fetch Client Licenses
      if (c.id != null) {
        int? cid = int.tryParse(c.id.toString());
        if (cid != null) {
          final reqLic = ModelQueries.list(amplify_models.ClientLicenses.classType, where: amplify_models.ClientLicenses.CLIENT_ID.eq(cid));
          final resLic = await Amplify.API.query(request: reqLic).response;
          final licenses = resLic.data?.items.whereType<amplify_models.ClientLicenses>().toList() ?? [];
          for (var l in licenses) {
            if (l.file_no != null && l.file_no!.trim().isNotEmpty && l.file_no!.toLowerCase() != 'null') {
              files.add('License: ${l.file_no}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching additional file numbers: $e');
    }
    return files.toSet().toList(); // Remove duplicates if any
  }

  void _showMergeDialog(Client client) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => ClientMergeDialog(
        primaryClient: client,
        allClients: _clients,
        onMerged: () {
          _fetchClients();
        },
      ),
    );
  }

  void _showGlobalMergeDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => GlobalMergeDialog(
        allClients: _clients,
        onMerged: () {
          _fetchClients();
        },
      ),
    );
  }

  Future<void> _showClientWorksDialog(Client c) async {
    try {
      // Fetch all deals with a high limit to avoid pagination missing the client's works
      final req = ModelQueries.list(amplify_models.Deals.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      var deals = res.data?.items.whereType<amplify_models.Deals>().toList() ?? [];

      final cNameLower = (c.name ?? '').toLowerCase().trim();
      final cIdStr = c.id?.toString();
      
      deals = deals.where((d) {
        final dNameLower = (d.client_name ?? '').toLowerCase().trim();
        final dIdStr = d.client_id?.toString();
        
        // Match by ID first, then fallback to flexible Name matching
        if (cIdStr != null && dIdStr != null && cIdStr == dIdStr) return true;
        if (cNameLower.isEmpty) return false;
        
        return dNameLower == cNameLower || 
               dNameLower.startsWith(cNameLower) || 
               cNameLower.startsWith(dNameLower);
      }).toList();

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
<<<<<<< HEAD
          backgroundColor: Colors.transparent,
          child: Container(
            width: 650,
            constraints: const BoxConstraints(maxHeight: 700),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 15)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)]),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.work_history_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Works for ${c.name}',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Manage deals and tasks for this client',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Text('${deals.length} Total', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
=======
          backgroundColor: Colors.grey.shade50,
          elevation: 12,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: 700,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.work, color: AppTheme.primaryColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Client Works', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.black87)),
                              Text(c.name, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.grey.shade100,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.grey.shade700),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
>>>>>>> cfeac8d1e8e813f769ee2f394331bdeedc2e53dd
                // Content
                Flexible(
                  child: deals.isEmpty 
                    ? Padding(
<<<<<<< HEAD
                        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                              child: Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
                            ),
                            const SizedBox(height: 20),
                            Text('No Works Found', style: TextStyle(fontSize: 20, color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Get started by adding a new work for this client.', style: TextStyle(color: Colors.grey.shade600)),
                          ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
=======
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_off_outlined, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No works found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                              const SizedBox(height: 8),
                              Text('There are no active or past works for this client.', style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
>>>>>>> cfeac8d1e8e813f769ee2f394331bdeedc2e53dd
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
<<<<<<< HEAD
                        itemCount: deals.length,
                        itemBuilder: (context, index) {
                          final d = deals[index];
=======
                        shrinkWrap: true,
                        itemCount: deals.length,
                        itemBuilder: (context, index) {
                          final d = deals[index];
                          final hasFileNo = d.register_no != null && d.register_no!.trim().isNotEmpty && d.register_no != 'null';
>>>>>>> cfeac8d1e8e813f769ee2f394331bdeedc2e53dd
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
<<<<<<< HEAD
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                              ]
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DealDetailScreen(deal: Deal.fromMap(d.toJson()))),
                                  ).then((_) => _showClientWorksDialog(c));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                        child: Icon(Icons.assignment_turned_in_rounded, color: AppTheme.primaryColor),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(d.name ?? 'Unnamed Work', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.black87)),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                                  child: Text('Stage: ${d.stage ?? "N/A"}', style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                                  child: Text('Type: ${d.work_type ?? "N/A"}', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Text('₹${d.amount ?? 0}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 18)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: (index * 40).ms, duration: 400.ms).slideX(begin: 0.1, curve: Curves.easeOut);
                        }
                      ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DealDetailScreen(
                                deal: Deal(
                                  name: 'New Work for ${c.name}',
                                  clientName: c.name,
                                  clientId: c.id,
                                  contactInfo: c.phone,
                                  company: c.companies != null && c.companies!.isNotEmpty ? c.companies!.first : null,
                                  workType: c.typeOfWork,
                                  stage: 'Lead',
                                ),
                              ),
                            ),
                          ).then((_) => _showClientWorksDialog(c));
                        },
                        icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
                        label: const Text('Add Work', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor, 
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
=======
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(d.name ?? 'Unnamed Work', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade100)),
                                              child: Text('Stage: ${d.stage ?? "N/A"}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purple.shade100)),
                                              child: Text('Type: ${d.work_type ?? "N/A"}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                            ),
                                            if (hasFileNo)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade100)),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.file_copy_outlined, size: 12, color: Colors.orange.shade700),
                                                    const SizedBox(width: 4),
                                                    Text('File/Reg No: ${d.register_no}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (d.amount != null) ...[
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                                      child: Column(
                                        children: [
                                          Text('₹${d.amount}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text('Amount', style: TextStyle(color: Colors.green.shade600, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }
                      ),
                ),
                
                // Footer
                if (deals.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
>>>>>>> cfeac8d1e8e813f769ee2f394331bdeedc2e53dd
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to load works: $e');
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
        await BackupAwareApi().deleteById(amplify_models.Clients.classType, amplify_models.ClientsModelIdentifier(id: id));
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

  void _showClientBillsDialog(Client client) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => _ClientBillsDialog(client: client),
    );
  }

  void _showClientForm([Client? client]) {
    final nameController = TextEditingController(text: client?.name);
    final emailController = TextEditingController(text: client?.email);
    final phoneController = TextEditingController(text: client?.phone);
    final workController = TextEditingController(text: client?.typeOfWork);
    final fileNoController = TextEditingController(text: client?.fileNo);
    final fileDateController = TextEditingController(text: client?.fileDate ?? DateFormat('dd/MM/yyyy').format(DateTime.now()));
    final dobController = TextEditingController(text: client?.dob);
    final careOfController = TextEditingController(text: client?.managedBy);

    Future<void> pickDate(BuildContext ctx, TextEditingController controller) async {
      final date = await showDatePicker(
        context: ctx,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (date != null) {
        controller.text = DateFormat('dd/MM/yyyy').format(date);
      }
    }
    final addressController = TextEditingController(text: client?.address);
    
    String accNo = '';
    String holderName = '';
    String ifsc = '';
    String branch = '';
    if (client?.bankAccountDetails != null && client!.bankAccountDetails!.isNotEmpty) {
      if (client.bankAccountDetails!.startsWith('{')) {
        try {
          final map = jsonDecode(client.bankAccountDetails!);
          accNo = map['accNo'] ?? '';
          holderName = map['holderName'] ?? '';
          ifsc = map['ifsc'] ?? '';
          branch = map['branch'] ?? '';
        } catch (_) {}
      } else {
        accNo = client.bankAccountDetails!;
      }
    }
    
    final accNoController = TextEditingController(text: accNo);
    final holderNameController = TextEditingController(text: holderName);
    final ifscController = TextEditingController(text: ifsc);
    final branchController = TextEditingController(text: branch);

    bool isContacted = client?.isContacted ?? false;
    List<Map<String, TextEditingController>> companyControllers = (client?.companies ?? []).map((c) {
      String name = c;
      String address = '';
      if (c.contains('|||')) {
        final parts = c.split('|||');
        name = parts[0];
        if (parts.length > 1) address = parts[1];
      }
      return {'name': TextEditingController(text: name), 'address': TextEditingController(text: address)};
    }).toList();
    List<Map<String, TextEditingController>> customFieldControllers = (client?.customFields ?? []).map((c) {
      String hd = c;
      String val = '';
      if (c.contains('|||')) {
        final parts = c.split('|||');
        hd = parts[0];
        if (parts.length > 1) val = parts[1];
      }
      return {'heading': TextEditingController(text: hd), 'value': TextEditingController(text: val)};
    }).toList();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Container(
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
                    isWide ? Row(
                      children: [
                        Expanded(child: _buildFormField(emailController, 'Email Address', Icons.email, false)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildFormField(phoneController, 'Phone Number', Icons.phone, true)),
                      ],
                    ) : Column(
                      children: [
                        _buildFormField(emailController, 'Email Address', Icons.email, false),
                        const SizedBox(height: 20),
                        _buildFormField(phoneController, 'Phone Number', Icons.phone, true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    isWide ? Row(
                      children: [
                        Expanded(child: _buildFormField(workController, 'Type of Work', Icons.work, false)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildFormField(fileNoController, 'File Number', Icons.folder, false)),
                      ],
                    ) : Column(
                      children: [
                        _buildFormField(workController, 'Type of Work', Icons.work, false),
                        const SizedBox(height: 20),
                        _buildFormField(fileNoController, 'File Number', Icons.folder, false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    isWide ? Row(
                      children: [
                        Expanded(child: _buildFormField(fileDateController, 'File Date', Icons.calendar_today, false, onTap: () => pickDate(context, fileDateController))),
                        const SizedBox(width: 20),
                        Expanded(child: _buildFormField(dobController, 'Date of Birth', Icons.cake, false, onTap: () => pickDate(context, dobController))),
                      ],
                    ) : Column(
                      children: [
                        _buildFormField(fileDateController, 'File Date', Icons.calendar_today, false, onTap: () => pickDate(context, fileDateController)),
                        const SizedBox(height: 20),
                        _buildFormField(dobController, 'Date of Birth', Icons.cake, false, onTap: () => pickDate(context, dobController)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    isWide ? Row(
                      children: [
                        Expanded(child: _buildFormField(careOfController, 'Care Of', Icons.supervised_user_circle, false)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Material(
                              color: Colors.transparent,
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
                        ),
                        const SizedBox(width: 20),
                        const Spacer(), // Balance layout if needed
                      ],
                    ) : Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Material(
                            color: Colors.transparent,
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
                    const SizedBox(height: 20),
                    const Text('Bank Account Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildFormField(accNoController, 'Account No', Icons.numbers, false)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFormField(holderNameController, 'Holder Name', Icons.person, false)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildFormField(ifscController, 'IFSC Code', Icons.code, false)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFormField(branchController, 'Branch', Icons.account_balance, false)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Companies', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    ...companyControllers.asMap().entries.map((e) {
                      int idx = e.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildFormField(e.value['name']!, 'Company Name', Icons.business, false),
                                  const SizedBox(height: 8),
                                  _buildFormField(e.value['address']!, 'Company Address', Icons.location_on, false, maxLines: 2),
                                ]
                              )
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                setModalState(() {
                                  companyControllers.removeAt(idx);
                                });
                              }
                            )
                          ]
                        )
                      );
                    }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            companyControllers.add({'name': TextEditingController(), 'address': TextEditingController()});
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Company'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Additional Custom Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    ...customFieldControllers.asMap().entries.map((e) {
                      int idx = e.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildFormField(e.value['heading']!, 'Heading / Title', Icons.title, false),
                                  const SizedBox(height: 8),
                                  _buildFormField(e.value['value']!, 'Value', Icons.description, false, maxLines: 2),
                                ]
                              )
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                setModalState(() {
                                  customFieldControllers.removeAt(idx);
                                });
                              }
                            )
                          ]
                        )
                      );
                    }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            customFieldControllers.add({'heading': TextEditingController(), 'value': TextEditingController()});
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Custom Field'),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        if (client == null) {
                          final newName = nameController.text.trim().toLowerCase();
                          final newPhone = phoneController.text.trim();
                          
                          Client? existingClient;
                          for (var c in _clients) {
                            if (c.name.trim().toLowerCase() == newName || 
                                (newPhone.isNotEmpty && c.phone != null && c.phone!.trim() == newPhone)) {
                              existingClient = c;
                              break;
                            }
                          }
                          
                          if (existingClient != null) {
                            final action = await showDialog<String>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Client Already Exists'),
                                content: Text('A client with the name "${existingClient!.name}" or phone "${existingClient.phone}" already exists.\n\nDo you want to create a new client anyway or open the existing one?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, 'create'), child: const Text('Create New')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, 'open'),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                                    child: const Text('Open Existing'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (action == 'cancel' || action == null) return;
                            
                            if (action == 'open') {
                              if (context.mounted) Navigator.pop(context); // close new client form
                              _showClientForm(existingClient); // open existing client form
                              return;
                            }
                          }
                        }

                        final bankDetailsJson = (accNoController.text.trim().isEmpty && holderNameController.text.trim().isEmpty && ifscController.text.trim().isEmpty && branchController.text.trim().isEmpty) 
                            ? '' 
                            : jsonEncode({
                                'accNo': accNoController.text.trim(),
                                'holderName': holderNameController.text.trim(),
                                'ifsc': ifscController.text.trim(),
                                'branch': branchController.text.trim(),
                              });

                        final newClient = Client(
                          id: client?.id,
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          address: addressController.text,
                          typeOfWork: workController.text,
                          fileDate: fileDateController.text,
                          fileNo: fileNoController.text,
                          isContacted: isContacted,
                          dob: dobController.text,
                          managedBy: careOfController.text,
                          balanceDue: client?.balanceDue,
                          bankAccountDetails: bankDetailsJson,
                          registrationNumber: client?.registrationNumber,
                          companies: companyControllers.map((c) {
                            final name = c['name']!.text.trim();
                            final addr = c['address']!.text.trim();
                            return '$name|||$addr';
                          }).where((c) => !c.startsWith('|||')).toList(),
                          customFields: customFieldControllers.map((c) {
                            final hd = c['heading']!.text.trim();
                            final val = c['value']!.text.trim();
                            return '$hd|||$val';
                          }).where((c) => !c.startsWith('|||')).toList(),
                        );
                        try {
                          if (client == null) {
                            int maxRegNo = 0;
                            for (var c in _clients) {
                              if (c.registrationNumber != null) {
                                final match = RegExp(r'\d+').firstMatch(c.registrationNumber!);
                                if (match != null) {
                                  final num = int.tryParse(match.group(0)!) ?? 0;
                                  if (num > maxRegNo) maxRegNo = num;
                                }
                              }
                            }
                            final newRegNo = 'CUC-${(maxRegNo + 1).toString().padLeft(4, '0')}';
                            
                            final model = amplify_models.Clients(
                              name: newClient.name,
                              email: newClient.email,
                              phone: newClient.phone,
                              address: newClient.address,
                              type_of_work: newClient.typeOfWork,
                              file_no: newClient.fileNo,
                              file_date: newClient.fileDate,
                              is_contacted: newClient.isContacted,
                              dob: newClient.dob,
                              managed_by: newClient.managedBy,
                              case_number: newRegNo,
                              companies: [
                                ...newClient.companies ?? [],
                                if (newClient.bankAccountDetails?.isNotEmpty == true) 'BANK_ACCOUNT|||${newClient.bankAccountDetails}',
                                ...?(newClient.customFields?.map((f) => 'CUSTOM_FIELD|||$f')),
                              ],
                            );
                            await BackupAwareApi().create(model);
                          } else {
                            final model = amplify_models.Clients(
                              id: newClient.id,
                              name: newClient.name,
                              email: newClient.email,
                              phone: newClient.phone,
                              address: newClient.address,
                              type_of_work: newClient.typeOfWork,
                              file_no: newClient.fileNo,
                              file_date: newClient.fileDate,
                              is_contacted: newClient.isContacted,
                              dob: newClient.dob,
                              managed_by: newClient.managedBy,
                              case_number: newClient.registrationNumber,
                              companies: [
                                ...newClient.companies ?? [],
                                if (newClient.bankAccountDetails?.isNotEmpty == true) 'BANK_ACCOUNT|||${newClient.bankAccountDetails}',
                                ...?(newClient.customFields?.map((f) => 'CUSTOM_FIELD|||$f')),
                              ],
                            );
                            await BackupAwareApi().update(model);
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
          );
        },
        ),
        ).animate().fadeIn(duration: 300.ms).scaleXY(begin: 0.95, end: 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildFormField(TextEditingController controller, String label, IconData icon, bool required, {int maxLines = 1, VoidCallback? onTap}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: onTap != null,
      onTap: onTap,
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
          (c.fileNo?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false) ||
          (c.registrationNumber?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false)
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
                            hintText: 'Search clients, reg no, files, phone...',
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
                      _buildSortDropdown(),
                      const SizedBox(width: 12),
                      _headerAction(Icons.refresh_rounded, 'Refresh', AppTheme.primaryColor, _fetchClients),
                      const SizedBox(width: 12),
                      _headerAction(Icons.download_rounded, 'Export to Excel', Colors.green, _exportToExcel),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showGlobalMergeDialog(),
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Merge All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                  hintText: 'Search clients, reg no...',
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
                  _buildSortDropdown(),
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

  Widget _buildSortDropdown() {
    return PopupMenuButton<String>(
      tooltip: 'Sort Clients',
      initialValue: _currentSort,
      onSelected: (val) {
        setState(() {
          _currentSort = val;
          _applySort();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.sort_rounded, color: AppTheme.primaryColor, size: 20),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Name (A-Z)', child: Text('Name (A-Z)')),
        const PopupMenuItem(value: 'Name (Z-A)', child: Text('Name (Z-A)')),
        const PopupMenuItem(value: 'Due (High-Low)', child: Text('Due (High-Low)')),
      ],
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
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showClientDetailsDialog(c, isWide),
        child: Padding(
          padding: EdgeInsets.all(isWide ? 20 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryColor)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWide ? 18 : 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${c.typeOfWork ?? "No Type"} • Reg: ${c.registrationNumber ?? "N/A"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
<<<<<<< HEAD
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWide ? 18 : 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (c.isContacted)
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
                          GestureDetector(
                            onTap: () => _showClientBillsDialog(c),
                            child: Container(
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${c.typeOfWork ?? "No Type of Work"} • File: ${c.fileNo ?? "N/A"} • Reg No: ${c.registrationNumber ?? "N/A"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),

                    ],
                  ),
=======
              ),
              if (c.balanceDue != null && c.balanceDue != "0/-" && c.balanceDue != "0") ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text("Due: ${c.balanceDue}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
>>>>>>> cfeac8d1e8e813f769ee2f394331bdeedc2e53dd
                ),
              ],
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showClientDetailsDialog(Client c, bool isWide) {
    String bankText = 'No Bank Details';
    if (c.bankAccountDetails != null && c.bankAccountDetails!.trim().isNotEmpty) {
      if (c.bankAccountDetails!.startsWith('{')) {
        try {
          final map = jsonDecode(c.bankAccountDetails!);
          final parts = <String>[];
          if (map['accNo']?.isNotEmpty == true) parts.add('Acc: ${map['accNo']}');
          if (map['holderName']?.isNotEmpty == true) parts.add('Name: ${map['holderName']}');
          if (map['ifsc']?.isNotEmpty == true) parts.add('IFSC: ${map['ifsc']}');
          if (map['branch']?.isNotEmpty == true) parts.add('Branch: ${map['branch']}');
          if (parts.isNotEmpty) bankText = parts.join(' | ');
        } catch (_) {}
      } else {
        bankText = c.bankAccountDetails!;
      }
    }

    List<String> actualCompanies = c.companies ?? [];
    List<String> customFields = [];
    
    // Also include custom fields if they exist natively in the model
    if (c.customFields != null) {
      for (var cf in c.customFields!) {
        // cf might be "Key|||Value" or just "Key: Value"
        if (cf.contains('|||')) {
          final parts = cf.split('|||');
          if (parts.length >= 2) customFields.add('${parts[0]}: ${parts[1]}');
        } else {
          customFields.add(cf.replaceAll('|||', ' - '));
        }
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.grey.shade50,
        elevation: 12,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: isWide ? 650 : double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.black87, letterSpacing: -0.5)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text('Created by: ${c.createdBy ?? "System/Legacy"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.grey.shade100,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade700),
                        onPressed: () => Navigator.pop(ctx),
                        splashRadius: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard('Basic Information', Icons.person_outline, [
                        _buildSimpleDetailRow(Icons.email_outlined, 'Email', c.email),
                        _buildSimpleDetailRow(Icons.phone_outlined, 'Phone', c.phone),
                        _buildSimpleDetailRow(Icons.cake_outlined, 'DOB', c.dob),
                        _buildSimpleDetailRow(Icons.location_on_outlined, 'Address', c.address),
                      ]),
                      const SizedBox(height: 20),
                      
                      _buildSectionCard('Work Details', Icons.work_outline, [
                        _buildSimpleDetailRow(Icons.work_outline, 'Type of Work', c.typeOfWork),
                        _buildSimpleDetailRow(Icons.balance, 'Case Number', c.caseNumber),
                        _buildSimpleDetailRow(Icons.folder_outlined, 'Primary File No', c.fileNo),
                        _buildSimpleDetailRow(Icons.calendar_today_outlined, 'File Date', c.fileDate),
                        _buildSimpleDetailRow(Icons.receipt_outlined, 'Reg No', c.registrationNumber),
                        _buildSimpleDetailRow(Icons.account_balance_wallet, 'Balance Due', c.balanceDue, isHighlight: true),
                        _buildSimpleDetailRow(Icons.supervised_user_circle_outlined, 'Care Of', c.managedBy),
                        _buildSimpleDetailRow(Icons.contact_phone_outlined, 'Contacted', c.isContacted ? "Yes" : "No"),
                        _buildSimpleDetailRow(Icons.star_outline, 'Review Rating', c.reviewRating > 0 ? '${c.reviewRating} Stars' : null),
                        
                        FutureBuilder<List<String>>(
                          future: _fetchAdditionalFileNumbers(c),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                    SizedBox(width: 12),
                                    Text('Loading related file numbers...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: snapshot.data!.map((fileItem) {
                                return _buildSimpleDetailRow(Icons.file_copy_outlined, 'Related File No', fileItem, isHighlight: false, customColor: Colors.blue.shade700);
                              }).toList(),
                            );
                          },
                        ),
                      ]),
                      
                      if (bankText != 'No Bank Details' || actualCompanies.isNotEmpty || customFields.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSectionCard('Additional Details', Icons.info_outline, [
                          if (c.bankAccountDetails != null && c.bankAccountDetails!.trim().isNotEmpty && c.bankAccountDetails!.startsWith('{')) 
                            ...() {
                              try {
                                final map = jsonDecode(c.bankAccountDetails!);
                                return [
                                  if (map['accNo']?.isNotEmpty == true) _buildSimpleDetailRow(Icons.numbers, 'Account No', map['accNo']),
                                  if (map['holderName']?.isNotEmpty == true) _buildSimpleDetailRow(Icons.person, 'Holder Name', map['holderName']),
                                  if (map['ifsc']?.isNotEmpty == true) _buildSimpleDetailRow(Icons.code, 'IFSC Code', map['ifsc']),
                                  if (map['branch']?.isNotEmpty == true) _buildSimpleDetailRow(Icons.account_balance, 'Branch', map['branch']),
                                ];
                              } catch (_) {
                                return [_buildSimpleDetailRow(Icons.account_balance_outlined, 'Bank Account', bankText)];
                              }
                            }()
                          else if (bankText != 'No Bank Details') 
                            _buildSimpleDetailRow(Icons.account_balance_outlined, 'Bank Account', bankText),
                            
                          for (var comp in actualCompanies) _buildSimpleDetailRow(Icons.business, 'Company', comp),
                          
                          for (var cf in customFields) 
                            _buildSimpleDetailRow(Icons.label_outline, cf.contains(':') ? cf.split(':').first.trim() : 'Custom Data', cf.contains(':') ? cf.substring(cf.indexOf(':') + 1).trim() : cf),
                        ]),
                      ],
                      
                      const SizedBox(height: 32),
                      const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.3)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 12,
                          children: [
                            _buildPremiumActionCard(ctx, Icons.edit, 'Edit Profile', () => _showClientForm(c), AppTheme.primaryColor),
                            _buildPremiumActionCard(ctx, Icons.folder_shared, 'Files Vault', () => _showClientFilesDialog(c), Colors.blue.shade700),
                            _buildPremiumActionCard(ctx, Icons.receipt_long, 'Bills', () => _showClientBillsDialog(c), Colors.teal.shade700),
                            _buildPremiumActionCard(ctx, Icons.work, 'Works', () => _showClientWorksDialog(c), Colors.indigo.shade700),
                            _buildPremiumActionCard(ctx, Icons.delete_outline, 'Delete', () => _deleteClient(c.id.toString()), Colors.red.shade700),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActionCard(BuildContext ctx, IconData icon, String label, VoidCallback onTap, Color color) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () { Navigator.pop(ctx); onTap(); },
        hoverColor: color.withValues(alpha: 0.15),
        splashColor: color.withValues(alpha: 0.2),
        child: Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 10),
              Text(
                label, 
                textAlign: TextAlign.center, 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis, 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.withAlpha(220)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    final validChildren = children.where((w) => w is! SizedBox || (w as SizedBox).width != 0.0 && (w as SizedBox).height != 0.0).toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.3)),
            ],
          ),
          const SizedBox(height: 20),
          ...validChildren,
        ],
      ),
    );
  }

  Widget _buildSimpleDetailRow(IconData icon, String label, String? value, {bool isHighlight = false, Color? customColor}) {
    if (value == null || value.trim().isEmpty || value.trim().toLowerCase() == 'false' || value.trim().toLowerCase() == 'null') return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isHighlight ? Colors.orange.shade700 : (customColor ?? Colors.blueGrey.shade300)),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade600, fontSize: 14)),
          ),
          Expanded(
            child: isHighlight
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 14)),
                  )
                : Text(value, style: TextStyle(color: customColor ?? Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ClientBillsDialog extends StatefulWidget {
  final Client client;
  const _ClientBillsDialog({required this.client});

  @override
  State<_ClientBillsDialog> createState() => _ClientBillsDialogState();
}

class _ClientBillsDialogState extends State<_ClientBillsDialog> {
  final _billingService = BillingService();
  bool _isLoading = true;
  List<Billing> _bills = [];

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    final ledger = await _billingService.getClientLedger(widget.client.name);
    if (!mounted) return;
    setState(() {
      _bills = ledger;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.grey.shade50,
      elevation: 12,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 700,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.receipt_long, color: AppTheme.primaryColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Client Ledger', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.black87)),
                              Text(widget.client.name, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.grey.shade100,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade700),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _bills.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No bills found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                              const SizedBox(height: 8),
                              Text('This client currently has no ledger history.', style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        shrinkWrap: true,
                        itemCount: _bills.length,
                        itemBuilder: (context, index) {
                          final b = _bills[index];
                          final isPaid = b.status == 'Received';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                    child: Icon(isPaid ? Icons.check_circle : Icons.pending_actions, color: isPaid ? Colors.green : Colors.orange, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Invoice: ${b.invoiceNo ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                                        const SizedBox(height: 4),
                                        Text('${b.type ?? 'N/A'} • ${b.date ?? 'N/A'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('₹${b.amount ?? '0'}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isPaid ? Colors.green.shade700 : Colors.black87)),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isPaid ? Colors.green.shade200 : Colors.orange.shade200),
                                        ),
                                        child: Text(isPaid ? 'Paid' : 'Pending', style: TextStyle(color: isPaid ? Colors.green.shade700 : Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            
            // Footer
            if (!_isLoading && _bills.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.tonal(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

