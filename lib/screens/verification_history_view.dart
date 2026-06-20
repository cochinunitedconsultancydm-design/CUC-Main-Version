import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/deal_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'google_docs_webview_screen.dart';

class VerificationHistoryView extends StatefulWidget {
  const VerificationHistoryView({super.key});

  @override
  State<VerificationHistoryView> createState() => _VerificationHistoryViewState();
}

class _VerificationHistoryViewState extends State<VerificationHistoryView> {
  final _dealService = DealService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _dealService.getVerificationHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFB),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_edu_rounded, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Verification History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Track all work draft approvals and rejections', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          itemCount: _history.length,
          separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade100),
          itemBuilder: (context, index) {
            final item = _history[index];
            final bool isVerified = item['status'] == 'Verified';
            final date = item['created_at'] != null ? DateTime.tryParse(item['created_at'].toString()) : null;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['deal_name'] != null && item['deal_name'].toString().trim().isNotEmpty) ...[
                          Text(item['deal_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                        ],
                        _buildVerificationDocInfo(item['drive_link']?.toString()),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Sender: ${item['sender']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reviewer', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(height: 4),
                        Text(item['reviewer'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isVerified ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isVerified ? Colors.green.shade200 : Colors.red.shade200),
                          ),
                          child: Text(
                            item['status'],
                            style: TextStyle(
                              color: isVerified ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (!isVerified && item['reason'].toString().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Reason: ${item['reason']}', style: TextStyle(color: Colors.red.shade400, fontSize: 12, fontStyle: FontStyle.italic)),
                        ]
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      date != null ? DateFormat('MMM d, yyyy\nh:mm a').format(date) : '-',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
          },
        ),
      ),
    );
  }

  Widget _buildVerificationDocInfo(String? driveLink) {
    List<Map<String, String>> docs = [];
    if (driveLink != null && driveLink.isNotEmpty) {
      try {
        final List<dynamic> parsed = jsonDecode(driveLink);
        for (var item in parsed) {
          docs.add({"name": item["name"].toString(), "url": item["url"].toString()});
        }
      } catch (e) {
        docs.add({"name": "Connected Document", "url": driveLink});
      }
    }

    if (docs.isEmpty) {
      return const Text('No Document Linked', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: docs.map((doc) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => GoogleDocsWebviewScreen(url: doc['url']!, title: doc['name'] ?? 'Document')));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.description_outlined, size: 14, color: Color(0xFF2563EB)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  doc['name'] ?? 'Document',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2563EB), decoration: TextDecoration.underline),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No verification history found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
        ],
      ),
    );
  }
}
