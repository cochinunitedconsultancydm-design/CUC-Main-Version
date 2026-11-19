import 'dart:io';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../models/inward_post_model.dart';
import '../services/inward_post_service.dart';
import '../services/logging_service.dart';
import '../services/supabase_backup_service.dart';

class InwardPostScreen extends StatefulWidget {
  final String currentUserRole;
  final String currentUserName;
  final String? initialWorkfileId; // Optional: pre-link to a specific workfile

  const InwardPostScreen({
    super.key,
    required this.currentUserRole,
    required this.currentUserName,
    this.initialWorkfileId,
  });

  @override
  State<InwardPostScreen> createState() => _InwardPostScreenState();
}

class _InwardPostScreenState extends State<InwardPostScreen> {
  // Form controllers
  final _senderController = TextEditingController();
  final _recipientController = TextEditingController();
  final _receivedByController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  // Post Type & Options
  String _postType = 'outward'; // 'outward' (Sent Letter) or 'inward' (Received Post)
  bool _hasAcknowledgement = true;
  
  // Workfile selection
  List<amplify_models.Deals> _workfiles = [];
  amplify_models.Deals? _selectedWorkfile;

  // Uploaded letter file
  Uint8List? _letterBytes;
  String? _letterFileName;
  bool _isUploading = false;

