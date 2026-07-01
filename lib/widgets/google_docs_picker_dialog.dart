import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../services/google_docs_service.dart';
import '../theme.dart';

class GoogleDocsPickerDialog extends StatefulWidget {
  final String? initialFileName;
  
  const GoogleDocsPickerDialog({super.key, this.initialFileName});

  @override
  State<GoogleDocsPickerDialog> createState() => _GoogleDocsPickerDialogState();
}

class _GoogleDocsPickerDialogState extends State<GoogleDocsPickerDialog> {
  bool _isLoading = true;
  bool _isCreating = false;
  List<drive.File> _files = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final authStr = await GoogleDocsService.signIn();
      if (authStr == null) {
        throw Exception('Failed to authenticate with Google.');
      }
      
      final files = await GoogleDocsService.getDriveFiles();
      if (mounted) {
        setState(() {
          _files = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createNewDoc() async {
    setState(() => _isCreating = true);
    try {
      final title = widget.initialFileName ?? 'New Work File Document';
      final link = await GoogleDocsService.createNewDocument(title);
      if (link != null && mounted) {
        Navigator.pop(context, link);
      } else {
        throw Exception('Failed to retrieve new document link.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              const Text('Select Google Doc', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
            ],
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(_error!, style: TextStyle(color: Colors.red.shade700), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchFiles, child: const Text('Retry')),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isCreating ? null : _createNewDoc,
                        icon: _isCreating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add),
                        label: Text(_isCreating ? 'Creating...' : 'Create New Document'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _files.isEmpty
                            ? Center(child: Text('No Google Docs found in your Drive.', style: TextStyle(color: Colors.grey.shade500)))
                            : ListView.builder(
                                itemCount: _files.length,
                                itemBuilder: (context, index) {
                                  final file = _files[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    elevation: 0,
                                    color: Colors.grey.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.description, color: Colors.blue),
                                      title: Text(file.name ?? 'Untitled', maxLines: 1, overflow: TextOverflow.ellipsis),
                                      subtitle: Text(
                                        file.modifiedTime != null ? 'Modified: ${file.modifiedTime!.toLocal().toString().split('.')[0]}' : '',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                      onTap: () {
                                        if (file.webViewLink != null) {
                                          Navigator.pop(context, file.webViewLink);
                                        }
                                      },
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
