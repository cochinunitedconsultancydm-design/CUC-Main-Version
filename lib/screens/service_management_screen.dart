import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../models/service_item.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final _client = Supabase.instance.client;
  List<ServiceItem> _services = [];
  bool _isLoading = true;
  bool _isImporting = false;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final result = await _client.from('service_content').select().order('title', ascending: true);
      debugPrint('ServiceMgmt: Fetched ${result.length} rows from service_content');
      final groups = <String, List<Map<String, dynamic>>>{};
      for (var s in result) {
        var t = s['title'].toString().toLowerCase();
        t = t.replaceAll('checklist', '');
        t = t.replaceAll(RegExp(r'\(\d+\)'), '');
        t = t.replaceAll('-', ' ');
        t = t.replaceAll('_', ' ');
        t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
        
        if (!groups.containsKey(t)) {
          groups[t] = [];
        }
        groups[t]!.add(s);
      }

      final List<Map<String, dynamic>> toKeepList = [];
      for (var entry in groups.entries) {
        if (entry.value.length > 1) {
          entry.value.sort((a, b) {
            final aDocs = a['details'] != null && a['details']['document_url'] != null ? 1 : 0;
            final bDocs = b['details'] != null && b['details']['document_url'] != null ? 1 : 0;
            if (aDocs != bDocs) return bDocs.compareTo(aDocs);
            return (a['id'] as int).compareTo(b['id'] as int);
          });
          toKeepList.add(entry.value.first);
        } else {
          toKeepList.add(entry.value.first);
        }
      }

      final List<ServiceItem> parsed = [];
      for (final row in toKeepList) {
        try {
          parsed.add(ServiceItem.fromMap(row));
        } catch (e) {
          debugPrint('ServiceMgmt: Failed to parse row: $e — $row');
        }
      }
      if (mounted) {
        setState(() {
          _services = parsed;
        });
      }
    } catch (e) {
      debugPrint('ServiceMgmt: Query failed: $e');
      _showError('Failed to fetch services: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _importPdfs() async {
    if (!mounted) return;
    setState(() => _isImporting = true);
    try {
      final serviceNamesResult = await _client.from('service_names').select('id').limit(1);
      int validServiceId;
      if (serviceNamesResult.isEmpty) {
         final newService = await _client.from('service_names').insert({'name': 'Imported Checklists'}).select('id').single();
         validServiceId = newService['id'];
      } else {
         validServiceId = serviceNamesResult.first['id'] as int;
      }

      final dir = Directory(r'D:\Cochin United\Cochin United\CUC Main Version\new checklist');
      if (!await dir.exists()) {
        _showError('Directory not found');
        return;
      }

      final files = dir.listSync().whereType<File>().where((f) => f.path.toLowerCase().endsWith('.pdf')).toList();
      
      int imported = 0;
      for (var file in files) {
        try {
          final bytes = await file.readAsBytes();
          final document = PdfDocument(inputBytes: bytes);
          final text = PdfTextExtractor(document).extractText();
          document.dispose();

          String fileName = file.uri.pathSegments.last;
          String title = fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
          // Clean title
          title = title.replaceAll(RegExp(r'checklist', caseSensitive: false), '');
          title = title.replaceAll(RegExp(r'\(\d+\)'), '');
          title = title.replaceAll('-', ' ');
          title = title.replaceAll('_', ' ');
          title = title.replaceAll(RegExp(r'\s+'), ' ').trim();

          if (title.isEmpty) continue;

          List<String> rawLines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          List<String> merged = [];
          for (var line in rawLines) {
            line = line.replaceAll(RegExp(r'^[\•\-\*]\s*'), '');
            if (merged.isNotEmpty && RegExp(r'^([a-z\-\(\)]|not |of |and |or |for )').hasMatch(line)) {
              merged[merged.length - 1] += ' $line';
            } else {
              merged.add(line);
            }
          }
          String cleanedNotes = merged.where((e) => e.length > 2).map((e) => '• $e').join('\n\n');

          await _client.from('service_content').insert({
            'title': title,
            'description': 'Requirements and checklist for $title.',
            'service_id': validServiceId,
            'details': {
               'notes': cleanedNotes,
               'raw_text': text,
               'document_url': file.uri.toString(),
            },
          });
          imported++;
        } catch (e) {
          debugPrint('Failed to import ${file.path}: $e');
        }
      }
      
      _showSuccess('Imported $imported services from PDFs!');
      _fetchServices();
    } catch (e) {
      _showError('Import failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showEditForm(ServiceItem service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditServiceForm(
        service: service,
        onSaved: () {
          if (mounted) Navigator.pop(context);
          _fetchServices();
          _showSuccess('Service updated successfully');
        },
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
          ),
        ),
      ],
    );
  }

  void _showAddForm() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Create New Service', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildFormField('Service Title', titleController, Icons.add_business_rounded),
                    const SizedBox(height: 20),
                    _buildFormField('Short Description', descController, Icons.info_outline_rounded, maxLines: 3),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            _showError('Please enter a service title');
                            return;
                          }
                          try {
                            await _client.from('service_content').insert({
                              'title': titleController.text.trim(),
                              'description': descController.text.trim(),
                              'service_id': 1,
                            });
                            if (mounted) Navigator.pop(context);
                            _fetchServices();
                            _showSuccess('Service created successfully');
                          } catch (e) {
                            _showError('Failed to add service: $e');
                          }
                        },
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text('Add Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;
        final filtered = _services.where((s) => 
          s.title.toLowerCase().contains(_searchTerm.toLowerCase())
        ).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddForm,
            backgroundColor: AppTheme.primaryColor,
            elevation: 8,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('New Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ).animate().scale(delay: 400.ms),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompactHeader(isWide),
              _buildSlimSearchArea(isWide),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                    ? _buildEmptyState()
                    : isWide 
                      ? GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            mainAxisExtent: 200,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _buildManagerServiceCard(filtered[index], index, true),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const Divider(height: 1, indent: 70),
                          itemBuilder: (context, index) => _buildServiceListTile(filtered[index], index),
                        ),
              ),
            ],
          ).animate().fadeIn(),
        );
      },
    );
  }

  Widget _buildCompactHeader(bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, isWide ? 40 : 24, isWide ? 32 : 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
                      'Service Catalog', 
                      style: TextStyle(
                        fontSize: isWide ? 32 : 24, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: -1,
                        color: AppTheme.textColor
                      )
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_services.length} ACTIVE SERVICES', 
                        style: const TextStyle(
                          color: AppTheme.primaryColor, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5
                        )
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (_isImporting)
                    const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  else
                    _headerAction(Icons.picture_as_pdf_rounded, _importPdfs),
                  const SizedBox(width: 8),
                  _headerAction(Icons.refresh_rounded, _fetchServices),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, VoidCallback onTap) {
    return IconButton.filled(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.08),
        foregroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSlimSearchArea(bool isWide) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 24, isWide ? 32 : 20, 8),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: TextField(
          onChanged: (val) => setState(() => _searchTerm = val),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Search within catalog...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_rounded, size: 60, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          const Text('No services match your search', style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildServiceListTile(ServiceItem service, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEditForm(service),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                      AppTheme.primaryColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getServiceIcon(service.title), color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description ?? 'No description provided',
                      style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 13, height: 1.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagerServiceCard(ServiceItem service, int index, bool isWide) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
        ),
        child: InkWell(
          onTap: () => _showEditForm(service),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.business_center_rounded, size: 100, color: AppTheme.primaryColor.withValues(alpha: 0.03)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getServiceIcon(service.title), color: AppTheme.primaryColor, size: 20),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showEditForm(service),
                          icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor),
                          tooltip: 'Edit Service',
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(service),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  service.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    service.description ?? 'System optimized consultancy service.',
                    style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 12, height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: const Text('ACTIVE SERVICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  void _confirmDelete(ServiceItem service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to remove "${service.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _client.from('service_content').delete().eq('id', service.id);
                if (mounted) Navigator.pop(context);
                _fetchServices();
                _showSuccess('Service deleted');
              } catch (e) {
                _showError('Delete failed: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('gst')) return Icons.account_balance_rounded;
    if (t.contains('registration')) return Icons.app_registration_rounded;
    if (t.contains('tax')) return Icons.money_rounded;
    if (t.contains('license')) return Icons.verified_user_rounded;
    if (t.contains('digital')) return Icons.vpn_key_rounded;
    if (t.contains('billing')) return Icons.receipt_long_rounded;
    return Icons.business_center_rounded;
  }
}

class _EditServiceForm extends StatefulWidget {
  final ServiceItem service;
  final VoidCallback onSaved;

  const _EditServiceForm({required this.service, required this.onSaved});

  @override
  State<_EditServiceForm> createState() => _EditServiceFormState();
}

class _EditServiceFormState extends State<_EditServiceForm> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _notesController;
  late Map<String, dynamic> _details;
  late List<Map<String, dynamic>> _faqs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service.title);
    _descController = TextEditingController(text: widget.service.description);
    
    _details = Map<String, dynamic>.from(widget.service.details ?? {});
    
    String notes = '';
    if (_details['notes'] != null && _details['notes'].toString().trim().isNotEmpty) {
      notes = _details['notes'].toString().trim();
    } else if (_details['checklist'] != null && _details['checklist'] is List) {
      notes = (_details['checklist'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).join('\n');
      _details['notes'] = notes;
    }

    _notesController = TextEditingController(text: notes);
    
    final faqsRaw = _details['faqs'] as List<dynamic>? ?? [];
    
    _faqs = faqsRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }



  Widget _buildFormField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, size: 20, color: AppTheme.primaryColor) : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
          ),
        ),
      ],
    );
  }

  void _addFaq() {
    setState(() {
      _faqs.add({'q': '', 'a': ''});
    });
  }

  void _removeFaq(int index) {
    setState(() {
      _faqs.removeAt(index);
    });
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      _details['faqs'] = _faqs;
      _details['notes'] = _notesController.text.trim();
      // Cards and other things in _details remain untouched.
      
      await Supabase.instance.client.from('service_content').update({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'details': _details,
      }).eq('id', widget.service.id);
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.redAccent));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Edit Service', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(widget.service.title, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormField('Display Title', _titleController, Icons.title_rounded),
                  const SizedBox(height: 20),
                  _buildFormField('Description', _descController, Icons.description_rounded, maxLines: 3),
                  const SizedBox(height: 32),
                  
                  if (_details['document_url'] != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 32.0),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded, size: 48, color: AppTheme.primaryColor),
                          const SizedBox(height: 16),
                          const Text('Official Document Attached', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text('The checklist and requirements are stored in the attached PDF document.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () => launchUrl(Uri.parse(_details['document_url'])),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Open PDF Document'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.list_alt_rounded, size: 20, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text('Checklist / Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          maxLines: 10,
                          minLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter all checklist items and requirements here...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  
                  // FAQs Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.help_outline_rounded, size: 20, color: AppTheme.primaryColor),
                          SizedBox(width: 8),
                          Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _addFaq,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add FAQ'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_faqs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: const Center(child: Text('No FAQs added yet.', style: TextStyle(color: AppTheme.mutedTextColor))),
                    )
                  else
                    ...List.generate(_faqs.length, (index) {
                      final faq = _faqs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.mutedTextColor, fontSize: 12)),
                                IconButton(
                                  onPressed: () => _removeFaq(index),
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: faq['q'],
                              onChanged: (v) => faq['q'] = v,
                              decoration: InputDecoration(
                                hintText: 'Enter question...',
                                isDense: true,
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: faq['a'],
                              onChanged: (v) => faq['a'] = v,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Enter answer...',
                                isDense: true,
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Update Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

