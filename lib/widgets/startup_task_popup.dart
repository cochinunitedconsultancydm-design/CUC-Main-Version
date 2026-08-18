import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../models/task.dart';
import '../theme.dart';
import '../screens/task_detail_screen.dart';

class StartupTaskPopup {
  static bool _hasShownThisSession = false;

  static Future<void> checkAndShow(BuildContext context) async {
    if (_hasShownThisSession) return;
    _hasShownThisSession = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final idInt = prefs.getInt('current_user_id');
      final idStr = prefs.getString('current_user_id_str');
      final currentUserId = idInt?.toString() ?? idStr;

      if (currentUserId == null) return;

      // Fetch tasks for the current user that are not completed
      final req = ModelQueries.list(amplify_models.Tasks.classType);
      final res = await Amplify.API.query(request: req).response;
      
      final allTasks = (res.data?.items ?? []).whereType<amplify_models.Tasks>().toList();
      
      // Filter for current user's tasks
      final userTasks = allTasks.where((t) {
        if (t.assigned_to?.toString() != currentUserId) return false;
        if (t.status == 'Completed') return false;
        // Optionally exclude Adjourned if they shouldn't pop up again
        // But let's show all pending/in-progress/adjourned so they remember to do them.
        return true;
      }).toList();

      if (userTasks.isEmpty) return;
      
      // Map to Task model
      final parsedTasks = userTasks.map((m) {
        return Task.fromMap({
          'id': m.id,
          'title': m.title,
          'description': m.description,
          'assigned_by': m.assigned_by,
          'assigned_to': m.assigned_to,
          'status': m.status,
          'due_date': m.due_date,
          'created_at': m.createdAt?.getDateTimeInUtc().toIso8601String(),
          'location': m.location,
          'client_name': m.client_name,
          'phone_number': m.phone_number,
          'updated_at': m.updatedAt?.getDateTimeInUtc().toIso8601String(),
        });
      }).toList();

      parsedTasks.sort((a, b) {
        final dateA = a.createdAt ?? DateTime(2000);
        final dateB = b.createdAt ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => _TaskDialog(tasks: parsedTasks, currentUserId: currentUserId),
        );
      }
    } catch (e) {
      debugPrint('Error showing startup task popup: $e');
    }
  }
}

class _TaskDialog extends StatelessWidget {
  final List<Task> tasks;
  final String currentUserId;

  const _TaskDialog({required this.tasks, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_late_outlined, color: AppTheme.accentColor, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Your Pending Tasks',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'You have ${tasks.length} task${tasks.length == 1 ? '' : 's'} requiring your attention.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = tasks[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        t.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.clientName != null && t.clientName!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Client: ${t.clientName}', style: TextStyle(color: Colors.grey.shade700)),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.getStatusColor(t.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              t.status ?? 'Unknown',
                              style: TextStyle(
                                color: AppTheme.getStatusColor(t.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // We do not pop the dialog, or we can pop it before navigating
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(
                              task: t,
                              isMyTask: true, // It's their task
                              onStatusUpdate: () {}, // Handled when re-fetching on the dashboard if necessary
                              currentUserId: currentUserId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }
}
