import 'package:flutter/material.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../models/inward_post_model.dart';
import '../services/inward_post_service.dart';
import '../models/deal.dart';
import '../services/deal_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';

import 'create_file_acknowledgement_screen.dart';

class FileAcknowledgementScreen extends StatefulWidget {
  final String currentUserRole;
  final String currentUserName;

  final Deal? initialDeal;
  final String? initialFileName;
  final String? initialFromName;
  final String? initialAction;

  const FileAcknowledgementScreen({
    super.key,
    required this.currentUserRole,
    required this.currentUserName,
    this.initialDeal,
    this.initialFileName,
    this.initialFromName,
    this.initialAction,
  });

  @override
  State<FileAcknowledgementScreen> createState() => _FileAcknowledgementScreenState();
}

class _FileAcknowledgementScreenState extends State<FileAcknowledgementScreen> {
  List<InwardPost> _posts = [];
  final List<StreamSubscription> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialAction != null && widget.initialAction == 'Create') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToCreateScreen();
      });
    }
    
    _loadPosts();
    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    try {
      final req = ModelSubscriptions.onCreate(amplify_models.InwardPosts.classType);
      _subscriptions.add(Amplify.API.subscribe(req, onEstablished: () {}).listen((event) => _loadPosts()));
      final reqUp = ModelSubscriptions.onUpdate(amplify_models.InwardPosts.classType);
      _subscriptions.add(Amplify.API.subscribe(reqUp, onEstablished: () {}).listen((event) => _loadPosts()));
      final reqDel = ModelSubscriptions.onDelete(amplify_models.InwardPosts.classType);
      _subscriptions.add(Amplify.API.subscribe(reqDel, onEstablished: () {}).listen((event) => _loadPosts()));
    } catch (e) {
      debugPrint('Failed to setup subscriptions: $e');
    }
  }



  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final posts = await InwardPostService.getPosts();
    List<Map<String, dynamic>> users = [];
    try {
      final req = ModelQueries.list(amplify_models.Users.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      final usersList = (res.data?.items ?? []).whereType<amplify_models.Users>().toList() ?? [];
      usersList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      users = usersList.map((u) => {
        'id': u.id,
        'name': u.name,
        'role': u.role,
      }).toList();
    } catch(e) {
      debugPrint('Error fetching users: $e');
    }
    
    if (mounted) {
      setState(() {
        // Show file acknowledgements by checking ID prefix OR description
        _posts = posts.where((p) => 
          p.id.startsWith('FILEACK-') || 
          p.description.startsWith('[Received] File:') ||
          p.description.startsWith('[Returned] File:')
        ).toList();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var s in _subscriptions) { s.cancel(); }
    super.dispose();
  }

  void _navigateToCreateScreen({InwardPost? postToEdit}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateFileAcknowledgementScreen(
          currentUserRole: widget.currentUserRole,
          currentUserName: widget.currentUserName,
          initialDeal: widget.initialDeal,
          initialFileName: widget.initialFileName,
          initialFromName: widget.initialFromName,
          initialAction: widget.initialAction,
          editingPost: postToEdit,
        ),
      ),
    ).then((value) {
      if (value == true) {
        _loadPosts();
      }
    });
  }



  Future<void> _confirmReceipt(InwardPost post) async {
    await InwardPostService.updatePostStatus(post.id, PostStatus.confirmedReceived);
    await _loadPosts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acknowledgement confirmed.'), backgroundColor: Colors.green),
      );
    }
  }


  Future<Uint8List> _generatePdfDocument(InwardPost post, PdfPageFormat format) async {
    final doc = pw.Document();
    
    String action = 'Received';
    String fileDesc = post.description;
    if (post.description.startsWith('[Received]')) {
      action = 'Received';
      fileDesc = post.description.replaceAll('[Received]', '').trim();
    } else if (post.description.startsWith('[Returned]')) {
      action = 'Returned';
      fileDesc = post.description.replaceAll('[Returned]', '').trim();
    }

    // Parse files from fileDesc
    String filesPart = fileDesc;
    String remarks = '';
    String title = '';
    
    if (filesPart.contains('Title: ') && filesPart.contains(' | File: ')) {
      final titlePart = filesPart.split(' | File: ')[0];
      title = titlePart.replaceFirst('Title: ', '').trim();
      filesPart = filesPart.substring(filesPart.indexOf(' | File: ') + 9);
    }

    if (filesPart.contains(' | Remarks:')) {
      final parts = fileDesc.split(' | Remarks:');
      filesPart = parts[0];
      remarks = parts[1].trim();
    }
    if (filesPart.startsWith('File: ')) {
      filesPart = filesPart.replaceFirst('File: ', '');
    }
    String legacyFileTypeStr = '';
    if (filesPart.contains('(') && filesPart.endsWith(')')) {
      int lastParen = filesPart.lastIndexOf('(');
      legacyFileTypeStr = filesPart.substring(lastParen).trim();
      legacyFileTypeStr = legacyFileTypeStr.replaceAll('(', '[').replaceAll(')', ']');
      filesPart = filesPart.substring(0, lastParen).trim();
    }
    List<String> filePartsList = filesPart.contains(' ; ') ? filesPart.split(' ; ') : filesPart.split(',');
    List<String> fileNames = filePartsList.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    List<pw.Widget> buildAddress(String name, bool isCompany) {
      return [
        pw.Text(name.toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        if (isCompany) ...[
          pw.Text('COCHIN UNITED CONSULTANCY', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text('4th FLOOR, MATHER SQUARE, C- BLOCK,', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('NEAR NORTH RAILWAY STATION', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('ERNAKULAM - 682018', style: const pw.TextStyle(fontSize: 10)),
        ]
      ];
    }

    bool recipientIsCompany = action == 'Received';
    bool senderIsCompany = action == 'Returned';

    String fromName = post.recipientName;
    bool fromIsCompany = recipientIsCompany;

    String toName = post.senderName;
    bool toIsCompany = senderIsCompany;
    
    String bodyText = action == 'Returned' 
        ? 'We hereby acknowledge receipt of the below-mentioned documents:' 
        : 'The following documents are submitted herewith:';

    pw.MemoryImage? logoImage;
    try {
      final ByteData bytes = await rootBundle.load('assets/logo.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (e) {
      debugPrint('Could not load logo for PDF: $e');
    }

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          buildBackground: (pw.Context context) {
            if (logoImage != null && action != 'Returned') {
              return pw.Center(
                child: pw.Opacity(
                  opacity: 0.1,
                  child: pw.Image(logoImage, width: 480, height: 480),
                ),
              );
            }
            return pw.SizedBox();
          },
        ),
        footer: (pw.Context context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.SizedBox(height: 20),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Ernakulam', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text(DateFormat('dd/MM/yyyy').format(post.receivedDate), style: const pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                    pw.SizedBox(),
                  ]
                )
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ),
            ]
          );
        },
        build: (pw.Context context) {
          return [
            if (action != 'Returned') ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (logoImage != null) pw.Image(logoImage, width: 90, height: 90) else pw.SizedBox(width: 90, height: 90),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'COCHIN UNITED CONSULTANCY',
                        style: pw.TextStyle(fontSize: 16, color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '4th Floor, Mather Square, C- Block,',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        'Near North Railway Station, Ernakulam, Kerala 682018',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('email id: cochinunitedconsultancydm@gmail.com', style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue700)),

                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 24),
            ] else ...[
              pw.SizedBox(height: 80),
            ],
            
            // Acknowledgement Letter Content
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20),
              child: pw.Center(
                child: pw.Text(
                  'ACKNOWLEDGEMENT LETTER',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 30),
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20),
              child: pw.Text('FROM', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 60, right: 20, top: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: buildAddress(fromName, fromIsCompany),
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20),
              child: pw.Text('TO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 60, right: 20, top: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: buildAddress(toName, toIsCompany),
              ),
            ),
            
            pw.SizedBox(height: 30),
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20),
              child: pw.Text('Sub: Document Acknowledgement Letter.', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ),
            
            pw.SizedBox(height: 20),
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20),
              child: pw.Text(bodyText, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ),
            
            if (title.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                child: pw.Text('Title: $title', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ),
            ],

            pw.SizedBox(height: 20),
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Sl No', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Document Name', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Type', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Remarks', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...List.generate(fileNames.length, (index) {
                      String fName = fileNames[index];
                      String fileRemark = '';
                      String currentFileType = legacyFileTypeStr.isNotEmpty ? legacyFileTypeStr : '[Original]';
                      
                      if (fName.contains('||')) {
                        final typeParts = fName.split('||');
                        fName = typeParts[0].trim();
                        if (typeParts.length > 1) {
                          final rest = typeParts[1];
                          if (rest.contains('::')) {
                            final rParts = rest.split('::');
                            currentFileType = '[${rParts[0].trim()}]';
                            fileRemark = rParts[1].trim();
                          } else {
                            currentFileType = '[${rest.trim()}]';
                          }
                        }
                      } else if (fName.contains('::')) {
                        final parts = fName.split('::');
                        fName = parts[0].trim();
                        if (parts.length > 1) {
                          fileRemark = parts[1].trim();
                        }
                      }
                      if (fileRemark.isEmpty && remarks.isNotEmpty) {
                        fileRemark = remarks;
                      }

                      return pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${index + 1}', style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fName.toUpperCase(), style: const pw.TextStyle(fontSize: 10))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(currentFileType, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fileRemark, style: const pw.TextStyle(fontSize: 10))),
                      ],
                    );
                  }),
                ],
              ),
            ),
            
          ];
        },
      ),
    );
    return doc.save();
  }

  Future<void> _printAcknowledgement(InwardPost post) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => _generatePdfDocument(post, format),
      name: 'Acknowledgement_${post.id}.pdf',
    );
  }

  void _showPdfPreviewDialog(InwardPost post) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PdfPreview(
                build: (format) => _generatePdfDocument(post, format),
                allowPrinting: true,
                allowSharing: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
              ),
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final visiblePosts = _posts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'File Handover Acknowledgements', 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF1E293B), letterSpacing: -0.5)
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _navigateToCreateScreen(),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text('Create New', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFB),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.0))),
                      Expanded(flex: 2, child: Text('HANDED OVER BY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.0))),
                      Expanded(flex: 2, child: Text('RECEIVED BY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.0))),
                      Expanded(flex: 2, child: Text('DATE & TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.0))),
                      SizedBox(width: 100, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.0))),
                      SizedBox(width: 140, child: Text('ACTIONS', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.0))),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : visiblePosts.isEmpty 
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text('No acknowledgements found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: visiblePosts.length,
                              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                              itemBuilder: (context, index) {
                                return _buildTableRow(visiblePosts[index]);
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(InwardPost post) {
    final isConfirmed = post.status == PostStatus.confirmedReceived;
    
    String action = 'Received';
    String fileDesc = post.description;
    if (post.description.startsWith('[Received]')) {
      action = 'Received';
      fileDesc = post.description.replaceAll('[Received]', '').trim();
    } else if (post.description.startsWith('[Returned]')) {
      action = 'Returned';
      fileDesc = post.description.replaceAll('[Returned]', '').trim();
    }

    final actionColor = action == 'Received' ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B);
    final iconData = action == 'Received' ? Icons.file_download_outlined : Icons.file_upload_outlined;

    String displayTitle = fileDesc;
    if (fileDesc.contains('Title: ') && fileDesc.contains(' | File: ')) {
      final titlePart = fileDesc.split(' | File: ')[0];
      displayTitle = titlePart.replaceFirst('Title: ', '').trim();
      if (displayTitle.isEmpty) displayTitle = 'Untitled Acknowledgement';
    }

    return InkWell(
      onTap: () => _showPdfPreviewDialog(post),
      hoverColor: Colors.blue.withValues(alpha: 0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Icon Anchor
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: actionColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: actionColor.withValues(alpha: 0.2)),
                  ),
                  child: Icon(iconData, color: actionColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayTitle, 
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B), height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          action.toUpperCase(),
                          style: TextStyle(color: actionColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // buffer
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blueGrey.shade50,
                  child: Text(post.senderName.isNotEmpty ? post.senderName[0].toUpperCase() : '?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(post.senderName, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.teal.shade50,
                  child: Text(post.recipientName.isNotEmpty ? post.recipientName[0].toUpperCase() : '?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(post.recipientName, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(DateFormat('MMM dd, yyyy').format(post.receivedDate), style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(DateFormat('hh:mm a').format(post.receivedDate), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('By: ${post.receivedBy}', style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: isConfirmed 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 14), 
                        const SizedBox(width: 4), 
                        Text('Confirmed', style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold))
                      ]
                    )
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pending_actions_rounded, color: Colors.orange.shade600, size: 14), 
                        const SizedBox(width: 4), 
                        Text('Pending', style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.bold))
                      ]
                    )
                  ),
          ),
          SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: () => _navigateToCreateScreen(postToEdit: post), icon: Icon(Icons.edit_note_rounded, color: Colors.blue.shade600, size: 24), tooltip: 'Edit', padding: const EdgeInsets.all(4), constraints: const BoxConstraints()),
                const SizedBox(width: 8),
                IconButton(onPressed: () => _printAcknowledgement(post), icon: Icon(Icons.print_rounded, color: Colors.teal.shade600, size: 20), tooltip: 'Print', padding: const EdgeInsets.all(4), constraints: const BoxConstraints()),
                if (!isConfirmed && post.recipientName.toLowerCase() == widget.currentUserName.toLowerCase()) ...[
                  const SizedBox(width: 8),
                  IconButton(onPressed: () => _confirmReceipt(post), icon: Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade600, size: 22), tooltip: 'Confirm', padding: const EdgeInsets.all(4), constraints: const BoxConstraints()),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}



}
