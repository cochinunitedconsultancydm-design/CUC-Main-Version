import 'package:amplify_api/amplify_api.dart';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../models/client.dart';
import '../services/logging_service.dart';
import 'package:url_launcher/url_launcher.dart';

// Isolate upload bytes was removed because Amplify Storage handles its own isolate/upload management.

class ClientFilesDialog extends StatefulWidget {
  final Client client;

  const ClientFilesDialog({super.key, required this.client});

  @override
  State<ClientFilesDialog> createState() => _ClientFilesDialogState();
}

class _ClientFilesDialogState extends State<ClientFilesDialog> {
  bool _isLoading = true;
  List<StorageItem> _personalFiles = [];
  List<StorageItem> _workItems = [];
  List<String> _workFolders = [];
  String? _currentWorkFolder;
  String _currentTab = 'personal'; // 'personal' or 'work'
  String _currentTab = 'personal'; // 'personal' or 'work'

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFiles() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final pFilesRes = await Amplify.Storage.list(
        path: StoragePath.fromString('public/${widget.client.id}/personal/'),
      ).result;
      
      final workPath = _currentWorkFolder == null 
          ? 'public/${widget.client.id}/work/' 
          : 'public/${widget.client.id}/work/$_currentWorkFolder/';
          
      final wFilesRes = await Amplify.Storage.list(
        path: StoragePath.fromString(workPath),
      ).result;
      
      if (!mounted) return;
      setState(() {
        _personalFiles = pFilesRes.items.where((f) => !f.path.contains('.emptyPlaceholder')).toList();
        
        if (_currentWorkFolder == null) {
          Set<String> folderNames = {};
          final workPathStr = workPath.toString();
          
          for (var item in wFilesRes.items) {
            String itemPath = item.path;
            
            // Handle cases where path might not contain 'public/' prefix in some Amplify versions
            if (!itemPath.startsWith('public/') && workPathStr.startsWith('public/')) {
               itemPath = 'public/' + itemPath;
            }
            
            if (itemPath.startsWith(workPathStr)) {
              final relativePath = itemPath.substring(workPathStr.length);
              if (relativePath.isNotEmpty) {
                final parts = relativePath.split('/').where((s) => s.isNotEmpty).toList();
                if (parts.isNotEmpty) {
                  folderNames.add(parts[0]);
                }
              }
            } else {
               // Fallback if paths don't match exactly but contain the work directory
               final workDirSegment = '/work/';
               if (itemPath.contains(workDirSegment)) {
                 final afterWork = itemPath.split(workDirSegment).last;
                 final parts = afterWork.split('/').where((s) => s.isNotEmpty).toList();
                 if (parts.isNotEmpty) {
                   folderNames.add(parts[0]);
                 }
               }
            }
          }
          _workFolders = folderNames.toList()..sort();
          _workItems = [];
        } else {
          _workFolders = [];
          _workItems = wFilesRes.items.where((f) => !f.path.contains('.emptyPlaceholder')).toList();
        }
      });
    } catch (e) {
      debugPrint("Load files error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error loading files: $e'), 
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createFolder() async {
    final folder = await _showWorkPrefixDialog();
    if (folder == null || folder.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final path = 'public/${widget.client.id}/work/${folder.replaceAll('/', '_')}/.emptyPlaceholder';
      
      await Amplify.Storage.uploadData(
        data: StorageDataPayload.string('folder_placeholder'),
        path: StoragePath.fromString(path),
      ).result;
      
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
          path = 'public/${widget.client.id}/work/$_currentWorkFolder/$fileName';
        } else {
          path = 'public/${widget.client.id}/$category/$fileName';
        }
        
        // Read file bytes and upload
        final file = File(filePath);
        
        await Amplify.Storage.uploadFile(
          localFile: AWSFile.fromPath(file.path),
          path: StoragePath.fromString(path),
        ).result;
        
        // Record in client_documents table
        try {
          final newDoc = amplify_models.ClientDocuments(
            client_id: widget.client.id.toString(),
            client_name: widget.client.name,
            document_name: fileName,
            storage_path: path,
            og_copy: details['og_copy'],
            remarks: details['remarks'],
          );
          await Amplify.API.mutate(request: ModelMutations.create(newDoc)).response;
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
          final folderPath = 'public/${widget.client.id}/work/$fileName/';
          final filesRes = await Amplify.Storage.list(path: StoragePath.fromString(folderPath)).result;
          for (var f in filesRes.items) {
            await Amplify.Storage.remove(path: StoragePath.fromString(f.path)).result;
          }
        } else {
          String pathToDelete = category == 'work' && _currentWorkFolder != null 
              ? 'public/${widget.client.id}/work/$_currentWorkFolder/$fileName'
              : 'public/${widget.client.id}/$category/$fileName';
          await Amplify.Storage.remove(path: StoragePath.fromString(pathToDelete)).result;
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
          ? 'public/${widget.client.id}/work/$_currentWorkFolder/$fileName'
          : 'public/${widget.client.id}/$category/$fileName';
      final res = await Amplify.Storage.getUrl(path: StoragePath.fromString(pathToDownload)).result;
      if (await canLaunchUrl(res.url)) {
        await launchUrl(res.url);
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

  Widget _buildFileList(List<StorageItem> files, String category) {
    final isWorkFoldersView = category == 'work' && _currentWorkFolder == null;

    if (isWorkFoldersView && _workFolders.isEmpty) {
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
              "No work folders created yet.", 
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
    } else if (!isWorkFoldersView && files.isEmpty) {
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
              "No files uploaded here yet.", 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 8),
            Text(
              "Click the button above to add one.", 
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)
            ),
            const SizedBox(height: 16),
            Text(
              _debugMsg,
              style: const TextStyle(color: Colors.red, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.1),
      );
    }

    int itemCount = isWorkFoldersView ? _workFolders.length : files.length;

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (isWorkFoldersView) {
          final folderName = _workFolders[index];
          return Card(
            elevation: 0,
            color: Colors.amber.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.shade200)),
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() => _currentWorkFolder = folderName);
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
                  title: Text(folderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _deleteFile('work', folderName, isFolder: true),
                        tooltip: "Delete Folder",
                        style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.amber.shade700),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: (30 * index).ms).slideY(begin: 0.1);
        }

        // File Item
        final f = files[index];
        final itemName = f.path.split('/').last;
        IconData icon = Icons.insert_drive_file;
        Color iconColor = Colors.blueGrey;
        if (itemName.toLowerCase().endsWith('.pdf')) {
          icon = Icons.picture_as_pdf;
          iconColor = Colors.redAccent;
        } else if (itemName.toLowerCase().endsWith('.jpg') || itemName.toLowerCase().endsWith('.png')) {
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
              title: Text(itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${(f.size ?? 0) ~/ 1024} KB', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.blueGrey, size: 20),
                    onPressed: () => _downloadFile(category, itemName),
                    tooltip: "Download File",
                    style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _deleteFile(category, itemName),
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
