import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../models/inward_post_model.dart';
import '../services/inward_post_service.dart';
import 'package:intl/intl.dart';

class InwardPostScreen extends StatefulWidget {
  final String currentUserRole;
  final String currentUserName;

  const InwardPostScreen({
    super.key,
    required this.currentUserRole,
    required this.currentUserName,
  });

  @override
  State<InwardPostScreen> createState() => _InwardPostScreenState();
}

class _InwardPostScreenState extends State<InwardPostScreen> {
  final _senderController = TextEditingController();
  final _recipientController = TextEditingController();
  final _receivedByController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<InwardPost> _posts = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _receivedByController.text = widget.currentUserName;
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final posts = await InwardPostService.getPosts();
    List<Map<String, dynamic>> users = [];
    try {
      final usersRes = await Supabase.instance.client.from('users').select('id, name, role').order('name', ascending: true);
      users = List<Map<String, dynamic>>.from(usersRes);
    } catch(e) {
      print('Error fetching users: $e');
    }
    
    if (mounted) {
      setState(() {
        _posts = posts;
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _senderController.dispose();
    _recipientController.dispose();
    _receivedByController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _logNewPost() async {
    if (_senderController.text.trim().isEmpty || _recipientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sender and Recipient are required'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final newPost = InwardPost(
      id: 'POST-${DateTime.now().millisecondsSinceEpoch}',
      senderName: _senderController.text.trim(),
      recipientName: _recipientController.text.trim(),
      receivedBy: _receivedByController.text.trim().isEmpty ? widget.currentUserName : _receivedByController.text.trim(),
      receivedDate: DateTime.now(),
      status: PostStatus.pendingConfirmation,
      description: _descriptionController.text.trim(),
    );

    await InwardPostService.addPost(newPost);
    
    setState(() {
      _senderController.clear();
      _recipientController.clear();
      _receivedByController.clear();
      _descriptionController.clear();
    });

    await _loadPosts();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post logged successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _confirmReceipt(InwardPost post) async {
    await InwardPostService.updatePostStatus(post.id, PostStatus.confirmedReceived);
    await _loadPosts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt confirmed.'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which posts to show. Managers see only their posts, Staff see all.
    final visiblePosts = _posts.where((post) {
      if (widget.currentUserRole == 'manager' || widget.currentUserRole == 'admin') {
        return post.recipientName.toLowerCase().contains(widget.currentUserName.toLowerCase()) || 
               widget.currentUserName.toLowerCase().contains('admin'); // Simple mock rule
      }
      return true; // Delivery Staff/Front desk see all
    }).toList();

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
          'Post Register', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textColor)
        ),
        centerTitle: true,
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
                    Expanded(flex: 1, child: _buildLogForm()),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildArchivesList(visiblePosts)),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 1, child: _buildLogForm()),
                    const SizedBox(height: 16),
                    Expanded(flex: 2, child: _buildArchivesList(visiblePosts)),
                  ],
                );
              }
            }
          ),
        ),
      ),
    );
  }

  Widget _buildLogForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('LOG NEW POST', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.2)),
            const SizedBox(height: 24),
            _buildInputField(controller: _senderController, hint: 'Sender Name', icon: Icons.person_outline),
            const SizedBox(height: 16),
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return _users;
                return _users.where((u) => 
                  (u['name']?.toString().toLowerCase() ?? '').contains(textEditingValue.text.toLowerCase())
                );
              },
              displayStringForOption: (u) => u['name']?.toString() ?? '',
              onSelected: (u) {
                _recipientController.text = u['name']?.toString() ?? '';
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
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
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.badge_outlined, color: Colors.grey.shade400, size: 20),
                      hintText: 'Intended Manager/Admin',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => _recipientController.text = val,
                  ),
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
            ),
            const SizedBox(height: 16),
            _buildInputField(controller: _receivedByController, hint: 'Received By', icon: Icons.person_search_outlined, readOnly: true),
            const SizedBox(height: 16),
            _buildInputField(controller: _descriptionController, hint: 'Description / Contents', icon: Icons.description_outlined, maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _logNewPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('REGISTER POST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivesList(List<InwardPost> visiblePosts) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('POST ARCHIVES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.mutedTextColor, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
              itemCount: visiblePosts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final post = visiblePosts[index];
                final isPending = post.status == PostStatus.pendingConfirmation;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isPending ? Colors.redAccent.withOpacity(0.3) : Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPending ? Colors.redAccent.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(isPending ? Icons.mark_email_unread_outlined : Icons.mark_email_read_outlined, 
                              color: isPending ? Colors.redAccent : Colors.green, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From: ${post.senderName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textColor)),
                            const SizedBox(height: 4),
                            Text('To: ${post.recipientName}  •  Recv by: ${post.receivedBy}', style: const TextStyle(fontSize: 12, color: AppTheme.mutedTextColor)),
                            if (post.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(post.description, style: const TextStyle(fontSize: 13, color: AppTheme.mutedTextColor, fontStyle: FontStyle.italic)),
                            ]
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(DateFormat('MMM dd, yyyy - hh:mm a').format(post.receivedDate), style: const TextStyle(fontSize: 11, color: AppTheme.primaryColor)),
                          const SizedBox(height: 8),
                          if (isPending)
                            ElevatedButton(
                              onPressed: () => _confirmReceipt(post),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                minimumSize: Size.zero,
                              ),
                              child: const Text('CONFIRM RECEIPT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            )
                          else
                            const Text('RECEIVED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
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
        style: TextStyle(color: readOnly ? Colors.grey.shade600 : AppTheme.textColor, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey.shade400, size: 20) : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
