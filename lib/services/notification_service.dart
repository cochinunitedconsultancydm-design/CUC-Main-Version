import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final int? dealId;
  final int? taskId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.dealId,
    this.taskId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      message: map['message'],
      type: map['type'] ?? 'info',
      dealId: map['deal_id'],
      taskId: map['task_id'],
      isRead: map['is_read'] == true,
      createdAt: map['created_at'] == null 
          ? DateTime.now() 
          : (map['created_at'] is DateTime 
              ? map['created_at'] as DateTime 
              : DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()),
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Global key for showing in-app notification toasts on desktop.
  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  final _client = Supabase.instance.client;
  final _localNotif = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  final _notificationController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get notificationStream => _notificationController.stream;
  RealtimeChannel? _notifChannel;

  Future<void> initLocalNotifications() async {
    if (_isInitialized) return;
    
    // Only initialize on mobile
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _isInitialized = true;
      return;
    }

    try {
      // Request permissions
      if (Platform.isAndroid) {
        await _localNotif.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      } else if (Platform.isIOS) {
        await _localNotif.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
      }

      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
      
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotif.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle tap
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String message,
    String? payload,
  }) async {
    // Desktop / Web: show in-app toast notification
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _showDesktopNotification(title: title, message: message);
      return;
    }
    
    await initLocalNotifications();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'cuc_tasks',
      'Task Notifications',
      channelDescription: 'Notifications for tasks and work management',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotif.show(
      id: DateTime.now().millisecond % 1000000,
      title: title,
      body: message,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }

  /// Shows an in-app floating toast notification for desktop platforms.
  void _showDesktopNotification({required String title, required String message}) {
    final messenger = scaffoldMessengerKey?.currentState;
    if (messenger == null) {
      debugPrint('Desktop notification skipped: no scaffoldMessengerKey');
      return;
    }

    try {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(message, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E293B),
          duration: const Duration(seconds: 4),
          width: 380,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
        ),
      );
    } catch (e) {
      debugPrint('Desktop notification UI error (likely no Scaffold): $e');
    }
  }

  Future<List<AppNotification>> getUnreadNotifications(int userId) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .order('created_at', ascending: false)
        .limit(50);
    return response.map((map) => AppNotification.fromMap(map)).toList();
  }

  Future<void> markAsRead(int notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead(int userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId);
  }

  Future<void> sendNotification({
    required int userId,
    required String title,
    required String message,
    String type = 'info',
    int? dealId,
    int? taskId,
  }) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'deal_id': dealId,
      'task_id': taskId,
      'is_read': false,
    });

    // Show local/desktop notification on sender device (skip for chat — receiver gets it via realtime)
    if (type != 'chat') {
      showLocalNotification(title: title, message: message);
    }
  }

  void startRealtimeListener(int userId) {
    if (_notifChannel != null) return;

    _notifChannel = _client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newNotif = AppNotification.fromMap(payload.newRecord);
            _notificationController.add(newNotif);
            showLocalNotification(
              title: newNotif.title,
              message: newNotif.message,
              payload: newNotif.taskId?.toString() ?? newNotif.dealId?.toString(),
            );
          },
        )
        .subscribe();
  }

  void stopRealtimeListener() {
    _notifChannel?.unsubscribe();
    _notifChannel = null;
  }

  Future<void> notifyAdmins({
    required String title,
    required String message,
    String type = 'info',
    int? dealId,
    int? taskId,
  }) async {
    try {
      final response = await _client.from('users').select('id').eq('role', 'admin');
      for (var row in response) {
        final adminId = row['id'] as int;
        await sendNotification(
          userId: adminId,
          title: title,
          message: message,
          type: type,
          dealId: dealId,
          taskId: taskId,
        );
      }
    } catch (e) {
      debugPrint('Error notifying admins: $e');
    }
  }

  /// Notifies only relevant stakeholders (Managers, Responsible Staff, and Participants/Collaborators).
  Future<void> notifyStakeholders({
    int? dealId,
    int? taskId,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    final Set<int> recipients = {};

    try {
      // 1. Always include Managers
      final managers = await _client.from('users').select('id').eq('role', 'manager');
      for (var row in managers) {
        recipients.add(row['id'] as int);
      }

      // 2. If Deal, include Responsible and Assignees
      if (dealId != null) {
        final dealRes = await _client.from('deals').select('responsible_id').eq('id', dealId).maybeSingle();
        if (dealRes != null && dealRes['responsible_id'] != null) {
          recipients.add(dealRes['responsible_id'] as int);
        }
        final assignees = await _client.from('deal_assignees').select('user_id').eq('deal_id', dealId);
        for (var row in assignees) {
          recipients.add(row['user_id'] as int);
        }
      }

      // 3. If Task, include AssignedTo and AssignedBy
      if (taskId != null) {
        final taskRes = await _client.from('tasks').select('assigned_to, assigned_by').eq('id', taskId).maybeSingle();
        if (taskRes != null) {
          if (taskRes['assigned_to'] != null) recipients.add(taskRes['assigned_to'] as int);
          if (taskRes['assigned_by'] != null) recipients.add(taskRes['assigned_by'] as int);
        }
      }

      // 4. Send to everyone collected
      for (var uid in recipients) {
        await sendNotification(
          userId: uid,
          title: title,
          message: message,
          type: type,
          dealId: dealId,
          taskId: taskId,
        );
      }
    } catch (e) {
      debugPrint('Error notifying stakeholders: $e');
    }
  }

  /// Checks and sends reminders with dynamic frequency based on urgency.
  Future<void> checkAndSendFrequentReminders() async {
    try {
      debugPrint('Running Smart Escalation Reminder Cron...');

      // 1. Remind Deals
      final deals = await _client
          .from('deals')
          .select('id, name, stage, responsible_id')
          .neq('stage', 'Completed');

      for (final dealMap in deals) {
        if (dealMap['responsible_id'] == null) continue;
        
        final dealId = dealMap['id'] as int;
        final resId = dealMap['responsible_id'] as int;
        final name = dealMap['name'];
        final stage = dealMap['stage'];

        // Check frequency for Deal
        final lastNotifRes = await _client
            .from('notifications')
            .select('created_at')
            .eq('deal_id', dealId)
            .eq('type', 'reminder')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        bool shouldNotify = true;
        if (lastNotifRes != null) {
          final lastRun = DateTime.parse(lastNotifRes['created_at'].toString());
          // Default frequency for deals: 12 hours
          if (DateTime.now().difference(lastRun).inHours < 12) {
            shouldNotify = false;
          }
        }

        if (shouldNotify) {
          await sendNotification(
            userId: resId,
            title: 'Reminder: Pending Deal',
            message: 'Deal "$name" is still in stage "$stage".',
            type: 'reminder',
            dealId: dealId,
          );
        }
      }

      // 2. Remind Tasks
      final tasks = await _client
          .from('tasks')
          .select('id, title, assigned_to, status, due_date')
          .neq('status', 'Completed');

      for (final taskMap in tasks) {
        if (taskMap['assigned_to'] == null) continue;

        final taskId = taskMap['id'] as int;
        final assignedTo = taskMap['assigned_to'] as int;
        final title = taskMap['title'];
        final status = taskMap['status'];
        final dueDateStr = taskMap['due_date']?.toString();
        final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;
        
        // Calculate dynamic frequency
        Duration interval = const Duration(hours: 24); // Default
        if (dueDate != null) {
          final timeToDue = dueDate.difference(DateTime.now());
          if (timeToDue.isNegative) {
            interval = const Duration(minutes: 30); // Overdue: Very frequent
          } else if (timeToDue.inHours < 4) {
            interval = const Duration(hours: 1); // < 4 hours: Hourly
          } else if (timeToDue.inHours < 24) {
            interval = const Duration(hours: 4); // < 1 day: Every 4 hours
          }
        }

        // Check last notification for this task
        final lastNotifRes = await _client
            .from('notifications')
            .select('created_at')
            .eq('task_id', taskId)
            .or('type.eq.reminder,type.eq.alert')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        bool shouldNotify = true;
        if (lastNotifRes != null) {
          final lastRun = DateTime.parse(lastNotifRes['created_at'].toString());
          if (DateTime.now().difference(lastRun) < interval) {
            shouldNotify = false;
          }
        }

        if (shouldNotify) {
          bool isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());
          await sendNotification(
            userId: assignedTo,
            title: isOverdue ? 'URGENT: OVERDUE TASK' : 'Task Reminder',
            message: isOverdue ? 'Task "$title" is OVERDUE!' : 'Task "$title" is still "$status". Due: ${DateFormat('hh:mm a').format(dueDate?.toLocal() ?? DateTime.now())}',
            type: isOverdue ? 'alert' : 'reminder',
            taskId: taskId,
          );
        }
      }
      
      debugPrint('Smart Escalation Reminders processed.');

    } catch (e) {
      debugPrint('Error running daily reminders: $e');
    }
  }
}
