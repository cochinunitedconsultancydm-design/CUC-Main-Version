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
import 'dart:typed_data';
import 'package:flutter/services.dart';

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
  final _fileController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _newFileController = TextEditingController();
  
  String _actionType = 'Received';
  String _fileType = 'Original';
  List<InwardPost> _posts = [];
  List<Map<String, dynamic>> _users = [];
  List<Deal> _deals = [];
  Deal? _selectedDeal;
  List<String> _selectedFiles = [];
  Map<String, String> _fileRemarks = {};
  final Map<String, TextEditingController> _fileRemarkControllers = {};
  bool _isLoading = true;
  InwardPost? _selectedPost;
  InwardPost? _editingPost;
  StateSetter? _dialogSetState;

  void _updateState(VoidCallback fn) {
    setState(fn);
    if (_dialogSetState != null) {
      _dialogSetState!(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialAction != null) {
      _actionType = widget.initialAction!;
    }
    
    _updateControllersForAction();

    if (widget.initialFileName != null) {
      _fileController.text = widget.initialFileName!;
      _selectedFiles = widget.initialFileName!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    
    _loadPosts();
  }

  void _updateControllersForAction({bool clearFiles = true}) {
    String dealClientData = '';
    if (_selectedDeal != null) {
      List<String> parts = [];
      if (_selectedDeal!.clientName != null && _selectedDeal!.clientName!.isNotEmpty) {
        parts.add(_selectedDeal!.clientName!);
      }
      if (_selectedDeal!.company != null && _selectedDeal!.company!.isNotEmpty) {
        parts.add(_selectedDeal!.company!);
      }
      if (_selectedDeal!.contactInfo != null && _selectedDeal!.contactInfo!.isNotEmpty) {
        parts.add(_selectedDeal!.contactInfo!);
      }
      dealClientData = parts.join('\n');
    }

    String currentClientName = '';
    if (_fromController.text != widget.currentUserName && _fromController.text.isNotEmpty) {
      currentClientName = _fromController.text;
    } else if (_toController.text != widget.currentUserName && _toController.text.isNotEmpty) {
      currentClientName = _toController.text;
    }

    if (_actionType == 'Received') {
      _toController.text = widget.currentUserName;
      if (_selectedDeal != null) {
        _fromController.text = dealClientData;
      } else if (widget.initialFromName != null) {
        _fromController.text = widget.initialFromName!;
      } else if (currentClientName.isNotEmpty) {
        _fromController.text = currentClientName;
      } else if (_editingPost == null) {
        _fromController.clear();
      }
    } else {
      _fromController.text = widget.currentUserName;
      if (_selectedDeal != null) {
        _toController.text = dealClientData;
      } else if (widget.initialFromName != null) {
        _toController.text = widget.initialFromName!;
      } else if (currentClientName.isNotEmpty) {
        _toController.text = currentClientName;
      } else if (_editingPost == null) {
        _toController.clear();
      }
    }
    
    if (clearFiles) {
      _selectedFiles.clear();
      _fileController.clear();
    }
  }

  Future<void> _loadPosts() async {
    _updateState(() => _isLoading = true);
    final posts = await InwardPostService.getPosts();
    List<Deal> deals = [];
    try {
      deals = await DealService().getAllDeals();
    } catch(e) {
      debugPrint('Error fetching deals: $e');
    }
    List<Map<String, dynamic>> users = [];
    try {
      final req = ModelQueries.list(amplify_models.Users.classType);
      final res = await Amplify.API.query(request: req).response;
      final usersList = res.data?.items.whereType<amplify_models.Users>().toList() ?? [];
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
      _updateState(() {
        // Show file acknowledgements by checking ID prefix OR description
        _posts = posts.where((p) => 
          p.id.startsWith('FILEACK-') || 
          p.description.startsWith('[Received] File:') ||
          p.description.startsWith('[Returned] File:')
        ).toList();
        _users = users;
        _deals = deals;
        if (widget.initialDeal != null) {
          try {
            _selectedDeal = deals.firstWhere((d) => d.id == widget.initialDeal!.id);
          } catch(e) {
            _selectedDeal = widget.initialDeal;
          }
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fileController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _newFileController.dispose();
    for (var c in _fileRemarkControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _logAcknowledgement() async {
    if (_selectedDeal == null && _editingPost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must link this acknowledgement to a Work / Deal.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final String fileName = _selectedFiles.map((f) {
      final remark = _fileRemarks[f] ?? '';
      return remark.isNotEmpty ? '$f::$remark' : f;
    }).join(' ; ');

    if (fileName.isEmpty || _fromController.text.trim().isEmpty || _toController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File Name, Handed Over By, and Received By are required'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final newPost = InwardPost(
      id: _editingPost?.id ?? 'FILEACK-${DateTime.now().millisecondsSinceEpoch}',
      senderName: _fromController.text.trim(),
      recipientName: _toController.text.trim(),
      receivedBy: _editingPost?.receivedBy ?? widget.currentUserName,
      receivedDate: _editingPost?.receivedDate ?? DateTime.now(),
      status: _editingPost?.status ?? PostStatus.pendingConfirmation,
      description: '[$_actionType] File: $fileName ($_fileType)',
    );

    if (_editingPost != null) {
      await InwardPostService.updatePost(newPost);
    } else {
      await InwardPostService.addPost(newPost);
    }
    
    if (_selectedDeal != null && _selectedFiles.isNotEmpty) {
      try {
        List<Map<String, dynamic>> fileStates = [];
        final rawReceived = _selectedDeal!.filesReceived ?? '';
        final receivedJson = rawReceived.isEmpty ? '[]' : rawReceived;
        final decoded = jsonDecode(receivedJson);
        if (decoded is List) {
           if (decoded.isNotEmpty && decoded.first is String) {
             fileStates = decoded.map((e) => {'name': e.toString(), 'status': 'Received', 'type': 'Copy'}).toList();
           } else {
             fileStates = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
           }
        }
        
        List<String> askedList = (_selectedDeal!.filesAsked ?? '').split(RegExp(r'[,\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

        for (final file in _selectedFiles) {
          int stateIndex = fileStates.indexWhere((s) => s['name'] == file);
          if (stateIndex != -1) {
            fileStates[stateIndex]['status'] = _actionType == 'Received' ? 'Received' : 'Returned';
          } else {
            fileStates.add({
              'name': file,
              'status': _actionType == 'Received' ? 'Received' : 'Returned',
              'type': 'Copy'
            });
          }
          if (_actionType == 'Received' && !askedList.contains(file)) {
            askedList.add(file);
          }
        }

        final updatedDeal = _selectedDeal!.copyWith(
          filesReceived: jsonEncode(fileStates),
          filesAsked: askedList.join(', ')
        );
        await DealService().updateDeal(updatedDeal);
        
        final idx = _deals.indexWhere((d) => d.id == _selectedDeal!.id);
        if (idx != -1) _deals[idx] = updatedDeal;
        _selectedDeal = updatedDeal;

      } catch (e) {
        debugPrint('Error updating deal files: $e');
      }
    }

    _updateState(() {
      _fileController.clear();
      _selectedFiles.clear();
      _fileRemarks.clear();
      for (var c in _fileRemarkControllers.values) {
        c.clear();
      }
      _newFileController.clear();
      _editingPost = null;
      if (_actionType == 'Received') {
        if (_selectedDeal == null) _fromController.clear();
        _toController.text = widget.currentUserName;
      } else {
        _toController.clear();
        if (_selectedDeal == null) _fromController.text = widget.currentUserName;
      }
    });

    await _loadPosts();

    if (mounted) {
      Navigator.of(context).pop(); // Close dialog if open
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acknowledgement logged successfully!'), backgroundColor: Colors.green),
      );
    }
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
    if (fileDesc.contains(' | Remarks:')) {
      final parts = fileDesc.split(' | Remarks:');
      filesPart = parts[0];
      remarks = parts[1].trim();
    }
    if (filesPart.startsWith('File: ')) {
      filesPart = filesPart.replaceFirst('File: ', '');
    }
    String fileTypeStr = '';
    if (filesPart.contains('(') && filesPart.endsWith(')')) {
      int lastParen = filesPart.lastIndexOf('(');
      fileTypeStr = filesPart.substring(lastParen).trim();
      fileTypeStr = fileTypeStr.replaceAll('(', '[').replaceAll(')', ']');
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

    String fromName = action == 'Returned' ? post.senderName : post.recipientName;
    bool fromIsCompany = action == 'Returned' ? senderIsCompany : recipientIsCompany;

    String toName = action == 'Returned' ? post.recipientName : post.senderName;
    bool toIsCompany = action == 'Returned' ? recipientIsCompany : senderIsCompany;
    
    String bodyText = action == 'Returned' 
        ? 'We are hereby returning the below mentioned documents' 
        : 'I hereby acknowledge that I have received the below mentioned documents';

    pw.MemoryImage? logoImage;
    try {
      final ByteData bytes = await rootBundle.load('assets/logo.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (e) {
      debugPrint('Could not load logo for PDF: $e');
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              if (logoImage != null)
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, width: 480, height: 480),
                  ),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Letterhead Header
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
                          pw.Text('mob no: +91 8590290105', style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                  pw.SizedBox(height: 24),
                  
                  // Acknowledgement Letter Content
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Center(
                          child: pw.Text(
                            'ACKNOWLEDGEMENT LETTER',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              decoration: pw.TextDecoration.underline,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 30),
                        
                        pw.Text('FROM', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 40, top: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: buildAddress(fromName, fromIsCompany),
                          ),
                        ),
                        
                        pw.SizedBox(height: 20),
                        
                        pw.Text('TO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 40, top: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: buildAddress(toName, toIsCompany),
                          ),
                        ),
                        
                        pw.SizedBox(height: 30),
                        
                        pw.Text('Sub: Document Acknowledgement Letter.', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        
                        pw.SizedBox(height: 20),
                        
                        pw.Text(bodyText, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        
                        pw.SizedBox(height: 20),
                        
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 20),
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
                                if (fName.contains('::')) {
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
                                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fileTypeStr, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center)),
                                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fileRemark, style: const pw.TextStyle(fontSize: 10))),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.Spacer(),
                  
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
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('Yours faithfully', style: const pw.TextStyle(fontSize: 11)),
                            pw.SizedBox(height: 40),
                            pw.Text(fromName.toUpperCase(), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ]
                    )
                  )
                ],
              ),
            ],
          );
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

  void _showCreateDialog({InwardPost? postToEdit}) {
    if (postToEdit != null) {
      _editingPost = postToEdit;
      String action = 'Received';
      String fileDesc = postToEdit.description;
      if (postToEdit.description.startsWith('[Received]')) {
        action = 'Received';
        fileDesc = postToEdit.description.replaceAll('[Received]', '').trim();
      } else if (postToEdit.description.startsWith('[Returned]')) {
        action = 'Returned';
        fileDesc = postToEdit.description.replaceAll('[Returned]', '').trim();
      }
      _actionType = action;
      
      String filesPart = fileDesc;
      if (fileDesc.contains(' | Remarks:')) {
        final parts = fileDesc.split(' | Remarks:');
        filesPart = parts[0];
      }
      
      if (filesPart.startsWith('File: ')) {
        filesPart = filesPart.replaceFirst('File: ', '');
      }
      String fileTypeStr = 'Original';
      if (filesPart.contains('(') && filesPart.endsWith(')')) {
        int lastParen = filesPart.lastIndexOf('(');
        String extractedType = filesPart.substring(lastParen).replaceAll('(', '').replaceAll(')', '').trim();
        if (extractedType.toLowerCase().contains('copy')) {
          fileTypeStr = 'Copy';
        } else {
          fileTypeStr = 'Original';
        }
        filesPart = filesPart.substring(0, lastParen).trim();
      }
      _fileType = fileTypeStr;
      
      _fileRemarks.clear();
      List<String> filePartsList = filesPart.contains(' ; ') ? filesPart.split(' ; ') : filesPart.split(',');
      _selectedFiles = filePartsList.map((e) {
        String f = e.trim();
        if (f.contains('::')) {
          final parts = f.split('::');
          String name = parts[0].trim();
          if (parts.length > 1) {
            _fileRemarks[name] = parts[1].trim();
          }
          return name;
        }
        return f;
      }).where((e) => e.isNotEmpty).toList();
      _fromController.text = postToEdit.senderName;
      _toController.text = postToEdit.recipientName;
      _selectedDeal = null; // Let them link it if they want, else it stays null
      
      // Update controllers
      _fileRemarkControllers.forEach((key, controller) {
        controller.text = _fileRemarks[key] ?? '';
      });
    } else {
      _editingPost = null;
      _selectedFiles.clear();
      _fileRemarks.clear();
      for (var c in _fileRemarkControllers.values) {
        c.clear();
      }
      _updateControllersForAction();
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            _dialogSetState = setDialogState;
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
                child: _buildLogForm(),
              ),
            );
          }
        );
      }
    ).then((_) {
      _dialogSetState = null;
      _editingPost = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visiblePosts = _posts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'File Handover Acknowledgements', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textColor)
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 800 ? 24.0 : 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildArchivesList(visiblePosts)),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildLivePreview()),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 1, child: _buildArchivesList(visiblePosts)),
                    const SizedBox(height: 16),
                    Expanded(flex: 1, child: _buildLivePreview()),
                  ],
                );
              }
            }
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: _selectedPost == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, size: 64, color: Colors.black12),
                  SizedBox(height: 16),
                  Text('Select an acknowledgement to preview', style: TextStyle(color: Colors.black38, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Or tap + to create a new one', style: TextStyle(color: Colors.black38, fontSize: 14)),
                ],
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PdfPreview(
                build: (format) => _generatePdfDocument(_selectedPost!, format),
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                allowPrinting: true,
                allowSharing: true,
              ),
            ),
    );
  }

  Widget _buildDealAutocomplete() {
    return Autocomplete<Deal>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Deal>.empty();
        }
        return _deals.where((Deal deal) {
          final dealName = deal.name.toLowerCase();
          final clientName = (deal.clientName ?? '').toLowerCase();
          final query = textEditingValue.text.toLowerCase();
          return dealName.contains(query) || clientName.contains(query);
        });
      },
      displayStringForOption: (Deal option) => '${option.name} (${option.clientName ?? 'No Client'})',
      onSelected: (Deal selection) {
        _updateState(() {
          _selectedDeal = selection;
          _updateControllersForAction(clearFiles: _editingPost == null);
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (_selectedDeal != null && controller.text.isEmpty) {
           controller.text = '${_selectedDeal!.name} (${_selectedDeal!.clientName ?? 'No Client'})';
        }
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: _editingPost != null ? 'Link to a Work / Deal (Optional for Edit)' : 'Link to a Work / Deal (Required)',
            hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
            prefixIcon: const Icon(Icons.business_center, color: AppTheme.primaryColor),
            suffixIcon: _selectedDeal != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      controller.clear();
                      _updateState(() {
                        _selectedDeal = null;
                        _updateControllersForAction();
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 300,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final deal = options.elementAt(index);
                  return ListTile(
                    title: Text(deal.name, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(deal.clientName ?? 'No Client', style: const TextStyle(fontSize: 12)),
                    onTap: () => onSelected(deal),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileChecklist() {
    List<String> availableFiles = [];
    
    if (_selectedDeal != null) {
      // Parse Deal files
      List<Map<String, dynamic>> fileStates = [];
      try {
        final rawReceived = _selectedDeal!.filesReceived ?? '';
        final receivedJson = rawReceived.isEmpty ? '[]' : rawReceived;
        final decoded = jsonDecode(receivedJson);
        if (decoded is List) {
           if (decoded.isNotEmpty && decoded.first is String) {
             fileStates = decoded.map((e) => {'name': e.toString(), 'status': 'Received', 'type': 'Copy'}).toList();
           } else {
             fileStates = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
           }
        }
      } catch(e) {
        debugPrint('Error parsing files: $e');
      }
      
      final askedList = (_selectedDeal!.filesAsked ?? '').split(RegExp(r'[,\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      if (_actionType == 'Received') {
        // Show asked files that are not received yet
        for (final f in askedList) {
          final state = fileStates.firstWhere((s) => s['name'] == f, orElse: () => {'name': f, 'status': 'Pending', 'type': 'Copy'});
          if (state['status'] != 'Received') {
            availableFiles.add(f);
          }
        }
      } else {
        // Show files that are currently received
        for (final state in fileStates) {
          if (state['status'] == 'Received') {
            availableFiles.add(state['name']);
          }
        }
      }
    }

    // Include newly typed files
    for (final f in _selectedFiles) {
      if (!availableFiles.contains(f)) {
        availableFiles.add(f);
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _actionType == 'Received' ? 'Select files being received:' : 'Select files being handed over:',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          if (availableFiles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No matching files found. You can add one below.', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableFiles.map((file) {
              final isSelected = _selectedFiles.contains(file);
              return FilterChip(
                label: Text(file, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                selected: isSelected,
                selectedColor: AppTheme.primaryColor,
                checkmarkColor: Colors.white,
                onSelected: (val) {
                  _updateState(() {
                    if (val) _selectedFiles.add(file);
                    else _selectedFiles.remove(file);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newFileController,
                  decoration: InputDecoration(
                    hintText: 'Type new file name and press Add...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      _updateState(() {
                        if (!_selectedFiles.contains(val.trim())) _selectedFiles.add(val.trim());
                        _newFileController.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final val = _newFileController.text.trim();
                  if (val.isNotEmpty) {
                    _updateState(() {
                      if (!_selectedFiles.contains(val)) _selectedFiles.add(val);
                      _newFileController.clear();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedFiles.isNotEmpty) ...[
            const Text('File Remarks:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            ..._selectedFiles.map((f) {
              _fileRemarkControllers[f] ??= TextEditingController(text: _fileRemarks[f] ?? '');
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _fileRemarkControllers[f],
                  decoration: InputDecoration(
                    labelText: f,
                    hintText: 'Add remarks for $f (optional)',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (val) {
                    _fileRemarks[f] = val;
                  },
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildLogForm() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_editingPost != null ? 'EDIT ACKNOWLEDGEMENT' : 'CREATE ACKNOWLEDGEMENT', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.2)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Received', style: TextStyle(fontSize: 14)),
                    value: 'Received',
                    groupValue: _actionType,
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      _updateState(() {
                        _actionType = val!;
                        _updateControllersForAction(clearFiles: false);
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Returned', style: TextStyle(fontSize: 14)),
                    value: 'Returned',
                    groupValue: _actionType,
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      _updateState(() {
                        _actionType = val!;
                        _updateControllersForAction(clearFiles: false);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDealAutocomplete(),
            const SizedBox(height: 16),
            if (_selectedDeal == null && _editingPost == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(child: Text('Please select a Work / Deal above to proceed with the file acknowledgement.', style: TextStyle(color: Colors.orange, fontSize: 13))),
                  ],
                ),
              )
            else
              _buildFileChecklist(),
            const SizedBox(height: 16),
            if (_selectedDeal != null || _editingPost != null) ...[
              const Text('FILE TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Original', style: TextStyle(fontSize: 14)),
                      value: 'Original',
                      groupValue: _fileType,
                      activeColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        _updateState(() {
                          _fileType = val!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Copy', style: TextStyle(fontSize: 14)),
                      value: 'Copy',
                      groupValue: _fileType,
                      activeColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        _updateState(() {
                          _fileType = val!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildUserAutocomplete(controller: _fromController, hint: 'Handed Over By', icon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildUserAutocomplete(controller: _toController, hint: 'Received By', icon: Icons.how_to_reg),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _logAcknowledgement,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(_editingPost != null ? 'UPDATE ACKNOWLEDGEMENT' : 'SAVE ACKNOWLEDGEMENT', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildUserAutocomplete({required TextEditingController controller, required String hint, required IconData icon}) {
    return Autocomplete<Map<String, dynamic>>(
      key: ValueKey('${controller.hashCode}_$_actionType'),
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return _users;
        return _users.where((u) => 
          (u['name']?.toString().toLowerCase() ?? '').contains(textEditingValue.text.toLowerCase())
        );
      },
      displayStringForOption: (u) => u['name']?.toString() ?? '',
      onSelected: (u) {
        controller.text = u['name']?.toString() ?? '';
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            if (textEditingController.text != value.text) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (textEditingController.text != value.text) {
                  textEditingController.text = value.text;
                }
              });
            }
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
                minLines: 1,
                maxLines: 5,
                onChanged: (val) {
                  if (controller.text != val) {
                    controller.text = val;
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            );
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text("${option['name']}", style: const TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon, bool isOptional = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildArchivesList(List<InwardPost> posts) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                const Text('RECENT ACKNOWLEDGEMENTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.2)),
                const Spacer(),
                if (_isLoading) const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: posts.isEmpty && !_isLoading
                ? const Center(child: Text('No acknowledgements found', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final post = posts[index];
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

                      final isSelected = _selectedPost?.id == post.id;

                      return Material(
                        color: isSelected 
                            ? AppTheme.primaryColor.withValues(alpha: 0.05) 
                            : (isConfirmed ? Colors.green.shade50 : AppTheme.surfaceColor),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            _updateState(() {
                              _selectedPost = post;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? AppTheme.primaryColor 
                                    : (isConfirmed ? Colors.green.shade200 : Colors.grey.shade200),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        fileDesc,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: action == 'Received' ? Colors.blue.shade100 : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        action,
                                        style: TextStyle(
                                          color: action == 'Received' ? Colors.blue.shade800 : Colors.orange.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('From: ${post.senderName}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.how_to_reg, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('To: ${post.recipientName}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(DateFormat('MMM dd, yyyy - hh:mm a').format(post.receivedDate), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Logged by: ${post.receivedBy}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                                          onPressed: () => _showCreateDialog(postToEdit: post),
                                          tooltip: 'Edit Acknowledgement',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.print, color: Colors.grey, size: 20),
                                          onPressed: () => _printAcknowledgement(post),
                                          tooltip: 'Print Acknowledgement',
                                        ),
                                        if (!isConfirmed && post.recipientName.toLowerCase() == widget.currentUserName.toLowerCase())
                                          TextButton.icon(
                                            onPressed: () => _confirmReceipt(post),
                                            icon: const Icon(Icons.check_circle_outline, size: 18),
                                            label: const Text('Confirm'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.green,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                          )
                                        else if (isConfirmed)
                                          const Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                                              SizedBox(width: 4),
                                              Text('Confirmed', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ],
                                          )
                                      ],
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
          ),
        ],
      ),
    );
  }
}
