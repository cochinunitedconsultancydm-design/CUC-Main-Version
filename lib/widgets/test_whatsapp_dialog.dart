import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/meta_service.dart';

class TestWhatsAppDialog extends StatefulWidget {
  final String? initialPhone;
  final String? initialStaffName;
  final dynamic initialStaffUserId;

  const TestWhatsAppDialog({
    super.key,
    this.initialPhone,
    this.initialStaffName,
    this.initialStaffUserId,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialPhone,
    String? initialStaffName,
    dynamic initialStaffUserId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => TestWhatsAppDialog(
        initialPhone: initialPhone,
        initialStaffName: initialStaffName,
        initialStaffUserId: initialStaffUserId,
      ),
    );
  }

  @override
  State<TestWhatsAppDialog> createState() => _TestWhatsAppDialogState();
}

class _TestWhatsAppDialogState extends State<TestWhatsAppDialog> {
  final _waService = WhatsAppCloudService();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _workTitleCtrl = TextEditingController(text: 'New Work Assignment - GST & FSSAI Registration');
  final _clientNameCtrl = TextEditingController(text: 'Cochin United Client');

  List<Map<String, dynamic>> _staffDirectory = [];
  Map<String, dynamic>? _selectedStaff;
  bool _useCustomPhone = false;
  bool _isWorkAlertMode = true;

