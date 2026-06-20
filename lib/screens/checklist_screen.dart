import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/checklist.dart';
import '../services/checklist_service.dart';
import '../services/auth_service.dart';
import '../services/deal_service.dart';
import '../models/deal.dart';
import '../theme.dart';
import '../widgets/premium_app_bar.dart';
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final _checklistService = ChecklistService();
  final _authService = AuthService();
  
  bool _isLoading = true;
  bool _isManager = false;
  int? _userId;
  List<Checklist> _checklists = [];
  List<Map<String, dynamic>> _users = [];
  List<Deal> _deals = [];
  
  // Create Checklist Form
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<Map<String, dynamic>> _selectedStaff = [];
  int? _selectedDealId;
  TextEditingController? _staffTextController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    _userId = await _authService.getUserId();
    _isManager = await _authService.isManager() || await _authService.isAdmin();
    
    if (_isManager) {
      final allUsers = await _checklistService.getAllUsers();
      _users = allUsers.where((u) => u['id'] != _userId).toList();
      _deals = await DealService().getAllDeals();
    }
    
    await _fetchChecklists();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchChecklists() async {
    if (_userId == null) return;
    
    if (_isManager) {
      _checklists = await _checklistService.getAllChecklists();
    } else {
      _checklists = await _checklistService.getChecklistsForUser(_userId!);
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchChecklists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: PremiumAppBar(
        title: const Text("Today's Task", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _buildChecklistList(),
      floatingActionButton: _isManager ? FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(24),
                child: _buildCreateForm(setDialogState),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Create Task', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ) : null,
    );
  }

  Widget _buildChecklistList() {
    if (_checklists.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Center(child: Text("No checklists for today.", style: TextStyle(color: Colors.grey))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _checklists.length,
        itemBuilder: (context, index) {
          final checklist = _checklists[index];
          return _buildChecklistCard(checklist);
        },
      ),
    );
  }

  Widget _buildChecklistCard(Checklist checklist) {
    Color statusColor = Colors.grey;
    switch (checklist.status) {
      case 'Completed': statusColor = Colors.green; break;
      case 'Not Completed': statusColor = Colors.red; break;
      case 'Postponed': statusColor = Colors.orange; break;
      case 'Pending': statusColor = Colors.blue; break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showChecklistDetails(checklist, statusColor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    checklist.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    checklist.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (checklist.description != null && checklist.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(checklist.description!, style: const TextStyle(color: Colors.grey)),
            ],
            if (checklist.dealId != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.link, size: 14, color: AppTheme.primaryColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Connected Work: ${checklist.dealName}",
                      style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _isManager ? "Responsible: ${checklist.responsibleName ?? 'Unknown'}" : "Assigned by: ${checklist.managerName ?? 'Manager'}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (checklist.status != 'Pending') ...[
              const SizedBox(height: 8),
              Text(
                checklist.status == 'Completed' ? "Remarks: ${checklist.remarks ?? 'N/A'}" : "Reason: ${checklist.reason ?? 'N/A'}",
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
            if (!_isManager && checklist.status == 'Pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showStatusDialog(checklist, 'Completed'),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text("Complete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showStatusDialog(checklist, 'Not Completed'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Not Done"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showStatusDialog(checklist, 'Postponed'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                      child: const Text("Postpone"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  void _showChecklistDetails(Checklist checklist, Color statusColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Task Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(checklist.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(checklist.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (checklist.description != null && checklist.description!.isNotEmpty) ...[
                const Text("Description", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(checklist.description!),
                const SizedBox(height: 16),
              ],
              const Text("Assigned To", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(checklist.responsibleName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              const Text("Created By", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(checklist.managerName ?? 'Manager', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              if (checklist.dealName != null) ...[
                const Text("Connected Work", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(checklist.dealName!, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
              ],
              if (checklist.dueDate != null) ...[
                const Text("Due Date", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(checklist.dueDate!, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
              ],
              if (checklist.remarks != null && checklist.remarks!.isNotEmpty) ...[
                const Text("Remarks", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(checklist.remarks!, style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 16),
              ],
              if (checklist.reason != null && checklist.reason!.isNotEmpty) ...[
                const Text("Reason for Delay", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(checklist.reason!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.red)),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        actions: [
          if (_isManager)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmation(checklist);
              },
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }
  
  void _showDeleteConfirmation(Checklist checklist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to completely delete this task? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _checklistService.deleteChecklist(checklist.id!);
                await _fetchChecklists();
              } catch(e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
              if (mounted) setState(() => _isLoading = false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      )
    );
  }

  Widget _buildCreateForm(StateSetter setDialogState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 8,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.assignment_add, color: AppTheme.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Create New Task", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text("Assign a daily checklist to a staff member", style: TextStyle(color: AppTheme.mutedTextColor)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 24,
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Task Title",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                        prefixIcon: const Icon(Icons.title, color: AppTheme.primaryColor),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Please enter a title" : null,
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: 0.05),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: "Description (Optional)",
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 48),
                          child: Icon(Icons.description, color: AppTheme.primaryColor),
                        ),
                      ),
                      maxLines: 3,
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: 0.05),
                    const SizedBox(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Task Date", style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate), style: const TextStyle(fontSize: 16)),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => _selectedDate = picked);
                        }
                      },
                    ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideX(begin: 0.05),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Assign To", style: TextStyle(fontWeight: FontWeight.w600)),
                                if (_users.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () {
                                      setDialogState(() {
                                        if (_selectedStaff.length == _users.length) {
                                          _selectedStaff.clear();
                                        } else {
                                          _selectedStaff = List.from(_users);
                                        }
                                      });
                                    },
                                    icon: Icon(_selectedStaff.length == _users.length ? Icons.clear_all : Icons.done_all, size: 18),
                                    label: Text(_selectedStaff.length == _users.length ? "Clear All" : "Select All"),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_selectedStaff.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedStaff.map((u) => Chip(
                                  label: Text("${u['name']} (${u['role']})"),
                                  onDeleted: () => setDialogState(() => _selectedStaff.remove(u)),
                                  backgroundColor: AppTheme.primaryColor.withAlpha(25),
                                  deleteIconColor: AppTheme.primaryColor,
                                  side: BorderSide.none,
                                )).toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Autocomplete<Map<String, dynamic>>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) return const Iterable<Map<String, dynamic>>.empty();
                                return _users.where((u) => 
                                  "${u['name']} (${u['role']})".toLowerCase().contains(textEditingValue.text.toLowerCase()) && 
                                  !_selectedStaff.any((s) => s['id'] == u['id'])
                                );
                              },
                              displayStringForOption: (u) => "${u['name']} (${u['role']})",
                              onSelected: (u) {
                                setDialogState(() {
                                  if (!_selectedStaff.any((s) => s['id'] == u['id'])) {
                                    _selectedStaff.add(u);
                                  }
                                });
                                _staffTextController?.clear();
                              },
                              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                _staffTextController = textEditingController;
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: "Search & Assign Staff",
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                                    prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                                  ),
                                  onChanged: (val) {
                                    // if (val.isEmpty) setDialogState(() => _selectedResponsibleId = null);
                                  },
                                );
                              },
                              optionsViewBuilder: (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(12),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(maxHeight: 250, maxWidth: constraints.maxWidth),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          final option = options.elementAt(index);
                                          return ListTile(
                                            title: Text("${option['name']} (${option['role']})", style: const TextStyle(fontWeight: FontWeight.w500)),
                                            onTap: () => onSelected(option),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        );
                      }
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: 0.05),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Autocomplete<Deal>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) return const Iterable<Deal>.empty();
                            return _deals.where((d) => d.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                          },
                          displayStringForOption: (d) => d.name,
                          onSelected: (d) => setDialogState(() => _selectedDealId = d.id),
                          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: "Search & Connect Work (Optional)",
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                                prefixIcon: const Icon(Icons.link, color: AppTheme.primaryColor),
                                suffixIcon: const Icon(Icons.search, color: Colors.grey),
                              ),
                              onChanged: (val) {
                                if (val.isEmpty) setDialogState(() => _selectedDealId = null);
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 250, maxWidth: constraints.maxWidth),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: 0.05),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Assign Task to Staff", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedStaff.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields and assign to at least one staff member.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? dealName;
      if (_selectedDealId != null) {
        dealName = _deals.firstWhere((d) => d.id == _selectedDealId).name;
      }
      
      for (final staff in _selectedStaff) {
        final checklist = Checklist(
          title: _titleController.text,
          description: _descController.text,
          responsibleId: staff['id'],
          dealId: _selectedDealId,
          dealName: dealName,
          dueDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        );
        await _checklistService.createChecklist(checklist);
      }
      
      _titleController.clear();
      _descController.clear();
      setState(() {
        _selectedStaff.clear();
        _selectedDealId = null;
        _selectedDate = DateTime.now();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checklist assigned successfully!")),
      );
      
      Navigator.pop(context); // Close the dialog
      await _fetchChecklists();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showStatusDialog(Checklist checklist, String status) {
    final controller = TextEditingController();
    final isComplete = status == 'Completed';
    final isPostponed = status == 'Postponed';
    
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    bool giveToManager = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isComplete ? "Complete Task" : (isPostponed ? "Postpone Task" : "Report Issue")),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Are you sure you want to mark this as $status?"),
                const SizedBox(height: 16),
                if (isPostponed) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("New Due Date", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryColor),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Give back to manager", style: TextStyle(fontSize: 14)),
                    value: giveToManager,
                    onChanged: (val) => setDialogState(() => giveToManager = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: isComplete ? "Remarks" : "Reason",
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  await _checklistService.updateChecklistStatus(
                    checklist.id!,
                    status,
                    remarks: isComplete ? controller.text : null,
                    reason: !isComplete ? controller.text : null,
                    newDueDate: isPostponed ? DateFormat('yyyy-MM-dd').format(selectedDate) : null,
                    reassignToManager: isPostponed && giveToManager,
                  );
                  await _fetchChecklists();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isComplete ? Colors.green : (isPostponed ? Colors.orange : Colors.red),
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
