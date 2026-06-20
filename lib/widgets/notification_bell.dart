import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _service = NotificationService();
  List<AppNotification> _notifications = [];
  int? _userId;
  Timer? _timer;
  StreamSubscription? _streamSub;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupStream();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _loadNotifications());
  }

  void _setupStream() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    if (userId != null) {
      _streamSub = _service.notificationStream.listen((n) {
        if (n.userId == userId) {
          _loadNotifications();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamSub?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');
      
      if (userId != null) {
        _userId = userId;
        final notifs = await _service.getUnreadNotifications(userId);
        if (mounted) setState(() => _notifications = notifs);
      }
    } catch (_) {}
  }

  void _showDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (_notifications.isNotEmpty)
              TextButton(
                onPressed: () async {
                  if (_userId != null) await _service.markAllAsRead(_userId!);
                  _loadNotifications();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Mark all as read', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        content: SizedBox(
          width: 400,
          height: 400,
          child: _notifications.isEmpty
              ? const Center(child: Text('No new notifications!', style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    IconData icon = Icons.notifications;
                    Color color = Colors.blue;

                    if (n.type == 'alert') {
                      icon = Icons.warning_rounded;
                      color = Colors.red;
                    } else if (n.type == 'reminder') {
                      icon = Icons.schedule_rounded;
                      color = Colors.orange;
                    } else if (n.type == 'assignment') {
                      icon = Icons.assignment_ind_rounded;
                      color = Colors.green;
                    } else if (n.type == 'chat') {
                      icon = Icons.chat_bubble_rounded;
                      color = Colors.indigo;
                    }

                    return ListTile(
                      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
                      title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(n.message, style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(DateFormat('MMM dd, hh:mm a').format(n.createdAt), style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.grey, size: 20),
                        tooltip: 'Mark as read',
                        onPressed: () async {
                          await _service.markAsRead(n.id);
                          _loadNotifications();
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () => _showDropdown(context),
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
        ),
        if (_notifications.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                _notifications.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
