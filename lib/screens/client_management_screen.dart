import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
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
import '../services/auth_service.dart';
import '../services/supabase_backup_service.dart';
import '../services/fiscal_year_service.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  final _excel = ExcelService();
  final _auth = AuthService();
  static final DateTime nov1Cutoff = FiscalYearService.nov1Cutoff;
  String _selectedPeriod = FiscalYearService.currentPeriod.value; // Starts fresh from Nov 1, 2026
  List<Client> _clients = [];
  List<amplify_models.Clients> _rawClients = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String _searchTerm = '';
  String _currentSort = 'Name (A-Z)';

  DateTime _getClientDate(Client c) {
    if (c.createdAt != null && c.createdAt!.isNotEmpty) {
      final parsed = DateTime.tryParse(c.createdAt!);
      if (parsed != null) return parsed.toLocal();
    }
    return DateTime(2000);
  }

  bool _phoneNumbersMatch(String? p1, String? p2) {
    if (p1 == null || p2 == null) return false;
    final list1 = p1
        .split(RegExp(r'[,/|]'))
        .map((p) => p.replaceAll(RegExp(r'\D'), ''))
        .where((p) => p.length >= 7)
        .toList();
    final list2 = p2
        .split(RegExp(r'[,/|]'))
        .map((p) => p.replaceAll(RegExp(r'\D'), ''))
        .where((p) => p.length >= 7)
        .toList();

    for (var n1 in list1) {
      for (var n2 in list2) {
        if (n1 == n2) return true;
        final s1 = n1.length >= 10 ? n1.substring(n1.length - 10) : n1;
        final s2 = n2.length >= 10 ? n2.substring(n2.length - 10) : n2;
        if (s1 == s2) return true;
      }
    }
    return false;
  }

  int get _count2025_2026 => _clients.where((c) => _getClientDate(c).isBefore(nov1Cutoff)).length;
  int get _count2026_2027 => _clients.where((c) => !_getClientDate(c).isBefore(nov1Cutoff)).length;
  int get _countAll => _clients.length;

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
    _selectedPeriod = FiscalYearService.currentPeriod.value;
    FiscalYearService.currentPeriod.addListener(_onPeriodChanged);
    _fetchClients();
  }

  void _onPeriodChanged() {
    if (mounted && _selectedPeriod != FiscalYearService.currentPeriod.value) {
      setState(() => _selectedPeriod = FiscalYearService.currentPeriod.value);
    }
  }

  @override
  void dispose() {
    FiscalYearService.currentPeriod.removeListener(_onPeriodChanged);
    super.dispose();
  }

  Future<void> _fetchClients() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    _isAdmin = await _auth.isAdmin();
    
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

      final reqLogs = ModelQueries.list(amplify_models.ActivityLogs.classType, where: amplify_models.ActivityLogs.ACTION.eq('CLIENT_CREATED'), limit: 10000);
      final resLogs = await Amplify.API.query(request: reqLogs).response;
      final logsList = resLogs.data?.items.whereType<amplify_models.ActivityLogs>().toList() ?? [];

      final reqUsers = ModelQueries.list(amplify_models.Users.classType, limit: 10000);
      final resUsers = await Amplify.API.query(request: reqUsers).response;
      final usersList = resUsers.data?.items.whereType<amplify_models.Users>().toList() ?? [];

      final Map<int, String> userNames = {};
      try {
        final sbMap = await SupabaseBackupService().getUsernameToIdMap();
        for (var u in usersList) {
          final uName = u.username?.toLowerCase() ?? '';
          if (sbMap.containsKey(uName)) {
            userNames[sbMap[uName]!] = u.name ?? uName;
          }
        }
      } catch (e) {
        debugPrint('Failed to get Supabase ID map: $e');
      }

      final Map<String, String> clientCreators = {};
      for (var log in logsList) {
        if (log.target_id != null && log.user_id != null) {
          clientCreators[log.target_id!] = userNames[log.user_id!] ?? 'Unknown';
        }
      }

      clientsList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      print('DEBUG: ActivityLogs CLIENT_CREATED count: ${logsList.length}');
      print('DEBUG: userNames mapping: $userNames');
      print('DEBUG: clientCreators mapping: $clientCreators');
      if (!mounted) return;
      setState(() {
        _rawClients = clientsList;
        _clients = clientsList.map((m) {
          final mappedCreator = clientCreators[m.id] ?? clientCreators[m.name ?? ''] ?? 'System/Legacy';
          print('DEBUG: Client ${m.name} (${m.id}) mapped to creator: $mappedCreator');
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
            registrationNumber: m.case_number,
            createdBy: mappedCreator,
            createdAt: (m.created_at != null && m.created_at!.isNotEmpty) ? m.created_at : m.createdAt?.format(),
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

  Future<void> _importSingleClientToCurrent(Client client, {bool skipConfirmation = false}) async {
    if (!skipConfirmation) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.drive_file_move_rounded, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Import Client to Current?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Text(
            'Do you want to import client "${client.name}" into the current period (2026-2027)?\n\nThe client record will be carried forward to start from the current period.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.drive_file_move_rounded, size: 16),
              label: const Text('Import to 2026-2027'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() => _isLoading = true);
    try {
      final targetDate = DateTime.now().isBefore(nov1Cutoff)
          ? DateTime(2026, 11, 1, 0, 0, 1)
          : DateTime.now();
      final targetDateStr = targetDate.toIso8601String();

      final raw = _rawClients.where((m) => m.id == client.id).firstOrNull;
      if (raw != null) {
        final updated = raw.copyWith(created_at: targetDateStr);
        await BackupAwareApi().update(updated);
      } else {
        final model = amplify_models.Clients(
          id: client.id,
          name: client.name,
          email: client.email,
          phone: client.phone,
          address: client.address,
          type_of_work: client.typeOfWork,
          file_no: client.fileNo,
          file_date: client.fileDate,
          is_contacted: client.isContacted,
          dob: client.dob,
          managed_by: client.managedBy,
          case_number: client.registrationNumber,
          companies: client.companies,
          custom_fields: client.customFields,
          created_at: targetDateStr,
        );
        await BackupAwareApi().update(model);
      }

      await LoggingService().logAction(
        action: 'CLIENT_IMPORTED',
        targetType: 'Client',
        targetId: client.name,
        details: 'Imported client "${client.name}" to 2026-2027 period',
      );

      if (mounted) {
        _showSuccess('Successfully imported "${client.name}" to 2026-2027!');
        setState(() {
          _selectedPeriod = '2026-2027';
        });
        await _fetchClients();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error importing client: $e');
      }
    }
  }

  Future<void> _showImportToCurrentDialog() async {
    final candidates = _clients.where((c) => _getClientDate(c).isBefore(nov1Cutoff)).toList();
    if (candidates.isEmpty) {
      _showError('No 2025-2026 clients available to import.');
      return;
    }

    final searchCtrl = TextEditingController();
    final selectedIds = <dynamic>{};
    bool isImporting = false;
    int importedCount = 0;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final query = searchCtrl.text.toLowerCase().trim();
          final displayed = query.isEmpty
              ? candidates
              : candidates.where((c) =>
                  c.name.toLowerCase().contains(query) ||
                  (c.phone?.toLowerCase().contains(query) ?? false) ||
                  (c.fileNo?.toLowerCase().contains(query) ?? false) ||
                  (c.registrationNumber?.toLowerCase().contains(query) ?? false)
                ).toList();

          final allDisplayedSelected = displayed.isNotEmpty && displayed.every((c) => selectedIds.contains(c.id));

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620, maxHeight: 680),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.drive_file_move_rounded, color: Color(0xFF10B981), size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Import Clients to Current',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Select clients from 2025-2026 to carry forward into 2026-2027',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: isImporting ? null : () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by client name, phone, or file no...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981))),
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '${selectedIds.length} selected of ${candidates.length} clients',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: isImporting
                              ? null
                              : () {
                                  setDialogState(() {
                                    if (allDisplayedSelected) {
                                      for (var c in displayed) {
                                        selectedIds.remove(c.id);
                                      }
                                    } else {
                                      for (var c in displayed) {
                                        if (c.id != null) selectedIds.add(c.id);
                                      }
                                    }
                                  });
                                },
                          child: Text(
                            allDisplayedSelected ? 'Deselect All' : 'Select All',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Expanded(
                      child: displayed.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_off_rounded, size: 40, color: Colors.grey.shade300),
                                  const SizedBox(height: 8),
                                  Text('No matching clients found', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: displayed.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 6),
                              itemBuilder: (context, i) {
                                final c = displayed[i];
                                final isChecked = selectedIds.contains(c.id);
                                final date = _getClientDate(c);
                                final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                                return Material(
                                  color: isChecked ? const Color(0xFF10B981).withValues(alpha: 0.08) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: isImporting
                                        ? null
                                        : () {
                                            setDialogState(() {
                                              if (isChecked) {
                                                selectedIds.remove(c.id);
                                              } else {
                                                if (c.id != null) selectedIds.add(c.id);
                                              }
                                            });
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isChecked,
                                            activeColor: const Color(0xFF10B981),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            onChanged: isImporting
                                                ? null
                                                : (val) {
                                                    setDialogState(() {
                                                      if (val == true) {
                                                        if (c.id != null) selectedIds.add(c.id);
                                                      } else {
                                                        selectedIds.remove(c.id);
                                                      }
                                                    });
                                                  },
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${c.phone?.isNotEmpty == true ? c.phone! : "No Phone"}${c.fileNo?.isNotEmpty == true ? " • File: ${c.fileNo}" : ""}${c.registrationNumber?.isNotEmpty == true ? " • Reg: ${c.registrationNumber}" : ""} • Date: $dateStr',
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    if (isImporting)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981))),
                            const SizedBox(width: 12),
                            Text('Importing $importedCount of ${selectedIds.length}...', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isImporting ? null : () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: (selectedIds.isEmpty || isImporting)
                              ? null
                              : () async {
                                  setDialogState(() {
                                    isImporting = true;
                                    importedCount = 0;
                                  });

                                  final targetDate = DateTime.now().isBefore(nov1Cutoff)
                                      ? DateTime(2026, 11, 1, 0, 0, 1)
                                      : DateTime.now();
                                  final targetDateStr = targetDate.toIso8601String();

                                  for (final id in selectedIds) {
                                    final match = candidates.firstWhereOrNull((c) => c.id == id);
                                    if (match != null) {
                                      try {
                                        final raw = _rawClients.where((m) => m.id == match.id).firstOrNull;
                                        if (raw != null) {
                                          final updated = raw.copyWith(created_at: targetDateStr);
                                          await BackupAwareApi().update(updated);
                                        } else {
                                          final model = amplify_models.Clients(
                                            id: match.id,
                                            name: match.name,
                                            email: match.email,
                                            phone: match.phone,
                                            address: match.address,
                                            type_of_work: match.typeOfWork,
                                            file_no: match.fileNo,
                                            file_date: match.fileDate,
                                            is_contacted: match.isContacted,
                                            dob: match.dob,
                                            managed_by: match.managedBy,
                                            case_number: match.registrationNumber,
                                            companies: match.companies,
                                            custom_fields: match.customFields,
                                            created_at: targetDateStr,
                                          );
                                          await BackupAwareApi().update(model);
                                        }
                                        await LoggingService().logAction(
                                          action: 'CLIENT_IMPORTED',
                                          targetType: 'Client',
                                          targetId: match.name,
                                          details: 'Imported client "${match.name}" to 2026-2027 period',
                                        );
                                      } catch (e) {
                                        debugPrint('Error importing client ${match.name}: $e');
                                      }
                                    }
                                    setDialogState(() {
                                      importedCount++;
                                    });
                                  }

                                  if (ctx.mounted) Navigator.pop(ctx);

                                  if (mounted) {
                                    setState(() {
                                      _selectedPeriod = '2026-2027';
                                    });
                                    await _fetchClients();
                                    if (!mounted) return;
                                    _showSuccess('Successfully imported ${selectedIds.length} client(s) into 2026-2027!');
                                  }
                                },
                          icon: const Icon(Icons.drive_file_move_rounded, size: 18),
                          label: Text(
                            selectedIds.isEmpty ? 'Select Clients to Import' : 'Import (${selectedIds.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
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

      // Filter out unpassed CRM leads so only passed ones come in client works
      deals = deals.where((d) {
        final isCrm = (d.pipeline ?? '').toLowerCase() == 'crm' || (d.pipeline ?? '').toLowerCase() == 'lead';
        if (isCrm && d.is_won != true) return false;
        return true;
      }).toList();

      final cNameLower = c.name.toLowerCase().trim();
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
                // Content
                Flexible(
                  child: deals.isEmpty 
                    ? Padding(
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
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: deals.length,
                        itemBuilder: (context, index) {
                          final d = deals[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
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
                                  company: c.companies != null && c.companies!.isNotEmpty ? _extractCompanyName(c.companies!.first) : null,
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
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to load works: $e');
    }
  }

  String _extractCompanyName(String raw) {
    if (raw.trim().startsWith('{')) {
      try {
        final map = jsonDecode(raw);
        if (map['name'] != null && map['name'].toString().isNotEmpty) {
          return map['name'].toString();
        }
      } catch (_) {}
    }
    if (raw.contains('|||')) {
      return raw.split('|||')[0].trim();
    }
    return raw;
  }

  Future<String?> _uploadDeedFile(PlatformFile file) async {
    try {
      final cleanName = file.name.replaceAll(' ', '_').replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');
      final s3Key = 'public/deeds/${UUID.getUUID()}_$cleanName';

      AWSFile localFile;
      if (file.bytes != null) {
        localFile = AWSFile.fromData(file.bytes!);
      } else if (!kIsWeb && file.path != null) {
        localFile = AWSFile.fromPath(file.path!);
      } else {
        return null;
      }

      try {
        await Amplify.Storage.uploadFile(
          localFile: localFile,
          path: StoragePath.fromString(s3Key),
        ).result;
      } catch (e) {
        debugPrint('Deed S3 upload notice: $e');
      }

      try {
        final bytes = file.bytes ?? (!kIsWeb && file.path != null ? await File(file.path!).readAsBytes() : null);
        if (bytes != null) {
          SupabaseBackupService().backupFileInBackground(s3Key, bytes);
        }
      } catch (_) {}

      return s3Key;
    } catch (e) {
      debugPrint('Error uploading deed file: $e');
      return null;
    }
  }

  Future<void> _openDeedDocument(String keyOrUrl) async {
    try {
      String openUrl = keyOrUrl;
      if (!keyOrUrl.startsWith('http://') && !keyOrUrl.startsWith('https://')) {
        final path = keyOrUrl.startsWith('public/') ? keyOrUrl : 'public/$keyOrUrl';
        final res = await Amplify.Storage.getUrl(path: StoragePath.fromString(path)).result;
        openUrl = res.url.toString();
      }
      final uri = Uri.parse(openUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
    } catch (e) {
      debugPrint('Error opening deed document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open document: $e'),
          backgroundColor: Colors.red.shade800,
        ));
      }
    }
  }

  void _showCompanyDetailsDialog(Client c) {
    final companiesRaw = c.companies ?? [];
    final companies = companiesRaw.map((raw) => _CompanyFormData.fromRaw(raw)).toList();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: 850,
            constraints: const BoxConstraints(maxHeight: 750),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_center_rounded, color: Color(0xFF1D4ED8), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c.name} - Companies & Deeds', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          Text('${companies.length} Registered Compan${companies.length > 1 ? 'ies' : 'y'} / Documentation Vault', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Expanded(
                  child: companies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.business_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text('No company or deed details added yet for this client.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                              const SizedBox(height: 12),
                              if (_isAdmin)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(dialogCtx);
                                    _showClientForm(c);
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Company Details'),
                                ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: companies.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 20),
                          itemBuilder: (ctx, idx) {
                            final comp = companies[idx];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Company Title Bar
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.business_rounded, color: Color(0xFF2563EB), size: 22),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            comp.nameCtrl.text.isNotEmpty ? comp.nameCtrl.text : 'Company #${idx + 1}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                                          ),
                                        ),
                                        if (comp.typeCtrl.text.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDBEAFE),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              comp.typeCtrl.text,
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Details Grid
                                        Wrap(
                                          spacing: 24,
                                          runSpacing: 12,
                                          children: [
                                            if (comp.addressCtrl.text.isNotEmpty)
                                              _buildDetailItem(Icons.location_on_outlined, 'Address', comp.addressCtrl.text),
                                            if (comp.phoneCtrl.text.isNotEmpty)
                                              _buildDetailItem(Icons.phone_outlined, 'Phone', comp.phoneCtrl.text),
                                            if (comp.emailCtrl.text.isNotEmpty)
                                              _buildDetailItem(Icons.email_outlined, 'Email', comp.emailCtrl.text),
                                            if (comp.gstinCtrl.text.isNotEmpty)
                                              _buildDetailItem(Icons.receipt_long_outlined, 'GSTIN', comp.gstinCtrl.text),
                                            if (comp.panCtrl.text.isNotEmpty)
                                              _buildDetailItem(Icons.credit_card_rounded, 'Company PAN', comp.panCtrl.text),
                                            if (comp.regNoCtrl.text.isNotEmpty)
                                              _buildDetailItem(Icons.tag_rounded, 'Reg / CIN', comp.regNoCtrl.text),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(height: 1),
                                        const SizedBox(height: 14),

                                        // Deeds Card
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFBEB),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0xFFFDE68A)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.description_rounded, size: 20, color: Color(0xFFD97706)),
                                                  const SizedBox(width: 8),
                                                  const Text('Deed & Legal Documentation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF92400E))),
                                                  const Spacer(),
                                                  if (comp.deedDocUrl != null && comp.deedDocUrl!.isNotEmpty)
                                                    ElevatedButton.icon(
                                                      onPressed: () => _openDeedDocument(comp.deedDocUrl!),
                                                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                                                      label: const Text('View Attached Deed', style: TextStyle(fontSize: 12)),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color(0xFFD97706),
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                        elevation: 0,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Wrap(
                                                spacing: 24,
                                                runSpacing: 8,
                                                children: [
                                                  _buildDetailItem(Icons.article_outlined, 'Deed Type', comp.deedTypeCtrl.text.isNotEmpty ? comp.deedTypeCtrl.text : 'Not Specified'),
                                                  if (comp.deedDateCtrl.text.isNotEmpty)
                                                    _buildDetailItem(Icons.calendar_today_outlined, 'Execution Date', comp.deedDateCtrl.text),
                                                  if (comp.deedRegNoCtrl.text.isNotEmpty)
                                                    _buildDetailItem(Icons.confirmation_number_outlined, 'Deed Reg No.', comp.deedRegNoCtrl.text),
                                                ],
                                              ),
                                              if (comp.deedNotesCtrl.text.isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Text('Notes & Key Terms: ${comp.deedNotesCtrl.text}', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800)),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Partners Section
                                        Text('Partners & Directors (${comp.partners.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 10),
                                        if (comp.partners.isEmpty)
                                          Text('No partners or directors recorded.', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic))
                                        else
                                          Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(2.2),
                                              1: FlexColumnWidth(1.8),
                                              2: FlexColumnWidth(1.8),
                                              3: FlexColumnWidth(1.8),
                                              4: FlexColumnWidth(1.8),
                                              5: FlexColumnWidth(1.0),
                                            },
                                            children: [
                                              TableRow(
                                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                                children: const [
                                                  Padding(padding: EdgeInsets.all(8), child: Text('Partner Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                                  Padding(padding: EdgeInsets.all(8), child: Text('Designation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                                  Padding(padding: EdgeInsets.all(8), child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                                  Padding(padding: EdgeInsets.all(8), child: Text('Aadhaar No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                                  Padding(padding: EdgeInsets.all(8), child: Text('PAN No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                                  Padding(padding: EdgeInsets.all(8), child: Text('Share %', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                                ],
                                              ),
                                              ...comp.partners.map((p) => TableRow(
                                                children: [
                                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.nameCtrl.text.isNotEmpty ? p.nameCtrl.text : 'N/A', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.roleCtrl.text.isNotEmpty ? p.roleCtrl.text : 'Partner', style: const TextStyle(fontSize: 12))),
                                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.phoneCtrl.text.isNotEmpty ? p.phoneCtrl.text : '-', style: const TextStyle(fontSize: 12))),
                                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.aadharCtrl.text.isNotEmpty ? p.aadharCtrl.text : '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)))),
                                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.panCtrl.text.isNotEmpty ? p.panCtrl.text : '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFB45309)))),
                                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.shareCtrl.text.isNotEmpty ? '${p.shareCtrl.text}%' : '-', style: const TextStyle(fontSize: 12))),
                                                ],
                                              )),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('Close'),
                    ),
                    if (_isAdmin) ...[
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          _showClientForm(c);
                        },
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _deleteClient(String id) async {
    if (!_isAdmin) {
      _showError('Permission Denied: Only Admin can delete clients');
      return;
    }
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
    if (client != null && !_isAdmin) {
      _showError('Permission Denied: Only Admin can edit client profiles');
      return;
    }
    final nameController = TextEditingController(text: client?.name);
    final emailController = TextEditingController(text: client?.email);
    List<TextEditingController> phoneControllers = (client?.phone ?? '').split(',').map((p) => TextEditingController(text: p.trim())).toList();
    if (phoneControllers.isEmpty || (phoneControllers.length == 1 && phoneControllers[0].text.isEmpty)) {
      phoneControllers = [TextEditingController()];
    }
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
    bool isContacted = client?.isContacted ?? false;
    List<_CompanyFormData> companyForms = (client?.companies ?? []).map((c) => _CompanyFormData.fromRaw(c)).toList();

    List<Map<String, TextEditingController>> customFieldControllers = (client?.customFields ?? []).map((c) {
      String name = '';
      String value = '';
      if (c.contains(':')) {
        final parts = c.split(':');
        name = parts.first.trim();
        if (parts.length > 1) value = parts.sublist(1).join(':').trim();
      } else {
        name = c;
      }
      return {'name': TextEditingController(text: name), 'value': TextEditingController(text: value)};
    }).toList();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
        final current2025Match = client == null ? () {
          final enteredPhones = phoneControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join(', ');
          if (enteredPhones.isEmpty) return null;
          for (var c in _clients) {
            if (_getClientDate(c).isBefore(nov1Cutoff)) {
              if (_phoneNumbersMatch(enteredPhones, c.phone)) {
                return c;
              }
            }
          }
          return null;
        }() : null;

        Widget build2025MatchBanner(Client match) {
          return Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6EE7B7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF059669)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Client already exists in 2025-2026',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('2025-2026', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '"${match.name}" (Phone: ${match.phone ?? "N/A"}${match.fileNo != null && match.fileNo!.isNotEmpty ? ", File: ${match.fileNo}" : ""}) is registered in 2025-2026.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF047857)),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context); // close modal
                    await _importSingleClientToCurrent(match, skipConfirmation: true);
                    _showClientForm(match);
                  },
                  icon: const Icon(Icons.drive_file_move_rounded, size: 15),
                  label: const Text('Import to Current (2026-2027)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          );
        }

        return Dialog(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildFormField(emailController, 'Email Address', Icons.email, false)),
                        const SizedBox(width: 20),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...phoneControllers.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(child: _buildFormField(
                                    e.value,
                                    'Phone Number',
                                    Icons.phone,
                                    e.key == 0,
                                    onChanged: (_) => setModalState(() {}),
                                  )),
                                  if (e.key > 0)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () => setModalState(() => phoneControllers.removeAt(e.key))
                                    )
                                ]
                              )
                            )),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => setModalState(() => phoneControllers.add(TextEditingController())),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Phone Number'),
                              ),
                            ),
                            if (current2025Match != null) build2025MatchBanner(current2025Match),
                          ]
                        )),
                      ],
                    ) : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFormField(emailController, 'Email Address', Icons.email, false),
                        const SizedBox(height: 20),
                        ...phoneControllers.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(child: _buildFormField(
                                e.value,
                                'Phone Number',
                                Icons.phone,
                                e.key == 0,
                                onChanged: (_) => setModalState(() {}),
                              )),
                              if (e.key > 0)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => setModalState(() => phoneControllers.removeAt(e.key))
                                )
                            ]
                          )
                        )),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => setModalState(() => phoneControllers.add(TextEditingController())),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Phone Number'),
                          ),
                        ),
                        if (current2025Match != null) build2025MatchBanner(current2025Match),
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
                    Row(
                      children: [
                        const Icon(Icons.business_center_rounded, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        const Text('Companies, Deeds & Partners Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            setModalState(() {
                              companyForms.add(_CompanyFormData(
                                nameCtrl: TextEditingController(),
                                typeCtrl: TextEditingController(text: 'Partnership Firm'),
                                addressCtrl: TextEditingController(),
                                phoneCtrl: TextEditingController(),
                                emailCtrl: TextEditingController(),
                                regNoCtrl: TextEditingController(),
                                gstinCtrl: TextEditingController(),
                                panCtrl: TextEditingController(),
                                deedTypeCtrl: TextEditingController(text: 'Partnership Deed'),
                                deedDateCtrl: TextEditingController(),
                                deedRegNoCtrl: TextEditingController(),
                                deedNotesCtrl: TextEditingController(),
                                deedDocUrl: null,
                                partners: [],
                              ));
                            });
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Company'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E40AF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (companyForms.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey.shade500, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No companies added yet. Click "+ Add Company" above to add business details, deeds documentation, and partner Aadhaar/PAN.',
                                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...companyForms.asMap().entries.map((e) {
                        int idx = e.key;
                        final company = e.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade200, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Company Header Bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.business_rounded, color: Color(0xFF1D4ED8), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        company.nameCtrl.text.isNotEmpty ? company.nameCtrl.text : 'Company #${idx + 1}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A8A)),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                      tooltip: 'Remove Company',
                                      onPressed: () {
                                        setModalState(() {
                                          companyForms.removeAt(idx);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Company Details
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: _buildFormField(company.nameCtrl, 'Company / Firm Name *', Icons.business, false),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: _buildFormField(company.typeCtrl, 'Constitution (e.g. Partnership / Pvt Ltd)', Icons.account_balance_outlined, false),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildFormField(company.addressCtrl, 'Registered Address', Icons.location_on_outlined, false, maxLines: 2),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(company.phoneCtrl, 'Official Phone', Icons.phone_outlined, false),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildFormField(company.emailCtrl, 'Official Email', Icons.email_outlined, false),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(company.gstinCtrl, 'GSTIN', Icons.receipt_long_outlined, false),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildFormField(company.panCtrl, 'Company PAN', Icons.badge_outlined, false),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildFormField(company.regNoCtrl, 'Reg No. / CIN / LLPIN', Icons.tag_rounded, false),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(height: 1),
                                    const SizedBox(height: 14),

                                    // Deeds & Documentation Section
                                    Row(
                                      children: [
                                        const Icon(Icons.description_rounded, size: 18, color: Color(0xFFD97706)),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Deeds & Documentation',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF92400E)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: _buildFormField(company.deedTypeCtrl, 'Deed Type (e.g. Partnership Deed, MOA)', Icons.article_outlined, false),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: _buildFormField(
                                            company.deedDateCtrl,
                                            'Execution / Deed Date',
                                            Icons.calendar_today_outlined,
                                            false,
                                            onTap: () => pickDate(context, company.deedDateCtrl),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(company.deedRegNoCtrl, 'Deed Reg No. / Doc No.', Icons.confirmation_number_outlined, false),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildFormField(company.deedNotesCtrl, 'Documentation Details / SRO / Notes', Icons.notes_rounded, false),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Attached Deed File Row
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.amber.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.attachment_rounded, size: 18, color: Colors.amber.shade900),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              company.deedDocUrl != null && company.deedDocUrl!.isNotEmpty
                                                  ? 'Attached Deed: ${company.deedDocUrl!.split('/').last}'
                                                  : 'No deed file attached yet',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: company.deedDocUrl != null ? FontWeight.bold : FontWeight.normal,
                                                color: company.deedDocUrl != null ? Colors.black87 : Colors.grey.shade600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (company.deedDocUrl != null && company.deedDocUrl!.isNotEmpty) ...[
                                            IconButton(
                                              icon: const Icon(Icons.visibility_rounded, size: 18, color: Colors.blue),
                                              tooltip: 'View Document',
                                              onPressed: () => _openDeedDocument(company.deedDocUrl!),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                              tooltip: 'Remove Document',
                                              onPressed: () {
                                                setModalState(() {
                                                  company.deedDocUrl = null;
                                                });
                                              },
                                            ),
                                          ],
                                          TextButton.icon(
                                            onPressed: company.isUploadingDoc
                                                ? null
                                                : () async {
                                                    final result = await FilePicker.pickFiles(
                                                      type: FileType.custom,
                                                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
                                                      withData: true,
                                                    );
                                                    if (result != null && result.files.isNotEmpty) {
                                                      setModalState(() => company.isUploadingDoc = true);
                                                      final uploadedKey = await _uploadDeedFile(result.files.first);
                                                      setModalState(() {
                                                        company.isUploadingDoc = false;
                                                        if (uploadedKey != null) {
                                                          company.deedDocUrl = uploadedKey;
                                                        }
                                                      });
                                                    }
                                                  },
                                            icon: company.isUploadingDoc
                                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                                : const Icon(Icons.upload_file_rounded, size: 16),
                                            label: Text(
                                              company.deedDocUrl != null ? 'Change File' : 'Upload Deed File',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(height: 1),
                                    const SizedBox(height: 14),

                                    // Partners / Directors Details Section
                                    Row(
                                      children: [
                                        const Icon(Icons.groups_rounded, size: 18, color: Color(0xFF047857)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Partners & Directors (${company.partners.length})',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF065F46)),
                                        ),
                                        const Spacer(),
                                        TextButton.icon(
                                          onPressed: () {
                                            setModalState(() {
                                              company.partners.add(_PartnerFormData(
                                                nameCtrl: TextEditingController(),
                                                roleCtrl: TextEditingController(text: 'Partner'),
                                                phoneCtrl: TextEditingController(),
                                                emailCtrl: TextEditingController(),
                                                aadharCtrl: TextEditingController(),
                                                panCtrl: TextEditingController(),
                                                shareCtrl: TextEditingController(),
                                              ));
                                            });
                                          },
                                          icon: const Icon(Icons.person_add_rounded, size: 16),
                                          label: const Text('Add Partner / Director', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF047857)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (company.partners.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          'No partners or directors added yet. Click "+ Add Partner / Director" above.',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                                        ),
                                      )
                                    else
                                      ...company.partners.asMap().entries.map((pEntry) {
                                        final pIdx = pEntry.key;
                                        final partner = pEntry.value;
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFD1FAE5),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      'Partner #${pIdx + 1}',
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  IconButton(
                                                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                                                    tooltip: 'Remove Partner',
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () {
                                                      setModalState(() {
                                                        company.partners.removeAt(pIdx);
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: _buildFormField(partner.nameCtrl, 'Partner / Director Name *', Icons.person_outline, false),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    flex: 2,
                                                    child: _buildFormField(partner.roleCtrl, 'Designation (e.g. Managing Partner)', Icons.work_outline, false),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildFormField(partner.phoneCtrl, 'Phone Number', Icons.phone_android_rounded, false),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: _buildFormField(partner.emailCtrl, 'Email Address', Icons.email_outlined, false),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: _buildFormField(partner.aadharCtrl, 'Aadhaar Number (12 Digits)', Icons.fingerprint_rounded, false),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    flex: 2,
                                                    child: _buildFormField(partner.panCtrl, 'PAN Number (e.g. ABCDE1234F)', Icons.credit_card_rounded, false),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    flex: 1,
                                                    child: _buildFormField(partner.shareCtrl, 'Share %', Icons.pie_chart_outline_rounded, false),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                    const Text('Custom Fields', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                                  _buildFormField(e.value['name']!, 'Field Name (e.g. GSTIN)', Icons.label_outline, false),
                                  const SizedBox(height: 8),
                                  _buildFormField(e.value['value']!, 'Field Value', Icons.text_fields, false),
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
                            customFieldControllers.add({'name': TextEditingController(), 'value': TextEditingController()});
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
                          final newPhoneStr = phoneControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join(', ');
                          
                          // 1. Check if client with this phone number already exists in 2025-2026
                          Client? existing2025Client;
                          if (newPhoneStr.isNotEmpty) {
                            for (var c in _clients) {
                              if (_getClientDate(c).isBefore(nov1Cutoff)) {
                                if (_phoneNumbersMatch(newPhoneStr, c.phone)) {
                                  existing2025Client = c;
                                  break;
                                }
                              }
                            }
                          }

                          if (existing2025Client != null) {
                            final action = await showDialog<String>(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.drive_file_move_rounded, color: Color(0xFF10B981), size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Client Already Exists in 2025-2026',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: const Color(0xFF10B981),
                                            child: Text(
                                              existing2025Client!.name.isNotEmpty ? existing2025Client.name[0].toUpperCase() : '?',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  existing2025Client.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                ),
                                                Text(
                                                  '📞 ${existing2025Client.phone ?? "No Phone"}',
                                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                ),
                                                if (existing2025Client.fileNo != null && existing2025Client.fileNo!.isNotEmpty)
                                                  Text(
                                                    '📁 File No: ${existing2025Client.fileNo}',
                                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('2025-2026', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'A client with this phone number already exists in 2025-2026.\n\nPlease import this client into the current period (2026-2027) instead of creating a duplicate record.',
                                      style: TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, 'cancel'),
                                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, 'create_anyway'),
                                    child: const Text('Create New Anyway', style: TextStyle(color: Colors.orange)),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pop(ctx, 'import'),
                                    icon: const Icon(Icons.drive_file_move_rounded, size: 16),
                                    label: const Text('Import Client to Current'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (action == 'cancel' || action == null) return;

                            if (action == 'import') {
                              if (context.mounted) Navigator.pop(context); // close new client form
                              await _importSingleClientToCurrent(existing2025Client, skipConfirmation: true);
                              _showClientForm(existing2025Client);
                              return;
                            }
                          } else {
                            // 2. Check if client already exists in current period (2026-2027)
                            Client? existingCurrentClient;
                            for (var c in _clients) {
                              if (!_getClientDate(c).isBefore(nov1Cutoff)) {
                                if ((newName.isNotEmpty && c.name.trim().toLowerCase() == newName) || 
                                    (newPhoneStr.isNotEmpty && _phoneNumbersMatch(newPhoneStr, c.phone))) {
                                  existingCurrentClient = c;
                                  break;
                                }
                              }
                            }
                            
                            if (existingCurrentClient != null) {
                              final action = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Client Already Exists in Current Period'),
                                  content: Text('A client with the name "${existingCurrentClient!.name}" or phone "${existingCurrentClient.phone}" already exists in 2026-2027.\n\nDo you want to create a new client anyway or open the existing one?'),
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
                                _showClientForm(existingCurrentClient); // open existing client form
                                return;
                              }
                            }
                          }
                        }

                        final newClient = Client(
                          id: client?.id,
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join(', '),
                          address: addressController.text,
                          typeOfWork: workController.text,
                          fileDate: fileDateController.text,
                          fileNo: fileNoController.text,
                          isContacted: isContacted,
                          dob: dobController.text,
                          managedBy: careOfController.text,
                          balanceDue: client?.balanceDue,
                          registrationNumber: client?.registrationNumber,
                          companies: companyForms.map((c) => c.toSerializedString()).where((s) => s.isNotEmpty).toList(),
                          customFields: customFieldControllers.map((c) {
                            final name = c['name']!.text.trim();
                            final val = c['value']!.text.trim();
                            if (name.isEmpty && val.isEmpty) return '';
                            return '$name: $val';
                          }).where((c) => c.isNotEmpty && c != ': ').toList(),
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
                              companies: newClient.companies,
                              custom_fields: newClient.customFields,
                              created_at: FiscalYearService.getEffectiveCreationDate().toIso8601String(),
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
                              companies: newClient.companies,
                              custom_fields: newClient.customFields,
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
    ).animate().fadeIn(duration: 300.ms).scaleXY(begin: 0.95, end: 1.0, curve: Curves.easeOutBack);
  },
),
);
}

  Widget _buildFormField(TextEditingController controller, String label, IconData icon, bool required, {int maxLines = 1, VoidCallback? onTap, ValueChanged<String>? onChanged}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: onTap != null,
      onTap: onTap,
      onChanged: onChanged,
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
        var periodFiltered = _clients;
        if (_selectedPeriod == '2025-2026') {
          periodFiltered = _clients.where((c) => _getClientDate(c).isBefore(nov1Cutoff)).toList();
        } else if (_selectedPeriod == '2026-2027') {
          periodFiltered = _clients.where((c) => !_getClientDate(c).isBefore(nov1Cutoff)).toList();
        }

        final filtered = periodFiltered.where((c) => 
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
                      FiscalYearHeaderPill(onSwitched: () { if (mounted) setState(() {}); }),
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
              Wrap(
                spacing: 8,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showClientForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Client'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                  ),
                  _buildSortDropdown(),
                  FiscalYearHeaderPill(onSwitched: () { if (mounted) setState(() {}); }),
                  _headerAction(Icons.refresh_rounded, 'Refresh', AppTheme.primaryColor, _fetchClients),
                  _headerAction(Icons.download_rounded, 'Export', Colors.green, _exportToExcel),
                  if (_selectedPeriod == '2026-2027' && _count2025_2026 > 0)
                    _headerAction(Icons.drive_file_move_outlined, 'Import from 25-26', const Color(0xFF10B981), _showImportToCurrentDialog),
                ],
              ).animate().fadeIn().slideY(begin: 0.1),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: _selectedPeriod == '2026-2027'
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.auto_awesome_rounded, size: 48, color: Color(0xFF10B981)),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Fresh Start: 2026-2027',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Starting fresh from Nov 1, 2026! No new clients registered yet.\nPrevious clients are safely archived in the "2025-2026" button ($_count2025_2026 clients).',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                  ),
                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _selectedPeriod = '2025-2026';
                                          });
                                        },
                                        icon: const Icon(Icons.history_rounded, size: 18),
                                        label: Text('Open 2025-2026 Clients ($_count2025_2026)'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF6366F1),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 2,
                                        ),
                                      ),
                                      if (_count2025_2026 > 0)
                                        ElevatedButton.icon(
                                          onPressed: _showImportToCurrentDialog,
                                          icon: const Icon(Icons.drive_file_move_rounded, size: 18),
                                          label: const Text('Import from 2025-2026'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF10B981),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            elevation: 2,
                                          ),
                                        ),
                                      OutlinedButton.icon(
                                        onPressed: () => _showClientForm(),
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('Add Client'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.primaryColor,
                                          side: const BorderSide(color: AppTheme.primaryColor),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_off_rounded, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text('No clients found for this period', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                                ],
                              ),
                      )
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

  String _formatDate(String? isoString, String? createdBy) {
    if (createdBy == 'System/Legacy') return 'Not Saved';
    if (isoString == null || isoString.isEmpty) return 'Not Saved';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return isoString;
    }
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
                _buildInfoPill(Icons.calendar_today_outlined, 'File Date: ${c.fileDate?.isNotEmpty == true ? c.fileDate! : 'N/A'}', isWide),
                _buildInfoPill(Icons.cake_outlined, 'DOB: ${c.dob?.isNotEmpty == true ? c.dob! : 'N/A'}', isWide),
                _buildInfoPill(Icons.location_on_outlined, c.address?.isNotEmpty == true ? c.address! : 'No Address', isWide),
                _buildInfoPill(Icons.supervised_user_circle_outlined, 'Care Of: ${c.managedBy?.isNotEmpty == true ? c.managedBy! : 'N/A'}', isWide),
                _buildInfoPill(Icons.person_add_outlined, 'Created By: ${c.createdBy ?? 'System/Legacy'}', isWide),
                _buildInfoPill(Icons.access_time_outlined, 'Created: ${_formatDate(c.createdAt, c.createdBy)}', isWide),
              ],
            ),
            if (c.companies != null && c.companies!.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _showCompanyDetailsDialog(c),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business_center_rounded, size: 16, color: Color(0xFF1D4ED8)),
                      const SizedBox(width: 8),
                      Text(
                        '${c.companies!.length} Compan${c.companies!.length > 1 ? 'ies' : 'y'} & Deeds / Partners',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF1E40AF)),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF1D4ED8)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 12,
              children: [
                if (c.companies != null && c.companies!.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _showCompanyDetailsDialog(c),
                    icon: const Icon(Icons.business_center_outlined, size: 16),
                    label: Text('Company & Deeds (${c.companies!.length})'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1D4ED8),
                      side: const BorderSide(color: Color(0xFF93C5FD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
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
                OutlinedButton.icon(
                  onPressed: () => _showClientBillsDialog(c),
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  label: const Text('Bills'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    side: BorderSide(color: Colors.teal.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showClientWorksDialog(c),
                  icon: const Icon(Icons.work_outline, size: 16),
                  label: const Text('Works'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    side: BorderSide(color: Colors.indigo.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showMergeDialog(c),
                  icon: const Icon(Icons.merge_type, size: 16),
                  label: const Text('Merge'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: BorderSide(color: Colors.purple.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (_isAdmin)
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
                if (_getClientDate(c).isBefore(nov1Cutoff))
                  ElevatedButton.icon(
                    onPressed: () => _importSingleClientToCurrent(c),
                    icon: const Icon(Icons.drive_file_move_rounded, size: 15),
                    label: const Text('Import to 26–27', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                if (_isAdmin)
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
      width: isWide ? 260 : double.infinity,
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('${widget.client.name} - Ledger', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_bills.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No bills found for this client.', style: TextStyle(color: Colors.grey))))
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _bills.length,
                  itemBuilder: (context, index) {
                    final b = _bills[index];
                    final isPaid = b.status == 'Received';
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor, size: 20),
                        ),
                        title: Text('Invoice: ${b.invoiceNo ?? 'N/A'} - ₹${b.amount ?? '0'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${b.type ?? 'N/A'} • ${b.date ?? 'N/A'}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isPaid ? Colors.green.shade200 : Colors.orange.shade200),
                          ),
                          child: Text(isPaid ? 'Paid' : 'Pending', style: TextStyle(color: isPaid ? Colors.green : Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompanyFormData {
  final TextEditingController nameCtrl;
  final TextEditingController typeCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController regNoCtrl;
  final TextEditingController gstinCtrl;
  final TextEditingController panCtrl;

  // Deeds & Documentation
  final TextEditingController deedTypeCtrl;
  final TextEditingController deedDateCtrl;
  final TextEditingController deedRegNoCtrl;
  final TextEditingController deedNotesCtrl;
  String? deedDocUrl;
  bool isUploadingDoc;

  // Partners
  final List<_PartnerFormData> partners;

  _CompanyFormData({
    required this.nameCtrl,
    required this.typeCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.regNoCtrl,
    required this.gstinCtrl,
    required this.panCtrl,
    required this.deedTypeCtrl,
    required this.deedDateCtrl,
    required this.deedRegNoCtrl,
    required this.deedNotesCtrl,
    this.deedDocUrl,
    this.isUploadingDoc = false,
    required this.partners,
  });

  factory _CompanyFormData.fromRaw(String raw) {
    if (raw.trim().startsWith('{')) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final partnersList = (map['partners'] as List?)?.map((p) {
          final pMap = p is Map ? Map<String, dynamic>.from(p) : <String, dynamic>{};
          return _PartnerFormData(
            nameCtrl: TextEditingController(text: pMap['name']?.toString() ?? ''),
            roleCtrl: TextEditingController(text: pMap['role']?.toString() ?? 'Partner'),
            phoneCtrl: TextEditingController(text: pMap['phone']?.toString() ?? ''),
            emailCtrl: TextEditingController(text: pMap['email']?.toString() ?? ''),
            aadharCtrl: TextEditingController(text: pMap['aadhar']?.toString() ?? ''),
            panCtrl: TextEditingController(text: pMap['pan']?.toString() ?? ''),
            shareCtrl: TextEditingController(text: pMap['share']?.toString() ?? ''),
          );
        }).toList() ?? [];

        return _CompanyFormData(
          nameCtrl: TextEditingController(text: map['name']?.toString() ?? ''),
          typeCtrl: TextEditingController(text: map['type']?.toString() ?? 'Partnership Firm'),
          addressCtrl: TextEditingController(text: map['address']?.toString() ?? ''),
          phoneCtrl: TextEditingController(text: map['phone']?.toString() ?? ''),
          emailCtrl: TextEditingController(text: map['email']?.toString() ?? ''),
          regNoCtrl: TextEditingController(text: map['reg_no']?.toString() ?? ''),
          gstinCtrl: TextEditingController(text: map['gstin']?.toString() ?? ''),
          panCtrl: TextEditingController(text: map['pan']?.toString() ?? ''),
          deedTypeCtrl: TextEditingController(text: map['deed_type']?.toString() ?? 'Partnership Deed'),
          deedDateCtrl: TextEditingController(text: map['deed_date']?.toString() ?? ''),
          deedRegNoCtrl: TextEditingController(text: map['deed_reg_no']?.toString() ?? ''),
          deedNotesCtrl: TextEditingController(text: map['deed_notes']?.toString() ?? ''),
          deedDocUrl: map['deed_doc_url']?.toString(),
          partners: partnersList,
        );
      } catch (_) {}
    }

    String name = raw;
    String address = '';
    String phone = '';
    if (raw.contains('|||')) {
      final parts = raw.split('|||');
      name = parts[0];
      if (parts.length > 1) address = parts[1];
      if (parts.length > 2) phone = parts[2];
    }
    return _CompanyFormData(
      nameCtrl: TextEditingController(text: name),
      typeCtrl: TextEditingController(text: 'Partnership Firm'),
      addressCtrl: TextEditingController(text: address),
      phoneCtrl: TextEditingController(text: phone),
      emailCtrl: TextEditingController(),
      regNoCtrl: TextEditingController(),
      gstinCtrl: TextEditingController(),
      panCtrl: TextEditingController(),
      deedTypeCtrl: TextEditingController(text: 'Partnership Deed'),
      deedDateCtrl: TextEditingController(),
      deedRegNoCtrl: TextEditingController(),
      deedNotesCtrl: TextEditingController(),
      deedDocUrl: null,
      partners: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': nameCtrl.text.trim(),
      'type': typeCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'reg_no': regNoCtrl.text.trim(),
      'gstin': gstinCtrl.text.trim(),
      'pan': panCtrl.text.trim().toUpperCase(),
      'deed_type': deedTypeCtrl.text.trim(),
      'deed_date': deedDateCtrl.text.trim(),
      'deed_reg_no': deedRegNoCtrl.text.trim(),
      'deed_notes': deedNotesCtrl.text.trim(),
      'deed_doc_url': deedDocUrl,
      'partners': partners.map((p) => p.toMap()).toList(),
    };
  }

  String toSerializedString() {
    return jsonEncode(toMap());
  }
}

class _PartnerFormData {
  final TextEditingController nameCtrl;
  final TextEditingController roleCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController aadharCtrl;
  final TextEditingController panCtrl;
  final TextEditingController shareCtrl;

  _PartnerFormData({
    required this.nameCtrl,
    required this.roleCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.aadharCtrl,
    required this.panCtrl,
    required this.shareCtrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': nameCtrl.text.trim(),
      'role': roleCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'aadhar': aadharCtrl.text.trim(),
      'pan': panCtrl.text.trim().toUpperCase(),
      'share': shareCtrl.text.trim(),
    };
  }
}

