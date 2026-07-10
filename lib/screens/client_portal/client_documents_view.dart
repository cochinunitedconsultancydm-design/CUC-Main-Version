import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../../models/ModelProvider.dart';
import '../../theme.dart';
import '../../services/auth_service.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDocumentsView extends StatefulWidget {
  const ClientDocumentsView({super.key});

  @override
  State<ClientDocumentsView> createState() => _ClientDocumentsViewState();
}

class _ClientDocumentsViewState extends State<ClientDocumentsView> {
  bool _isLoading = true;
  List<ClientDocuments> _documents = [];

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    setState(() => _isLoading = true);
    try {
      final clientName = await AuthService().getUserName();
      final clientUuid = await AuthService().getUserIdStr();
      
      if (clientUuid != null || clientName != null) {
        // Fetch explicit ClientDocuments records (handling pagination to get all records)
        List<ClientDocuments> allDocs = [];
        GraphQLRequest<PaginatedResult<ClientDocuments>> request = ModelQueries.list(
          ClientDocuments.classType,
          limit: 1000,
        );
        
        while (true) {
          final response = await Amplify.API.query(request: request).response;
          if (response.data?.items != null) {
            allDocs.addAll(response.data!.items.whereType<ClientDocuments>());
          }
          if (response.data?.hasNextResult == true) {
            request = response.data!.requestForNextResult!;
          } else {
            break;
          }
        }
        
        // Only show documents that belong to this client AND are either explicitly shared by staff
        // OR were uploaded by the client themselves (via portal).
        final filteredDocs = allDocs.where((d) {
          bool belongsToClient = false;
          if (clientUuid != null && d.client_id == clientUuid) {
            belongsToClient = true;
          } else if (clientName != null && d.client_name?.trim().toLowerCase() == clientName.trim().toLowerCase()) {
            belongsToClient = true;
          }
          
          if (!belongsToClient) return false;
          
          final remarks = d.remarks ?? '';
          final storagePath = d.storage_path ?? '';
          
          final isSharedByStaff = remarks.contains('[SHARED]');
          final isUploadedByClient = remarks.contains('Uploaded by Client') || storagePath.contains('/portal_uploads/');
          
          return isSharedByStaff || isUploadedByClient;
        }).toList();

        // Deduplicate records that point to the exact same storage_path
        // (Solves ghost duplicate records created during network delays)
        final Map<String, ClientDocuments> uniqueDocs = {};
        for (var doc in filteredDocs) {
          final path = doc.storage_path ?? doc.id;
          // Prioritize keeping the one that is explicitly shared or just keep the latest
          if (!uniqueDocs.containsKey(path) || (doc.remarks?.contains('[SHARED]') == true && !(uniqueDocs[path]?.remarks?.contains('[SHARED]') ?? false))) {
            uniqueDocs[path] = doc;
          }
        }
        
        final finalDocs = uniqueDocs.values.toList();

        // Sort by date descending
        finalDocs.sort((a, b) {
          final dateA = a.createdAt?.getDateTimeInUtc() ?? DateTime(2000);
          final dateB = b.createdAt?.getDateTimeInUtc() ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });

        setState(() {
          _documents = finalDocs;
          debugPrint('MyDocs: Set state with \${_documents.length} allowed docs');
        });
      }
    } catch (e) {
      debugPrint('Error fetching client documents: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);
        
        final filePath = result.files.single.path!;
        String fileName = result.files.single.name;
        
        final clientId = await AuthService().getUserIdStr();
        final clientName = await AuthService().getUserName();
        
        if (clientId == null || clientName == null) {
          setState(() => _isLoading = false);
          return;
        }

        String path = 'public/$clientId/portal_uploads/$fileName';
        
        final file = File(filePath);
        
        await Amplify.Storage.uploadFile(
          localFile: AWSFile.fromPath(file.path),
          path: StoragePath.fromString(path),
        ).result;
        
        final newDoc = ClientDocuments(
          client_id: clientId,
          client_name: clientName,
          document_name: fileName,
          storage_path: path,
          og_copy: 'No',
          remarks: 'Uploaded by Client via Portal',
          verification_status: 'Under Verification',
          rejection_reason: '',
        );
        
        await BackupAwareApi().create(newDoc);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully!'), backgroundColor: Colors.green),
          );
        }
        
        await _fetchDocuments();
      }
    } catch (e) {
      debugPrint('File upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadFile(ClientDocuments doc) async {
    if (doc.storage_path == null) return;
    try {
      final result = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(doc.storage_path!),
      ).result;
      
      final urlString = result.url.toString();
      final uri = Uri.parse(urlString);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open download link.')));
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate download link.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Documents', style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              ElevatedButton.icon(
                onPressed: _uploadFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _documents.isEmpty
            ? const Center(child: Text('No documents found.', style: TextStyle(color: AppTheme.mutedTextColor)))
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  final doc = _documents[index];
                  final isRejected = doc.verification_status == 'Rejected';
                  final isOk = doc.verification_status == 'File OK';
                  final isPdf = doc.document_name?.toLowerCase().endsWith('.pdf') ?? false;

                  return Card(
                    color: AppTheme.surfaceColor,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isPdf ? Colors.red.shade50 : Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded, 
                                  color: isPdf ? Colors.redAccent : Colors.purpleAccent,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.document_name ?? 'Document', 
                                      style: const TextStyle(fontSize: 16, color: AppTheme.textColor, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(doc.remarks ?? 'No remarks', style: const TextStyle(fontSize: 13, color: AppTheme.mutedTextColor)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (doc.verification_status != null && doc.verification_status!.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOk ? Colors.green.shade50 : (isRejected ? Colors.red.shade50 : Colors.amber.shade50),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isOk ? Colors.green.shade200 : (isRejected ? Colors.red.shade200 : Colors.amber.shade200)),
                                  ),
                                  child: Text(
                                    doc.verification_status!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isOk ? Colors.green.shade700 : (isRejected ? Colors.red.shade700 : Colors.amber.shade700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          
                          if (isRejected && doc.rejection_reason != null && doc.rejection_reason!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade100),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: Colors.red.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Reason: ${doc.rejection_reason}', 
                                      style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),
                          
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _downloadFile(doc),
                              icon: const Icon(Icons.download_rounded, size: 18),
                              label: const Text('Download / View File'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
