import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import '../models/checklist.dart' as old;
import 'auth_service.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistService {

  Future<List<old.Checklist>> getChecklistsForUser(int userId, {String? date}) async {
    final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
    
    try {
      final req = ModelQueries.list(
        Checklists.classType,
        where: Checklists.RESPONSIBLE_ID.eq(userId).and(
          Checklists.DUE_DATE.eq(targetDate).or(Checklists.STATUS.eq('Pending').and(Checklists.DUE_DATE.lt(targetDate)))
        )
      );
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<Checklists>().toList() ?? [];
      
      items.sort((a, b) => (b.createdAt?.toString() ?? '').compareTo(a.createdAt?.toString() ?? ''));
      
      List<old.Checklist> mapped = [];
      for (var c in items) {
        String? mName, rName;
        if (c.manager_id != null) {
          final mReq = ModelQueries.list(Users.classType, where: Users.ID.eq(c.manager_id));
          final mRes = await Amplify.API.query(request: mReq).response;
          if (mRes.data?.items.isNotEmpty == true) mName = mRes.data!.items.first?.name;
        }
        if (c.responsible_id != null) {
          final rReq = ModelQueries.list(Users.classType, where: Users.ID.eq(c.responsible_id));
          final rRes = await Amplify.API.query(request: rReq).response;
          if (rRes.data?.items.isNotEmpty == true) rName = rRes.data!.items.first?.name;
        }
        mapped.add(old.Checklist.fromMap({
          ...c.toJson(),
          'manager_name': mName,
          'responsible_name': rName,
        }));
      }
      return mapped;
    } catch (e) {
      safePrint('Error getChecklistsForUser: $e');
      return [];
    }
  }

  Future<List<old.Checklist>> getAllChecklists({String? date}) async {
    final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
    try {
      final req = ModelQueries.list(
        Checklists.classType,
        where: Checklists.DUE_DATE.eq(targetDate).or(Checklists.STATUS.eq('Pending').and(Checklists.DUE_DATE.lt(targetDate)))
      );
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<Checklists>().toList() ?? [];
      items.sort((a, b) => (b.createdAt?.toString() ?? '').compareTo(a.createdAt?.toString() ?? ''));
      
      List<old.Checklist> mapped = [];
      for (var c in items) {
        String? mName, rName;
        if (c.manager_id != null) {
          final mReq = ModelQueries.list(Users.classType, where: Users.ID.eq(c.manager_id));
          final mRes = await Amplify.API.query(request: mReq).response;
          if (mRes.data?.items.isNotEmpty == true) mName = mRes.data!.items.first?.name;
        }
        if (c.responsible_id != null) {
          final rReq = ModelQueries.list(Users.classType, where: Users.ID.eq(c.responsible_id));
          final rRes = await Amplify.API.query(request: rReq).response;
          if (rRes.data?.items.isNotEmpty == true) rName = rRes.data!.items.first?.name;
        }
        mapped.add(old.Checklist.fromMap({
          ...c.toJson(),
          'manager_name': mName,
          'responsible_name': rName,
        }));
      }
      return mapped;
    } catch (e) {
      safePrint('Error getAllChecklists: $e');
      return [];
    }
  }

  Future<dynamic> createChecklist(old.Checklist checklist) async {
    final prefs = await SharedPreferences.getInstance();
    final managerId = prefs.getInt('current_user_id');
    
    final Map<String, dynamic> values = checklist.toMap();
    final mId = values['manager_id'] ?? managerId;
    final dDate = values['due_date'] ?? DateTime.now().toIso8601String().split('T')[0];
    
    final newChecklist = Checklists(
      title: values['title'] ?? '',
      description: values['description'],
      manager_id: mId,
      responsible_id: values['responsible_id'],
      status: values['status'] ?? 'Pending',
      remarks: values['remarks'],
      reason: values['reason'],
      due_date: dDate,
    );

    try {
      final res = await Amplify.API.mutate(request: ModelMutations.create(newChecklist)).response;
      final checklistId = res.data?.id;

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
    } catch (e) {
      safePrint('Error createChecklist: $e');
      throw e;
    }
  }

  Future<void> updateChecklistStatus(dynamic id, String status, {String? remarks, String? reason, String? newDueDate, bool reassignToManager = false}) async {
    try {
      final req = ModelQueries.get(Checklists.classType, ChecklistsModelIdentifier(id: id.toString()));
      final res = await Amplify.API.query(request: req).response;
      if (res.data == null) return;
      
      final c = res.data!;
      int? respId = c.responsible_id;
      if (reassignToManager && c.manager_id != null) {
        respId = c.manager_id;
      }

      final updated = c.copyWith(
        status: status,
        remarks: remarks,
        reason: reason,
        due_date: newDueDate,
        responsible_id: respId,
      );
      
      await Amplify.API.mutate(request: ModelMutations.update(updated)).response;

      if (c.manager_id != null) {
        String responsibleName = 'Staff';
        if (c.responsible_id != null) {
          final rReq = ModelQueries.list(Users.classType, where: Users.ID.eq(c.responsible_id));
          final rRes = await Amplify.API.query(request: rReq).response;
          if (rRes.data?.items.isNotEmpty == true) responsibleName = rRes.data!.items.first?.name ?? 'Staff';
        }

        await NotificationService().sendNotification(
          userId: c.manager_id!,
          title: "Checklist $status",
          message: "$responsibleName marked \"${c.title}\" as $status${reassignToManager ? ' and assigned it back to you' : ''}.",
          type: 'checklist_update',
        );
      }
    } catch (e) {
      safePrint('Error updateChecklistStatus: $e');
      throw e;
    }
  }

  Future<int> getPendingCountForUser(int userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      final req = ModelQueries.list(
        Checklists.classType, 
        where: Checklists.RESPONSIBLE_ID.eq(userId)
          .and(Checklists.DUE_DATE.eq(today))
          .and(Checklists.STATUS.eq('Pending'))
      );
      final res = await Amplify.API.query(request: req).response;
      return res.data?.items.length ?? 0;
    } catch (e) {
      safePrint('Error getPendingCountForUser: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final req = ModelQueries.list(Users.classType);
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<Users>().toList() ?? [];
      items.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      return items.map((u) => u.toJson()).toList();
    } catch (e) {
      safePrint('Error getAllUsers: $e');
      return [];
    }
  }

  Future<void> deleteChecklist(dynamic id) async {
    try {
      await Amplify.API.mutate(
        request: ModelMutations.deleteById(Checklists.classType, ChecklistsModelIdentifier(id: id.toString()))
      ).response;
    } catch (e) {
      safePrint('Error deleteChecklist: $e');
      throw e;
    }
  }
}
