import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/encryption_service.dart';
import '../services/notification_service.dart';
import '../services/deal_service.dart';
import '../models/deal.dart';
import 'deal_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/premium_app_bar.dart';
class ChatScreen extends StatefulWidget {
  final int? targetUserId; // If null, staff is chatting with Admin
  final String? targetUserName;

  const ChatScreen({super.key, this.targetUserId, this.targetUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _client = Supabase.instance.client;
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  int? _myId;
  bool _isLoading = true;
  bool _isTargetOnline = false;
  Deal? _selectedDeal;
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    _myId = prefs.getInt('current_user_id');
    
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    final targetId = widget.targetUserId ?? 1;
    if (_myId == null) return;

    setState(() => _isLoading = true);

    _messagesSubscription = _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .listen((data) async {
          // Filter messages for this conversation (Supabase stream filter is limited)
          final filtered = data.where((m) {
            final sId = m['sender_id'] as int;
            final rId = m['receiver_id'] as int;
            return (sId == _myId && rId == targetId) || (sId == targetId && rId == _myId);
          }).toList();

          // Fetch sender names and decrypt content
          // We do this inside a separate method to keep the stream listener clean
          _processMessages(filtered);
        }, onError: (e) {
          debugPrint('Stream error: $e');
          if (mounted) setState(() => _isLoading = false);
        });
  }

  Future<void> _processMessages(List<Map<String, dynamic>> rawMessages) async {
    try {
      final targetId = widget.targetUserId ?? 1;

      // Ping my online status
      if (_myId != null) {
        await _client.from('users').update({'last_seen': DateTime.now().toIso8601String()}).eq('id', _myId!);
      }

      // Check if target is online
      final targetRes = await _client.from('users').select('last_seen').eq('id', targetId).maybeSingle();
      bool isOnline = false;
      if (targetRes != null && targetRes['last_seen'] != null) {
        final lastSeen = DateTime.parse(targetRes['last_seen'].toString()).toLocal();
        isOnline = DateTime.now().difference(lastSeen).inMinutes < 5;
      }

      // We need to fetch names for senders. For simplicity, we'll fetch all users once or join.
      // Since streams don't support joins, we'll map sender IDs to names.
      final userRes = await _client.from('users').select('id, name');
      final userMap = {for (var u in userRes) u['id']: u['name']};

      final processed = rawMessages.map((m) {
        return {
          ...m,
          'sender_name': userMap[m['sender_id']] ?? 'System',
          'content': EncryptionService().decryptText(m['content'] ?? '')
        };
      }).toList();

      if (mounted) {
        setState(() {
          _isTargetOnline = isOnline;
          _messages = processed;
          _isLoading = false;
        });
        _scrollToBottom();

        // Mark messages as read
        await _client
            .from('messages')
            .update({'is_read': true})
            .eq('sender_id', targetId)
            .eq('receiver_id', _myId!)
            .eq('is_read', false);
      }
    } catch (e) {
      debugPrint('Error processing messages: $e');
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final attachmentId = _selectedDeal?.id;
    final attachmentType = attachmentId != null ? 'work' : null;

    if (_msgController.text.trim().isEmpty && attachmentId == null) return;
    
    final content = _msgController.text.trim();
    _msgController.clear();
    setState(() => _selectedDeal = null);
    
    try {
      final targetId = widget.targetUserId ?? 1;
      final encryptedContent = EncryptionService().encryptText(content.isEmpty ? '[Attachment]' : content);
      
      await _client.from('messages').insert({
        'sender_id': _myId,
        'receiver_id': targetId,
        'content': encryptedContent,
        'attachment_type': attachmentType,
        'attachment_id': attachmentId,
      });

      // Notify the receiver
      String senderName = await AuthService().getUserName() ?? 'Someone';
      String preview = content.isEmpty ? '📎 Attached a work' : content;
      await NotificationService().sendNotification(
        userId: targetId,
        title: 'New Message from $senderName',
        message: preview.length > 50 ? '${preview.substring(0, 47)}...' : preview,
        type: 'chat',
      );

      // No need to call _fetchMessages, the stream will handle it
      _scrollToBottom();
    } catch (e) {
      _msg('Send failed: $e');
    }
  }

  Future<void> _showWorkPicker() async {
    final dealService = DealService();
    try {
      final deals = await dealService.getAllDeals();
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Attach Work to Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: deals.isEmpty 
                  ? const Center(child: Text('No work found'))
                  : ListView.builder(
                      itemCount: deals.length,
                      itemBuilder: (context, index) {
                        final d = deals[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.work_outline_rounded, color: AppTheme.primaryColor, size: 20),
                          ),
                          title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(d.clientName ?? 'No Client', style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => _selectedDeal = d);
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _msg('Failed to load work: $e');
    }
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Soft modern background
      appBar: PremiumAppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                widget.targetUserName?[0].toUpperCase() ?? 'A',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.targetUserName ?? 'Chat with Admin',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_isTargetOnline)
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      const Text('Online', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                    ],
                  )
                else
                  const Text('Offline', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white.withOpacity(0.1), height: 1),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.attach_file_rounded, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  final isMe = m['sender_id'] == _myId;
                  final time = DateTime.parse(m['created_at'].toString()).toLocal();
                  
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        gradient: isMe ? LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.85)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ) : null,
                        color: isMe ? null : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isMe ? 20 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 20),
                        ),
                        border: isMe ? null : Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (m['attachment_type'] == 'work' && m['attachment_id'] != null)
                            FutureBuilder<Deal?>(
                              future: DealService().getDealById(int.parse(m['attachment_id'].toString())),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox.shrink();
                                final deal = snapshot.data!;
                                return InkWell(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DealDetailScreen(deal: deal))),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.white.withOpacity(0.15) : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isMe ? Colors.white24 : Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(color: isMe ? Colors.white.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                                          child: Icon(Icons.work_rounded, color: isMe ? Colors.white : AppTheme.primaryColor, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                deal.name,
                                                style: TextStyle(color: isMe ? Colors.white : AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 13),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                deal.clientName ?? 'No Client',
                                                style: TextStyle(color: isMe ? Colors.white70 : AppTheme.mutedTextColor, fontSize: 11),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.chevron_right_rounded, color: isMe ? Colors.white70 : AppTheme.mutedTextColor, size: 18),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (m['content'] != '[Attachment]')
                            Text(
                              m['content'],
                              style: TextStyle(
                                color: isMe ? Colors.white : const Color(0xFF334155),
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('hh:mm a').format(time),
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.done_all_rounded, size: 14, color: Colors.white70),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ),
          if (_selectedDeal != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_rounded, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Attaching: ${_selectedDeal!.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textColor)),
                          Text(_selectedDeal!.clientName ?? 'No Client', style: const TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                      onPressed: () => setState(() => _selectedDeal = null),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor, size: 26),
                  onPressed: _showWorkPicker,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            minLines: 1,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF94A3B8), size: 22),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
