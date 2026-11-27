import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../models/dsc_record.dart';
import '../services/logging_service.dart';
import '../services/excel_service.dart';
import '../services/client_service.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import 'package:cuc_app/services/backup_aware_api.dart';
import '../services/auth_service.dart';

class DscManagementScreen extends StatefulWidget {
  const DscManagementScreen({super.key});

  @override
  State<DscManagementScreen> createState() => _DscManagementScreenState();
}

class _DscManagementScreenState extends State<DscManagementScreen> {
  final _excel = ExcelService();
  final _clientService = ClientService();
  List<DscRecord> _records = [];
  List<Map<String, dynamic>> _clientsList = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String _searchTerm = '';
  String _statusFilter = 'All'; // All, Active, Expiring, Expired

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
    _fetchRecords();
    _fetchClients();
  }

  Future<void> _checkAdminRole() async {
    final isAdmin = await AuthService().isAdmin();
    if (mounted) setState(() => _isAdmin = isAdmin);
  }

  Future<void> _fetchClients() async {
    try {
      final clients = await _clientService.getAllClients();
      if (mounted) {
        setState(() => _clientsList = clients);
      }
    } catch (_) {}
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.DscRecords.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      final recordsList = (res.data?.items ?? []).whereType<amplify_models.DscRecords>().toList();
      recordsList.sort((a, b) => (a.dsc_expiry_date ?? '').compareTo(b.dsc_expiry_date ?? ''));

      setState(() {
        _records = recordsList.map((row) => DscRecord(
          id: int.tryParse(row.id),
          clientName: row.client_name,
          emailId: row.email_id,
          phoneNo: row.phone_no,
          username: row.username,
          password: row.password,
          dscTakenDate: row.dsc_taken_date != null ? DateTime.tryParse(row.dsc_taken_date!) : null,
          dscExpiryDate: row.dsc_expiry_date != null ? DateTime.tryParse(row.dsc_expiry_date!) : null,
        )).toList();
      });
    } catch (e) {
      _showError('Failed to fetch Digital Signature records: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(int id) async {
    if (!_isAdmin) {
      _showError('Permission Denied: Only Admin can delete DSC records');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Confirm Delete'),
          ],
        ),
        content: const Text('Are you sure you want to delete this Digital Signature record? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await BackupAwareApi().deleteById(
          amplify_models.DscRecords.classType,
          amplify_models.DscRecordsModelIdentifier(id: id.toString()),
        );
        _fetchRecords();
        _showSuccess('Digital Signature deleted');
      } catch (e) {
        _showError('Delete failed: $e');
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final path = await _excel.exportDsc(_records);
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

  // ==========================================
  // CONNECT CLIENT & COMMUNICATION HELPERS
  // ==========================================
  Future<void> _launchWhatsApp(String phone, String clientName, DateTime? expiryDate) async {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 10) clean = '91$clean';
    final expiryStr = expiryDate != null ? DateFormat('dd MMM yyyy').format(expiryDate) : 'N/A';
    final msg = Uri.encodeComponent(
      'Hello $clientName,\n\n'
      'This is Cochin United Consultancy regarding your Digital Signature Certificate (DSC).\n'
      'Expiry Date: $expiryStr\n\n'
      'Please let us know if you need assistance or renewal support.\n\n'
      'Best regards,\nCochin United Consultancy',
    );
    try {
      final url = Uri.parse('https://wa.me/$clean?text=$msg');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      _showError('Could not launch WhatsApp');
    }
  }

  Future<void> _launchCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    try {
      await launchUrl(Uri.parse('tel:$clean'));
    } catch (_) {
      _showError('Could not launch phone dialer');
    }
  }

  Future<void> _launchEmail(String email, String clientName, DateTime? expiryDate) async {
    final expiryStr = expiryDate != null ? DateFormat('dd MMM yyyy').format(expiryDate) : 'N/A';
    final subject = Uri.encodeComponent('Digital Signature (DSC) Update - $clientName');
    final body = Uri.encodeComponent(
      'Dear $clientName,\n\n'
      'This is Cochin United Consultancy regarding your Digital Signature (DSC) certificate.\n'
      'Validity Expiry Date: $expiryStr\n\n'
      'Please reach out to us if you need any assistance or renewal.\n\n'
      'Best regards,\nCochin United Consultancy\n+91 70124 66754\ncochinunitedconsultancydm@gmail.com',
    );
    try {
      await launchUrl(Uri.parse('mailto:$email?subject=$subject&body=$body'));
    } catch (_) {
      _showError('Could not launch email client');
    }
  }

  void _showConnectClientDialog(Function(Map<String, dynamic> client) onClientSelected) {
    String searchQuery = '';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredClients = _clientsList.where((c) {
            final q = searchQuery.toLowerCase().trim();
            if (q.isEmpty) return true;
            final name = (c['name'] ?? '').toString().toLowerCase();
            final phone = (c['phone'] ?? '').toString().toLowerCase();
            final email = (c['email'] ?? '').toString().toLowerCase();
            final company = (c['companies'] ?? '').toString().toLowerCase();
            return name.contains(q) || phone.contains(q) || email.contains(q) || company.contains(q);
          }).toList();

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            elevation: 16,
            child: Container(
              width: 580,
              height: 560,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.link_rounded, color: Color(0xFF2563EB), size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Connect Client', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            SizedBox(height: 2),
                            Text('Select an existing client from your master directory to link details', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    autofocus: true,
                    onChanged: (val) => setDialogState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search by client name, phone, email, or company...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setDialogState(() => searchQuery = ''))
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('${filteredClients.length} clients available', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const Text('Click "Connect" to auto-populate', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filteredClients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_search_rounded, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                const Text('No clients match your search', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredClients.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final c = filteredClients[idx];
                              final name = c['name']?.toString() ?? 'Unnamed';
                              final phone = c['phone']?.toString() ?? '';
                              final email = c['email']?.toString() ?? '';
                              final company = c['companies']?.toString() ?? '';

                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'C',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  ),
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (phone.isNotEmpty || email.isNotEmpty)
                                      Text('$phone${phone.isNotEmpty && email.isNotEmpty ? " • " : ""}$email', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    if (company.isNotEmpty)
                                      Text(company, style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade600, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    onClientSelected(c);
                                  },
                                  icon: const Icon(Icons.link_rounded, size: 14),
                                  label: const Text('Connect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        },
      ),
    );
  }

  // ==========================================
  // ADD / EDIT FORM (REDESIGNED WITH CONNECT CLIENT)
  // ==========================================
  void _showRecordForm([DscRecord? record]) {
    if (record != null && !_isAdmin) {
      _showError('Permission Denied: Only Admin can edit DSC records');
      return;
    }

    final clientNameController = TextEditingController(text: record?.clientName);
    final emailController = TextEditingController(text: record?.emailId);
    final phoneController = TextEditingController(text: record?.phoneNo);
    final usernameController = TextEditingController(text: record?.username);
    final passwordController = TextEditingController(text: record?.password);

    Map<String, dynamic>? connectedClient;
    if (record?.clientName != null) {
      final match = _clientsList.where((c) => (c['name']?.toString().toLowerCase() ?? '') == record!.clientName!.toLowerCase()).firstOrNull;
      if (match != null) connectedClient = match;
    }

    DateTime? takenDate = record?.dscTakenDate ?? DateTime.now();
    DateTime? expiryDate = record?.dscExpiryDate ?? DateTime.now().add(const Duration(days: 730)); // 2 years default
    bool obscurePassword = true;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          int remainingDays = expiryDate != null ? expiryDate!.difference(DateTime.now()).inDays : 0;
          bool isExpired = remainingDays < 0;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            elevation: 16,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 620,
              padding: const EdgeInsets.all(28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.vpn_key_rounded, color: Color(0xFF2563EB), size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record == null ? 'Add Digital Signature (DSC)' : 'Edit Digital Signature',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Record client DSC token details, portal credentials, and validity period',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          icon: const Icon(Icons.close_rounded, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Client Section Header with Connect Client button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CLIENT INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8)),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showConnectClientDialog((selected) {
                              setModalState(() {
                                connectedClient = selected;
                                clientNameController.text = selected['name']?.toString() ?? '';
                                if (selected['phone'] != null && selected['phone'].toString().isNotEmpty) {
                                  phoneController.text = selected['phone'].toString();
                                }
                                if (selected['email'] != null && selected['email'].toString().isNotEmpty) {
                                  emailController.text = selected['email'].toString();
                                }
                              });
                            });
                          },
                          icon: const Icon(Icons.link_rounded, size: 15),
                          label: const Text('Connect Client', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Connected Status Banner
                    if (connectedClient != null || clientNameController.text.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Connected: ${clientNameController.text.trim()}${phoneController.text.isNotEmpty ? " • ${phoneController.text.trim()}" : ""}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setModalState(() {
                                  connectedClient = null;
                                  clientNameController.clear();
                                  phoneController.clear();
                                  emailController.clear();
                                });
                              },
                              child: const Text('Disconnect', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Client Selection / Autocomplete
                    Autocomplete<Map<String, dynamic>>(
                      initialValue: TextEditingValue(text: clientNameController.text),
                      optionsBuilder: (TextEditingValue textVal) {
                        if (textVal.text.trim().isEmpty) {
                          return _clientsList.take(5);
                        }
                        final q = textVal.text.toLowerCase();
                        return _clientsList.where((c) {
                          final name = c['name']?.toString().toLowerCase() ?? '';
                          final phone = c['phone']?.toString().toLowerCase() ?? '';
                          return name.contains(q) || phone.contains(q);
                        });
                      },
                      displayStringForOption: (option) => option['name']?.toString() ?? '',
                      onSelected: (option) {
                        connectedClient = option;
                        clientNameController.text = option['name']?.toString() ?? '';
                        if (option['phone'] != null && option['phone'].toString().isNotEmpty) {
                          phoneController.text = option['phone'].toString();
                        }
                        if (option['email'] != null && option['email'].toString().isNotEmpty) {
                          emailController.text = option['email'].toString();
                        }
                        setModalState(() {});
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        // Keep controller in sync
                        controller.addListener(() {
                          clientNameController.text = controller.text;
                        });

                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            labelText: 'Client Name *',
                            hintText: 'Type client name or click "Connect Client" above',
                            prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF2563EB)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.link_rounded, color: Color(0xFF2563EB)),
                              tooltip: 'Connect Client from Directory',
                              onPressed: () {
                                _showConnectClientDialog((selected) {
                                  setModalState(() {
                                    connectedClient = selected;
                                    controller.text = selected['name']?.toString() ?? '';
                                    clientNameController.text = controller.text;
                                    if (selected['phone'] != null && selected['phone'].toString().isNotEmpty) {
                                      phoneController.text = selected['phone'].toString();
                                    }
                                    if (selected['email'] != null && selected['email'].toString().isNotEmpty) {
                                      emailController.text = selected['email'].toString();
                                    }
                                  });
                                });
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                            isDense: true,
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 560,
                              constraints: const BoxConstraints(maxHeight: 220),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                itemCount: options.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (context, idx) {
                                  final opt = options.elementAt(idx);
                                  return ListTile(
                                    dense: true,
                                    leading: const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Color(0xFFEFF6FF),
                                      child: Icon(Icons.person, size: 16, color: Color(0xFF2563EB)),
                                    ),
                                    title: Text(opt['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    subtitle: Text('${opt['phone'] ?? ''} • ${opt['email'] ?? ''}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    trailing: const Icon(Icons.link_rounded, size: 18, color: Color(0xFF2563EB)),
                                    onTap: () => onSelected(opt),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone and Email Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone No',
                              hintText: 'e.g. 9876543210',
                              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email ID',
                              hintText: 'client@example.com',
                              prefixIcon: const Icon(Icons.email_outlined, size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Quick Connect with Client bar if phone or email exists
                    if (phoneController.text.trim().isNotEmpty || emailController.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Text('Connect Now: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                            if (phoneController.text.trim().isNotEmpty) ...[
                              InkWell(
                                onTap: () => _launchWhatsApp(phoneController.text.trim(), clientNameController.text.trim(), expiryDate),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFF25D366).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Color(0xFF128C7E)),
                                      SizedBox(width: 4),
                                      Text('WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF128C7E))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _launchCall(phoneController.text.trim()),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.phone_outlined, size: 13, color: Color(0xFF2563EB)),
                                      SizedBox(width: 4),
                                      Text('Call', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (emailController.text.trim().isNotEmpty) ...[
                              InkWell(
                                onTap: () => _launchEmail(emailController.text.trim(), clientNameController.text.trim(), expiryDate),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.email_outlined, size: 13, color: Colors.amber.shade900),
                                      const SizedBox(width: 4),
                                      Text('Email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Username & Password Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: 'Portal Username',
                              hintText: 'e.g. GST / MCA Username',
                              prefixIcon: const Icon(Icons.account_circle_outlined, size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password / PIN',
                              hintText: 'Token Password / Portal PIN',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey),
                                onPressed: () => setModalState(() => obscurePassword = !obscurePassword),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Validity Dates Section
                    const Text('VALIDITY PERIOD & DATES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8)),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // Taken Date Card
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: takenDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  takenDate = picked;
                                  // Keep expiry 2 years ahead by default if not modified
                                  if (expiryDate == null || expiryDate!.isBefore(picked)) {
                                    expiryDate = picked.add(const Duration(days: 730));
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF2563EB), size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Taken / Issue Date', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          takenDate != null ? DateFormat('dd/MM/yyyy').format(takenDate!) : 'Not Set',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Expiry Date Card
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: expiryDate ?? (takenDate ?? DateTime.now()).add(const Duration(days: 730)),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setModalState(() => expiryDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isExpired ? Colors.red.shade50.withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isExpired ? Colors.red.shade300 : Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isExpired ? Colors.red.shade100 : Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.event_busy_rounded, color: isExpired ? Colors.red : Colors.amber.shade800, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Expiry Date', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          expiryDate != null ? DateFormat('dd/MM/yyyy').format(expiryDate!) : 'Not Set',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isExpired ? Colors.red.shade800 : Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Quick Expiry Presets
                    Row(
                      children: [
                        const Text('Quick Validity: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        _buildPresetChip('+ 1 Year', () {
                          final base = takenDate ?? DateTime.now();
                          setModalState(() => expiryDate = DateTime(base.year + 1, base.month, base.day));
                        }),
                        const SizedBox(width: 6),
                        _buildPresetChip('+ 2 Years', () {
                          final base = takenDate ?? DateTime.now();
                          setModalState(() => expiryDate = DateTime(base.year + 2, base.month, base.day));
                        }),
                        const SizedBox(width: 6),
                        _buildPresetChip('+ 3 Years', () {
                          final base = takenDate ?? DateTime.now();
                          setModalState(() => expiryDate = DateTime(base.year + 3, base.month, base.day));
                        }),
                        const Spacer(),
                        if (expiryDate != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isExpired ? Colors.red.shade100 : (remainingDays < 30 ? Colors.orange.shade100 : Colors.green.shade100),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isExpired ? 'Expired' : (remainingDays < 30 ? 'Expiring in $remainingDays days' : 'Active ($remainingDays days left)'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isExpired ? Colors.red.shade900 : (remainingDays < 30 ? Colors.orange.shade900 : Colors.green.shade900),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final clientName = clientNameController.text.trim();
                                  if (clientName.isEmpty) {
                                    _showError('Please enter client name');
                                    return;
                                  }

                                  setModalState(() => isSaving = true);
                                  try {
                                    if (record == null) {
                                      final newDsc = amplify_models.DscRecords(
                                        client_name: clientName,
                                        email_id: emailController.text.trim(),
                                        phone_no: phoneController.text.trim(),
                                        username: usernameController.text.trim(),
                                        password: passwordController.text.trim(),
                                        dsc_taken_date: takenDate?.toIso8601String(),
                                        dsc_expiry_date: expiryDate?.toIso8601String(),
                                      );
                                      await BackupAwareApi().create(newDsc);
                                      await LoggingService().logAction(
                                        action: 'SIGNATURE_CREATED',
                                        targetType: 'Signature',
                                        targetId: clientName,
                                        details: 'Added digital signature for $clientName',
                                      );
                                    } else {
                                      final updateDsc = amplify_models.DscRecords(
                                        id: record.id.toString(),
                                        client_name: clientName,
                                        email_id: emailController.text.trim(),
                                        phone_no: phoneController.text.trim(),
                                        username: usernameController.text.trim(),
                                        password: passwordController.text.trim(),
                                        dsc_taken_date: takenDate?.toIso8601String(),
                                        dsc_expiry_date: expiryDate?.toIso8601String(),
                                      );
                                      await BackupAwareApi().update(updateDsc);
                                      await LoggingService().logAction(
                                        action: 'SIGNATURE_UPDATED',
                                        targetType: 'Signature',
                                        targetId: record.id.toString(),
                                        details: 'Updated signature for $clientName',
                                      );
                                    }
                                    if (mounted) Navigator.pop(dialogCtx);
                                    _fetchRecords();
                                    _showSuccess('Digital Signature saved successfully');
                                  } catch (e) {
                                    setModalState(() => isSaving = false);
                                    _showError('Save failed: $e');
                                  }
                                },
                          icon: isSaving
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_rounded, size: 18),
                          label: Text(isSaving ? 'Saving...' : 'Save Signature'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
      ),
    );
  }

  // ==========================================
  // MAIN SCREEN VIEW
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;

        // Apply search & status filter
        final filtered = _records.where((r) {
          final query = _searchTerm.toLowerCase();
          final matchesSearch = (r.clientName?.toLowerCase().contains(query) ?? false) ||
              (r.username?.toLowerCase().contains(query) ?? false) ||
              (r.phoneNo?.toLowerCase().contains(query) ?? false) ||
              (r.emailId?.toLowerCase().contains(query) ?? false);

          if (!matchesSearch) return false;

          final now = DateTime.now();
          final isExpired = r.dscExpiryDate != null && r.dscExpiryDate!.isBefore(now);
          final isExpiringSoon = !isExpired && r.dscExpiryDate != null && r.dscExpiryDate!.isBefore(now.add(const Duration(days: 30)));
          final isActive = !isExpired && !isExpiringSoon;

          if (_statusFilter == 'Active') return isActive;
          if (_statusFilter == 'Expiring Soon') return isExpiringSoon;
          if (_statusFilter == 'Expired') return isExpired;
          return true;
        }).toList();

        // Statistics
        final now = DateTime.now();
        final totalCount = _records.length;
        final expiredCount = _records.where((r) => r.dscExpiryDate != null && r.dscExpiryDate!.isBefore(now)).length;
        final expiringCount = _records.where((r) {
          final exp = r.dscExpiryDate;
          if (exp == null) return false;
          return !exp.isBefore(now) && exp.isBefore(now.add(const Duration(days: 30)));
        }).length;
        final activeCount = totalCount - expiredCount - expiringCount;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 28 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Digital Signature (DSC)',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage client cryptographic USB tokens, portal credentials, and expiry alerts',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _fetchRecords,
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                          tooltip: 'Refresh',
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _exportToExcel,
                          icon: const Icon(Icons.download_rounded, color: Colors.green),
                          tooltip: 'Export to Excel',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        ElevatedButton.icon(
                          onPressed: () => _showRecordForm(),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Add Signature', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Statistics Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - 36) / 4;
                    if (constraints.maxWidth < 700) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatCard('Total DSCs', totalCount.toString(), Icons.vpn_key_rounded, const Color(0xFF2563EB), constraints.maxWidth / 2 - 12),
                          _buildStatCard('Active', activeCount.toString(), Icons.check_circle_rounded, const Color(0xFF16A34A), constraints.maxWidth / 2 - 12),
                          _buildStatCard('Expiring Soon', expiringCount.toString(), Icons.access_time_rounded, const Color(0xFFD97706), constraints.maxWidth / 2 - 12),
                          _buildStatCard('Expired', expiredCount.toString(), Icons.warning_rounded, const Color(0xFFDC2626), constraints.maxWidth / 2 - 12),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: _buildStatCard('Total DSCs', totalCount.toString(), Icons.vpn_key_rounded, const Color(0xFF2563EB), cardWidth)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Active', activeCount.toString(), Icons.check_circle_rounded, const Color(0xFF16A34A), cardWidth)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Expiring (< 30d)', expiringCount.toString(), Icons.access_time_rounded, const Color(0xFFD97706), cardWidth)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Expired', expiredCount.toString(), Icons.warning_rounded, const Color(0xFFDC2626), cardWidth)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),

                // Search Bar and Status Filters
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => _searchTerm = val),
                        decoration: InputDecoration(
                          hintText: 'Search by client name, username, email, or phone...',
                          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                          suffixIcon: _searchTerm.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchTerm = ''))
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _buildFilterChip('All'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Active'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Expiring Soon'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Expired'),
                  ],
                ),
                const SizedBox(height: 20),

                // Results list / cards
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                  )
                else if (filtered.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16)]),
                            child: const Icon(Icons.vpn_key_outlined, size: 54, color: Colors.grey),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _records.isEmpty ? 'No Digital Signatures added yet.' : 'No digital signatures match your search.',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _records.isEmpty ? 'Click "Add Signature" above to register your first client DSC.' : 'Try adjusting the search query or status filters.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildDscCard(filtered[index], isWide),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, double width) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _statusFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _statusFilter = label),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppTheme.primaryColor : Colors.black87,
        fontSize: 13,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200),
      ),
    );
  }

  Widget _buildDscCard(DscRecord r, bool isWide) {
    final now = DateTime.now();
    final bool isExpired = r.dscExpiryDate != null && r.dscExpiryDate!.isBefore(now);
    final bool isExpiringSoon = !isExpired && r.dscExpiryDate != null && r.dscExpiryDate!.isBefore(now.add(const Duration(days: 30)));
    final int daysRemaining = r.dscExpiryDate != null ? r.dscExpiryDate!.difference(now).inDays : 0;

    final Color statusColor = isExpired ? const Color(0xFFDC2626) : (isExpiringSoon ? const Color(0xFFD97706) : const Color(0xFF16A34A));
    final String statusText = isExpired ? 'Expired' : (isExpiringSoon ? 'Expiring in $daysRemaining days' : 'Active');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: EdgeInsets.symmetric(horizontal: isWide ? 22 : 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.vpn_key_rounded, color: statusColor, size: 22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  r.clientName ?? 'Unnamed Client',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (r.phoneNo != null && r.phoneNo!.trim().isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF128C7E), size: 18),
                  tooltip: 'Connect via WhatsApp',
                  onPressed: () => _launchWhatsApp(r.phoneNo!, r.clientName ?? 'Client', r.dscExpiryDate),
                ),
              ],
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                if (r.username != null && r.username!.isNotEmpty) ...[
                  const Icon(Icons.account_circle_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(r.username!, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 14),
                ],
                if (r.dscExpiryDate != null) ...[
                  const Icon(Icons.event_busy_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Expiry: ${DateFormat('dd MMM yyyy').format(r.dscExpiryDate!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(isWide ? 22 : 16, 8, isWide ? 22 : 16, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          'Portal Username',
                          r.username ?? 'N/A',
                          Icons.person_outline,
                          copyable: r.username != null && r.username!.isNotEmpty,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          'Password / PIN',
                          r.password ?? 'N/A',
                          Icons.lock_outline,
                          copyable: r.password != null && r.password!.isNotEmpty,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          'Email Address',
                          r.emailId ?? 'N/A',
                          Icons.email_outlined,
                          copyable: r.emailId != null && r.emailId!.isNotEmpty,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          'Phone Number',
                          r.phoneNo ?? 'N/A',
                          Icons.phone_outlined,
                          copyable: r.phoneNo != null && r.phoneNo!.isNotEmpty,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          'Taken / Issue Date',
                          r.dscTakenDate != null ? DateFormat('dd/MM/yyyy').format(r.dscTakenDate!) : 'N/A',
                          Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          'Expiry Date',
                          r.dscExpiryDate != null ? DateFormat('dd/MM/yyyy').format(r.dscExpiryDate!) : 'N/A',
                          Icons.event_busy_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Connect Client Buttons
                      if (r.phoneNo != null && r.phoneNo!.trim().isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: () => _launchWhatsApp(r.phoneNo!, r.clientName ?? 'Client', r.dscExpiryDate),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Color(0xFF128C7E)),
                          label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF128C7E), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF128C7E)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _launchCall(r.phoneNo!),
                          icon: const Icon(Icons.phone_outlined, size: 15, color: Color(0xFF2563EB)),
                          label: const Text('Call', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2563EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (r.emailId != null && r.emailId!.trim().isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: () => _launchEmail(r.emailId!, r.clientName ?? 'Client', r.dscExpiryDate),
                          icon: Icon(Icons.email_outlined, size: 15, color: Colors.amber.shade900),
                          label: Text('Email', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.amber.shade700),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (_isAdmin) ...[
                        OutlinedButton.icon(
                          onPressed: () => _showRecordForm(r),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFF2563EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _deleteRecord(r.id!),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon, {bool copyable = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (copyable) ...[
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied $label to clipboard'), duration: const Duration(seconds: 1)),
                    );
                  },
                  child: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primaryColor),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
