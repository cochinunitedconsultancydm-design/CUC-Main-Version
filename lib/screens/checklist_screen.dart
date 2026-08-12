import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/checklist.dart';
import '../services/checklist_service.dart';
import '../services/auth_service.dart';
import '../services/deal_service.dart';
import '../models/deal.dart';
import '../services/supabase_backup_service.dart';
import '../theme.dart';
import '../widgets/premium_app_bar.dart';
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> with SingleTickerProviderStateMixin {
  final _checklistService = ChecklistService();
  final _authService = AuthService();
  
  bool _isLoading = true;
  bool _isManager = false;
  int? _userId;
  List<Checklist> _checklists = [];
  List<Checklist> _myTasks = [];
  List<Checklist> _delegatedTasks = [];
  List<Checklist> _allTasks = [];
  TabController? _tabController;
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
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedTaskCategory = 'Applications & Verification';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    _userId = await _authService.getUserId();
    _isManager = await _authService.isManager() || await _authService.isAdmin();
    
    if (_tabController != null) _tabController!.dispose();
    _tabController = TabController(length: _isManager ? 3 : 2, vsync: this);
    
    final allUsers = await _checklistService.getAllUsers();
    final sbUserMap = await SupabaseBackupService().getUsernameToIdMap();
    _users = allUsers.map((u) {
      final uname = u['username']?.toString().toLowerCase();
      final uemail = u['email']?.toString().toLowerCase();
      final intId = sbUserMap[uname] ?? sbUserMap[uemail];
      return {
        ...u,
        'id': intId ?? u['id'],
      };
    }).toList();
    _deals = await DealService().getAllDeals();
    
    final sariga = _users.firstWhere(
      (u) => (u['name'] ?? '').toString().toLowerCase().contains('sariga'), 
      orElse: () => {}
    );
    if (sariga.isNotEmpty && sariga['id'] is int) {
      await _checklistService.patchNullTasksToSariga(sariga['id']);
    }

    await _fetchChecklists();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchChecklists() async {
    if (_userId == null) return;
    
    final all = await _checklistService.getAllChecklists();
    
    if (mounted) {
      setState(() {
        _checklists = all;
        _myTasks = all.where((c) {
          debugPrint('Checking task: ${c.title}, resp: ${c.responsibleId}, user: $_userId');
          return c.responsibleId?.toString() == _userId?.toString();
        }).toList();
        _delegatedTasks = all.where((c) => c.managerId?.toString() == _userId?.toString()).toList();
        _allTasks = all;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchChecklists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _tabController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: PremiumAppBar(
        title: const Text("Today's Task", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: TabBar(
              controller: _tabController!,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey.shade500,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                const Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.person_outline, size: 18), SizedBox(width: 8), Text('My Tasks')],
                  ),
                ),
                const Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.forward_to_inbox_outlined, size: 18), SizedBox(width: 8), Text('Delegated Tasks')],
                  ),
                ),
                if (_isManager) 
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.list_alt_rounded, size: 18), SizedBox(width: 8), Text('All Tasks')],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController!,
              children: [
                _buildChecklistList(_myTasks),
                _buildChecklistList(_delegatedTasks),
                if (_isManager) _buildChecklistList(_allTasks),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
      ),
    );
  }

  Widget _buildChecklistList(List<Checklist> tasks) {
    final appsTasks = tasks.where((t) => t.title.contains('[Applications & Verification]')).toList();
    final casesTasks = tasks.where((t) => t.title.contains('[Cases & RTI]')).toList();
    final billingTasks = tasks.where((t) => t.title.contains('[Billing]')).toList();
    final followUpTasks = tasks.where((t) => t.title.contains('[Follow-ups]')).toList();
    final otherTasks = tasks.where((t) => !t.title.contains('[Applications & Verification]') && !t.title.contains('[Cases & RTI]') && !t.title.contains('[Billing]') && !t.title.contains('[Follow-ups]')).toList();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          
          Widget content;
          if (isWide) {
            content = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildChecklistSection("Applications & Verification", appsTasks)),
                const SizedBox(width: 16),
                Expanded(child: _buildChecklistSection("Cases & RTI", casesTasks)),
                const SizedBox(width: 16),
                Expanded(child: _buildChecklistSection("Billing", billingTasks)),
                const SizedBox(width: 16),
                Expanded(child: _buildChecklistSection("Follow-ups", followUpTasks)),
              ],
            );
          } else {
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildChecklistSection("Applications & Verification", appsTasks),
                const SizedBox(height: 16),
                _buildChecklistSection("Cases & RTI", casesTasks),
                const SizedBox(height: 16),
                _buildChecklistSection("Billing", billingTasks),
                const SizedBox(height: 16),
                _buildChecklistSection("Follow-ups", followUpTasks),
              ],
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                if (otherTasks.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildChecklistSection("Other Tasks", otherTasks),
                ],
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChecklistSection(String title, List<Checklist> sectionTasks) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${sectionTasks.length}',
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sectionTasks.isEmpty)
            Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
              ),
              child: Text(
                "No tasks",
                style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: sectionTasks.length,
              itemBuilder: (context, index) {
                return _buildChecklistCard(sectionTasks[index], isCompact: true);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(Checklist checklist, {bool isCompact = false}) {
    Color statusColor = Colors.grey;
    switch (checklist.status) {
      case 'Completed': statusColor = Colors.green; break;
      case 'Not Completed': statusColor = Colors.red; break;
      case 'Postponed': statusColor = Colors.orange; break;
      case 'Pending': statusColor = Colors.blue; break;
    }

    String cleanTitle = checklist.title;
    for (final cat in ['[Applications & Verification]', '[Cases & RTI]', '[Billing]', '[Follow-ups]']) {
      if (cleanTitle.startsWith(cat)) {
        cleanTitle = cleanTitle.substring(cat.length).trim();
        break;
      }
    }

    String displayTitle = cleanTitle;
    String? displayTime;
    final timeMatch = RegExp(r'^\[(.*?)\]\s+(.*)$').firstMatch(cleanTitle);
    if (timeMatch != null) {
      displayTime = timeMatch.group(1);
      displayTitle = timeMatch.group(2)!;
    }

    return Container(
      margin: isCompact ? const EdgeInsets.only(bottom: 12) : const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showChecklistDetails(checklist, statusColor),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 5, color: statusColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayTitle,
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textColor, height: 1.3),
                                    ),
                                    if (displayTime != null) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.schedule, size: 14, color: AppTheme.primaryColor.withValues(alpha: 0.8)),
                                          const SizedBox(width: 6),
                                          Text(displayTime, style: TextStyle(color: AppTheme.primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600, fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  checklist.status,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          if (checklist.description != null && checklist.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(checklist.description!, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4)),
                          ],
                          if (checklist.dealId != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.link, size: 14, color: Colors.blue.shade700),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      "Deal: ${checklist.dealName}",
                                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Builder(
                                builder: (context) {
                                  final respUser = _users.firstWhere((u) => u['id']?.toString() == checklist.responsibleId?.toString(), orElse: () => {});
                                  final mgrUser = _users.firstWhere((u) => u['id']?.toString() == checklist.managerId?.toString(), orElse: () => {});
                                  
                                  final rName = respUser.isNotEmpty ? respUser['name'] : (checklist.responsibleName ?? 'Unknown');
                                  final mName = mgrUser.isNotEmpty ? mgrUser['name'] : (checklist.managerName ?? 'Manager');
                                  
                                  return Text(
                                    (checklist.managerId == _userId || _isManager) ? "Assigned to $rName" : "From $mName",
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  );
                                }
                              ),
                            ],
                          ),
                          if (checklist.status != 'Pending') ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      checklist.status == 'Completed' ? "Remarks: ${checklist.remarks ?? 'N/A'}" : "Reason: ${checklist.reason ?? 'N/A'}",
                                      style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChecklistDetails(Checklist checklist, Color statusColor) {
    String cleanTitle = checklist.title;
    for (final cat in ['[Applications & Verification]', '[Cases & RTI]', '[Billing]', '[Follow-ups]']) {
      if (cleanTitle.startsWith(cat)) {
        cleanTitle = cleanTitle.substring(cat.length).trim();
        break;
      }
    }

    String displayTitle = cleanTitle;
    String? displayTime;
    final timeMatch = RegExp(r'^\[(.*?)\]\s+(.*)$').firstMatch(cleanTitle);
    if (timeMatch != null) {
      displayTime = timeMatch.group(1);
      displayTitle = timeMatch.group(2)!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Task Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(checklist.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (displayTime != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(displayTime, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  ],
                ),
              ],
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
              if (!_isManager && checklist.status == 'Pending') ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                const Text("Update Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showStatusDialog(checklist, 'Completed');
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text("Complete", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showStatusDialog(checklist, 'Not Completed');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Not Done", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showStatusDialog(checklist, 'Postponed');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: BorderSide(color: Colors.orange.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Postpone", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
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
                              Text("Assign a daily task to a staff member", style: TextStyle(color: AppTheme.mutedTextColor)),
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
                    DropdownButtonFormField<String>(
                      value: _selectedTaskCategory,
                      decoration: InputDecoration(
                        labelText: 'Task Category',
                        prefixIcon: const Icon(Icons.category, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                      ),
                      items: ['Applications & Verification', 'Cases & RTI', 'Billing', 'Follow-ups'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.w500)))).toList(),
                      onChanged: (v) => setDialogState(() => _selectedTaskCategory = v!),
                    ).animate().fadeIn(delay: 50.ms, duration: 400.ms).slideX(begin: 0.05),
                    const SizedBox(height: 20),
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
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
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
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Task Time", style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(_selectedTime.format(context), style: const TextStyle(fontSize: 16)),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.access_time, color: AppTheme.primaryColor),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) {
                          setDialogState(() => _selectedTime = picked);
                        }
                      },
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: 0.05),
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
                        shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
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
        int? respId;
        if (staff['id'] is int) {
          respId = staff['id'];
        } else if (staff['id'] != null) {
          respId = int.tryParse(staff['id'].toString());
        }

        final checklist = Checklist(
          title: '[$_selectedTaskCategory] [${_selectedTime.format(context)}] ${_titleController.text}',
          description: _descController.text,
          responsibleId: respId,
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
        _selectedTime = TimeOfDay.now();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task assigned successfully!")),
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
