import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../models/client.dart';
import '../services/logging_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Uploads bytes to Supabase Storage in a fresh isolate.
/// This bypasses the global HTTP state corruption caused by Supabase.initialize().
Future<void> _isolateUploadBytes({
  required String supabaseUrl,
  required String serviceRoleKey,
  required String storagePath,
  required List<int> bytes,
  required String contentType,
}) async {
  await Isolate.run(() async {
    final httpClient = HttpClient();
    final url = Uri.parse('$supabaseUrl/storage/v1/object/client-files/$storagePath');
    final request = await httpClient.postUrl(url);
    request.headers.set('Authorization', 'Bearer $serviceRoleKey');
    request.headers.set('apikey', serviceRoleKey);
    request.headers.set('x-upsert', 'true');
    request.headers.contentType = ContentType.parse(contentType);
    request.add(bytes);
    final response = await request.close();
    if (response.statusCode >= 400) {
      final body = await response.transform(SystemEncoding().decoder).join();
      throw Exception('HTTP ${response.statusCode}: $body');
    }
    httpClient.close();
  });
}

class ClientFilesDialog extends StatefulWidget {
  final Client client;

  const ClientFilesDialog({super.key, required this.client});

  @override
  State<ClientFilesDialog> createState() => _ClientFilesDialogState();
}

class _ClientFilesDialogState extends State<ClientFilesDialog> {
  static const _supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
  static const _serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTc5MzEzMiwiZXhwIjoyMDgxMzY5MTMyfQ.w15N2FZ8xHeDBDcwj79Kl-JBXi1h0QnB9UDNRbAhVZ4';

  late final SupabaseClient _serviceClient;
  late final StorageFileApi _storage;
  bool _isLoading = true;
  List<FileObject> _personalFiles = [];
  List<FileObject> _workItems = [];
  String? _currentWorkFolder;
  String _currentTab = 'personal'; // 'personal' or 'work'

  @override
  void initState() {
    super.initState();
    _serviceClient = SupabaseClient(_supabaseUrl, _serviceRoleKey);
    _storage = _serviceClient.storage.from('client-files');
    _loadFiles();
  }

