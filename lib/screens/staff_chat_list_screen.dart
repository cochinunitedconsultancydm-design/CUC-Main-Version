import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import 'chat_screen.dart';

class StaffChatListScreen extends StatefulWidget {
  const StaffChatListScreen({super.key});

  @override
  State<StaffChatListScreen> createState() => _StaffChatListScreenState();
}

class _StaffChatListScreenState extends State<StaffChatListScreen> {
  dynamic _selectedUserId;
  String? _selectedUserName;

  void _onUserSelected(dynamic id, String name) {
    setState(() {
      _selectedUserId = id;
      _selectedUserName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 800;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 380,
                child: _ChatListView(
                  onUserSelected: _onUserSelected,
                  selectedUserId: _selectedUserId,
                  isSplitView: true,
                ),
              ),
              Container(width: 1, color: Colors.grey.shade200),
              Expanded(
                child: _selectedUserId == null
                    ? Container(
                        color: const Color(0xFFF4F7FB),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 24),
                              Text('Select a conversation to start chatting', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                            ],
                          ).animate().fadeIn(),
                        ),
                      )
                    : ChatScreen(
                        key: ValueKey(_selectedUserId),
                        targetUserId: _selectedUserId,
                        targetUserName: _selectedUserName,
                        isSplitView: true,
                      ),
              ),
            ],
          );
        } else {
          if (_selectedUserId != null) {
            return ChatScreen(
              key: ValueKey(_selectedUserId),
              targetUserId: _selectedUserId,
              targetUserName: _selectedUserName,
              isSplitView: false,
              onBackPressed: () => setState(() => _selectedUserId = null),
            );
          }
          return _ChatListView(
            onUserSelected: _onUserSelected,
            isSplitView: false,
          );
        }
      },
    );
  }
}

class _ChatListView extends StatefulWidget {
  final Function(dynamic, String)? onUserSelected;
  final dynamic selectedUserId;
  final bool isSplitView;

  const _ChatListView({this.onUserSelected, this.selectedUserId, this.isSplitView = false});

  @override
  State<_ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<_ChatListView> {
  List<Map<String, dynamic>> _staff = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStaff() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getInt('current_user_id') ?? 1;

      final myIdStr = myId.toString();

      final uReq = ModelQueries.list(amplify_models.Users.classType, limit: 10000);
      final uRes = await Amplify.API.query(request: uReq).response;
      var usersRes = uRes.data?.items.whereType<amplify_models.Users>().toList() ?? [];
      
      usersRes = usersRes.where((u) => u.id != myIdStr).toList();
      usersRes.sort((a, b) {
        int r = (a.role ?? '').compareTo(b.role ?? '');
        if (r != 0) return r;
        return (a.name ?? '').compareTo(b.name ?? '');
      });
      
      final mReq = ModelQueries.list(
        amplify_models.Messages.classType,
        where: amplify_models.Messages.RECEIVER_ID.eq(myId).and(amplify_models.Messages.IS_READ.eq(false))
      );
      final mRes = await Amplify.API.query(request: mReq).response;
      final unreadRes = mRes.data?.items.whereType<amplify_models.Messages>().toList() ?? [];
      
      final Map<String, int> unreadCounts = {};
      for (var msg in unreadRes) {
        if (msg.sender_id != null) {
          final senderIdStr = msg.sender_id.toString();
          unreadCounts[senderIdStr] = (unreadCounts[senderIdStr] ?? 0) + 1;
        }
      }

      final sReq = ModelQueries.list(amplify_models.UserSessions.classType);
      final sRes = await Amplify.API.query(request: sReq).response;
      var sessionsRes = sRes.data?.items.whereType<amplify_models.UserSessions>().toList() ?? [];
      
      sessionsRes.sort((a, b) {
        final dateA = a.login_time != null ? DateTime.tryParse(a.login_time!) ?? DateTime(2000) : DateTime(2000);
        final dateB = b.login_time != null ? DateTime.tryParse(b.login_time!) ?? DateTime(2000) : DateTime(2000);
        return dateB.compareTo(dateA); // descending
      });
          
      final List<Map<String, dynamic>> staffList = [];
      for (var u in usersRes) {
        final userSessions = sessionsRes.where((s) => s.user_id?.toString() == u.id.toString()).toList();
        final session = userSessions.isNotEmpty ? userSessions.first : null;

        staffList.add({
          'id': u.id,
          'name': u.name,
          'username': u.username,
          'role': u.role,
          'unread_count': unreadCounts[u.id] ?? 0,
          'is_active': session?.is_active ?? false,
          'status': session?.status ?? 'Offline',
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.redAccent;
      case 'manager': return Colors.indigo;
      case 'accountant': return Colors.teal;
      case 'delivery': return Colors.orange;
      default: return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaff = _staff.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final username = (s['username'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isSplitView) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Internal Chat', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  SizedBox(height: 4),
                  Text('Connect and collaborate with your team', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              IconButton(
                onPressed: _fetchStaff,
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                tooltip: 'Refresh List',
                style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1), padding: const EdgeInsets.all(12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Messages', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                IconButton(
                  onPressed: _fetchStaff,
                  icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor, size: 20),
                  tooltip: 'Refresh List',
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1), padding: const EdgeInsets.all(8)),
                ),
              ],
            ),
          ),
        ],
        
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search staff...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor, size: 20),
              suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ).animate().fadeIn(),
        
        const SizedBox(height: 16),
        
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : filteredStaff.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No staff found', style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    ],
                  ).animate().fadeIn(),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filteredStaff.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = filteredStaff[index];
                    final unread = s['unread_count'] as int;
                    final role = (s['role'] ?? 'staff').toString().toLowerCase();
                    final roleColor = _getRoleColor(role);
                    final isActive = s['is_active'] == true;
                    final isSelected = s['id'] == widget.selectedUserId;

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.grey.shade100, width: 1.5),
                        boxShadow: isSelected ? null : [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          hoverColor: AppTheme.primaryColor.withValues(alpha: 0.02),
                          onTap: () {
                            if (widget.onUserSelected != null) {
                              widget.onUserSelected!(s['id'], s['name']);
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatScreen(targetUserId: s['id'], targetUserName: s['name']),
                              )).then((_) => _fetchStaff());
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: roleColor.withValues(alpha: 0.1),
                                      child: Text(s['name']?[0] ?? '?', style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18)),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: isActive ? Colors.green : Colors.grey.shade400,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(s['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ),
                                          if (role == 'admin') ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                                              child: const Text('ADMIN', style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold)),
                                            ),
                                          ]
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text('@${s['username']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                if (unread > 0)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                    child: Text(unread.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: (index * 20).ms).slideX(begin: 0.02, end: 0);
                  },
                ),
        ),
      ],
    );
  }
}

