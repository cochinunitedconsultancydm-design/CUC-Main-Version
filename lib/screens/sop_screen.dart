import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/supabase_backup_service.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/backup_aware_api.dart';
import '../services/logging_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class SopScreen extends StatefulWidget {
  const SopScreen({super.key});

  @override
  State<SopScreen> createState() => _SopScreenState();
}

class _SopScreenState extends State<SopScreen> {
  bool _isLoading = true;
  bool _isAdmin = false;
  List<ServiceContent> _sops = [];
  List<ServiceContent> _filteredSops = [];
  List<Deals> _deals = [];
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  static const int _sopServiceId = 999999; // Identifier for SOPs

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
    _fetchSops();
    _searchController.addListener(_filterSops);
  }

  Future<void> _checkAdminRole() async {
    final auth = AuthService();
    final isAdmin = await auth.isAdmin();
    final isManager = await auth.isManager();
    final role = (await auth.getUserRole())?.toLowerCase().trim() ?? '';
    final canManage = isAdmin || isManager || role == 'hr' || role == 'admin' || role == 'manager' || role == 'staff' || role == 'superadmin' || role.isNotEmpty;
    if (mounted) setState(() => _isAdmin = canManage);
  }

  List<String> _getPdfUrls(ServiceContent sop) {
    final list = <String>[];
    if (sop.pdf_url != null && sop.pdf_url!.trim().isNotEmpty) {
      list.addAll(_parseJsonStringArray(sop.pdf_url));
    }
    if (sop.image_path != null && sop.image_path!.trim().isNotEmpty) {
      for (final p in _parseJsonStringArray(sop.image_path)) {
        if (!list.contains(p)) list.add(p);
      }
    }
    return list.where((u) {
      final t = u.trim();
      return t.isNotEmpty && t != '[]' && t != 'null' && t != '""' && t != "''";
    }).toList();
  }

  Future<String?> _uploadSinglePdf(PlatformFile file) async {
    try {
      final cleanName = file.name.replaceAll(' ', '_').replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');
      final s3Key = 'public/sops/${UUID.getUUID()}_$cleanName';

      Uint8List? bytes = file.bytes;
      if (bytes == null && !kIsWeb && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      bool uploaded = false;
      // 1. Try Amplify Storage S3
      try {
        AWSFile localFile;
        if (file.bytes != null) {
          localFile = AWSFile.fromData(file.bytes!);
        } else if (!kIsWeb && file.path != null) {
          localFile = AWSFile.fromPath(file.path!);
        } else if (bytes != null) {
          localFile = AWSFile.fromData(bytes);
        } else {
          throw Exception('No data found for file');
        }

        await Amplify.Storage.uploadFile(
          localFile: localFile,
          path: StoragePath.fromString(s3Key),
        ).result;
        uploaded = true;
      } catch (e) {
        debugPrint('Amplify S3 upload failed for $cleanName (will try Supabase backup): $e');
      }

      // 2. Backup / fallback to Supabase Storage
      if (bytes != null) {
        try {
          final supOk = await SupabaseBackupService().backupFile(s3Key, bytes);
          if (supOk) uploaded = true;
        } catch (e) {
          debugPrint('Supabase upload error for $cleanName: $e');
        }
      }

      if (uploaded) {
        return s3Key;
      } else {
        throw Exception('Could not upload to cloud storage');
      }
    } catch (e) {
      debugPrint('Error uploading single PDF: $e');
      return null;
    }
  }

  Future<void> _openPdf(String rawUrlOrKey) async {
    try {
      String openUrl = rawUrlOrKey.trim();
      if (openUrl.isEmpty) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Opening document...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // If it's a local file that exists, launch it directly
      if (!kIsWeb && File(openUrl).existsSync()) {
        final uri = Uri.file(openUrl);
        await launchUrl(uri);
        return;
      }

      // Normalize path
      String storagePath = openUrl;
      if (!openUrl.startsWith('http://') && !openUrl.startsWith('https://')) {
        storagePath = openUrl.startsWith('public/') ? openUrl : 'public/$openUrl';
      } else if (openUrl.contains('.amazonaws.com/')) {
        final uri = Uri.parse(openUrl);
        String p = uri.path;
        if (p.startsWith('/')) p = p.substring(1);
        if (p.contains('public/')) p = p.substring(p.indexOf('public/'));
        storagePath = p;
      }

      final supabaseFallbackUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co/storage/v1/object/public/cuc-backups/$storagePath';

      // On Windows Desktop: attempt to download bytes and open locally for 100% reliable viewing!
      if (!kIsWeb && Platform.isWindows) {
        try {
          List<int>? bytes;

          // 1. Try Amplify Storage download
          try {
            final downloadRes = await Amplify.Storage.downloadData(
              path: StoragePath.fromString(storagePath),
            ).result;
            bytes = downloadRes.bytes;
          } catch (e) {
            debugPrint('Amplify downloadData failed: $e');
          }

          // 2. Try Supabase Storage download if Amplify failed
          if (bytes == null || bytes.isEmpty) {
            try {
              final supRes = await http.get(Uri.parse(supabaseFallbackUrl)).timeout(const Duration(seconds: 8));
              if (supRes.statusCode == 200 && supRes.bodyBytes.isNotEmpty) {
                bytes = supRes.bodyBytes;
              }
            } catch (e) {
              debugPrint('Supabase download failed: $e');
            }
          }

          // 3. Try direct HTTP if openUrl was a full URL
          if ((bytes == null || bytes.isEmpty) && (openUrl.startsWith('http://') || openUrl.startsWith('https://'))) {
            try {
              final directRes = await http.get(Uri.parse(openUrl)).timeout(const Duration(seconds: 8));
              if (directRes.statusCode == 200 && directRes.bodyBytes.isNotEmpty) {
                bytes = directRes.bodyBytes;
              }
            } catch (e) {
              debugPrint('Direct HTTP download failed: $e');
            }
          }

          if (bytes != null && bytes.isNotEmpty) {
            final cleanFileName = storagePath.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
            final finalName = cleanFileName.toLowerCase().endsWith('.pdf') ? cleanFileName : '$cleanFileName.pdf';
            final tempDir = Directory.systemTemp;
            final tempFile = File('${tempDir.path}\\$finalName');
            await tempFile.writeAsBytes(bytes);
            await Process.run('cmd', ['/c', 'start', '""', tempFile.path]);
            return;
          }
        } catch (winErr) {
          debugPrint('Windows local download/open failed: $winErr');
        }
      }

      // Web / Browser fallback
      if (!openUrl.startsWith('http://') && !openUrl.startsWith('https://')) {
        try {
          final res = await Amplify.Storage.getUrl(
            path: StoragePath.fromString(storagePath),
          ).result;
          openUrl = res.url.toString();
        } catch (s3Error) {
          debugPrint('Amplify getUrl failed, trying Supabase storage fallback: $s3Error');
          openUrl = supabaseFallbackUrl;
        }
      }

      final url = Uri.parse(openUrl);
      bool launched = false;
      try {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
      } catch (_) {}

      if (!launched) {
        try {
          launched = await launchUrl(url, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (!launched && !kIsWeb && Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '""', openUrl]);
        launched = true;
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open link automatically: $openUrl'),
          action: SnackBarAction(label: 'Copy', onPressed: () => Clipboard.setData(ClipboardData(text: openUrl))),
        ));
      }
    } catch (e) {
      debugPrint('Error opening PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error opening PDF: $e'),
          backgroundColor: Colors.red.shade800,
        ));
      }
    }
  }

  Future<void> _quickAttachPdf(ServiceContent sop) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              const SizedBox(width: 12),
              Text('Uploading "${file.name}"...'),
            ],
          ),
          duration: const Duration(seconds: 4),
        ));
      }

      final s3Key = await _uploadSinglePdf(file);
      if (s3Key == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to upload "${file.name}". Please check network connection.'),
            backgroundColor: Colors.red.shade800,
          ));
        }
        return;
      }

      final urls = _getPdfUrls(sop);
      urls.add(s3Key);

      final updated = sop.copyWith(pdf_url: jsonEncode(urls));
      await BackupAwareApi().update(updated);
      await LoggingService().logAction(
        action: 'SOP_PDF_ATTACHED',
        targetType: 'SOP',
        targetId: sop.id,
        details: 'Attached document "${file.name}" to SOP "${sop.title}"',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Successfully attached "${file.name}" to "${sop.title}"!'),
          backgroundColor: Colors.green.shade700,
        ));
        _fetchSops();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error attaching document: $e'),
          backgroundColor: Colors.red.shade800,
        ));
      }
    }
  }

  Future<void> _removePdfFromSop(ServiceContent sop, String urlToRemove) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Document?'),
        content: const Text('Are you sure you want to remove this attached document from this SOP?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final urls = _getPdfUrls(sop);
      urls.remove(urlToRemove);
      final updated = sop.copyWith(pdf_url: urls.isEmpty ? null : jsonEncode(urls));
      await BackupAwareApi().update(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document removed from SOP'), backgroundColor: Colors.orange),
        );
        _fetchSops();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing document: $e'), backgroundColor: Colors.red.shade800),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSops() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSops = List.from(_sops);
      } else {
        _filteredSops = _sops.where((sop) {
          final title = sop.title?.toLowerCase() ?? '';
          final desc = sop.description?.toLowerCase() ?? '';
          final details = sop.details?.toLowerCase() ?? '';
          return title.contains(query) || desc.contains(query) || details.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchSops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final req = ModelQueries.list(
        ServiceContent.classType,
        where: ServiceContent.SERVICE_ID.eq(_sopServiceId),
       limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      if (res.hasErrors) {
        throw Exception(res.errors.first.message);
      }
      final sopsList = (res.data?.items ?? []).whereType<ServiceContent>().toList();
      sopsList.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
      
      final dealsReq = ModelQueries.list(Deals.classType, limit: 10000);
      final dealsRes = await Amplify.API.query(request: dealsReq).response;
      final dealsList = (dealsRes.data?.items ?? []).whereType<Deals>().toList();
      
      if (mounted) {
        setState(() {
          _sops = sopsList;
          _filteredSops = List.from(sopsList);
          _deals = dealsList;
          _isLoading = false;
        });
        _filterSops();
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

  Future<void> _deleteSop(ServiceContent sop) async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission Denied: Only Admin can delete SOPs'), backgroundColor: Colors.red));
      return;
    }
    try {
      await BackupAwareApi().delete(sop);
      await LoggingService().logAction(action: 'SOP_DELETED', targetType: 'SOP', targetId: sop.id, details: 'Deleted SOP: ${sop.title}');
      _fetchSops();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red.shade800,
        ));
      }
    }
  }

  List<String> _parseJsonStringArray(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) return [];
    if (jsonString.trim().startsWith('[')) {
      try {
        final decoded = jsonDecode(jsonString);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return [jsonString];
  }

  void _showAddEditSopDialog([ServiceContent? sop]) {
    if (sop != null && !_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission Denied: Only Admin can edit SOPs'), backgroundColor: Colors.red));
      return;
    }
    final titleController = TextEditingController(text: sop?.title);
    final descController = TextEditingController(text: sop?.description);
    final contentController = TextEditingController(text: sop?.details);
    bool isSaving = false;
    List<String> uploadedPdfUrls = sop != null ? _getPdfUrls(sop) : [];
    List<PlatformFile> newPdfs = [];
    List<String> selectedCaseIds = _parseJsonStringArray(sop?.previous_case_id);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 20,
              backgroundColor: AppTheme.backgroundColor,
              child: Container(
                width: 650,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sop == null ? Icons.post_add_rounded : Icons.edit_document,
                            color: AppTheme.primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          sop == null ? 'Create New SOP' : 'Edit SOP',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: titleController,
                      label: 'SOP Title',
                      hint: 'e.g. Employee Onboarding Process',
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: descController,
                      label: 'Short Description',
                      hint: 'Brief summary of what this SOP covers...',
                      icon: Icons.short_text,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: contentController,
                      label: 'Detailed Content',
                      hint: 'Step-by-step procedure...',
                      icon: Icons.subject_rounded,
                      maxLines: 10,
                    ),
                    const SizedBox(height: 20),
                    const Text('Related Work Files / Cases', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Select Work File'),
                          value: null,
                          onChanged: (val) {
                            if (val != null && !selectedCaseIds.contains(val)) {
                              setDialogState(() => selectedCaseIds.add(val));
                            }
                          },
                          items: _deals.map((deal) {
                            return DropdownMenuItem<String>(
                              value: deal.id,
                              child: Text(deal.name ?? deal.id),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedCaseIds.map((caseId) {
                        final deal = _deals.where((d) => d.id == caseId).firstOrNull;
                        return Chip(
                          label: Text(deal?.name ?? caseId, style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setDialogState(() => selectedCaseIds.remove(caseId));
                          },
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Attached PDFs', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                          allowMultiple: true,
                          withData: true,
                        );
                        if (result != null) {
                          setDialogState(() {
                            for (var file in result.files) {
                              newPdfs.add(file);
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text('Add PDFs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        ...uploadedPdfUrls.asMap().entries.map((entry) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            title: Text('Attached Document ${entry.key + 1}', style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                              onPressed: () => setDialogState(() => uploadedPdfUrls.removeAt(entry.key)),
                            ),
                          );
                        }),
                        ...newPdfs.asMap().entries.map((entry) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.upload_file, color: Colors.green),
                            title: Text(entry.value.name, style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                              onPressed: () => setDialogState(() => newPdfs.removeAt(entry.key)),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            foregroundColor: AppTheme.mutedTextColor,
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (titleController.text.trim().isEmpty) return;
                                  setDialogState(() => isSaving = true);
                                  try {
                                    for (var file in newPdfs) {
                                      final s3Key = await _uploadSinglePdf(file);
                                      if (s3Key != null) {
                                        uploadedPdfUrls.add(s3Key);
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text('Warning: Failed to upload "${file.name}"'),
                                            backgroundColor: Colors.orange.shade800,
                                          ));
                                        }
                                      }
                                    }

                                    final newSop = ServiceContent(
                                      id: sop?.id ?? UUID.getUUID(),
                                      service_id: _sopServiceId,
                                      title: titleController.text.trim(),
                                      description: descController.text.trim(),
                                      details: contentController.text.trim(),
                                      pdf_url: uploadedPdfUrls.isEmpty ? null : jsonEncode(uploadedPdfUrls),
                                      previous_case_id: selectedCaseIds.isEmpty ? null : jsonEncode(selectedCaseIds),
                                    );

                                    if (sop == null) {
                                      await BackupAwareApi().create(newSop);
                                      await LoggingService().logAction(action: 'SOP_CREATED', targetType: 'SOP', targetId: newSop.id, details: 'Created SOP: ${titleController.text.trim()}');
                                    } else {
                                      await BackupAwareApi().update(newSop);
                                      await LoggingService().logAction(action: 'SOP_UPDATED', targetType: 'SOP', targetId: newSop.id, details: 'Updated SOP: ${titleController.text.trim()}');
                                    }
                                    
                                    if (mounted) {
                                      Navigator.pop(context);
                                      _fetchSops();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red.shade800,
                                      ));
                                    }
                                  } finally {
                                    if (mounted) setDialogState(() => isSaving = false);
                                  }
                                },
                          icon: isSaving 
                              ? const SizedBox(
                                  width: 18, 
                                  height: 18, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                )
                              : const Icon(Icons.check_circle_outline_rounded, size: 20),
                          label: Text(
                            isSaving ? 'Saving...' : 'Save SOP',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().scale(
              begin: const Offset(0.95, 0.95), 
              end: const Offset(1, 1), 
              curve: Curves.easeOutCubic, 
              duration: 300.ms,
            ).fadeIn(duration: 300.ms);
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.notoSansMalayalam(
        textStyle: const TextStyle(),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.mutedTextColor.withValues(alpha: 0.5)),
        prefixIcon: maxLines == 1 ? Icon(icon, color: AppTheme.primaryColor.withValues(alpha: 0.7)) : null,
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  void _confirmDelete(ServiceContent sop) {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission Denied: Only Admin can delete SOPs'), backgroundColor: Colors.red));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete SOP?'),
        content: Text('Are you sure you want to delete "${sop.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSop(sop);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Standard Operating Procedures',
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: -0.5,
                        color: AppTheme.textColor,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage and view all internal company procedures',
                      style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 15),
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
                if (!isWide) const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditSopDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Create SOP', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search SOPs by title, description, or content...',
                  hintStyle: TextStyle(color: AppTheme.mutedTextColor.withValues(alpha: 0.5)),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.mutedTextColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppTheme.mutedTextColor),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text('Failed to load data: $_error', style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        )
                      : _filteredSops.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No SOPs found',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Try adjusting your search or click "Create SOP".',
                                    style: TextStyle(color: AppTheme.mutedTextColor),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 600.ms)
                          : ListView.separated(
                              itemCount: _filteredSops.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                final sop = _filteredSops[index];
                                return Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      leading: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryColor),
                                      ),
                                      title: Text(
                                        sop.title ?? 'Untitled',
                                        style: GoogleFonts.notoSansMalayalam(textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                                      ),
                                      subtitle: (sop.description != null && sop.description!.isNotEmpty)
                                          ? Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                sop.description!,
                                                style: GoogleFonts.notoSansMalayalam(textStyle: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 14)),
                                              ),
                                            )
                                          : null,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_isAdmin)
                                            IconButton(
                                              icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700),
                                              tooltip: 'Edit',
                                              onPressed: () => _showAddEditSopDialog(sop),
                                            ),
                                          if (_isAdmin)
                                            IconButton(
                                              icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600),
                                              tooltip: 'Delete',
                                              onPressed: () => _confirmDelete(sop),
                                            ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                                        ],
                                      ),
                                      children: [
                                        if (sop.details != null && sop.details!.isNotEmpty)
                                          Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceColor,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Text(
                                              sop.details!,
                                              style: GoogleFonts.notoSansMalayalam(
                                                textStyle: const TextStyle(
                                                  fontSize: 15,
                                                  height: 1.6,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (sop.previous_case_id != null && sop.previous_case_id!.isNotEmpty)
                                            ..._parseJsonStringArray(sop.previous_case_id).map((caseId) {
                                              final deal = _deals.where((d) => d.id == caseId).firstOrNull;
                                              return Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.cases_rounded, color: Colors.blue.shade700, size: 20),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'Related Work File: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        deal?.name ?? caseId,
                                                        style: TextStyle(color: Colors.blue.shade800),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          Builder(
                                            builder: (context) {
                                              final pdfUrls = _getPdfUrls(sop);
                                              if (pdfUrls.isNotEmpty) {
                                                return Column(
                                                  children: [
                                                    ...pdfUrls.asMap().entries.map((entry) {
                                                      final rawUrlOrKey = entry.value;
                                                      String displayName = 'Document ' + (entry.key + 1).toString();
                                                      if (rawUrlOrKey.contains('_')) {
                                                        final parts = rawUrlOrKey.split('/').last.split('_');
                                                        if (parts.length > 1) {
                                                          displayName = parts.sublist(1).join('_');
                                                        }
                                                      } else if (rawUrlOrKey.contains('/')) {
                                                        displayName = rawUrlOrKey.split('/').last;
                                                      }
                                                      if (displayName.contains('?')) {
                                                        displayName = displayName.split('?').first;
                                                      }

                                                      return Container(
                                                        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 10),
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red.shade50.withValues(alpha: 0.6),
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: Colors.red.shade200),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.all(8),
                                                              decoration: BoxDecoration(
                                                                color: Colors.red.shade100,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Icon(Icons.picture_as_pdf_rounded, color: Colors.red.shade700, size: 24),
                                                            ),
                                                            const SizedBox(width: 14),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    displayName,
                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textColor),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                  const SizedBox(height: 2),
                                                                  Text(
                                                                    'Attached Reference Document',
                                                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            ElevatedButton.icon(
                                                              onPressed: () => _openPdf(rawUrlOrKey),
                                                              icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                                              label: const Text('View / Open'),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.red.shade700,
                                                                foregroundColor: Colors.white,
                                                                elevation: 0,
                                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                              ),
                                                            ),
                                                            if (_isAdmin) ...[
                                                              const SizedBox(width: 6),
                                                              IconButton(
                                                                icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                                                                tooltip: 'Remove Document',
                                                                onPressed: () => _removePdfFromSop(sop, rawUrlOrKey),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                    if (_isAdmin)
                                                      Container(
                                                        alignment: Alignment.centerLeft,
                                                        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
                                                        child: TextButton.icon(
                                                          onPressed: () => _quickAttachPdf(sop),
                                                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                                                          label: const Text('Attach Another Document', style: TextStyle(fontWeight: FontWeight.w600)),
                                                          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              }

                                              return Container(
                                                margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50.withValues(alpha: 0.5),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.blue.shade200),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.shade100,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(Icons.picture_as_pdf_outlined, color: Colors.blue.shade800, size: 24),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'No PDF document attached to this procedure',
                                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 14),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            'Attach a PDF or reference file for this procedure so team members can view and download it.',
                                                            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    ElevatedButton.icon(
                                                      onPressed: () => _quickAttachPdf(sop),
                                                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                                                      label: const Text('Attach PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppTheme.primaryColor,
                                                        foregroundColor: Colors.white,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        elevation: 1,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                      ],
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