  @override
  void dispose() {
    _serviceClient.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final pFiles = await _storage.list(path: '${widget.client.id}/personal');
      
      final workPath = _currentWorkFolder == null 
          ? '${widget.client.id}/work' 
          : '${widget.client.id}/work/$_currentWorkFolder';
          
      final wFiles = await _storage.list(path: workPath);
      
      if (!mounted) return;
      setState(() {
        _personalFiles = pFiles.where((f) => f.name != '.emptyPlaceholder').toList();
        _workItems = wFiles.where((f) => f.name != '.emptyPlaceholder').toList();
      });
    } catch (e) {
      debugPrint("Load files error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createFolder() async {
    final folder = await _showWorkPrefixDialog();
    if (folder == null || folder.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final path = '${widget.client.id}/work/${folder.replaceAll('/', '_')}/.emptyPlaceholder';
      
      // Upload in a fresh isolate to bypass Supabase.initialize() HTTP corruption
      await _isolateUploadBytes(
        supabaseUrl: _supabaseUrl,
        serviceRoleKey: _serviceRoleKey,
        storagePath: path,
        bytes: 'folder_placeholder'.codeUnits,
        contentType: 'text/plain',
      );
      
      await _logUpload('work', 'Folder Created: $folder');
      await _loadFiles();
    } catch (e) {
      debugPrint('Create folder error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create folder: $e'), backgroundColor: Colors.redAccent));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadFile(String category) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        String fileName = result.files.single.name;
        
        // Show dialog to collect og_copy and remarks
        final details = await _showUploadDetailsDialog(fileName);
        if (details == null) return; // User cancelled
        
        setState(() => _isLoading = true);
        
        String path;
        if (category == 'work') {
          if (_currentWorkFolder == null) {
            setState(() => _isLoading = false);
            return; 
          }
          path = '${widget.client.id}/work/$_currentWorkFolder/$fileName';
        } else {
          path = '${widget.client.id}/$category/$fileName';
        }
        
        // Read file bytes and upload in a fresh isolate
        final fileBytes = await File(filePath).readAsBytes();
        final ext = fileName.split('.').last.toLowerCase();
        final contentType = {
          'pdf': 'application/pdf',
          'jpg': 'image/jpeg', 'jpeg': 'image/jpeg',
          'png': 'image/png',
          'doc': 'application/msword',
          'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'xls': 'application/vnd.ms-excel',
          'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        }[ext] ?? 'application/octet-stream';
        
        await _isolateUploadBytes(
          supabaseUrl: _supabaseUrl,
          serviceRoleKey: _serviceRoleKey,
          storagePath: path,
          bytes: fileBytes,
          contentType: contentType,
        );
        
        // Record in client_documents table
        try {
          await Supabase.instance.client.from('client_documents').insert({
            'client_id': widget.client.id.toString(),
            'client_name': widget.client.name,
            'document_name': fileName,
            'storage_path': path,
            'og_copy': details['og_copy'],
            'remarks': details['remarks'],
          });
        } catch (dbError) {
          debugPrint('Failed to log document to DB: $dbError');
        }
        
        await _logUpload(category, fileName);
        await _loadFiles();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logUpload(String category, String fileName) async {
    await LoggingService().logAction(
      action: 'FILE_UPLOADED',
      targetType: 'Client',
      targetId: widget.client.name,
      details: 'Uploaded $category file: $fileName',
    );
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File uploaded successfully!'), backgroundColor: Colors.green));
  }

  Future<String?> _showWorkPrefixDialog() async {
    String? prefix;
    await showDialog(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text("Create Work Folder"),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: "e.g. GST Return Q1",
              helperText: "A new folder will be created for this work",
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                prefix = ctrl.text;
                Navigator.pop(context);
              },
              child: const Text("Create Folder"),
            ),
          ],
        );
      }
    );
    return prefix;
  }

  Future<Map<String, String>?> _showUploadDetailsDialog(String fileName) async {
    String selectedOgCopy = 'Copy';
    final remarksController = TextEditingController();
    
    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('File Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('File: $fileName', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Document Type', style: TextStyle(fontWeight: FontWeight.w500)),
                  DropdownButton<String>(
                    value: selectedOgCopy,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Original', child: Text('Original')),
                      DropdownMenuItem(value: 'Copy', child: Text('Copy')),
                      DropdownMenuItem(value: 'NA', child: Text('NA')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedOgCopy = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Remarks', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextField(
                    controller: remarksController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Needs verification, File OK',
                      isDense: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context, {
                      'og_copy': selectedOgCopy,
                      'remarks': remarksController.text.trim().isEmpty ? 'File OK' : remarksController.text.trim(),
                    });
                  },
                  child: const Text('Upload'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _deleteFile(String category, String fileName, {bool isFolder = false}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFolder ? 'Delete Folder' : 'Delete File'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        if (isFolder) {
          // Supabase storage folder deletion requires deleting all files inside it.
          // For simplicity, we assume folder is empty or user is deleting the files manually first.
          // Wait, if we want to delete a folder, we must list its files and delete them.
          final files = await _storage.list(path: '${widget.client.id}/work/$fileName');
          List<String> paths = files.map((f) => '${widget.client.id}/work/$fileName/${f.name}').toList();
          if (paths.isNotEmpty) {
             await _storage.remove(paths);
          }
        } else {
          String pathToDelete = category == 'work' && _currentWorkFolder != null 
              ? '${widget.client.id}/work/$_currentWorkFolder/$fileName'
              : '${widget.client.id}/$category/$fileName';
          await _storage.remove([pathToDelete]);
        }
        await _loadFiles();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.redAccent));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadFile(String category, String fileName) async {
    try {
      String pathToDownload = category == 'work' && _currentWorkFolder != null 
          ? '${widget.client.id}/work/$_currentWorkFolder/$fileName'
          : '${widget.client.id}/$category/$fileName';
      final url = await _storage.createSignedUrl(pathToDownload, 60 * 60);
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open file: $e'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 750),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 32, offset: Offset(0, 16))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Sidebar Navigation
              Container(
                width: 260,
                color: const Color(0xFFF8FAFC),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.folder_special, color: AppTheme.primaryColor, size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: Text('Files Vault', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(widget.client.name, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _buildNavItem('Personal Details', Icons.person_outline, 'personal'),
                    _buildNavItem('Work Folders', Icons.work_outline, 'work'),
                  ],
                ),
              ),
              // Vertical Divider
              Container(width: 1, color: Colors.grey.shade200),
              // Main Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        children: [
                          if (_currentTab == 'work' && _currentWorkFolder != null) ...[
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black87),
                              onPressed: () {
                                setState(() => _currentWorkFolder = null);
                                _loadFiles();
                              },
                              style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Text(
                              _currentTab == 'personal' ? 'Personal Files' 
                              : _currentWorkFolder == null ? 'Work Folders' 
                              : _currentWorkFolder!,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_currentTab == 'work' && _currentWorkFolder == null) {
                                _createFolder();
                              } else {
                                _uploadFile(_currentTab);
                              }
                            },
                            icon: Icon(_currentTab == 'work' && _currentWorkFolder == null ? Icons.create_new_folder : Icons.cloud_upload_outlined, size: 18),
                            label: Text(_currentTab == 'work' && _currentWorkFolder == null ? 'New Folder' : 'Upload File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black54),
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                          ),
                        ],
                      ),
                    ),
                    // Content Grid/List
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: _isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : _currentTab == 'personal' 
                              ? _buildFileList(_personalFiles, 'personal') 
                              : _buildFileList(_workItems, 'work'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).scaleXY(begin: 0.98, end: 1.0, curve: Curves.easeOutQuart),
    );
  }

  Widget _buildNavItem(String title, IconData icon, String tab) {
    final isSelected = _currentTab == tab;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentTab = tab;
            _currentWorkFolder = null;
          });
          _loadFiles();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600, size: 20),
              const SizedBox(width: 12),
              Text(
                title, 
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700, 
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileList(List<FileObject> files, String category) {
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: Icon(Icons.snippet_folder_outlined, size: 64, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            Text(
              category == 'work' && _currentWorkFolder == null ? "No work folders created yet." : "No files uploaded here yet.", 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 8),
            Text(
              "Click the button above to add one.", 
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.1),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isFolder = category == 'work' && _currentWorkFolder == null && (file.id == null || file.metadata == null);

        if (isFolder) {
          return Card(
            elevation: 0,
            color: Colors.amber.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.shade200)),
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() => _currentWorkFolder = file.name);
                _loadFiles();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.folder, color: Colors.amber.shade800),
                  ),
                  title: Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  trailing: Icon(Icons.chevron_right, color: Colors.amber.shade700),
                ),
              ),
            ),
          ).animate().fadeIn(delay: (30 * index).ms).slideY(begin: 0.1);
        }

        // File Item
        IconData icon = Icons.insert_drive_file;
        Color iconColor = Colors.blueGrey;
        if (file.name.toLowerCase().endsWith('.pdf')) {
          icon = Icons.picture_as_pdf;
          iconColor = Colors.redAccent;
        } else if (file.name.toLowerCase().endsWith('.jpg') || file.name.toLowerCase().endsWith('.png')) {
          icon = Icons.image;
          iconColor = Colors.purpleAccent;
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor),
              ),
              title: Text(file.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${(file.metadata?['size'] ?? 0) ~/ 1024} KB', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.blueGrey, size: 20),
                    onPressed: () => _downloadFile(category, file.name),
                    tooltip: "Download File",
                    style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _deleteFile(category, file.name),
                    tooltip: "Delete File",
                    style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (30 * index).ms).slideY(begin: 0.1);
      },
    );
  }
}
