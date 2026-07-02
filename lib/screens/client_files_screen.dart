import 'package:flutter/material.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
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
      final req = ModelQueries.list(amplify_models.Deals.classType, where: amplify_models.Deals.PIPELINE.eq('Work File'));
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
                            return Card(
                              elevation: 2,
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
                                        ],
                                      ),
                                      if ((workFile.register_no != null && workFile.register_no!.isNotEmpty) || (workFile.work_type != null && workFile.work_type!.isNotEmpty)) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
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
                                            if (workFile.work_type != null && workFile.work_type!.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '${workFile.work_type}',
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
  final VoidCallback onUpdate;
  
  const WorkFileDetailDialog({super.key, required this.workFile, required this.onUpdate});

  @override
  State<WorkFileDetailDialog> createState() => _WorkFileDetailDialogState();
}

class _WorkFileDetailDialogState extends State<WorkFileDetailDialog> {
  late amplify_models.Deals _currentWorkFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _currentWorkFile = widget.workFile;
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
      final req = ModelQueries.list(amplify_models.Clients.classType, where: amplify_models.Clients.ID.eq(clientId));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final dbClient = res.data!.items.first as amplify_models.Clients;
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
      await Amplify.API.mutate(request: req).response;

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
                      if (_currentWorkFile.work_type != null && _currentWorkFile.work_type!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Type: ${_currentWorkFile.work_type}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Client: ${_currentWorkFile.client_name ?? "Unknown"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
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