  bool _isLoading = true;
  bool _isSending = false;
  String? _resultStatus;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadDirectory();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    _workTitleCtrl.dispose();
    _clientNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDirectory() async {
    try {
      final list = await _waService.getStaffDirectoryWithPhones();
      if (!mounted) return;

      setState(() {
        _staffDirectory = list;
        _isLoading = false;

        // Try to match initialStaffUserId or initialPhone
        if (widget.initialStaffUserId != null) {
          final idStr = widget.initialStaffUserId.toString().trim().toLowerCase();
          final found = list.firstWhere(
            (s) => s['id']?.toString() == idStr ||
                   s['username']?.toString().toLowerCase() == idStr ||
                   s['name']?.toString().toLowerCase() == idStr,
            orElse: () => <String, dynamic>{},
          );
          if (found.isNotEmpty) {
            _selectedStaff = found;
            _phoneCtrl.text = found['phone']?.toString() ?? '';
          }
        } else if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
          final clean = WhatsAppCloudService.formatPhone(widget.initialPhone!);
          final found = list.firstWhere(
            (s) => s['phone']?.toString() == clean,
            orElse: () => <String, dynamic>{},
          );
          if (found.isNotEmpty) {
            _selectedStaff = found;
          } else {
            _useCustomPhone = true;
          }
          _phoneCtrl.text = clean;
        } else if (list.isNotEmpty) {
          _selectedStaff = list.first;
          _phoneCtrl.text = _selectedStaff!['phone']?.toString() ?? '';
        }

        _updateDefaultMessage();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _useCustomPhone = true;
          _phoneCtrl.text = widget.initialPhone ?? '';
          _updateDefaultMessage();
        });
      }
    }
  }

  void _updateDefaultMessage() {
    final staffName = _selectedStaff?['name'] ?? widget.initialStaffName ?? 'Team Member';
    if (_isWorkAlertMode) {
      _messageCtrl.text =
          '🔔 *CUC Assignment Alert*\n\n'
          'Hello *$staffName*,\n'
          'A new *Work File* has been assigned to you in CUC System.\n\n'
          '📌 *Title:* ${_workTitleCtrl.text.trim()}\n'
          '👤 *Client:* ${_clientNameCtrl.text.trim()}\n'
          '📅 *Deadline:* Today\n'
          '⚡ *Priority:* High\n'
          '👤 *Assigned By:* Operations Manager\n'
          '📝 *Details:* Please review client documents and initiate registration process.\n\n'
          '👉 *Please open Cochin United Consultancy App to view & take action.*';
    } else {
      _messageCtrl.text =
          'Hello $staffName, this is a test notification from Cochin United Consultancy System via Meta WhatsApp Cloud API.';
    }
  }

  Future<void> _sendTestMessage() async {
    final phone = _phoneCtrl.text.trim();
    final msg = _messageCtrl.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _resultStatus = 'Please enter a valid recipient phone number.';
        _isSuccess = false;
      });
      return;
    }
    if (msg.isEmpty) {
      setState(() {
        _resultStatus = 'Message cannot be empty.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isSending = true;
      _resultStatus = null;
    });

    try {
      final res = await _waService.sendMessage(toPhone: phone, message: msg);
      if (!mounted) return;

      setState(() {
        _isSending = false;
        _isSuccess = res.success;
        if (res.success) {
          _resultStatus = 'WhatsApp message delivered successfully! (Message ID: ${res.messageId})';
        } else {
          _resultStatus = 'Cloud API Error: ${res.error}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _isSuccess = false;
        _resultStatus = 'Connection error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.mark_chat_unread_rounded, color: Color(0xFF16A34A), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test WhatsApp Notification',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Send a live test message to verify staff WhatsApp assignment alerts.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const Divider(height: 24),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recipient selector header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'RECIPIENT STAFF',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _useCustomPhone = !_useCustomPhone;
                                      if (!_useCustomPhone && _selectedStaff != null) {
                                        _phoneCtrl.text = _selectedStaff!['phone']?.toString() ?? '';
                                      }
                                      _updateDefaultMessage();
                                    });
                                  },
                                  icon: Icon(
                                    _useCustomPhone ? Icons.group_outlined : Icons.edit_outlined,
                                    size: 14,
                                    color: const Color(0xFF2563EB),
                                  ),
                                  label: Text(
                                    _useCustomPhone ? 'Pick from Staff List' : 'Enter Custom Phone',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  ),
                                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            if (!_useCustomPhone && _staffDirectory.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Map<String, dynamic>>(
                                    value: _selectedStaff,
                                    isExpanded: true,
                                    icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF64748B)),
                                    items: _staffDirectory.map((s) {
                                      final name = s['name']?.toString() ?? 'Staff';
                                      final phone = s['phone']?.toString() ?? 'No Phone';
                                      final role = s['role']?.toString().toUpperCase() ?? '';
                                      return DropdownMenuItem<Map<String, dynamic>>(
                                        value: s,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 12,
                                              backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.15),
                                              child: Text(
                                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (role.isNotEmpty) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE2E8F0),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(role, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Text(
                                              phone,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: phone != 'No Phone' ? const Color(0xFF16A34A) : Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedStaff = val;
                                          _phoneCtrl.text = val['phone']?.toString() ?? '';
                                          _updateDefaultMessage();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ] else ...[
                              TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF16A34A), size: 20),
                                  hintText: 'e.g. 919876543210 or 9876543210',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Alert Mode Toggle
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Work Assignment Alert (Live Template)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                  selected: _isWorkAlertMode,
                                  selectedColor: const Color(0xFF16A34A).withValues(alpha: 0.15),
                                  labelStyle: TextStyle(color: _isWorkAlertMode ? const Color(0xFF16A34A) : const Color(0xFF64748B)),
                                  onSelected: (val) {
                                    setState(() {
                                      _isWorkAlertMode = true;
                                      _updateDefaultMessage();
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Custom Text Message', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                  selected: !_isWorkAlertMode,
                                  selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
                                  labelStyle: TextStyle(color: !_isWorkAlertMode ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                  onSelected: (val) {
                                    setState(() {
                                      _isWorkAlertMode = false;
                                      _updateDefaultMessage();
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            if (_isWorkAlertMode) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _workTitleCtrl,
                                      onChanged: (_) => _updateDefaultMessage(),
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'Work / Task Title',
                                        prefixIcon: const Icon(Icons.work_outline, size: 16),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _clientNameCtrl,
                                      onChanged: (_) => _updateDefaultMessage(),
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'Client Name',
                                        prefixIcon: const Icon(Icons.person_outline, size: 16),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Message box
                            const Text(
                              'MESSAGE PREVIEW / PAYLOAD',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF86EFAC)),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: TextField(
                                controller: _messageCtrl,
                                maxLines: 6,
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),

                            // Result alert banner
                            if (_resultStatus != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      _isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                                      color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _resultStatus!,
                                            style: TextStyle(
                                              color: _isSuccess ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (!_isSuccess) ...[
                                            const SizedBox(height: 6),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                WhatsAppCloudService.launchWhatsAppApp(
                                                  phone: _phoneCtrl.text.trim(),
                                                  message: _messageCtrl.text.trim(),
                                                );
                                              },
                                              icon: const Icon(Icons.open_in_new, size: 14),
                                              label: const Text('Open in WhatsApp Web / App', style: TextStyle(fontSize: 11)),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF16A34A),
                                                side: const BorderSide(color: Color(0xFF16A34A)),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),

              const Divider(height: 24),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendTestMessage,
                    icon: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, size: 16),
                    label: Text(
                      _isSending ? 'Sending Test...' : 'Send Test Message',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
