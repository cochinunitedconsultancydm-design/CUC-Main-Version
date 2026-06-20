import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deal.dart';
import '../models/deal_activity.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DealService {
  final _client = Supabase.instance.client;

  Future<List<Deal>> getAllDeals() async {
    final response = await _client
        .from('deals')
        .select()
        .order('updated_at', ascending: false);
    return response.map((map) => Deal.fromMap(map)).toList();
  }

  Stream<List<Deal>> getDealsStream() {
    return _client
        .from('deals')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((data) => data.map((map) => Deal.fromMap(map)).toList());
  }

  Future<void> deleteDeal(int id) async {
    await _client.from('deals').delete().eq('id', id);
  }

  Future<Deal?> getDealById(int id) async {
    final response = await _client
        .from('deals')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return Deal.fromMap(response);
  }

  Future<List<Deal>> getDealsByStage(String stage) async {
    final response = await _client
        .from('deals')
        .select()
        .eq('stage', stage)
        .order('updated_at', ascending: false);
    return response.map((map) => Deal.fromMap(map)).toList();
  }

  Future<int> createDeal(Deal deal) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    final userName = prefs.getString('user_name');

    final Map<String, dynamic> values = deal.toMap();
    values.remove('id'); // Remove id for INSERT as it's auto-generated
    if (values['responsible_id'] == null) values['responsible_id'] = userId;
    if (values['responsible_name'] == null) values['responsible_name'] = userName;

    final response = await _client
        .from('deals')
        .insert(values)
        .select('id')
        .single();
    
    final dealId = response['id'] as int;

    // Add initial lead as assignee
    if (userId != null) {
      await _client.from('deal_assignees').insert({
        'deal_id': dealId,
        'user_id': userId,
        'role': 'Lead',
      });
    }

    // Log creation activity
    await addActivity(DealActivity(
      dealId: dealId,
      type: 'status',
      title: 'Work Created',
      description: 'Project pipeline started at stage: ${deal.stage}',
      createdBy: userId ?? 1,
    ));

    // Notify stakeholders using centralized service
    await NotificationService().notifyStakeholders(
      title: 'New Work Created',
      message: '${userName ?? 'A staff member'} created a new work: ${deal.name}',
      dealId: dealId,
    );

    return dealId;
  }

  Future<void> updateDeal(Deal deal) async {
    final Map<String, dynamic> values = deal.toMap();
    final id = values.remove('id');
    
    await _client
        .from('deals')
        .update(values)
        .eq('id', id);

    await NotificationService().notifyStakeholders(
      title: 'Work Updated',
      message: 'Work "${deal.name}" has been updated.',
      dealId: deal.id,
    );
  }

  Future<void> moveDealToStage(int dealId, String fromStage, String toStage) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');

    await _client
        .from('deals')
        .update({'stage': toStage, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', dealId);

    await _client.from('deal_stage_history').insert({
      'deal_id': dealId,
      'from_stage': fromStage,
      'to_stage': toStage,
      'changed_by': userId,
    });

    final dealRes = await _client
        .from('deals')
        .select('name, responsible_id')
        .eq('id', dealId)
        .single();
        
    final dealName = dealRes['name'] ?? 'Unknown Deal';
    final responsibleId = dealRes['responsible_id'] as int?;
    
    if (toStage == 'Completed' && responsibleId != null) {
      await NotificationService().sendNotification(
        userId: responsibleId,
        title: 'Work Completed',
        message: 'Your work "$dealName" has been marked as Completed.',
        type: 'completion',
        dealId: dealId,
      );
    } else {
      await NotificationService().notifyStakeholders(
        title: 'Work Stage Updated',
        message: 'Work "$dealName" moved from $fromStage to $toStage',
        dealId: dealId,
      );
    }
  }

  Future<void> handoverDeal(int dealId, int fromUserId, int toUserId, String note) async {
    // 1. Log handover
    await _client.from('deal_handover_history').insert({
      'deal_id': dealId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'note': note,
    });

    // 2. Update primary responsible person
    final userRes = await _client.from('users').select('name').eq('id', toUserId).single();
    final toUserName = userRes['name'] ?? 'Unknown';

    await _client
        .from('deals')
        .update({
          'responsible_id': toUserId,
          'responsible_name': toUserName,
          'updated_at': DateTime.now().toIso8601String()
        })
        .eq('id', dealId);

    // 3. Ensure new person is an assignee with Lead role
    await _client
        .from('deal_assignees')
        .update({'role': 'Collaborator'})
        .match({'deal_id': dealId, 'user_id': fromUserId});

    await _client.from('deal_assignees').upsert({
      'deal_id': dealId,
      'user_id': toUserId,
      'role': 'Lead',
    }, onConflict: 'deal_id,user_id');

    final fromRes = await _client.from('users').select('name').eq('id', fromUserId).single();
    final fromUserName = fromRes['name'] ?? 'Unknown';

    final dealRes = await _client.from('deals').select('name').eq('id', dealId).single();
    final dealName = dealRes['name'] ?? 'Work';

    await NotificationService().notifyStakeholders(
      title: 'Work Handover',
      message: '$fromUserName handed over work "$dealName" to you ($toUserName). Note: $note',
      type: 'assignment',
      dealId: dealId,
    );
  }

  Future<void> addAssignee(int dealId, int userId, {String role = 'Collaborator'}) async {
    await _client.from('deal_assignees').upsert({
      'deal_id': dealId,
      'user_id': userId,
      'role': role,
    }, onConflict: 'deal_id,user_id');

    final dealRes = await _client.from('deals').select('name').eq('id', dealId).single();
    final dealName = dealRes['name'] ?? 'Work';

    await NotificationService().notifyStakeholders(
      dealId: dealId,
      title: 'Work Team Updated',
      message: 'Team for "$dealName" has been updated.',
      type: 'assignment',
    );
  }

  Future<void> removeAssignee(int dealId, int userId) async {
    await _client.from('deal_assignees').delete().match({
      'deal_id': dealId,
      'user_id': userId,
    });
  }

  Future<List<DealAssignee>> getAssignees(int dealId) async {
    final response = await _client
        .from('deal_assignees')
        .select('*, users(name)')
        .eq('deal_id', dealId);
    
    return response.map((map) {
      // Flatten the user name from the join
      final user = map['users'] as Map<String, dynamic>?;
      if (user != null) map['user_name'] = user['name'];
      return DealAssignee.fromMap(map);
    }).toList();
  }

  Future<void> addActivity(DealActivity activity) async {
    final values = activity.toMap();
    values.remove('id');
    values.remove('is_completed');
    
    await _client.from('deal_activities').insert(values);
  }

  Future<List<DealActivity>> getActivities(int dealId) async {
    try {
      final response = await _client
          .from('deal_activities')
          .select()
          .eq('deal_id', dealId)
          .order('created_at', ascending: false);
      
      final users = await getAllUsers();
      final userMap = {
        for (var u in users) u['id'] as int: u['name'] as String
      };
      
      return response.map((map) {
        final createdById = map['created_by'] as int?;
        if (createdById != null) {
          map['creator_name'] = userMap[createdById] ?? 'Unknown';
        }
        return DealActivity.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('Error getting activities: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVerificationHistory() async {
    try {
      final response = await _client
          .from('deal_activities')
          .select('*, deals(name, responsible_name, drive_link)')
          .filter('title', 'in', '("Work Verified","Reverification Needed")')
          .order('created_at', ascending: false);

      final users = await getAllUsers();
      final userMap = {for (var u in users) u['id'] as int: u['name'] as String};
      
      return response.map((map) {
        final deal = map['deals'] as Map<String, dynamic>?;
        return {
          'id': map['id'],
          'deal_id': map['deal_id'],
          'deal_name': deal?['name'] ?? 'Unknown Deal',
          'drive_link': deal?['drive_link'],
          'sender': deal?['responsible_name'] ?? 'Unknown',
          'reviewer': userMap[map['created_by']] ?? 'Unknown',
          'status': map['title'] == 'Work Verified' ? 'Verified' : 'Rejected',
          'reason': map['title'] == 'Work Verified' ? '-' : map['description']?.replaceAll('Returned for reverification. Remarks: ', '') ?? '',
          'created_at': map['created_at'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting verification history: $e');
      return [];
    }
  }

  Future<void> toggleActivityCompletion(int activityId, bool completed) async {
    await _client
        .from('deal_activities')
        .update({'is_completed': completed})
        .eq('id', activityId);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _client
        .from('users')
        .select('id, name, username, role')
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
}
