import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ModelProvider.dart';
import '../theme.dart';
import '../services/notification_service.dart';
import '../services/logging_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cuc_app/services/backup_aware_api.dart';

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
  int _recurrenceDays = -1; // -1 = None, 0 = Monthly, 7 = Weekly, 28 = Every 28 Days, 365 = Yearly
  int _generationCount = 12;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _assignedTo = widget.currentUserId?.toString();
    _dueDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  DateTime _getDueDateForCycle(int cycleIndex) {
    if (_recurrenceDays == -1) return _dueDate!;
    if (_recurrenceDays == 0) {
      int targetYear = _dueDate!.year;
      int targetMonth = _dueDate!.month + cycleIndex;
      while (targetMonth > 12) {
        targetMonth -= 12;
        targetYear += 1;
      }
      final daysInMonth = DateTime(targetYear, targetMonth + 1, 0).day;
      final targetDay = _dueDate!.day > daysInMonth ? daysInMonth : _dueDate!.day;
      return DateTime(targetYear, targetMonth, targetDay, _dueDate!.hour, _dueDate!.minute);
    } else {
      return _dueDate!.add(Duration(days: _recurrenceDays * cycleIndex));
    }
  }

  Future<void> _saveReminder() async {
    if (_titleCtrl.text.isEmpty || _assignedTo == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      int createdCount = 0;
      final int cycles = _recurrenceDays == -1 ? 1 : _generationCount;
      String? firstTaskId;
      
      for (int i = 0; i < cycles; i++) {
        final cycleDate = _getDueDateForCycle(i);
        
        // Skip past dates if recurring
        if (_recurrenceDays != -1 && cycleDate.isBefore(DateTime.now())) continue;

        final task = Tasks(
          title: _titleCtrl.text,
          description: _descCtrl.text.isNotEmpty ? _descCtrl.text : 'Calendar Reminder',
          assigned_to: int.tryParse(_assignedTo.toString()),
          assigned_by: int.tryParse(widget.currentUserId.toString()),
          due_date: cycleDate.toIso8601String(),
          status: 'Pending',
        );

        final res = await BackupAwareApi().create(task);
        if (firstTaskId == null && res.data?.id != null) {
          firstTaskId = res.data!.id;
        }
        createdCount++;
      }

      if (firstTaskId != null) {
        String msg = createdCount > 1 
            ? 'Created $createdCount recurring reminders for "${_titleCtrl.text}".'
            : 'Reminder "${_titleCtrl.text}" has been added to your calendar.';
        await NotificationService().notifyStakeholders(
          taskId: firstTaskId,
          title: createdCount > 1 ? 'Recurring Reminders Added' : 'New Reminder Added',
          message: msg,
          type: 'assignment',
        );
      }
      
      await LoggingService().logAction(
        action: 'REMINDER_CREATED', 
        targetType: 'Task', 
        targetId: _titleCtrl.text, 
        details: 'Assigned to ID: $_assignedTo via Calendar. Cycles: $createdCount'
      );

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(createdCount > 1 ? '$createdCount recurring reminders added!' : 'Reminder added to calendar!', style: const TextStyle(color: Colors.white)), backgroundColor: AppTheme.primaryColor));
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
    // Hot-reload safeguard: ensure _assignedTo is string and exists in the list
    if (_assignedTo != null) {
      _assignedTo = _assignedTo.toString();
      final exists = widget.allUsers.any((u) => u['id']?.toString() == _assignedTo);
      if (!exists && widget.allUsers.isNotEmpty) {
        _assignedTo = widget.allUsers.first['id']?.toString();
      }
    }

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
                  value: u['id']?.toString(),
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
              const SizedBox(height: 16),
              // Plan Validity / Recurrence
              DropdownButtonFormField<int>(
                initialValue: _recurrenceDays,
                decoration: InputDecoration(
                  labelText: 'Recurrence',
                  prefixIcon: const Icon(Icons.loop_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
                items: const [
                  DropdownMenuItem(value: -1, child: Text('None (One-time)', style: TextStyle(fontWeight: FontWeight.w500))),
                  DropdownMenuItem(value: 0, child: Text('Monthly (Same Date)', style: TextStyle(fontWeight: FontWeight.w500))),
                  DropdownMenuItem(value: 7, child: Text('Every Week (7 Days)', style: TextStyle(fontWeight: FontWeight.w500))),
                  DropdownMenuItem(value: 28, child: Text('Every 28 Days', style: TextStyle(fontWeight: FontWeight.w500))),
                  DropdownMenuItem(value: 365, child: Text('Yearly (365 Days)', style: TextStyle(fontWeight: FontWeight.w500))),
                ],
                onChanged: (v) => setState(() => _recurrenceDays = v ?? -1),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              ),
              
              if (_recurrenceDays != -1) ...[
                const SizedBox(height: 16),
                // Generate For (Cycles)
                DropdownButtonFormField<int>(
                  initialValue: _generationCount,
                  decoration: InputDecoration(
                    labelText: 'Generate For',
                    prefixIcon: const Icon(Icons.auto_mode_rounded, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                  ),
                  items: [2, 3, 6, 12, 24, 36].map((m) => DropdownMenuItem<int>(
                    value: m,
                    child: Text('$m Occurrences', style: const TextStyle(fontWeight: FontWeight.w500)),
                  )).toList(),
                  onChanged: (v) => setState(() => _generationCount = v ?? 12),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                ),
              ],
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
