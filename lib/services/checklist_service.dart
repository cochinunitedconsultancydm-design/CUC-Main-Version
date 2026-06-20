import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/checklist.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistService {
  final _client = Supabase.instance.client;

  Future<List<Checklist>> getChecklistsForUser(int userId, {String? date}) async {
    final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
    
    final response = await _client
        .from('checklists')
        .select('*, manager:users!manager_id(name), responsible:users!responsible_id(name)')
        .eq('responsible_id', userId)
        .or('due_date.eq.$targetDate,and(status.eq.Pending,due_date.lt.$targetDate)')
        .order('created_at', ascending: false);
    
    return response.map((map) {
      final manager = map['manager'] as Map<String, dynamic>?;
      final responsible = map['responsible'] as Map<String, dynamic>?;
      if (manager != null) map['manager_name'] = manager['name'];
      if (responsible != null) map['responsible_name'] = responsible['name'];
      return Checklist.fromMap(map);
    }).toList();
  }

  Future<List<Checklist>> getAllChecklists({String? date}) async {
    final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
    
    final response = await _client
        .from('checklists')
        .select('*, manager:users!manager_id(name), responsible:users!responsible_id(name)')
        .or('due_date.eq.$targetDate,and(status.eq.Pending,due_date.lt.$targetDate)')
        .order('created_at', ascending: false);
    
    return response.map((map) {
      final manager = map['manager'] as Map<String, dynamic>?;
      final responsible = map['responsible'] as Map<String, dynamic>?;
      if (manager != null) map['manager_name'] = manager['name'];
      if (responsible != null) map['responsible_name'] = responsible['name'];
      return Checklist.fromMap(map);
    }).toList();
  }

  Future<int> createChecklist(Checklist checklist) async {
    final prefs = await SharedPreferences.getInstance();
    final managerId = prefs.getInt('current_user_id');
    
    final Map<String, dynamic> values = checklist.toMap();
    values.remove('id');
    if (values['manager_id'] == null) values['manager_id'] = managerId;
    if (values['due_date'] == null) values['due_date'] = DateTime.now().toIso8601String().split('T')[0];

    final response = await _client
        .from('checklists')
        .insert(values)
        .select('id')
        .single();
    
    final checklistId = response['id'] as int;

    if (checklist.responsibleId != null) {
      final managerName = await AuthService().getUserName();
      await NotificationService().sendNotification(
        userId: checklist.responsibleId!,
        title: "New Checklist Assigned",
        message: "${managerName ?? 'Manager'} assigned you a new checklist: ${checklist.title}",
        type: 'checklist',
      );
    }

    return checklistId;
  }

  Future<void> updateChecklistStatus(int id, String status, {String? remarks, String? reason, String? newDueDate, bool reassignToManager = false}) async {
    final Map<String, dynamic> updateData = {
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (remarks != null) updateData['remarks'] = remarks;
    if (reason != null) updateData['reason'] = reason;
    if (newDueDate != null) updateData['due_date'] = newDueDate;

    // Fetch existing checklist data if we need it for reassignment or notification
    final checklistRes = await _client
        .from('checklists')
        .select('manager_id, title, responsible_id, users!responsible_id(name)')
        .eq('id', id)
        .single();
    
    final managerId = checklistRes['manager_id'] as int?;
    final title = checklistRes['title'];
    final responsibleName = checklistRes['users']?['name'] ?? 'Staff';

    if (reassignToManager && managerId != null) {
      updateData['responsible_id'] = managerId;
    }

    await _client
        .from('checklists')
        .update(updateData)
        .eq('id', id);
        
    // Notify the manager
    if (managerId != null) {
      await NotificationService().sendNotification(
        userId: managerId,
        title: "Checklist $status",
        message: "$responsibleName marked \"$title\" as $status${reassignToManager ? ' and assigned it back to you' : ''}.",
        type: 'checklist_update',
      );
    }
  }

  Future<int> getPendingCountForUser(int userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client
        .from('checklists')
        .select('id')
        .eq('responsible_id', userId)
        .eq('due_date', today)
        .eq('status', 'Pending');
    
    return response.length;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _client
        .from('users')
        .select('id, name, username, role')
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteChecklist(int id) async {
    await _client.from('checklists').delete().eq('id', id);
  }
}
