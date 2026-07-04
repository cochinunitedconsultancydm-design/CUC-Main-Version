import 'package:flutter/material.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../widgets/premium_app_bar.dart';
import 'create_work_file_dialog.dart';
import '../models/deal.dart' as models;
import 'deal_detail_screen.dart';
import '../models/client.dart';
import 'client_files_dialog.dart';
import '../services/logging_service.dart';

class ClientFilesScreen extends StatefulWidget {
  const ClientFilesScreen({super.key});

  @override
  State<ClientFilesScreen> createState() => _ClientFilesScreenState();
}

class _ClientFilesScreenState extends State<ClientFilesScreen> {
  final _searchController = TextEditingController();
  List<amplify_models.Deals> _workFiles = [];
  List<amplify_models.Deals> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkFiles() async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.Deals.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      
      if (res.data != null) {
        final List<amplify_models.Deals> fetched = res.data!.items.whereType<amplify_models.Deals>().toList();
        fetched.sort((a, b) => (b.createdAt?.getDateTimeInUtc() ?? DateTime.now()).compareTo(a.createdAt?.getDateTimeInUtc() ?? DateTime.now()));
        
        if (mounted) {
          setState(() {
            _workFiles = fetched;
            _filtered = fetched;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching work files: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteWorkFile(amplify_models.Deals workFile) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Work File'),
        content: Text('Are you sure you want to delete the work file "${workFile.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await BackupAwareApi().delete(workFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work file deleted successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        }
        _fetchWorkFiles();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _editWorkFile(amplify_models.Deals workFile) async {
    final nameController = TextEditingController(text: workFile.name);
    final fileNoController = TextEditingController(text: workFile.register_no);
    final typeController = TextEditingController(text: workFile.work_type);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Work File'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fileNoController,
                decoration: const InputDecoration(labelText: 'File No', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (updated == true) {
      setState(() => _isLoading = true);
      try {
        final newDeal = workFile.copyWith(
          name: nameController.text.trim(),
          register_no: fileNoController.text.trim(),
          work_type: typeController.text.trim(),
        );
        await BackupAwareApi().update(newDeal);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work file updated successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        }
        _fetchWorkFiles();
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating: $e')));
        }
      }
    }
  }

  void _filterWorkFiles(String query) {
    if (query.isEmpty) {
      setState(() => _filtered = _workFiles);
      return;
    }
    
    final lower = query.toLowerCase();
    setState(() {
      _filtered = _workFiles.where((w) => 
        (w.name?.toLowerCase().contains(lower) ?? false) || 
        (w.client_name?.toLowerCase().contains(lower) ?? false)
      ).toList();
    });
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateWorkFileDialog(
        onSaved: () {
          _fetchWorkFiles();
        },
      ),
    );
  }

  void _viewWorkFile(amplify_models.Deals workFile) {
    showDialog(
      context: context,
      builder: (context) => WorkFileDetailDialog(
        workFile: workFile,
        allWorkFiles: _workFiles,
        onUpdate: _fetchWorkFiles,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PremiumAppBar(
        title: const Text('Work File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Work File'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterWorkFiles,
                      decoration: const InputDecoration(
                        hintText: 'Search work files by name or client...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _fetchWorkFiles,
                  icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.1),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_off_rounded, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No work files found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 160,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final workFile = _filtered[index];
                            final bool isSubWork = workFile.pipeline == 'Sub Work';
                            return Card(
                              elevation: 2,
                              color: isSubWork ? Colors.deepPurple.shade50 : null,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _viewWorkFile(workFile),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                            child: const Icon(Icons.work_history_rounded, color: AppTheme.primaryColor),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              workFile.name ?? 'Untitled', 
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                            tooltip: 'Edit Work File',
                                            onPressed: () => _editWorkFile(workFile),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            tooltip: 'Delete Work File',
                                            onPressed: () => _deleteWorkFile(workFile),
                                          ),
                                        ],
                                      ),
                                      if (true) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            if (isSubWork)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Sub Work',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900),
                                                ),
                                              ),
                                            if (workFile.register_no != null && workFile.register_no!.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'File No: ${workFile.register_no}',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                                ),
                                              ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                (workFile.work_type != null && workFile.work_type!.trim().isNotEmpty) ? '${workFile.work_type}' : 'Type: N/A',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const Spacer(),
                                      Text(
                                        'Client: ${workFile.client_name ?? "Unknown"}',
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(
                                            workFile.createdAt?.getDateTimeInUtc().toString().split(' ')[0] ?? '',
                                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkFileDetailDialog extends StatefulWidget {
  final amplify_models.Deals workFile;
  final List<amplify_models.Deals> allWorkFiles;
  final VoidCallback onUpdate;
  
  const WorkFileDetailDialog({super.key, required this.workFile, required this.allWorkFiles, required this.onUpdate});

  @override
  State<WorkFileDetailDialog> createState() => _WorkFileDetailDialogState();
}

class _WorkFileDetailDialogState extends State<WorkFileDetailDialog> {
  late amplify_models.Deals _currentWorkFile;
  bool _isUploading = false;
  List<amplify_models.ActivityLogs> _logs = [];
  bool _isLoadingLogs = true;
  List<amplify_models.Deals> _subWorks = [];

  @override
  void initState() {
    super.initState();
    _currentWorkFile = widget.workFile;
    _subWorks = widget.allWorkFiles.where((w) => w.contact_status == _currentWorkFile.id).toList();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoadingLogs = true);
    try {
      final req = ModelQueries.list(
        amplify_models.ActivityLogs.classType,
        where: amplify_models.ActivityLogs.TARGET_ID.eq(_currentWorkFile.name),
        limit: 1000,
      );
      final res = await Amplify.API.query(request: req).response;
      if (res.data != null) {
        final fetchedLogs = res.data!.items.whereType<amplify_models.ActivityLogs>().toList();
        fetchedLogs.sort((a, b) => (b.createdAt?.getDateTimeInUtc() ?? DateTime.now())
            .compareTo(a.createdAt?.getDateTimeInUtc() ?? DateTime.now()));
        if (mounted) setState(() => _logs = fetchedLogs);
      }
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLogs = false);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }

  Future<void> _downloadFile(BuildContext context, String path) async {
    try {
      final result = await Amplify.Storage.getUrl(path: StoragePath.fromString(path)).result;
      _launchUrl(result.url.toString());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open file: $e')));
      }
    }
  }

  Future<void> _selectFromVault() async {
    final clientId = _currentWorkFile.company ?? '';
    if (clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client ID not found on this Work File.')));
      return;
    }
    
    Client? client;
    try {
      final req = ModelQueries.get(amplify_models.Clients.classType, amplify_models.ClientsModelIdentifier(id: clientId));
      final res = await Amplify.API.query(request: req).response;
      if (res.data != null) {
        final dbClient = res.data!;
        client = Client(
          id: dbClient.id,
          name: dbClient.name ?? 'Unknown',
          email: dbClient.email,
          phone: dbClient.phone,
          address: dbClient.address,
        );
      }
    } catch (e) {
      debugPrint('Error fetching client: $e');
    }

    if (client == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not load Client details.')));
      return;
    }

    if (!mounted) return;
    
    final selectedPath = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => ClientFilesDialog(client: client!, isSelectionMode: true),
    );

    if (selectedPath != null && mounted) {
      _attachFileToWork(selectedPath);
    }
  }

  Future<void> _attachFileToWork(String path) async {
    setState(() => _isUploading = true);
    try {
      List<String> files = [];
      if (_currentWorkFile.files_received != null && _currentWorkFile.files_received!.isNotEmpty) {
        try {
          final decoded = jsonDecode(_currentWorkFile.files_received!);
          if (decoded is List) {
            files = decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          debugPrint("Parse error in attach: $e");
        }
      }
      
      if (!files.contains(path)) {
        files.add(path);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File is already attached.')));
        setState(() => _isUploading = false);
        return;
      }
      
      final updatedDeal = _currentWorkFile.copyWith(files_received: jsonEncode(files));
      final req = ModelMutations.update(updatedDeal);
      await BackupAwareApi().update(updatedDeal);

      if (mounted) {
        setState(() {
          _currentWorkFile = updatedDeal;
        });
        widget.onUpdate();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File attached successfully!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handoverWorkFile() async {
    List<amplify_models.Users> staffList = [];
    try {
      final req = ModelQueries.list(amplify_models.Users.classType, limit: 1000);
      final res = await Amplify.API.query(request: req).response;
      if (res.data != null) {
        final List<amplify_models.Users> fetched = res.data!.items.whereType<amplify_models.Users>().toList();
        final List<amplify_models.Users> deduplicated = [];
        for (var staff in fetched) {
          final name = (staff.name ?? staff.username ?? 'Unknown').trim();
          if (name == 'Unknown' || name.isEmpty) continue;
          
          bool isDuplicate = false;
          for (int i = 0; i < deduplicated.length; i++) {
            final existingName = (deduplicated[i].name ?? deduplicated[i].username ?? '').trim();
            final n1 = name.toLowerCase();
            final n2 = existingName.toLowerCase();
            
            if (n1.startsWith(n2) || n2.startsWith(n1)) {
              isDuplicate = true;
              if (name.length > existingName.length) {
                deduplicated[i] = staff;
              }
              break;
            }
          }
          
          if (!isDuplicate) {
            deduplicated.add(staff);
          }
        }
        staffList = deduplicated;
        staffList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      }
    } catch (e) {
      debugPrint('Error fetching staff: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error loading staff.')));
      return;
    }

    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Handover Work File'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return ListTile(
                  leading: const Icon(Icons.person, color: AppTheme.primaryColor),
                  title: Text(staff.name ?? staff.username ?? 'Unknown'),
                  onTap: () {
                    showDialog<Map<String, String>>(
                      context: context,
                      builder: (ctx) {
                        final reasonController = TextEditingController();
                        final remarksController = TextEditingController();
                        return AlertDialog(
                          title: Text('Handover to ${staff.name}'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: reasonController,
                                decoration: const InputDecoration(
                                  labelText: 'Reason (Optional)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: remarksController,
                                decoration: const InputDecoration(
                                  labelText: 'Remarks (Optional)',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, {'reason': reasonController.text.trim(), 'remarks': remarksController.text.trim()}),
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      }
                    ).then((data) {
                      if (data != null) {
                        Navigator.pop(context, {'staff': staff, 'reason': data['reason'], 'remarks': data['remarks']});
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        );
      },
    );

    if (result != null && mounted) {
      final selectedStaff = result['staff'] as amplify_models.Users;
      final reason = result['reason'] as String?;
      final remarks = result['remarks'] as String?;

      setState(() => _isUploading = true);
      try {
        final updatedDeal = _currentWorkFile.copyWith(
          responsible_id: int.tryParse(selectedStaff.id),
          responsible_name: selectedStaff.name,
        );
        final req = ModelMutations.update(updatedDeal);
        await BackupAwareApi().update(updatedDeal);
        
        String detailsText = 'Handed over Work File to ${selectedStaff.name}';
        if (reason != null && reason.isNotEmpty) detailsText += ' - Reason: $reason';
        if (remarks != null && remarks.isNotEmpty) detailsText += ' - Remarks: $remarks';

        await LoggingService().logAction(
          action: 'WORK_FILE_HANDOVER',
          targetType: 'WorkFile',
          targetId: updatedDeal.name,
          details: detailsText,
        );

        setState(() => _currentWorkFile = updatedDeal);
        _fetchLogs();
        widget.onUpdate();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work File Handed Over successfully!')));
      } catch (e) {
        debugPrint('Error handing over: $e');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error handing over: $e')));
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Work File History'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: _isLoadingLogs 
              ? const Center(child: CircularProgressIndicator())
              : _logs.isEmpty 
                  ? const Center(child: Text('No history found.'))
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return ListTile(
                          leading: const Icon(Icons.history, color: Colors.blue),
                          title: Text(log.details ?? log.action ?? 'Unknown Action'),
                          subtitle: Text(log.createdAt?.getDateTimeInUtc().toLocal().toString().split('.')[0] ?? ''),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        );
      },
    );
  }

  void _addSubWork() {
    List<amplify_models.Deals> availableForSub = widget.allWorkFiles.where((w) => 
      w.id != _currentWorkFile.id && 
      w.contact_status != _currentWorkFile.id
    ).toList();
    List<amplify_models.Deals> filteredForSearch = List.from(availableForSub);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Sub Work'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by name or client...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        final lower = val.toLowerCase();
                        setDialogState(() {
                          filteredForSearch = availableForSub.where((w) => 
                            (w.name?.toLowerCase().contains(lower) ?? false) || 
                            (w.client_name?.toLowerCase().contains(lower) ?? false)
                          ).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredForSearch.length,
                        itemBuilder: (context, index) {
                          final wf = filteredForSearch[index];
                          return ListTile(
                            leading: const Icon(Icons.folder, color: AppTheme.primaryColor),
                            title: Text(wf.name ?? 'Untitled'),
                            subtitle: Text('Client: ${wf.client_name ?? "Unknown"}'),
                            onTap: () async {
                              Navigator.pop(context);
                              setState(() => _isUploading = true);
                              try {
                                final updatedWF = wf.copyWith(contact_status: _currentWorkFile.id);
                                await BackupAwareApi().update(updatedWF);
                                setState(() {
                                  _subWorks.add(updatedWF);
                                });
                                widget.onUpdate();
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sub work added successfully!')));
                              } catch (e) {
                                debugPrint('Error adding sub work: $e');
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding sub work: $e')));
                              } finally {
                                if (mounted) setState(() => _isUploading = false);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> files = [];
    if (_currentWorkFile.files_received != null && _currentWorkFile.files_received!.isNotEmpty) {
      try {
        final decoded = jsonDecode(_currentWorkFile.files_received!);
        if (decoded is List) {
          files = decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        debugPrint("Error parsing files JSON: $e");
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentWorkFile.name ?? 'Work File Details', 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      if (_currentWorkFile.register_no != null && _currentWorkFile.register_no!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('File No: ${_currentWorkFile.register_no}', style: TextStyle(color: Colors.amber.shade700, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Type: ${_currentWorkFile.work_type != null && _currentWorkFile.work_type!.trim().isNotEmpty ? _currentWorkFile.work_type : "N/A"}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(width: 16),
                          Text('Status: ${_currentWorkFile.stage ?? "Unknown"}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Client: ${_currentWorkFile.client_name ?? "Unknown"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Created By: ${_currentWorkFile.referred_by ?? "Unknown"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            
            Builder(
              builder: (context) {
                amplify_models.Deals? parentWorkFile;
                if (_currentWorkFile.contact_status != null && _currentWorkFile.contact_status!.isNotEmpty) {
                  try {
                    parentWorkFile = widget.allWorkFiles.firstWhere((w) => w.id == _currentWorkFile.contact_status);
                  } catch (_) {}
                }
                
                if (parentWorkFile != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text('Main File: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => WorkFileDetailDialog(
                                workFile: parentWorkFile!,
                                allWorkFiles: widget.allWorkFiles,
                                onUpdate: widget.onUpdate,
                              ),
                            );
                          },
                          child: Text(
                            parentWorkFile.name ?? 'Unknown',
                            style: const TextStyle(color: Colors.blue, fontSize: 14, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Handled By: ${_currentWorkFile.responsible_name ?? "Unassigned"}', style: TextStyle(color: Colors.grey.shade800, fontSize: 15, fontWeight: FontWeight.w500)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _showHistoryDialog,
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('History'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _handoverWorkFile,
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('Handover'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sub Works', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _addSubWork,
                  icon: const Icon(Icons.add_link, size: 18),
                  label: const Text('Add Sub Work'),
                ),
              ],
            ),
            if (_subWorks.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                constraints: const BoxConstraints(maxHeight: 150),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _subWorks.length,
                  itemBuilder: (context, index) {
                    final sw = _subWorks[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.subdirectory_arrow_right, color: Colors.blue),
                      title: Text(sw.name ?? 'Untitled'),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                border: Border.all(color: Colors.green.shade200),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                sw.stage ?? 'Unknown',
                                style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Handled By: ${sw.responsible_name ?? "Unassigned"}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                        onPressed: () async {
                          setState(() => _isUploading = true);
                          try {
                            final updatedWF = sw.copyWith(contact_status: '');
                            await BackupAwareApi().update(updatedWF);
                            setState(() {
                              _subWorks.removeWhere((w) => w.id == sw.id);
                            });
                            widget.onUpdate();
                          } catch (e) {
                            debugPrint('Error removing sub work: $e');
                          } finally {
                            if (mounted) setState(() => _isUploading = false);
                          }
                        },
                        tooltip: 'Remove Sub Work',
                      ),
                    );
                  },
                ),
              ),
              
            const Divider(height: 24),

            if (_currentWorkFile.drive_link != null && _currentWorkFile.drive_link!.isNotEmpty) ...[
              const Text('Google Docs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: const Text('Open connected Google Doc'),
                subtitle: Text(_currentWorkFile.drive_link!, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl(_currentWorkFile.drive_link!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
              ),
              const SizedBox(height: 24),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Connected Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (_isUploading)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  TextButton.icon(
                    onPressed: _selectFromVault,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Add File'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (files.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: Text('No files attached to this work.', style: TextStyle(color: Colors.grey.shade500))),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final path = files[index];
                    final fileName = path.split('/').last;
                    final isPersonal = path.contains('/personal/');
                    final category = isPersonal ? 'Personal' : 'Work';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(isPersonal ? Icons.person : Icons.work, color: AppTheme.primaryColor),
                        title: Text(fileName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text(category, style: TextStyle(fontSize: 12, color: isPersonal ? Colors.blue.shade700 : Colors.green.shade700)),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_rounded),
                          onPressed: () => _downloadFile(context, path),
                          tooltip: 'Open / Download',
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
