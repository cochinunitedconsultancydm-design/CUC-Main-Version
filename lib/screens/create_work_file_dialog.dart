import 'package:flutter/material.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import '../models/ModelProvider.dart' as amplify_models;
import '../models/client.dart';
import '../theme.dart';
import '../widgets/google_docs_picker_dialog.dart';

class CreateWorkFileDialog extends StatefulWidget {
  final VoidCallback onSaved;
  const CreateWorkFileDialog({super.key, required this.onSaved});

  @override
  State<CreateWorkFileDialog> createState() => _CreateWorkFileDialogState();
}

class _CreateWorkFileDialogState extends State<CreateWorkFileDialog> {
  final _googleDocsController = TextEditingController();
  final _workNameController = TextEditingController();
  final _fileNoController = TextEditingController();
  
  bool _isLoading = false;
  List<Client> _clients = [];
  Client? _selectedClient;
  
  List<StorageItem> _clientFiles = [];
  Set<String> _selectedFiles = {};
  bool _isLoadingFiles = false;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  @override
  void dispose() {
    _googleDocsController.dispose();
    _workNameController.dispose();
    _fileNoController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.Clients.classType, limit: 1000);
      final res = await Amplify.API.query(request: req).response;
      if (res.data != null) {
        final List<Client> fetched = res.data!.items
            .whereType<amplify_models.Clients>()
            .map((m) => Client(
              id: m.id,
              name: m.name ?? '',
              phone: m.phone,
            ))
            .toList();
        fetched.sort((a, b) => a.name.compareTo(b.name));
        if (mounted) setState(() => _clients = fetched);
      }
    } catch (e) {
      debugPrint('Error fetching clients: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClientFiles(Client client) async {
    setState(() {
      _isLoadingFiles = true;
      _clientFiles = [];
      _selectedFiles.clear();
    });
    
    try {
      // Fetch both personal and work files
      final pFilesRes = await Amplify.Storage.list(
        path: StoragePath.fromString('public/${client.id}/personal/'),
      ).result;
      
      final wFilesRes = await Amplify.Storage.list(
        path: StoragePath.fromString('public/${client.id}/work/'),
      ).result;
      
      if (!mounted) return;
      setState(() {
        _clientFiles.addAll(pFilesRes.items.where((f) => !f.path.contains('.emptyPlaceholder')));
        _clientFiles.addAll(wFilesRes.items.where((f) => !f.path.contains('.emptyPlaceholder')));
      });
    } catch (e) {
      debugPrint("Load files error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingFiles = false);
    }
  }

  Future<void> _saveWorkFile() async {
    if (_selectedClient == null || _workNameController.text.trim().isEmpty || _fileNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a client, enter a work name, and provide a File No.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final filesJson = jsonEncode(_selectedFiles.toList());
      
      final newDeal = amplify_models.Deals(
        name: _workNameController.text.trim(),
        client_name: _selectedClient!.name,
        company: _selectedClient!.id.toString(), // Using company field to store Client ID safely
        pipeline: 'Work File',
        stage: 'Active',
        drive_link: _googleDocsController.text.trim(),
        register_no: _fileNoController.text.trim(),
        files_received: filesJson,
        created_at: DateTime.now().toIso8601String(),
        updated_at: DateTime.now().toIso8601String(),
      );

      final req = ModelMutations.create(newDeal);
      await Amplify.API.mutate(request: req).response;

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving work file: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.create_new_folder_rounded, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Text('Create New Work File', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _workNameController,
                decoration: InputDecoration(
                  labelText: 'Work File Name (e.g. Annual Audit 2026)',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              Autocomplete<Client>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _clients.take(10);
                  }
                  return _clients.where((Client client) {
                    final label = '${client.name} ${client.phone}'.toLowerCase();
                    return label.contains(textEditingValue.text.toLowerCase());
                  }).take(10);
                },
                displayStringForOption: (Client option) => '${option.name} ${option.phone != null ? '(${option.phone})' : ''}',
                onSelected: (Client selection) {
                  setState(() => _selectedClient = selection);
                  _loadClientFiles(selection);
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  if (_selectedClient != null && textEditingController.text.isEmpty) {
                    textEditingController.text = '${_selectedClient!.name} ${_selectedClient!.phone != null ? '(${_selectedClient!.phone})' : ''}';
                  }
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Select Client (Type to search)',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                      suffixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    ),
                  );
                },
                optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Client> onSelected, Iterable<Client> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: Colors.white,
                      child: Container(
                        width: 450,
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Client option = options.elementAt(index);
                            return ListTile(
                              title: Text('${option.name} ${option.phone != null ? '(${option.phone})' : ''}', style: const TextStyle(fontWeight: FontWeight.w500)),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _fileNoController,
                      decoration: InputDecoration(
                        labelText: 'File No',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    if (_selectedClient != null) ...[
                      const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text('Select Needed Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                      ),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isLoadingFiles
                          ? const Center(child: CircularProgressIndicator())
                          : _clientFiles.isEmpty
                            ? Center(child: Text('No files found for this client.', style: TextStyle(color: Colors.grey.shade500)))
                            : ListView.builder(
                                itemCount: _clientFiles.length,
                                itemBuilder: (context, index) {
                                  final file = _clientFiles[index];
                                  final isPersonal = file.path.contains('/personal/');
                                  final category = isPersonal ? 'Personal' : 'Work';
                                  final fileName = file.path.split('/').last;
                                  final isSelected = _selectedFiles.contains(file.path);
                                  
                                  return CheckboxListTile(
                                    title: Text(fileName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    subtitle: Text(category, style: TextStyle(fontSize: 11, color: isPersonal ? Colors.blue.shade700 : Colors.green.shade700)),
                                    value: isSelected,
                                    activeColor: AppTheme.primaryColor,
                                    checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedFiles.add(file.path);
                                        } else {
                                          _selectedFiles.remove(file.path);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _googleDocsController,
                            decoration: InputDecoration(
                              labelText: 'Connected Google Docs Link',
                              hintText: 'Paste or pick Google Docs URL',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                              prefixIcon: const Icon(Icons.link_rounded, color: AppTheme.primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            tooltip: 'Browse Google Docs',
                            icon: const Icon(Icons.add_to_drive, color: Colors.blue),
                            onPressed: () async {
                              final String? link = await showDialog<String>(
                                context: context,
                                builder: (context) => GoogleDocsPickerDialog(
                                  initialFileName: _workNameController.text.isNotEmpty ? _workNameController.text : null,
                                ),
                              );
                              if (link != null && link.isNotEmpty) {
                                setState(() {
                                  _googleDocsController.text = link;
                                });
                              }
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
              TextButton(
                onPressed: () => Navigator.pop(context), 
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), foregroundColor: Colors.grey.shade700),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveWorkFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Work File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          );
        }
      }
