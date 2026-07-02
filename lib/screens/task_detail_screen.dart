import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../models/task.dart';
import '../theme.dart';
import '../services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cuc_app/services/backup_aware_api.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final bool isMyTask;
  final VoidCallback onStatusUpdate;
  final dynamic currentUserId;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.isMyTask,
    required this.onStatusUpdate,
    this.currentUserId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.ID.eq(_task.id.toString()));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final existingTask = res.data!.items.first!;
        
        String? desc = existingTask.description;
        // Clean description when resuming from Adjourned status
        if (newStatus == 'In Progress' && _task.status == 'Adjourned') {
          final parsed = AdjournmentDetails.parse(_task.description);
          desc = parsed.cleanDescription;
        }

        final updatedAmplifyTask = existingTask.copyWith(
          status: newStatus,
          description: desc,
        );

        await BackupAwareApi().update(updatedAmplifyTask);

        // Re-fetch to get joined user data for UI mapping
        final fetchedUpdatedTask = await _fetchTask(_task.id.toString());
        if (fetchedUpdatedTask != null) {
          // Notify creator on completion
          if (newStatus == 'Completed' && fetchedUpdatedTask.assignedBy != null) {
            await NotificationService().notifyStakeholders(
              taskId: fetchedUpdatedTask.id,
              title: 'Task Completed',
              message: 'Your task "${fetchedUpdatedTask.title}" has been completed by ${fetchedUpdatedTask.assignedToName}.',
              type: 'completion',
            );
          } else if (newStatus == 'In Progress' && fetchedUpdatedTask.assignedBy != null) {
            await NotificationService().notifyStakeholders(
              taskId: fetchedUpdatedTask.id,
              title: 'Task Started',
              message: '${fetchedUpdatedTask.assignedToName} has started work on "${fetchedUpdatedTask.title}".',
              type: 'info',
            );
          }

          if (mounted) {
            setState(() {
              _task = fetchedUpdatedTask;
            });
          }

          // Notify the assigner if someone else updates the status
          if (_task.assignedBy != null && _task.assignedBy.toString() != widget.currentUserId.toString()) {
            await NotificationService().notifyStakeholders(
              taskId: _task.id,
              title: 'Task Status Updated',
              message: 'Task "${_task.title}" is now ${_task.status} by ${_task.assignedToName ?? "Staff"}',
              type: 'status_update',
            );
          }
        }
      }
      
      widget.onStatusUpdate();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Task?> _fetchTask(String id) async {
    final req = ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.ID.eq(id));
    final res = await Amplify.API.query(request: req).response;
    if (res.data?.items.isNotEmpty == true) {
      final t = res.data!.items.first!;
      
      // Fetch users
      final uReq = ModelQueries.list(amplify_models.Users.classType);
      final uRes = await Amplify.API.query(request: uReq).response;
      final users = uRes.data?.items.whereType<amplify_models.Users>().toList() ?? [];
      final userMap = {for (var u in users) u.id.toString(): u};
      
      final assignedByUser = userMap[t.assigned_by?.toString()];
      final assignedToUser = userMap[t.assigned_to?.toString()];
      
      return Task.fromMap({
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'assigned_by': t.assigned_by,
        'assigned_to': t.assigned_to,
        'status': t.status,
        'due_date': t.due_date,
        'created_at': t.createdAt?.getDateTimeInUtc().toIso8601String(),
        'updated_at': t.updatedAt?.getDateTimeInUtc().toIso8601String(),
        'location': t.location,
        'client_name': t.client_name,
        'phone_number': t.phone_number,
        'assigned_by_name': assignedByUser?.name,
        'assigned_to_name': assignedToUser?.name,
      });
    }
    return null;
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch action')));
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openMap(String location) async {
    if (location.toLowerCase().startsWith('http')) {
      await _launchUrl(location);
    } else {
      final query = Uri.encodeComponent(location);
      final url = 'https://www.google.com/maps/search/?api=1&query=$query';
      await _launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _task.status == 'Completed';
    final isInProgress = _task.status == 'In Progress';
    final isAdjourned = _task.status == 'Adjourned';
    final isPickedUp = _task.status == 'Picked Up';
    final requiresReturn = _task.title.contains('[Requires Return]');
    final statusColor = isCompleted 
        ? Colors.green 
        : (isPickedUp ? Colors.teal : (isInProgress 
            ? Colors.blue 
            : (isAdjourned ? Colors.amber.shade700 : Colors.orange)));
    
    final createdAtDate = _task.createdAt != null ? DateTime.tryParse(_task.createdAt!)?.toLocal() : null;
    final dueDate = _task.dueDate != null ? DateTime.tryParse(_task.dueDate!)?.toLocal() : null;
    final updatedAtDate = _task.updatedAt != null ? DateTime.tryParse(_task.updatedAt!)?.toLocal() : null;
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now()) && !isCompleted;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: statusColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [statusColor, statusColor.withBlue(255).withRed(100)],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(Icons.assignment_rounded, size: 200, color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _task.status.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _task.title,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOverdue)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          const Text('This task is past its due date!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ).animate().shake(),

                  Row(
                    children: [
                      Expanded(child: _buildQuickInfo(Icons.person_outline, 'Assigned To', _task.assignedToName ?? 'Unassigned')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickInfo(Icons.info_outline_rounded, 'Status', _task.status)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildQuickInfo(Icons.calendar_today_rounded, 'Due Date', dueDate != null ? DateFormat('MMM dd, yyyy').format(dueDate) : 'No Date')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickInfo(Icons.access_time_rounded, 'Due Time', dueDate != null ? DateFormat('hh:mm a').format(dueDate) : 'No Time')),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (isCompleted && updatedAtDate != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('COMPLETION TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a').format(updatedAtDate),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF166534)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                  const Text('DESCRIPTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.mutedTextColor, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Text(
                      AdjournmentDetails.parse(_task.description).cleanDescription.isEmpty
                          ? 'No description provided.'
                          : AdjournmentDetails.parse(_task.description).cleanDescription,
                      style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF334155)),
                    ),
                  ),
                  
                  if (isAdjourned) ...[
                    Builder(
                      builder: (context) {
                        final adjDetails = AdjournmentDetails.parse(_task.description);
                        if (adjDetails.reason == null) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            const Text('ADJOURNMENT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.mutedTextColor, letterSpacing: 1)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.amber.shade200),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, color: Colors.amber.shade900),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'TASK ADJOURNED',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Reason: ${adjDetails.reason}',
                                    style: const TextStyle(fontSize: 15, color: Color(0xFF78350F), height: 1.5),
                                  ),
                                  if (adjDetails.postponedDate != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Postponed Date: ${DateFormat('dd MMM yyyy').format(adjDetails.postponedDate!)}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                                    ),
                                  ],
                                ],
                              ),
                            ).animate().fadeIn().scale(),
                          ],
                        );
                      }
                    ),
                  ],
                  const SizedBox(height: 32),

                  const Text('ADDITIONAL DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.mutedTextColor, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  _buildDetailTile(Icons.person_pin_rounded, 'Client Name', _task.clientName ?? 'N/A'),
                   _buildDetailTile(
                    Icons.phone_iphone_rounded, 
                    'Phone Number', 
                    _task.phoneNumber ?? 'N/A',
                    onTap: (_task.phoneNumber != null && _task.phoneNumber != 'N/A') ? () => _launchUrl('tel:${_task.phoneNumber}') : null,
                  ),
                  _buildDetailTile(
                    Icons.location_on_rounded, 
                    'Location', 
                    _task.location ?? 'N/A',
                    onTap: (_task.location != null && _task.location != 'N/A') ? () => _openMap(_task.location!) : null,
                  ),
                  if (dueDate != null)
                    _buildDetailTile(Icons.calendar_month_rounded, 'Due Date', DateFormat('dd MMM yyyy, hh:mm a').format(dueDate)),
                  _buildDetailTile(Icons.history_rounded, 'Created On', createdAtDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAtDate) : 'N/A'),
                  _buildDetailTile(Icons.verified_user_outlined, 'Assigned By', _task.assignedByName ?? 'System'),
                  if (isCompleted && updatedAtDate != null)
                    _buildDetailTile(Icons.check_circle_outline_rounded, 'Completed On', DateFormat('dd MMM yyyy, hh:mm a').format(updatedAtDate)),

                  const SizedBox(height: 40),

                  if (widget.isMyTask && !isCompleted)
                    Center(
                      child: Column(
                        children: [
                          const Text('ACTION REQUIRED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.mutedTextColor, letterSpacing: 2)),
                          const SizedBox(height: 16),
                          _isLoading 
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  _SlideAction(
                                    key: ValueKey('${_task.status}_1'),
                                    label: isAdjourned 
                                        ? 'SLIDE TO RESUME WORK' 
                                        : (isPickedUp
                                            ? 'SLIDE TO RETURN'
                                            : (isInProgress 
                                                ? (requiresReturn ? 'SLIDE TO PICKUP' : 'SLIDE TO COMPLETE') 
                                                : 'SLIDE TO START WORK')),
                                    baseColor: isAdjourned 
                                        ? Colors.amber.shade800 
                                        : (isPickedUp
                                            ? Colors.teal
                                            : (isInProgress ? Colors.green : Colors.blue)),
                                    onSlide: () => _updateStatus(
                                      isAdjourned 
                                          ? 'In Progress' 
                                          : (isPickedUp
                                              ? 'Completed'
                                              : (isInProgress 
                                                  ? (requiresReturn ? 'Picked Up' : 'Completed') 
                                                  : 'In Progress')),
                                    ),
                                  ),
                                  if (isInProgress) ...[
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final reasonController = TextEditingController();
                                        DateTime? postponedDate;
                                        
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (c) => StatefulBuilder(
                                            builder: (context, setStateModal) {
                                              return AlertDialog(
                                                title: const Text('Adjourn Task'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller: reasonController,
                                                      decoration: const InputDecoration(
                                                        labelText: 'Reason for Adjournment',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    ListTile(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                        side: BorderSide(color: Colors.grey.shade300),
                                                      ),
                                                      title: Text(postponedDate == null 
                                                          ? 'Select Postponed Date' 
                                                          : 'Postponed to: ${DateFormat('dd MMM yyyy').format(postponedDate!)}'),
                                                      trailing: const Icon(Icons.calendar_today),
                                                      onTap: () async {
                                                        final picked = await showDatePicker(
                                                          context: context,
                                                          initialDate: DateTime.now().add(const Duration(days: 1)),
                                                          firstDate: DateTime.now(),
                                                          lastDate: DateTime.now().add(const Duration(days: 365)),
                                                        );
                                                        if (picked != null) {
                                                          setStateModal(() => postponedDate = picked);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(c, false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (reasonController.text.isEmpty || postponedDate == null) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Please fill all fields')),
                                                        );
                                                        return;
                                                      }
                                                      Navigator.pop(c, true);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.amber.shade800,
                                                      foregroundColor: Colors.white,
                                                    ),
                                                    child: const Text('Adjourn'),
                                                  ),
                                                ],
                                              );
                                            }
                                          ),
                                        );
                                        
                                        if (confirm == true) {
                                          final currentDesc = AdjournmentDetails.parse(_task.description).cleanDescription;
                                          final dateStr = DateFormat('yyyy-MM-dd').format(postponedDate!);
                                          final newDesc = "${currentDesc.trim()}\n\n[ADJOURNED]\nReason: ${reasonController.text}\nPostponed Date: $dateStr";
                                          
                                          setState(() => _isLoading = true);
                                          try {
                                            final req = ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.ID.eq(_task.id.toString()));
                                            final res = await Amplify.API.query(request: req).response;
                                            if (res.data?.items.isNotEmpty == true) {
                                              final existingTask = res.data!.items.first!;
                                              final updatedAmplifyTask = existingTask.copyWith(
                                                description: newDesc,
                                              );
                                              await BackupAwareApi().update(updatedAmplifyTask);
                                            }
                                            
                                            await _updateStatus('Adjourned');
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to adjourn: $e')),
                                            );
                                          } finally {
                                            if (mounted) setState(() => _isLoading = false);
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.pause_circle_outline_rounded),
                                      label: const Text('ADJOURN TASK', style: TextStyle(fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.amber.shade800,
                                        side: BorderSide(color: Colors.amber.shade800, width: 2),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.mutedTextColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value, 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), height: 1.2),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: onTap != null ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.05), shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
                    Text(
                      value, 
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600, 
                        color: const Color(0xFF1E293B),
                        decoration: onTap != null ? TextDecoration.underline : null,
                        decorationColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                      )
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.open_in_new_rounded, size: 14, color: AppTheme.primaryColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideAction extends StatefulWidget {
  final String label;
  final VoidCallback onSlide;
  final Color baseColor;

  const _SlideAction({super.key, required this.label, required this.onSlide, required this.baseColor});

  @override
  State<_SlideAction> createState() => _SlideActionState();
}

class _SlideActionState extends State<_SlideAction> {
  double _position = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        return Container(
          width: maxWidth,
          height: 64,
          decoration: BoxDecoration(
            color: widget.baseColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(widget.label, style: TextStyle(color: widget.baseColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
              ),
              Positioned(
                left: _position + 4,
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _position += details.delta.dx;
                      if (_position < 0) _position = 0;
                      if (_position > maxWidth - 60) _position = maxWidth - 60;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_position > maxWidth - 80) {
                      setState(() => _position = maxWidth - 60);
                      widget.onSlide();
                    } else {
                      setState(() => _position = 0);
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.baseColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: widget.baseColor.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Icon(Icons.double_arrow_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class AdjournmentDetails {
  final String? reason;
  final DateTime? postponedDate;
  final String cleanDescription;

  AdjournmentDetails({this.reason, this.postponedDate, required this.cleanDescription});

  factory AdjournmentDetails.parse(String? desc) {
    if (desc == null || desc.isEmpty) {
      return AdjournmentDetails(cleanDescription: '');
    }

    final regExp = RegExp(
      r'\[ADJOURNED\]\s*\n\s*Reason:\s*(.*?)\s*\n\s*Postponed Date:\s*(.*?)$',
      multiLine: true,
      caseSensitive: false,
    );

    final match = regExp.firstMatch(desc);
    if (match != null) {
      final reason = match.group(1)?.trim();
      final dateStr = match.group(2)?.trim();
      DateTime? date;
      if (dateStr != null) {
        date = DateTime.tryParse(dateStr);
      }
      
      final index = desc.indexOf('[ADJOURNED]');
      final clean = desc.substring(0, index).trim();
      return AdjournmentDetails(reason: reason, postponedDate: date, cleanDescription: clean);
    }

    return AdjournmentDetails(cleanDescription: desc);
  }
}

