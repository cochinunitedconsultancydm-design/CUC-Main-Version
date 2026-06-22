import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/client_document.dart';
import '../models/ModelProvider.dart';
import '../theme.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadedFilesScreen extends StatefulWidget {
  const UploadedFilesScreen({super.key});

  @override
  State<UploadedFilesScreen> createState() => _UploadedFilesScreenState();
}

class _UploadedFilesScreenState extends State<UploadedFilesScreen> {
  List<ClientDocument> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final req = ModelQueries.list(ClientDocuments.classType);
      final res = await Amplify.API.query(request: req).response;
      var all = res.data?.items.whereType<ClientDocuments>().toList() ?? [];
      
      all.sort((a, b) {
        final dateA = a.createdAt?.getDateTimeInUtc() ?? DateTime(2000);
        final dateB = b.createdAt?.getDateTimeInUtc() ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _documents = all.map((m) => ClientDocument.fromMap({
            'id': m.id,
            'client_id': m.client_id,
            'client_name': m.client_name,
            'document_name': m.document_name,
            'storage_path': m.storage_path,
            'og_copy': m.og_copy,
            'remarks': m.remarks,
            'created_at': m.createdAt?.getDateTimeInUtc().toIso8601String(),
          })).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load documents: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateField(String id, String field, String value) async {
    try {
      final req = ModelQueries.list(ClientDocuments.classType, where: ClientDocuments.ID.eq(id));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final doc = res.data!.items.first!;
        var updated = doc;
        if (field == 'og_copy') {
          updated = doc.copyWith(og_copy: value);
        } else if (field == 'remarks') {
          updated = doc.copyWith(remarks: value);
        }
        await Amplify.API.mutate(request: ModelMutations.update(updated).response);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated successfully'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _downloadFile(ClientDocument doc) async {
    try {
      final result = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(doc.storagePath),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            validateObjectExistence: true,
            expiresIn: Duration(hours: 1),
          ),
        ),
      ).result;
      
      final url = result.url.toString();
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw Exception("Could not open file URL");
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open file: $e'), backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _deleteDocument(ClientDocument doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Delete record for "${doc.documentName}"? Note: This does not delete the actual file from storage.'),
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
      try {
        final req = ModelQueries.list(ClientDocuments.classType, where: ClientDocuments.ID.eq(doc.id));
        final res = await Amplify.API.query(request: req).response;
        if (res.data?.items.isNotEmpty == true) {
          await Amplify.API.mutate(request: ModelMutations.delete(res.data!.items.first!).response);
        }
        _fetchDocuments();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded, size: 64, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 24),
          const Text("No Documents Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          const SizedBox(height: 8),
          Text("Uploaded client files will appear here securely.", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('Error Loading Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade800)),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'Unknown error', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade600)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchDocuments,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            ),
          ],
        ),
      ).animate().fadeIn().scaleXY(begin: 0.95),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_shared_rounded, color: AppTheme.primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client Document Vault',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage, track, and verify uploaded client files',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _fetchDocuments,
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: const Text('Refresh Vault'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 24),
          
          // Main Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _documents.isEmpty
                            ? _buildEmptyState()
                            : _buildDataTable(),
              ),
            ).animate().fadeIn(delay: 100.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 64),
          child: DataTable(
            headingRowHeight: 56,
            dataRowMinHeight: 64,
            dataRowMaxHeight: 64,
            headingRowColor: WidgetStateProperty.resolveWith((states) => const Color(0xFFF8FAFC)),
            horizontalMargin: 24,
            dividerThickness: 1,
            columns: const [
              DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey))),
              DataColumn(label: Text('Upload Date', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey))),
              DataColumn(label: Text('Client Info', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey))),
              DataColumn(label: Text('Document', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey))),
              DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey))),
              DataColumn(label: Text('Verification Remarks', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey))),
            ],
            rows: List.generate(_documents.length, (index) {
              final doc = _documents[index];
              final isNotOk = doc.remarks.toLowerCase().contains('not ok');
              
              return DataRow(
                color: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) return Colors.grey.shade50;
                  return index.isEven ? Colors.white : const Color(0xFFFAFAFA);
                }),
                cells: [
                  DataCell(Text('${index + 1}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600))),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(doc.createdAt), style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(DateFormat('hh:mm a').format(doc.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    )
                  ),
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Text(doc.clientName[0].toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        ),
                        const SizedBox(width: 12),
                        Text(doc.clientName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    )
                  ),
                  DataCell(
                    InkWell(
                      onTap: () => _downloadFile(doc),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              doc.documentName.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                              size: 16,
                              color: doc.documentName.toLowerCase().endsWith('.pdf') ? Colors.redAccent : Colors.purpleAccent,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                doc.documentName,
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: doc.ogCopy == 'Original' ? Colors.purple.shade50 : Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: doc.ogCopy == 'Original' ? Colors.purple.shade200 : Colors.blueGrey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ['Original', 'Copy', 'NA'].contains(doc.ogCopy) ? doc.ogCopy : 'Copy',
                          icon: Icon(Icons.expand_more_rounded, size: 16, color: doc.ogCopy == 'Original' ? Colors.purple.shade700 : Colors.blueGrey.shade700),
                          isDense: true,
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w700, 
                            color: doc.ogCopy == 'Original' ? Colors.purple.shade700 : Colors.blueGrey.shade700,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Original', child: Text('Original')),
                            DropdownMenuItem(value: 'Copy', child: Text('Copy')),
                            DropdownMenuItem(value: 'NA', child: Text('NA')),
                          ],
                          onChanged: (val) {
                            if (val != null && val != doc.ogCopy) {
                              setState(() {
                                _documents[index] = ClientDocument(
                                  id: doc.id, clientId: doc.clientId, clientName: doc.clientName,
                                  documentName: doc.documentName, storagePath: doc.storagePath,
                                  ogCopy: val, remarks: doc.remarks, createdAt: doc.createdAt
                                );
                              });
                              _updateField(doc.id, 'og_copy', val);
                            }
                          },
                        ),
                      ),
                    )
                  ),
                  DataCell(
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: isNotOk ? Colors.red.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isNotOk ? Colors.red.shade200 : Colors.green.shade200),
                      ),
                      child: TextFormField(
                        initialValue: doc.remarks,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isNotOk ? Colors.red.shade900 : Colors.green.shade900,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          hintText: 'Add remarks...',
                          hintStyle: TextStyle(color: isNotOk ? Colors.red.shade300 : Colors.green.shade300),
                          isDense: true,
                        ),
                        onFieldSubmitted: (val) {
                          if (val != doc.remarks) {
                            _updateField(doc.id, 'remarks', val);
                          }
                        },
                      ),
                    )
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.cloud_download_rounded, color: AppTheme.primaryColor, size: 20),
                          onPressed: () => _downloadFile(doc),
                          tooltip: 'Download Document',
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteDocument(doc),
                          tooltip: 'Delete Log',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    )
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
