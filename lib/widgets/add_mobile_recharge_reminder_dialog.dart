import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/ModelProvider.dart';
import '../theme.dart';
import '../services/notification_service.dart';
import '../services/logging_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cuc_app/services/backup_aware_api.dart';

class AddMobileRechargeReminderDialog extends StatefulWidget {
  final dynamic currentUserId;
  final List<Map<String, dynamic>> allUsers;
  final VoidCallback onSaved;

  const AddMobileRechargeReminderDialog({
    super.key,
    required this.currentUserId,
    required this.allUsers,
    required this.onSaved,
  });

  @override
  State<AddMobileRechargeReminderDialog> createState() => _AddMobileRechargeReminderDialogState();
}

class _AddMobileRechargeReminderDialogState extends State<AddMobileRechargeReminderDialog> {
  final _personNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  dynamic _assignedTo;
  DateTime _baseRechargeDate = DateTime.now().add(const Duration(days: 1));
  int _recurrenceDays = 0; // 0 = Monthly (Same Date)
  int _generationCount = 12;
  bool _isSaving = false;

  final List<int> _reminderDaysBefore = [5, 4, 3, 2, 1];

  @override
  void initState() {
    super.initState();
    _assignedTo = widget.currentUserId?.toString();
  }

  @override
  void dispose() {
    _personNameCtrl.dispose();
    _mobileCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Gets the recharge date for a specific cycle index based on recurrence pattern.
  DateTime _getRechargeDateForCycle(int cycleIndex) {
    if (_recurrenceDays == 0) {
      // Monthly: Same date every month
      int targetYear = _baseRechargeDate.year;
      int targetMonth = _baseRechargeDate.month + cycleIndex;
      while (targetMonth > 12) {
        targetMonth -= 12;
        targetYear += 1;
      }
      final daysInMonth = DateTime(targetYear, targetMonth + 1, 0).day;
      final targetDay = _baseRechargeDate.day > daysInMonth ? daysInMonth : _baseRechargeDate.day;
      return DateTime(targetYear, targetMonth, targetDay, 9, 0);
    } else {
      // Fixed interval (e.g. 28 days)
      return _baseRechargeDate.add(Duration(days: _recurrenceDays * cycleIndex));
    }
  }

  Future<void> _saveReminders() async {
    if (_personNameCtrl.text.isEmpty || _mobileCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill Person Name and Mobile Number.')),
      );
      return;
    }

    if (_mobileCtrl.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final personName = _personNameCtrl.text.trim();
      final mobile = _mobileCtrl.text.trim();
      final notes = _notesCtrl.text.trim();
      int createdCount = 0;
      int generatedCycles = 0;
      int cycleOffset = 0;
      
      final now = DateTime.now();
      String? firstTaskId;

      while (generatedCycles < _generationCount) {
        final rechargeDate = _getRechargeDateForCycle(cycleOffset);
        
        // Check if at least one reminder for this rechargeDate is in the future
        bool hasFutureReminder = false;
        for (final daysBefore in _reminderDaysBefore) {
          if (rechargeDate.subtract(Duration(days: daysBefore)).isAfter(now)) {
            hasFutureReminder = true;
            break;
          }
        }
        
        if (hasFutureReminder) {
          for (final daysBefore in _reminderDaysBefore) {
            final reminderDate = rechargeDate.subtract(Duration(days: daysBefore));
            
            // Skip if reminder date is in the past
            if (reminderDate.isBefore(now)) continue;

            final daysLabel = daysBefore == 1 ? '1 day' : '$daysBefore days';
            final title = '📱 Recharge Reminder: $personName ($daysLabel left)';
            final description = 'Mobile: $mobile\n'
                'Recharge Date: ${DateFormat('dd MMM yyyy').format(rechargeDate)}\n'
                'Days Remaining: $daysBefore\n'
                '${notes.isNotEmpty ? 'Notes: $notes' : ''}'.trim();

            final task = Tasks(
              title: title,
              description: description,
              assigned_to: int.tryParse(_assignedTo.toString()),
              assigned_by: int.tryParse(widget.currentUserId.toString()),
              due_date: reminderDate.toIso8601String(),
              status: 'Pending',
            );

            final res = await BackupAwareApi().create(task);
            if (firstTaskId == null && res.data?.id != null) {
              firstTaskId = res.data!.id;
            }

            createdCount++;
          }
          generatedCycles++;
        }
        cycleOffset++;
      }

      if (firstTaskId != null) {
        String pattern = _recurrenceDays == 0 ? 'Monthly' : 'Every $_recurrenceDays Days';
        await NotificationService().notifyStakeholders(
          taskId: firstTaskId,
          title: '📱 Recurring Mobile Recharge Reminders Set',
          message: 'Created $createdCount reminders for $personName ($mobile) - Pattern: $pattern for $_generationCount cycles.',
          type: 'assignment',
        );
      }

      await LoggingService().logAction(
        action: 'MOBILE_RECHARGE_REMINDER_CREATED',
        targetType: 'Task',
        targetId: '$personName - $mobile',
        details: 'Created $createdCount reminders for $personName ($mobile) for $_generationCount cycles (Recurrence: $_recurrenceDays days), assigned to ID: $_assignedTo',
      );

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$createdCount recharge reminders created for $personName!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save reminders: $e'), backgroundColor: Colors.redAccent),
        );
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

    // Just for UI preview calculation
    final now = DateTime.now();
    DateTime firstRechargeDate = _getRechargeDateForCycle(0);
    if (firstRechargeDate.subtract(const Duration(days: 1)).isBefore(now)) {
      firstRechargeDate = _getRechargeDateForCycle(1);
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
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.green.withAlpha(60), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mobile Recharge Reminder', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)),
                SizedBox(height: 2),
                Text('Get reminders 5 days before recharge', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Person Name
              TextField(
                controller: _personNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Person / Account Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 16),

              // Mobile Number
              TextField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 16),

              // Base Recharge Date
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.green.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: const Text('Next Recharge Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                subtitle: Text(
                  DateFormat('dd MMM yyyy').format(_baseRechargeDate),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)]),
                  child: Icon(Icons.calendar_month_rounded, color: Colors.green.shade700, size: 20),
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _baseRechargeDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Colors.green)),
                      child: child!,
                    ),
                  );
                  if (d != null) setState(() => _baseRechargeDate = d);
                },
              ),
              const SizedBox(height: 16),

              // Plan Validity / Recurrence
              DropdownButtonFormField<int>(
                value: _recurrenceDays,
                decoration: InputDecoration(
                  labelText: 'Plan Validity (Recurrence)',
                  prefixIcon: const Icon(Icons.loop_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Monthly (Same Date)', style: TextStyle(fontWeight: FontWeight.w500))),
                  DropdownMenuItem(value: 24, child: Text('Every 24 Days', style: TextStyle(fontWeight: FontWeight.w500))),
                  DropdownMenuItem(value: 28, child: Text('Every 28 Days', style: TextStyle(fontWeight: FontWeight.w500))),
                  DropdownMenuItem(value: 56, child: Text('Every 56 Days', style: TextStyle(fontWeight: FontWeight.w500))),
                  DropdownMenuItem(value: 84, child: Text('Every 84 Days', style: TextStyle(fontWeight: FontWeight.w500))),
                  DropdownMenuItem(value: 365, child: Text('Yearly (365 Days)', style: TextStyle(fontWeight: FontWeight.w500))),
                ],
                onChanged: (v) => setState(() => _recurrenceDays = v ?? 0),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              // Generate For (Cycles)
              DropdownButtonFormField<int>(
                value: _generationCount,
                decoration: InputDecoration(
                  labelText: 'Generate For',
                  prefixIcon: const Icon(Icons.auto_mode_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
                items: [1, 3, 6, 12, 24].map((m) => DropdownMenuItem<int>(
                  value: m,
                  child: Text('$m Cycles/Recharges', style: const TextStyle(fontWeight: FontWeight.w500)),
                )).toList(),
                onChanged: (v) => setState(() => _generationCount = v ?? 12),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Assign To
              DropdownButtonFormField<dynamic>(
                initialValue: _assignedTo,
                decoration: InputDecoration(
                  labelText: 'Assign Reminders To',
                  prefixIcon: const Icon(Icons.assignment_ind_outlined, size: 20),
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

              // Notes
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 24), child: Icon(Icons.sticky_note_2_outlined, size: 20)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 16),

              // Info Box: Reminder Schedule Preview
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'First Month\'s Schedule',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._reminderDaysBefore.map((daysBefore) {
                      final reminderDate = firstRechargeDate.subtract(Duration(days: daysBefore));
                      final isPast = reminderDate.isBefore(DateTime.now());
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              isPast ? Icons.close_rounded : Icons.notifications_active_rounded,
                              size: 14,
                              color: isPast ? Colors.grey : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${DateFormat('dd MMM yyyy (EEE)').format(reminderDate)} — $daysBefore ${daysBefore == 1 ? 'day' : 'days'} before',
                              style: TextStyle(
                                fontSize: 12,
                                color: isPast ? Colors.grey : Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                                decoration: isPast ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (isPast) ...[
                              const SizedBox(width: 6),
                              Text('(skipped)', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
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
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveReminders,
          icon: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.phone_android_rounded, size: 18),
          label: Text(
            _isSaving ? 'Creating...' : 'Create Reminders',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            shadowColor: Colors.green.withAlpha(100),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }
}
