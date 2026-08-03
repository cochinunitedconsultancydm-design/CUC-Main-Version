import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/ModelProvider.dart';
import '../../services/auth_service.dart';

class ClientDealChatScreen extends StatefulWidget {
  final Deals deal;
  final bool isStaff;

  const ClientDealChatScreen({super.key, required this.deal, this.isStaff = false});

  @override
  State<ClientDealChatScreen> createState() => _ClientDealChatScreenState();
}

class _ClientDealChatScreenState extends State<ClientDealChatScreen> {
  bool _isLoading = true;
  List<DealActivities> _messages = [];
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _clientName = 'Client';

  @override
  void initState() {
    super.initState();
    _loadClientName();
    _fetchMessages();
  }

  Future<void> _loadClientName() async {
    final name = await AuthService().getUserName();
    if (name != null && mounted) {
      setState(() {
        _clientName = name;
      });
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final req = ModelQueries.list(
        DealActivities.classType,
        where: DealActivities.DEAL_ID.eq(widget.deal.id),
        limit: 1000,
      );
      final res = await Amplify.API.query(request: req).response;
      if (mounted) {
        setState(() {
          final allActs = (res.data?.items ?? []).whereType<DealActivities>().toList() ?? [];
          _messages = allActs.where((a) => a.type == 'client_query' || a.type == 'staff_reply').toList();
          
          _messages.sort((a, b) {
            final aDate = a.createdAt?.getDateTimeInUtc() ?? DateTime.parse(a.created_at ?? DateTime.now().toIso8601String());
            final bDate = b.createdAt?.getDateTimeInUtc() ?? DateTime.parse(b.created_at ?? DateTime.now().toIso8601String());
            return aDate.compareTo(bDate);
          });
          
          _isLoading = false;
        });
        
        // Scroll to bottom
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
    } catch (e) {
      debugPrint('Error fetching chat: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    try {
      final act = DealActivities(
        deal_id: widget.deal.id.toString(),
        type: widget.isStaff ? 'staff_reply' : 'client_query',
        title: widget.isStaff ? 'Staff Reply' : 'Client Query',
        description: text,
        created_by: widget.isStaff ? 1 : 0, // 0 for client, 1 for staff
        created_at: DateTime.now().toIso8601String(),
      );

      final req = ModelMutations.create(act);
      await Amplify.API.mutate(request: req).response;
      
      _fetchMessages();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat with Staff', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.deal.name ?? 'Workfile', style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
          ],
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildChatBubble(_messages[index], index);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Messages Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Send a message to ask a question about this workfile.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildChatBubble(DealActivities act, int index) {
    final isClientMsg = act.type == 'client_query';
    final isMe = widget.isStaff ? !isClientMsg : isClientMsg;
    
    final senderName = isClientMsg ? _clientName : (widget.deal.responsible_name?.isNotEmpty == true ? widget.deal.responsible_name : 'Staff');
    
    DateTime date = act.createdAt?.getDateTimeInUtc() ?? DateTime.now();
    if (act.created_at != null) {
      date = DateTime.tryParse(act.created_at!) ?? date;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              senderName ?? 'Unknown',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isClientMsg ? AppTheme.accentColor.withValues(alpha: 0.1) : Colors.green.shade50,
                  child: Icon(isClientMsg ? Icons.person_rounded : Icons.support_agent_rounded, size: 16, color: isClientMsg ? AppTheme.accentColor : Colors.green),
                ),
              if (!isMe) const SizedBox(width: 8),
              
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                      bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        act.description ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white : AppTheme.textColor,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(date),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white54 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (isMe) const SizedBox(width: 8),
              if (isMe)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Icon(widget.isStaff ? Icons.support_agent_rounded : Icons.person_rounded, size: 16, color: AppTheme.primaryColor),
                ),
            ],
          ).animate().fadeIn(delay: (50 * (index % 10)).ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