  // Data lists
  List<InwardPost> _posts = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  // Active filter tab: 'all', 'outward', 'inward', 'pending_ack'
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _receivedByController.text = widget.currentUserName;
    _senderController.text = 'Cochin United Consultancy';
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadPosts(),
      _loadWorkfiles(),
      _loadUsers(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPosts() async {
    final posts = await InwardPostService.getPosts();
    if (mounted) {
      setState(() => _posts = posts);
    }
  }

  Future<void> _loadWorkfiles() async {
    try {
      final req = ModelQueries.list(amplify_models.Deals.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      final deals = (res.data?.items ?? []).whereType<amplify_models.Deals>().toList();
      deals.sort((a, b) => (b.createdAt?.getDateTimeInUtc() ?? DateTime(2000))
          .compareTo(a.createdAt?.getDateTimeInUtc() ?? DateTime(2000)));

      if (mounted) {
        setState(() {
          _workfiles = deals;
          if (widget.initialWorkfileId != null) {
            final match = deals.where((d) => d.id == widget.initialWorkfileId).toList();
            if (match.isNotEmpty) {
              _selectedWorkfile = match.first;
              _postType = 'outward';
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading workfiles for posts: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final req = ModelQueries.list(amplify_models.Users.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      var usersList = (res.data?.items ?? []).whereType<amplify_models.Users>().toList();

      Set<String> deletedKeys = {};
      try {
        final prefs = await SharedPreferences.getInstance();
        deletedKeys = (prefs.getStringList('deleted_staff_keys') ?? [])
            .map((k) => k.toLowerCase().trim())
            .toSet();
      } catch (_) {}

      usersList = usersList.where((u) {
        if ((u.role ?? '').toLowerCase().trim() == 'deleted') return false;
        final uid = u.id.toLowerCase().trim();
        final uname = (u.username ?? '').toLowerCase().trim();
        final uemail = (u.email ?? '').toLowerCase().trim();
        final uNameStr = (u.name ?? '').toLowerCase().trim();
        if (deletedKeys.contains(uid) ||
            (uname.isNotEmpty && deletedKeys.contains(uname)) ||
            (uemail.isNotEmpty && deletedKeys.contains(uemail)) ||
            (uNameStr.isNotEmpty && deletedKeys.contains(uNameStr))) {
          return false;
        }
        return true;
      }).toList();

      usersList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      if (mounted) {
        setState(() {
          _users = usersList.map((u) => {
            'id': u.id,
            'name': u.name ?? u.username ?? 'Staff',
            'role': u.role ?? 'staff',
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  @override
  void dispose() {
    _senderController.dispose();
    _recipientController.dispose();
    _receivedByController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- FILE PICKER FOR SENT LETTER ---
  Future<void> _pickLetterFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? bytes = file.bytes;
        if (bytes == null && file.path != null && !kIsWeb) {
          bytes = await File(file.path!).readAsBytes();
        }

        if (bytes != null) {
          setState(() {
            _letterBytes = bytes;
            _letterFileName = file.name;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking letter file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select file: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _clearSelectedLetter() {
    setState(() {
      _letterBytes = null;
      _letterFileName = null;
    });
  }

  // --- LOGGING NEW POST / SENT LETTER ---
  Future<void> _logNewPost() async {
    final sender = _senderController.text.trim();
    final recipient = _recipientController.text.trim();

    if (sender.isEmpty || recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sender and Recipient are required'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? letterStoragePath;
      String? uploadedLetterName = _letterFileName;

      // 1. Upload sent letter to S3 / Supabase Storage if attached
      if (_letterBytes != null && _letterFileName != null) {
        final cleanName = _letterFileName!.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        letterStoragePath = 'public/posts/letters/${timestamp}_$cleanName';

        await Amplify.Storage.uploadData(
          data: StorageDataPayload.bytes(_letterBytes!),
          path: StoragePath.fromString(letterStoragePath),
        ).result;

        // Backup to Supabase Storage asynchronously
        SupabaseBackupService().backupFileInBackground(letterStoragePath, _letterBytes!);
      }

      final postId = 'POST-${DateTime.now().millisecondsSinceEpoch}';
      final isSent = _postType == 'outward';

      final newPost = InwardPost(
        id: postId,
        senderName: sender,
        recipientName: recipient,
        receivedBy: _receivedByController.text.trim().isEmpty 
            ? widget.currentUserName 
            : _receivedByController.text.trim(),
        receivedDate: DateTime.now(),
        status: isSent 
            ? (_hasAcknowledgement ? PostStatus.pendingConfirmation : PostStatus.confirmedReceived)
            : PostStatus.pendingConfirmation,
        description: _descriptionController.text.trim(),
        postType: _postType,
        workfileId: _selectedWorkfile?.id,
        workfileName: _selectedWorkfile?.name,
        workfileNumber: _selectedWorkfile?.register_no,
        letterStoragePath: letterStoragePath,
        letterFileName: uploadedLetterName,
        hasAcknowledgement: isSent ? _hasAcknowledgement : false,
        ackStatus: (isSent && _hasAcknowledgement) ? 'pending' : 'none',
      );

      await InwardPostService.addPost(newPost);

      await LoggingService().logAction(
        action: isSent ? 'SENT_LETTER_LOGGED' : 'INWARD_POST_LOGGED',
        targetType: 'PostRegister',
        targetId: newPost.id,
        details: '${isSent ? "Sent letter to" : "Logged post from"} $recipient (Workfile: ${_selectedWorkfile?.name ?? "None"})',
      );

      // Reset form
      _recipientController.clear();
      _descriptionController.clear();
      _clearSelectedLetter();
      if (!isSent) {
        _senderController.clear();
      } else {
        _senderController.text = 'Cochin United Consultancy';
      }
      setState(() {
        _selectedWorkfile = null;
        _hasAcknowledgement = true;
      });

      await _loadPosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSent ? 'Sent letter logged successfully!' : 'Inward post logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error logging post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save post: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // --- UPLOAD ACKNOWLEDGEMENT DIALOG ---
  Future<void> _showUploadAcknowledgementDialog(InwardPost post) async {
    Uint8List? ackBytes;
    String? ackFileName;
    DateTime ackDate = DateTime.now();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.orange, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Upload Acknowledgement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Letter to: ${post.recipientName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      if (post.workfileName != null) ...[
                        const SizedBox(height: 4),
                        Text('Workfile: [${post.workfileNumber ?? "WF"}] ${post.workfileName}', style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                      ],
                      const SizedBox(height: 4),
                      Text('Sent Date: ${DateFormat('dd MMM yyyy').format(post.receivedDate)}', style: const TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Signed Acknowledgement / Delivery Proof', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    try {
                      final result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                        withData: true,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        final file = result.files.first;
                        Uint8List? bytes = file.bytes;
                        if (bytes == null && file.path != null && !kIsWeb) {
                          bytes = await File(file.path!).readAsBytes();
                        }
                        if (bytes != null) {
                          setModalState(() {
                            ackBytes = bytes;
                            ackFileName = file.name;
                          });
                        }
                      }
                    } catch (e) {
                      debugPrint('Error picking acknowledgement file: $e');
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: ackFileName != null ? Colors.green.shade50 : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ackFileName != null ? Colors.green.shade300 : Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          ackFileName != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                          color: ackFileName != null ? Colors.green : AppTheme.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ackFileName ?? 'Click to select signed receipt / photo / PDF',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: ackFileName != null ? FontWeight.bold : FontWeight.normal,
                            color: ackFileName != null ? Colors.green.shade800 : AppTheme.mutedTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.mutedTextColor),
                    const SizedBox(width: 8),
                    const Text('Date Received:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: ackDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (picked != null) {
                          setModalState(() => ackDate = picked);
                        }
                      },
                      child: Text(DateFormat('dd MMM yyyy').format(ackDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: (ackBytes == null || isSubmitting) ? null : () async {
                setModalState(() => isSubmitting = true);
                try {
                  final cleanName = ackFileName!.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
                  final timestamp = DateTime.now().millisecondsSinceEpoch;
                  final ackStoragePath = 'public/posts/acknowledgements/${timestamp}_$cleanName';

                  await Amplify.Storage.uploadData(
                    data: StorageDataPayload.bytes(ackBytes!),
                    path: StoragePath.fromString(ackStoragePath),
                  ).result;

                  SupabaseBackupService().backupFileInBackground(ackStoragePath, ackBytes!);

                  await InwardPostService.updateAcknowledgement(
                    post.id,
                    ackPath: ackStoragePath,
                    ackFileName: ackFileName!,
                    ackDate: ackDate,
                  );

                  await LoggingService().logAction(
                    action: 'POST_ACKNOWLEDGEMENT_UPLOADED',
                    targetType: 'PostRegister',
                    targetId: post.id,
                    details: 'Uploaded acknowledgement for letter to ${post.recipientName}',
                  );

                  if (mounted) Navigator.pop(ctx);
                  await _loadPosts();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Acknowledgement uploaded and verified!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  debugPrint('Failed to upload acknowledgement: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent),
                    );
                  }
                } finally {
                  if (mounted) setModalState(() => isSubmitting = false);
                }
              },
              icon: isSubmitting 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save Acknowledgement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ATTACH / UPDATE SENT LETTER DOCUMENT DIALOG ---
  void _showAttachLetterDialog(InwardPost post) {
    Uint8List? pickedBytes;
    String? pickedFileName;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.attach_file_rounded, color: Colors.indigo, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Attach Sent Letter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attach the dispatch/sent letter copy for:\n"${post.recipientName}"',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                if (pickedFileName == null) ...[
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
                          withData: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;
                          Uint8List? bytes = file.bytes;
                          if (bytes == null && file.path != null) {
                            bytes = await File(file.path!).readAsBytes();
                          }
                          if (bytes != null) {
                            setModalState(() {
                              pickedBytes = bytes;
                              pickedFileName = file.name;
                            });
                          }
                        }
                      } catch (e) {
                        debugPrint('File pick error: $e');
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: const Text('Choose Letter File (PDF / Image / Doc)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description, color: Colors.indigo, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pickedFileName!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                          onPressed: () => setModalState(() {
                            pickedBytes = null;
                            pickedFileName = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: (pickedBytes == null || isSubmitting) ? null : () async {
                setModalState(() => isSubmitting = true);
                try {
                  final cleanName = pickedFileName!.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
                  final timestamp = DateTime.now().millisecondsSinceEpoch;
                  final letterStoragePath = 'public/posts/letters/${timestamp}_$cleanName';

                  await Amplify.Storage.uploadData(
                    data: StorageDataPayload.bytes(pickedBytes!),
                    path: StoragePath.fromString(letterStoragePath),
                  ).result;

                  SupabaseBackupService().backupFileInBackground(letterStoragePath, pickedBytes!);

                  await InwardPostService.updateLetterDocument(
                    post.id,
                    letterPath: letterStoragePath,
                    letterFileName: pickedFileName!,
                  );

                  await LoggingService().logAction(
                    action: 'SENT_LETTER_DOCUMENT_ATTACHED',
                    targetType: 'PostRegister',
                    targetId: post.id,
                    details: 'Attached letter document to post: $pickedFileName',
                  );

                  if (mounted) Navigator.pop(ctx);
                  await _loadPosts();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Letter document attached successfully!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  debugPrint('Failed to attach letter document: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent),
                    );
                  }
                } finally {
                  if (mounted) setModalState(() => isSubmitting = false);
                }
              },
              icon: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save Letter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- VIEW / DOWNLOAD DOCUMENT ---
  Future<void> _viewDocument(String storagePath, String documentTitle) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Text('Opening $documentTitle...')),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      final lowerTitle = documentTitle.toLowerCase();
      final isImage = lowerTitle.endsWith('.png') || lowerTitle.endsWith('.jpg') || lowerTitle.endsWith('.jpeg') || lowerTitle.endsWith('.webp');

      // 1. Get signed S3 URL with Amplify Storage
      final result = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(storagePath),
      ).result;
      final url = result.url;

      // 2. If it's an image, show in-app interactive preview dialog
      if (isImage && mounted) {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.image, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              documentTitle,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, color: Colors.white70, size: 18),
                            tooltip: 'Open in Browser',
                            onPressed: () => launchUrl(url, mode: LaunchMode.externalApplication),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),
                      Flexible(
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.network(
                            url.toString(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator(color: Colors.white));
                            },
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Text('Failed to load image preview', style: TextStyle(color: Colors.white70)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }

      // 3. For PDFs and other documents:
      // On Windows Desktop: download file locally and launch with default system viewer (Adobe Acrobat, Edge, Chrome)
      if (!kIsWeb) {
        try {
          final downloadRes = await Amplify.Storage.downloadData(
            path: StoragePath.fromString(storagePath),
          ).result;
          final bytes = downloadRes.bytes;
          final cleanFileName = documentTitle.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
          final tempDir = Directory.systemTemp;
          final tempFile = File('${tempDir.path}\\$cleanFileName');
          await tempFile.writeAsBytes(bytes);
          await Process.run('cmd', ['/c', 'start', '""', tempFile.path]);
          return;
        } catch (downloadErr) {
          debugPrint('Local temp open failed, falling back to browser: $downloadErr');
        }
      }

      // 4. Browser fallback: open pre-signed URL in default browser
      try {
        final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (launched) return;
      } catch (_) {}

      await launchUrl(url);
    } catch (e) {
      debugPrint('Error viewing document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open document: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // --- POST DETAILS DIALOG ---
  void _showPostDetailsDialog(InwardPost post) {
    final isSent = post.isSentLetter;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSent ? Icons.outgoing_mail : Icons.mark_email_unread_rounded,
              color: isSent ? Colors.indigo : Colors.teal,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isSent ? 'Sent Letter Details' : 'Inward Post Details',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender & Recipient Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSent ? 'To: ${post.recipientName}' : 'From: ${post.senderName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSent
                            ? 'From: ${post.senderName}  •  Sent by: ${post.receivedBy}'
                            : 'To: ${post.recipientName}  •  Received by: ${post.receivedBy}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      if (post.description.isNotEmpty) ...[
                        const Divider(height: 16),
                        Text(post.description, style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Connected Workfile
                if (post.workfileName != null) ...[
                  const Text('Connected Workfile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_shared_rounded, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '[${post.workfileNumber ?? "WF"}] ${post.workfileName}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Sent Letter Document Section
                if (isSent) ...[
                  const Text('Sent Letter Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  if (post.letterStoragePath != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description_rounded, color: Colors.indigo, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              post.letterFileName ?? 'Sent_Letter',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _viewDocument(post.letterStoragePath!, post.letterFileName ?? 'Sent_Letter'),
                            icon: const Icon(Icons.visibility_rounded, size: 14),
                            label: const Text('Open', style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAttachLetterDialog(post);
                      },
                      icon: const Icon(Icons.upload_file_outlined, size: 16),
                      label: const Text('Attach Letter File'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.indigo),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Acknowledgement Receipt Section
                  if (post.hasAcknowledgement) ...[
                    const Text('Acknowledgement Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 6),
                    if (post.isAckReceived && post.ackStoragePath != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                post.ackFileName ?? 'Acknowledgement_Receipt',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _viewDocument(post.ackStoragePath!, post.ackFileName ?? 'Acknowledgement_Receipt'),
                              icon: const Icon(Icons.visibility_rounded, size: 14),
                              label: const Text('Open', style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showUploadAcknowledgementDialog(post);
                        },
                        icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                        label: const Text('Upload Acknowledgement'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                      ),
                    ],
                  ],
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // --- CONFIRM INWARD RECEIPT ---
  Future<void> _confirmReceipt(InwardPost post) async {
    await InwardPostService.updatePostStatus(post.id, PostStatus.confirmedReceived);
    await LoggingService().logAction(
      action: 'INWARD_POST_CONFIRMED',
      targetType: 'Inward Post',
      targetId: post.id,
      details: 'Confirmed receipt of inward post from ${post.senderName}',
    );
    await _loadPosts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt confirmed.'), backgroundColor: Colors.green),
      );
    }
  }

  // --- DELETE POST ---
  Future<void> _deletePost(InwardPost post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Post Entry'),
        content: Text('Are you sure you want to delete this record (${post.isSentLetter ? "Sent to" : "From"} ${post.isSentLetter ? post.recipientName : post.senderName})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await InwardPostService.deletePost(post.id);
      await LoggingService().logAction(
        action: 'POST_ENTRY_DELETED',
        targetType: 'PostRegister',
        targetId: post.id,
        details: 'Deleted post record ${post.id}',
      );
      await _loadPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post record deleted.'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Search query filter
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _posts.where((p) {
      if (query.isNotEmpty) {
        final matchesSender = p.senderName.toLowerCase().contains(query);
        final matchesRecipient = p.recipientName.toLowerCase().contains(query);
        final matchesDesc = p.description.toLowerCase().contains(query);
        final matchesWf = (p.workfileName ?? '').toLowerCase().contains(query) ||
            (p.workfileNumber ?? '').toLowerCase().contains(query);
        if (!matchesSender && !matchesRecipient && !matchesDesc && !matchesWf) {
          return false;
        }
      }

      if (_activeFilter == 'outward') return p.isSentLetter;
      if (_activeFilter == 'inward') return !p.isSentLetter;
      if (_activeFilter == 'pending_ack') return p.isAwaitingAck;
      return true;
    }).toList();

    final sentCount = _posts.where((p) => p.isSentLetter).length;
    final inwardCount = _posts.where((p) => !p.isSentLetter).length;
    final pendingAckCount = _posts.where((p) => p.isAwaitingAck).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          children: [
            const Text(
              'Post Register & Sent Letters', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textColor)
            ),
            Text(
              'Track inward parcels, sent letters, workfiles & acknowledgements',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
            tooltip: 'Refresh Posts',
            onPressed: _loadInitialData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 900 ? 24.0 : 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 950;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 420, child: _buildLogForm()),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildArchivesList(
                        visiblePosts: filtered,
                        sentCount: sentCount,
                        inwardCount: inwardCount,
                        pendingAckCount: pendingAckCount,
                      ),
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLogForm(),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 700,
                        child: _buildArchivesList(
                          visiblePosts: filtered,
                          sentCount: sentCount,
                          inwardCount: inwardCount,
                          pendingAckCount: pendingAckCount,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // --- LOGGING FORM WIDGET ---
  Widget _buildLogForm() {
    final isSent = _postType == 'outward';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSent ? 'LOG SENT LETTER' : 'LOG INWARD POST',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSent ? Colors.indigo.shade50 : Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSent ? 'OUTWARD' : 'INWARD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSent ? Colors.indigo.shade700 : Colors.teal.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Post Type Switcher Segmented Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _postType = 'outward';
                        if (_senderController.text.isEmpty || _senderController.text == 'Sender Name') {
                          _senderController.text = 'Cochin United Consultancy';
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSent ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSent ? [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2)),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forward_to_inbox_rounded, size: 16, color: isSent ? Colors.indigo : Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Sent Letter',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSent ? FontWeight.bold : FontWeight.w500,
                              color: isSent ? Colors.indigo : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _postType = 'inward';
                        if (_senderController.text == 'Cochin United Consultancy') {
                          _senderController.clear();
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isSent ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !isSent ? [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2)),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mark_email_read_rounded, size: 16, color: !isSent ? Colors.teal : Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Inward Post',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: !isSent ? FontWeight.bold : FontWeight.w500,
                              color: !isSent ? Colors.teal : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sender input
          _buildInputField(
            controller: _senderController,
            hint: isSent ? 'From (e.g. Cochin United Consultancy)' : 'Sender Name / Authority',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),

          // Recipient input
          if (isSent) ...[
            _buildInputField(
              controller: _recipientController,
              hint: 'Recipient Name / Client / Department',
              icon: Icons.business_outlined,
            ),
          ] else ...[
            // Inward Autocomplete for internal recipient
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return _users;
                return _users.where((u) => 
                  (u['name']?.toString().toLowerCase() ?? '').contains(textEditingValue.text.toLowerCase())
                );
              },
              displayStringForOption: (u) => u['name']?.toString() ?? '',
              onSelected: (u) => _recipientController.text = u['name']?.toString() ?? '',
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return _buildInputField(
                  controller: textEditingController,
                  hint: 'Intended Staff / Manager (Recipient)',
                  icon: Icons.badge_outlined,
                  onChanged: (val) => _recipientController.text = val,
                );
              },
            ),
          ],
          const SizedBox(height: 12),

          // Connect Workfile Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedWorkfile != null ? AppTheme.primaryColor.withValues(alpha: 0.5) : Colors.grey.shade200,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<amplify_models.Deals?>(
                value: _selectedWorkfile,
                isExpanded: true,
                hint: Row(
                  children: [
                    Icon(Icons.folder_shared_outlined, size: 20, color: Colors.grey.shade400),
                    const SizedBox(width: 10),
                    Text('Connect Related Workfile (Optional)', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                  ],
                ),
                items: [
                  const DropdownMenuItem<amplify_models.Deals?>(
                    value: null,
                    child: Text('No Connected Workfile', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                  ..._workfiles.map((wf) {
                    final fileNo = wf.register_no?.isNotEmpty == true ? '[${wf.register_no}] ' : '';
                    final title = '$fileNo${wf.name ?? "Untitled Workfile"}';
                    return DropdownMenuItem<amplify_models.Deals?>(
                      value: wf,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() => _selectedWorkfile = val);
                },
              ),
            ),
          ),
          if (_selectedWorkfile != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Linked to Workfile: ${_selectedWorkfile!.name ?? "Workfile"}',
                      style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _selectedWorkfile = null),
                    child: const Icon(Icons.close, size: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Upload Sent Letter File Picker (when sent letter)
          if (isSent) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.upload_file_rounded, size: 18, color: Colors.purple),
                      const SizedBox(width: 8),
                      const Text(
                        'Upload Sent Letter Document',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_letterFileName == null) ...[
                    OutlinedButton.icon(
                      onPressed: _pickLetterFile,
                      icon: const Icon(Icons.attach_file_rounded, size: 16),
                      label: const Text('Attach Letter (PDF / Image)', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: BorderSide(color: Colors.purple.shade200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description_rounded, size: 16, color: Colors.purple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _letterFileName!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _clearSelectedLetter,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Toggle for Acknowledgement
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _hasAcknowledgement ? Colors.amber.shade50.withValues(alpha: 0.6) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasAcknowledgement ? Colors.amber.shade200 : Colors.grey.shade200,
                ),
              ),
              child: SwitchListTile(
                value: _hasAcknowledgement,
                onChanged: (val) => setState(() => _hasAcknowledgement = val),
                title: const Text('Requires Acknowledgement?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _hasAcknowledgement 
                      ? 'Will alert for signed receipt / proof of delivery' 
                      : 'No acknowledgement required for this letter',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                activeColor: Colors.orange,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            const SizedBox(height: 12),
          ],

          _buildInputField(
            controller: _receivedByController,
            hint: isSent ? 'Sent By / Handler' : 'Received By',
            icon: Icons.person_search_outlined,
            readOnly: true,
          ),
          const SizedBox(height: 12),

          _buildInputField(
            controller: _descriptionController,
            hint: 'Description / Notes / Reference No',
            icon: Icons.description_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _isUploading ? null : _logNewPost,
            icon: _isUploading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(isSent ? Icons.send_rounded : Icons.save_alt_rounded, size: 18),
            label: Text(
              _isUploading ? 'SAVING...' : (isSent ? 'REGISTER SENT LETTER' : 'REGISTER INWARD POST'),
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSent ? Colors.indigo : AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // --- ARCHIVES LIST & FILTER BAR ---
  Widget _buildArchivesList({
    required List<InwardPost> visiblePosts,
    required int sentCount,
    required int inwardCount,
    required int pendingAckCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('POST & LETTER ARCHIVES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.mutedTextColor, letterSpacing: 1.2)),
              Text('${visiblePosts.length} entries', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by recipient, sender, workfile, notes...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchController.clear()))
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All Posts (${_posts.length})'),
                const SizedBox(width: 8),
                _buildFilterChip('outward', 'Sent Letters ($sentCount)', icon: Icons.forward_to_inbox_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('inward', 'Inward Posts ($inwardCount)', icon: Icons.mark_email_read_rounded),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'pending_ack', 
                  'Awaiting Ack ($pendingAckCount)',
                  icon: Icons.hourglass_top_rounded,
                  badgeColor: pendingAckCount > 0 ? Colors.orange : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List of Posts
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : visiblePosts.isEmpty 
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: visiblePosts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildPostCard(visiblePosts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, {IconData? icon, Color? badgeColor}) {
    final isSelected = _activeFilter == key;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: isSelected ? Colors.white : (badgeColor ?? AppTheme.primaryColor)),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _activeFilter = key),
      selectedColor: badgeColor ?? AppTheme.primaryColor,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : Colors.grey.shade800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No matching records found', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }

  // --- POST ENTRY CARD ---
  Widget _buildPostCard(InwardPost post) {
    final isSent = post.isSentLetter;
    final isPendingInward = !isSent && post.status == PostStatus.pendingConfirmation;

    Color cardBorderColor = Colors.grey.shade200;
    if (isSent) {
      if (post.isAwaitingAck) {
        cardBorderColor = Colors.orange.withValues(alpha: 0.5);
      } else if (post.isAckReceived) {
        cardBorderColor = Colors.green.withValues(alpha: 0.4);
      } else {
        cardBorderColor = Colors.indigo.withValues(alpha: 0.3);
      }
    } else if (isPendingInward) {
      cardBorderColor = Colors.redAccent.withValues(alpha: 0.3);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showPostDetailsDialog(post),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorderColor, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Type badge + Status badges + Actions
          Row(
            children: [
              // Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSent ? Colors.indigo.shade50 : Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSent ? Icons.forward_to_inbox_rounded : Icons.mark_email_read_rounded,
                      size: 13,
                      color: isSent ? Colors.indigo : Colors.teal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSent ? 'SENT LETTER' : 'INWARD POST',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSent ? Colors.indigo : Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Acknowledgement Status Badge
              if (isSent && post.hasAcknowledgement) ...[
                if (post.isAwaitingAck)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_top_rounded, size: 12, color: Colors.orange.shade800),
                        const SizedBox(width: 4),
                        Text(
                          'Awaiting Acknowledgement',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                  )
                else if (post.isAckReceived)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Ack Received: ${post.ackReceivedDate != null ? DateFormat("dd MMM").format(post.ackReceivedDate!) : "Yes"}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
              ],
              const Spacer(),

              // Date
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(post.receivedDate),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),

              // Delete button for Admin / Manager
              if (widget.currentUserRole == 'admin' || widget.currentUserRole == 'manager') ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Delete Entry',
                  onPressed: () => _deletePost(post),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Main Header: To / From
          Text(
            isSent ? 'To: ${post.recipientName}' : 'From: ${post.senderName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textColor),
          ),
          const SizedBox(height: 4),

          // Subtitle: Sender & Handler info
          Text(
            isSent 
                ? 'From: ${post.senderName}  •  Sent by: ${post.receivedBy}'
                : 'To: ${post.recipientName}  •  Received by: ${post.receivedBy}',
            style: const TextStyle(fontSize: 12, color: AppTheme.mutedTextColor),
          ),

          // Description / Notes
          if (post.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              post.description,
              style: const TextStyle(fontSize: 13, color: AppTheme.textColor),
            ),
          ],
          const SizedBox(height: 10),

          // Connected Workfile Chip
          if (post.workfileName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_shared_rounded, size: 14, color: Colors.blue),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Workfile: [${post.workfileNumber ?? "WF"}] ${post.workfileName}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Document Action Buttons & Acknowledgement Handling
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 1. View Sent Letter Document (if uploaded)
              if (post.letterStoragePath != null) ...[
                OutlinedButton.icon(
                  onPressed: () => _viewDocument(post.letterStoragePath!, post.letterFileName ?? 'Sent_Letter'),
                  icon: const Icon(Icons.description_outlined, size: 14),
                  label: Text(
                    post.letterFileName != null ? 'View Letter (${post.letterFileName})' : 'View Sent Letter',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    side: BorderSide(color: Colors.indigo.shade200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                InkWell(
                  onTap: () => _showAttachLetterDialog(post),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 12, color: Colors.grey),
                  ),
                ),
              ],

              // 2. Attach Letter File (if sent letter has no document attached yet)
              if (isSent && post.letterStoragePath == null) ...[
                OutlinedButton.icon(
                  onPressed: () => _showAttachLetterDialog(post),
                  icon: const Icon(Icons.upload_file_outlined, size: 14, color: Colors.indigo),
                  label: const Text(
                    'Attach Letter File',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.indigo),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    side: BorderSide(color: Colors.indigo.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],

              // 3. Upload Acknowledgement (if awaiting)
              if (isSent && post.isAwaitingAck) ...[
                ElevatedButton.icon(
                  onPressed: () => _showUploadAcknowledgementDialog(post),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 14),
                  label: const Text('Upload Acknowledgement', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],

              // 4. View Acknowledgement (if already received)
              if (isSent && post.isAckReceived && post.ackStoragePath != null) ...[
                OutlinedButton.icon(
                  onPressed: () => _viewDocument(post.ackStoragePath!, post.ackFileName ?? 'Acknowledgement_Receipt'),
                  icon: const Icon(Icons.verified_outlined, size: 14, color: Colors.green),
                  label: Text(
                    post.ackFileName != null ? 'Ack Receipt (${post.ackFileName})' : 'View Acknowledgement',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                // Re-upload / Update button
                InkWell(
                  onTap: () => _showUploadAcknowledgementDialog(post),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 12, color: Colors.grey),
                  ),
                ),
              ],

              // 5. Inward Confirm Receipt
              if (isPendingInward) ...[
                ElevatedButton(
                  onPressed: () => _confirmReceipt(post),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('CONFIRM INWARD RECEIPT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade100 : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onChanged: onChanged,
        style: TextStyle(color: readOnly ? Colors.grey.shade600 : AppTheme.textColor, fontSize: 13),
        decoration: InputDecoration(
          prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey.shade400, size: 18) : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
