import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../services/logging_service.dart';
import '../theme.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'task_detail_screen.dart';
import 'dart:async';

class TaskManagementScreen extends StatefulWidget {
  final String? initialStatus;
  const TaskManagementScreen({super.key, this.initialStatus});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> with SingleTickerProviderStateMixin {
  final _auth = AuthService();
  
  late TabController _tabController;
  
  bool _isLoading = true;
  bool _isAdmin = false;
  dynamic _currentUserId;
  
  List<Task> _myTasks = [];
  List<Task> _delegatedTasks = [];
  List<Task> _allTasks = []; // For Admins

  List<Map<String, dynamic>> _allUsers = [];
  final _searchController = TextEditingController();
  String _statusFilter = 'All';

  StreamSubscription? _createSub;
  StreamSubscription? _updateSub;
  StreamSubscription? _deleteSub;

  @override
  void initState() {
    super.initState();
    if (widget.initialStatus != null) {
      _statusFilter = widget.initialStatus!;
    }
    _initData();
  }

  Future<void> _initData() async {
    dynamic userId;
    bool isAdmin = false;
    
    try {
      final role = await _auth.getUserRole();
      final name = await _auth.getUserName();
      isAdmin = role == 'admin' || role == 'manager';
      
      final prefs = await SharedPreferences.getInstance();
      final idInt = prefs.getInt('current_user_id');
      final idStr = prefs.getString('current_user_id_str');
      userId = idInt ?? idStr;
      
      if (userId == null && name != null) {
        final req = ModelQueries.list(amplify_models.Users.classType, where: amplify_models.Users.USERNAME.eq(name));
        final res = await Amplify.API.query(request: req).response;
        if (res.data?.items.isNotEmpty == true) {
          userId = res.data!.items.first!.id;
        }
      }
    } catch (e) {
      debugPrint('Error in _initData: $e');
    }
    
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _currentUserId = userId ?? '0';
        _tabController = TabController(length: _isAdmin ? 3 : 2, vsync: this);
      });
    }

    await Future.wait([
      _fetchTasks(),
      _fetchUsers(),
    ]);
    
    _subscribeToTasks();
  }

  void _subscribeToTasks() {
    _createSub = Amplify.API.subscribe(
      ModelSubscriptions.onCreate(amplify_models.Tasks.classType),
    ).listen((event) => _fetchTasks());

    _updateSub = Amplify.API.subscribe(
      ModelSubscriptions.onUpdate(amplify_models.Tasks.classType),
    ).listen((event) => _fetchTasks());

    _deleteSub = Amplify.API.subscribe(
      ModelSubscriptions.onDelete(amplify_models.Tasks.classType),
    ).listen((event) => _fetchTasks());
  }

  @override
  void dispose() {
    _createSub?.cancel();
    _updateSub?.cancel();
    _deleteSub?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final req = ModelQueries.list(amplify_models.Users.classType);
      final res = await Amplify.API.query(request: req).response;
      var users = res.data?.items.whereType<amplify_models.Users>().toList() ?? [];
      users.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      if (mounted) {
        setState(() {
          _allUsers = users.map((u) => {
            'id': u.id,
            'name': u.name,
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchTasks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.Tasks.classType);
      final res = await Amplify.API.query(request: req).response;
      var tasks = res.data?.items.whereType<amplify_models.Tasks>().toList() ?? [];
      
      tasks.sort((a, b) {
        final dateA = a.createdAt?.getDateTimeInUtc() ?? DateTime(2000);
        final dateB = b.createdAt?.getDateTimeInUtc() ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      
      final uReq = ModelQueries.list(amplify_models.Users.classType);
      final uRes = await Amplify.API.query(request: uReq).response;
      final usersList = uRes.data?.items.whereType<amplify_models.Users>().toList() ?? [];
      final userMap = {for (var u in usersList) u.id.toString(): u};

      final List<Task> parsedTasks = tasks.map((m) {
        final assignedByMap = userMap[m.assigned_by?.toString()];
        final assignedToMap = userMap[m.assigned_to?.toString()];
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
          'assigned_by_name': assignedByMap?.name,
          'assigned_to_name': assignedToMap?.name,
        });
      }).toList();

      if (mounted) {
        setState(() {
          _allTasks = parsedTasks;
          if (_currentUserId != null) {
            _myTasks = parsedTasks.where((t) => t.assignedTo?.toString() == _currentUserId?.toString()).toList();
            _delegatedTasks = parsedTasks.where((t) => t.assignedBy?.toString() == _currentUserId?.toString()).toList();
          } else {
            _myTasks = [];
            _delegatedTasks = [];
          }
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading tasks: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTaskStatus(Task task, String newStatus) async {
    try {
      final req = ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.ID.eq(task.id.toString()));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final existingTask = res.data!.items.first!;
        final updated = existingTask.copyWith(status: newStatus);
        await Amplify.API.mutate(request: ModelMutations.update(updated));
      }
      _fetchTasks();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _deleteTask(dynamic id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
        ],
      )
    );
    if (ok == true) {
      try {
        final req = ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.ID.eq(id.toString()));
        final res = await Amplify.API.query(request: req).response;
        if (res.data?.items.isNotEmpty == true) {
          await Amplify.API.mutate(request: ModelMutations.delete(res.data!.items.first!));
        }
        _fetchTasks();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  void _showTaskDialog([Task? task]) {
    final titleCtrl = TextEditingController(text: task?.title);
    final descCtrl = TextEditingController(text: task?.description);
    final locCtrl = TextEditingController(text: task?.location);
    final clientCtrl = TextEditingController(text: task?.clientName);
    final phoneCtrl = TextEditingController(text: task?.phoneNumber);
    dynamic assignedTo = task?.assignedTo;
    DateTime? dueDate = task?.dueDate != null ? DateTime.tryParse(task!.dueDate!) : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(task == null ? 'Assign New Task' : 'Edit Task'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Task Title', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location (Optional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined))),
                    const SizedBox(height: 16),
                    TextField(controller: clientCtrl, decoration: const InputDecoration(labelText: 'Client Name (Optional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline))),
                    const SizedBox(height: 16),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number (Optional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined))),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<dynamic>(
                      initialValue: assignedTo,
                      decoration: const InputDecoration(labelText: 'Assign To', border: OutlineInputBorder()),
                      items: _allUsers.map((u) => DropdownMenuItem<dynamic>(
                        value: u['id'],
                        child: Text(u['name'].toString()),
                      )).toList(),
                      onChanged: (v) => setModalState(() => assignedTo = v),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
                      title: Text(dueDate == null ? 'Select Due Date & Time' : 'Due: ${DateFormat('MMM dd, yyyy - hh:mm a').format(dueDate!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) {
                          if (!context.mounted) return;
                          final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(dueDate ?? DateTime.now()),
                          );
                          if (t != null) {
                            setModalState(() => dueDate = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                          } else {
                            setModalState(() => dueDate = d);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.isEmpty || assignedTo == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill title and assignee')));
                    return;
                  }
                  try {
                    if (task == null) {
                      final newTask = amplify_models.Tasks(
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        assigned_to: int.tryParse(assignedTo.toString()),
                        assigned_by: int.tryParse(_currentUserId.toString()),
                        due_date: dueDate?.toIso8601String(),
                        location: locCtrl.text.isEmpty ? null : locCtrl.text,
                        client_name: clientCtrl.text.isEmpty ? null : clientCtrl.text,
                        phone_number: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                        status: 'Pending',
                      );
                      final res = await Amplify.API.mutate(request: ModelMutations.create(newTask)).response;
                      final newId = res.data?.id;
                      final tName = titleCtrl.text;
                      
                      if (newId != null) {
                        await NotificationService().notifyStakeholders(
                          taskId: newId,
                          title: 'New Task Created',
                          message: 'Task "$tName" has been created and assigned.',
                          type: 'assignment',
                        );
                      }
                      await LoggingService().logAction(action: 'TASK_CREATED', targetType: 'Task', targetId: tName, details: 'Assigned to ID: $assignedTo');
                    } else {
                      final req = ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.ID.eq(task.id.toString()));
                      final res = await Amplify.API.query(request: req).response;
                      if (res.data?.items.isNotEmpty == true) {
                        final existingTask = res.data!.items.first!;
                        final updatedTask = existingTask.copyWith(
                          title: titleCtrl.text,
                          description: descCtrl.text,
                          assigned_to: int.tryParse(assignedTo.toString()),
                          due_date: dueDate?.toIso8601String(),
                          location: locCtrl.text.isEmpty ? null : locCtrl.text,
                          client_name: clientCtrl.text.isEmpty ? null : clientCtrl.text,
                          phone_number: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                        );
                        await Amplify.API.mutate(request: ModelMutations.update(updatedTask));
                      }
                      
                      await LoggingService().logAction(action: 'TASK_UPDATED', targetType: 'Task', targetId: task.id.toString(), details: 'Updated task: ${titleCtrl.text}');
                      await NotificationService().notifyStakeholders(
                        taskId: task.id,
                        title: 'Task Updated',
                        message: 'Task "${titleCtrl.text}" has been updated.',
                        type: 'info',
                      );
                    }
                    if (mounted) Navigator.pop(context);
                    _fetchTasks();
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                child: const Text('Save Task'),
              ),
            ],
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    if (_currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWide)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Task Management', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2, color: const Color(0xFF1E293B))),
                Row(
                  children: [
                    IconButton(
                      onPressed: _fetchTasks,
                      icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showTaskDialog(),
                      icon: const Icon(Icons.add_task),
                      label: const Text('Assign Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else ...[
            Text('Task Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1.2, color: const Color(0xFF1E293B))),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: _fetchTasks,
                  icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTaskDialog(),
                    icon: const Icon(Icons.add_task),
                    label: const Text('Assign Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              const Tab(text: 'My Tasks'),
              const Tab(text: 'Delegated Tasks'),
              if (_isAdmin) const Tab(text: 'All Tasks'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks, clients or locations...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
                    items: ['All', 'Pending', 'In Progress', 'Adjourned', 'Completed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _statusFilter = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(_myTasks, isWide, isMyTask: true),
                    _buildTaskList(_delegatedTasks, isWide, isMyTask: false),
                    if (_isAdmin) _buildTaskList(_allTasks, isWide, isMyTask: false),
                  ],
                ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildTaskList(List<Task> tasks, bool isWide, {required bool isMyTask}) {
    final searchTerm = _searchController.text.toLowerCase();
    final filteredTasks = tasks.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(searchTerm) || 
                            (t.description?.toLowerCase().contains(searchTerm) ?? false) ||
                            (t.clientName?.toLowerCase().contains(searchTerm) ?? false) ||
                            (t.location?.toLowerCase().contains(searchTerm) ?? false);
      final matchesStatus = _statusFilter == 'All' || t.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(_searchController.text.isEmpty && _statusFilter == 'All' ? 'No tasks found!' : 'No matching tasks!', style: TextStyle(color: Colors.grey.shade500, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: filteredTasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = filteredTasks[index];
        final isCompleted = t.status == 'Completed';
        final isOverdue = t.dueDate != null && DateTime.parse(t.dueDate!).isBefore(DateTime.now()) && !isCompleted;

        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: t, 
                isMyTask: isMyTask, 
                onStatusUpdate: _fetchTasks,
                currentUserId: _currentUserId,
              ),
            ),
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green.withValues(alpha: 0.1) : AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle : Icons.assignment,
                          color: isCompleted ? Colors.green : AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: isCompleted ? TextDecoration.lineThrough : null)),
                            const SizedBox(height: 4),
                            Text(
                              t.description ?? 'No description',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _infoChip(Icons.person, isMyTask ? 'From: ${t.assignedByName ?? "System"}' : 'To: ${t.assignedToName ?? "Unknown"}', Colors.blue.shade700),
                                if (t.dueDate != null)
                                  _infoChip(Icons.calendar_today, 'Due: ${DateFormat('MMM dd').format(DateTime.parse(t.dueDate!))}', isOverdue ? Colors.red : Colors.orange.shade800),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isCompleted 
                                        ? Colors.green 
                                        : (t.status == 'In Progress' 
                                            ? Colors.blue 
                                            : (t.status == 'Adjourned' 
                                                ? Colors.amber 
                                                : Colors.grey))).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t.status, 
                                    style: TextStyle(
                                      color: isCompleted 
                                          ? Colors.green 
                                          : (t.status == 'In Progress' 
                                              ? Colors.blue 
                                              : (t.status == 'Adjourned' 
                                                  ? Colors.amber.shade900 
                                                  : Colors.grey.shade700)), 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isWide) ...[
                        const SizedBox(width: 16),
                        _buildActionButtons(t, isMyTask),
                      ]
                    ],
                  ),
                  if (!isWide && (_isAdmin || !isMyTask)) ...[
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActionButtons(t, isMyTask),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (30 * index).ms).slideX(begin: 0.02, end: 0);
      },
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionButtons(Task t, bool isMyTask) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMyTask || _isAdmin) ...[
          IconButton(onPressed: () => _showTaskDialog(t), icon: const Icon(Icons.edit, color: Colors.grey)),
          IconButton(onPressed: () => _deleteTask(t.id!), icon: const Icon(Icons.delete, color: Colors.redAccent)),
        ],
      ],
    );
  }
}
