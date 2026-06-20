import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'chat_screen.dart';

class StaffChatListScreen extends StatefulWidget {
  const StaffChatListScreen({super.key});

  @override
  State<StaffChatListScreen> createState() => _StaffChatListScreenState();
}

class _StaffChatListScreenState extends State<StaffChatListScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _staff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getInt('current_user_id') ?? 1;

      // Fetch all users except self
      final usersRes = await _client
          .from('users')
          .select('id, name, username, role')
          .neq('id', myId)
          .order('role', ascending: true)
          .order('name', ascending: true);
      
      // Fetch unread counts for all users
      final unreadRes = await _client
          .from('messages')
          .select('sender_id')
          .eq('receiver_id', myId)
          .eq('is_read', false);
      
      final Map<int, int> unreadCounts = {};
      for (var msg in unreadRes) {
        final senderId = msg['sender_id'] as int;
        unreadCounts[senderId] = (unreadCounts[senderId] ?? 0) + 1;
      }

      final List<Map<String, dynamic>> staffList = [];
      for (var u in usersRes) {
        staffList.add({
          ...u,
          'unread_count': unreadCounts[u['id']] ?? 0,
        });
      }

      if (!mounted) return;
      setState(() {
        _staff = staffList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Chat list error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (MediaQuery.of(context).size.width > 600)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Internal Chat', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1)),
              IconButton(
                onPressed: _fetchStaff,
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withOpacity(0.1), padding: const EdgeInsets.all(12)),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Internal Chat', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const SizedBox(height: 16),
              IconButton(
                onPressed: _fetchStaff,
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withOpacity(0.1), padding: const EdgeInsets.all(12)),
              ),
            ],
          ),
        const SizedBox(height: 32),
        Expanded(
          child: _isLoading ? const Center(child: CircularProgressIndicator())
          : Card(
              child: ListView.separated(
                itemCount: _staff.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = _staff[index];
                  final unread = s['unread_count'] as int;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(s['name']?[0] ?? '?', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(s['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (s['role'] == 'admin')
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.red.shade200)),
                            child: const Text('ADMIN', style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                    subtitle: Text('Click to chat with ${s['username']}'),
                    trailing: unread > 0 ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      child: Text(unread.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ) : const Icon(Icons.chevron_right_rounded, color: AppTheme.mutedTextColor),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatScreen(targetUserId: s['id'], targetUserName: s['name']),
                      )).then((_) => _fetchStaff());
                    },
                  );
                },
              ),
            ),
        ),
      ],
    );
  }
}
