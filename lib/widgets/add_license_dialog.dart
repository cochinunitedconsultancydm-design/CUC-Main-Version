import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AddLicenseDialog extends StatefulWidget {
  const AddLicenseDialog({super.key});

  @override
  State<AddLicenseDialog> createState() => _AddLicenseDialogState();
}

class _AddLicenseDialogState extends State<AddLicenseDialog> {
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<Clients> _clients = [];
  List<LicenseTypes> _licenseTypes = [];

  static const Map<int, String> _fallbackLicenseTypes = {
    2: 'Rent',
    4: 'FSSAI',
    5: 'Labour Registration',
    6: 'Insurance',
    7: 'Corporation License',
    8: 'PCC',
    9: 'Driving License',
    10: 'Passport',
    11: 'Health Card of Employees',
    12: 'DSC',
  };

  dynamic _selectedClientId;
  dynamic _selectedTypeId;
  final _manualClientController = TextEditingController();
  final _fileNoController = TextEditingController();
  DateTime? _expiryDate;
  File? _selectedFile;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final cReq = ModelQueries.list(Clients.classType);
      final cRes = await Amplify.API.query(request: cReq).response;
      var cList = cRes.data?.items.whereType<Clients>().toList() ?? [];
      cList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

      final lReq = ModelQueries.list(LicenseTypes.classType);
      final lRes = await Amplify.API.query(request: lReq).response;
      var lList = lRes.data?.items.whereType<LicenseTypes>().toList() ?? [];
      lList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

      if (mounted) {
        setState(() {
          _clients = cList;
          _licenseTypes = lList;
          
          if (_licenseTypes.isEmpty) {
            _licenseTypes = _fallbackLicenseTypes.entries.map((e) => LicenseTypes(id: e.key.toString(), name: e.value)).toList();
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      _showSnack('Error selecting file: $e', isError: true);
    }
  }

  Future<void> _submit() async {
    if (_selectedTypeId == null) {
      _showSnack('Please select a license type', isError: true);
      return;
    }

    if (_selectedClientId == null && _manualClientController.text.trim().isEmpty) {
      _showSnack('Please select a client or enter a manual name', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final license = ClientLicenses(
        client_id: int.tryParse(_selectedClientId?.toString() ?? ''),
        manual_client_name: _selectedClientId == null ? _manualClientController.text.trim() : null,
        license_type_id: int.tryParse(_selectedTypeId?.toString() ?? ''),
        file_no: _fileNoController.text.trim(),
        expiry_date: _expiryDate?.toIso8601String(),
        status: 'Active',
      );

      await BackupAwareApi().create(license);

      if (_selectedFile != null && _selectedClientId != null) {
        final matchedClient = _clients.firstWhere((c) => c.id == _selectedClientId.toString(), orElse: () => Clients(name: _manualClientController.text));
        final typeName = _licenseTypes.firstWhere((t) => t.id == _selectedTypeId.toString(), orElse: () => LicenseTypes(name: 'License')).name;
        
        final docName = '[License] - $typeName - ${_fileNoController.text.trim()}';
        final path = 'public/$_selectedClientId/work/$_selectedFileName';
        
        await Amplify.Storage.uploadFile(
          localFile: AWSFile.fromPath(_selectedFile!.path),
          path: StoragePath.fromString(path),
        ).result;
        
        final doc = ClientDocuments(
          client_id: _selectedClientId.toString(),
          client_name: matchedClient.name,
          document_name: docName,
          storage_path: path,
          created_at: DateTime.now().toIso8601String(),
        );
        await BackupAwareApi().create(doc);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error adding license: $e', isError: true);
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: AppTheme.primaryColor.withValues(alpha: 0.7), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC), // Slate 50
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        width: 450,
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B), // Slate 800
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield_rounded, color: AppTheme.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add New License', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Register a new license to the system', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),

            // Form Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LICENSE DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<dynamic>(
                      initialValue: _selectedTypeId,
                      isExpanded: true,
                      decoration: _inputDecoration('Select License Type', Icons.category_rounded),
                      icon: const Icon(Icons.expand_more_rounded, color: Colors.grey),
                      items: _licenseTypes.map((type) {
                        return DropdownMenuItem<dynamic>(
                          value: type.id,
                          child: Text(type.name ?? 'Unknown', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedTypeId = val),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text('CLIENT ASSIGNMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<dynamic>(
                      initialValue: _selectedClientId,
                      isExpanded: true,
                      decoration: _inputDecoration('Select Registered Client', Icons.business_rounded),
                      icon: const Icon(Icons.expand_more_rounded, color: Colors.grey),
                      items: [
                        const DropdownMenuItem<dynamic>(value: null, child: Text('-- No Registered Client (Manual Entry) --', overflow: TextOverflow.ellipsis, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
                        ..._clients.map((client) {
                          return DropdownMenuItem<dynamic>(
                            value: client.id,
                            child: Text(client.name ?? 'Unknown', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                          );
                        }),
                      ],
                      onChanged: (val) => setState(() {
                        _selectedClientId = val;
                        if (val != null) _manualClientController.clear();
                      }),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_selectedClientId == null) ...[
                      TextField(
                        controller: _manualClientController,
                        decoration: _inputDecoration('Manual Client Name', Icons.person_add_alt_1_rounded),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Text('REGISTRATION INFO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _fileNoController,
                      decoration: _inputDecoration('File Number / ID', Icons.tag_rounded),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event_busy_rounded, color: AppTheme.primaryColor.withValues(alpha: 0.7), size: 20),
                                const SizedBox(width: 16),
                                Text(
                                  _expiryDate == null ? 'Select Expiry Date' : DateFormat('dd MMM yyyy').format(_expiryDate!),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _expiryDate == null ? FontWeight.normal : FontWeight.w500,
                                    color: _expiryDate == null ? Colors.grey.shade500 : AppTheme.textColor,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.edit_calendar_rounded, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_selectedClientId != null) ...[
                      const Text('ATTACHMENTS (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.upload_file_rounded, color: AppTheme.primaryColor.withValues(alpha: 0.7), size: 20),
                                  const SizedBox(width: 16),
                                  Text(
                                    _selectedFileName ?? 'Upload License Document',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: _selectedFileName == null ? FontWeight.normal : FontWeight.w500,
                                      color: _selectedFileName == null ? Colors.grey.shade500 : AppTheme.textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              if (_selectedFileName != null)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                                  onPressed: () => setState(() { _selectedFile = null; _selectedFileName = null; }),
                                )
                              else
                                const Icon(Icons.attach_file_rounded, size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      foregroundColor: Colors.grey.shade700,
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Create License', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
