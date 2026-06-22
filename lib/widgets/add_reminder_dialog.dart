import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import '../theme.dart';
import '../services/notification_service.dart';
import '../services/logging_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddReminderDialog extends StatefulWidget {
  final dynamic currentUserId;
  final List<Map<String, dynamic>> allUsers;
  final VoidCallback onSaved;

  const AddReminderDialog({
    super.key,
    required this.currentUserId,
    required this.allUsers,
    required this.onSaved,
  });

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  dynamic _assignedTo;
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _assignedTo = widget.currentUserId;
    _dueDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveReminder() async {
    if (_titleCtrl.text.isEmpty || _assignedTo == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final task = Tasks(
        title: _titleCtrl.text,
        description: _descCtrl.text.isNotEmpty ? _descCtrl.text : 'Calendar Reminder',
        assigned_to: int.tryParse(_assignedTo.toString()),
        assigned_by: int.tryParse(widget.currentUserId.toString()),
        due_date: _dueDate!.toIso8601String(),
        status: 'Pending',
      );

      final res = await Amplify.API.mutate(request: ModelMutations.create(task)).response;
      final newTask = res.data;
      final newId = newTask?.id;

      if (newId != null) {
        await NotificationService().notifyStakeholders(
          taskId: newId,
          title: 'New Reminder Added',
          message: 'Reminder "${_titleCtrl.text}" has been added to your calendar.',
          type: 'assignment',
        );
      }
      
      await LoggingService().logAction(
        action: 'REMINDER_CREATED', 
        targetType: 'Task', 
        targetId: _titleCtrl.text, 
        details: 'Assigned to ID: $_assignedTo via Calendar'
      );

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder added to calendar!', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.primaryColor));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save reminder: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_available_rounded, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Text('New Reminder', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        ],
      ),
      content: SizedBox(
        width: 500, // Fixed max width for premium look
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleCtrl, 
                decoration: InputDecoration(
                  labelText: 'Reminder Title (e.g. Visit Village Office)',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl, 
                maxLines: 2, 
                decoration: InputDecoration(
                  labelText: 'Details / Notes (Optional)',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<dynamic>(
                initialValue: _assignedTo,
                decoration: InputDecoration(
                  labelText: 'Assign To',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
                items: widget.allUsers.map((u) => DropdownMenuItem<dynamic>(
                  value: u['id'],
                  child: Text(u['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w500)),
                )).toList(),
                onChanged: (v) => setState(() => _assignedTo = v),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AppTheme.primaryColor.withAlpha(10),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                  _dueDate == null ? 'Select Date & Time' : 'Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(_dueDate!)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)]),
                  child: const Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 18),
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.primaryColor,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (d != null) {
                    if (!mounted) return;
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
                    );
                    if (t != null) {
                      setState(() => _dueDate = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                    } else {
                      setState(() => _dueDate = d);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), foregroundColor: Colors.grey.shade700),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveReminder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor, 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            shadowColor: AppTheme.primaryColor.withAlpha(100),
          ),
          child: _isSaving 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }
}
