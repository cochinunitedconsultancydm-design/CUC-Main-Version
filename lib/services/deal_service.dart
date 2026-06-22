import 'package:amplify_api/amplify_api.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import '../models/deal.dart' as old;
import '../models/deal_activity.dart' as oldActivity;
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DealService {

  Future<List<old.Deal>> getAllDeals() async {
    try {
      final req = ModelQueries.list(Deals.classType);
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<Deals>().toList() ?? [];
      items.sort((a, b) => (b.updatedAt?.toString() ?? '').compareTo(a.updatedAt?.toString() ?? ''));
      return items.map((m) => old.Deal.fromMap(m.toJson())).toList();
    } catch (e) {
      debugPrint('Error getAllDeals: $e');
      return [];
    }
  }

  Stream<List<old.Deal>> getDealsStream() {
    late StreamController<List<old.Deal>> controller;
    StreamSubscription<GraphQLResponse<String>>? createSub;
    StreamSubscription<GraphQLResponse<String>>? updateSub;
    StreamSubscription<GraphQLResponse<String>>? deleteSub;

    void fetchAndEmit() async {
      try {
        final req = ModelQueries.list(Deals.classType);
        final res = await Amplify.API.query(request: req).response;
        var items = res.data?.items.where((e) => e != null).cast<Deals>().toList() ?? [];
        items.sort((a, b) => (b.updatedAt?.toString() ?? '').compareTo(a.updatedAt?.toString() ?? ''));
        controller.add(items.map((m) => old.Deal.fromMap(m.toJson())).toList());
      } catch (e) {
        debugPrint('Error fetchAndEmit deals: $e');
      }
    }

    controller = StreamController<List<old.Deal>>.broadcast(
      onListen: () {
        fetchAndEmit();
        createSub = Amplify.API.subscribe(GraphQLRequest<String>(document: 'subscription { onCreateDeals { id } }')).listen((_) => fetchAndEmit());
        updateSub = Amplify.API.subscribe(GraphQLRequest<String>(document: 'subscription { onUpdateDeals { id } }')).listen((_) => fetchAndEmit());
        deleteSub = Amplify.API.subscribe(GraphQLRequest<String>(document: 'subscription { onDeleteDeals { id } }')).listen((_) => fetchAndEmit());
      },
      onCancel: () {
        createSub?.cancel();
        updateSub?.cancel();
        deleteSub?.cancel();
      }
    );

    return controller.stream;
  }

  Future<void> deleteDeal(dynamic id) async {
    try {
      final req = ModelQueries.list(Deals.classType, where: Deals.ID.eq(id.toString()));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        await Amplify.API.mutate(request: ModelMutations.delete(res.data!.items.first!).response);
      }
    } catch (e) {
      debugPrint('Error deleteDeal: $e');
    }
  }

  Future<old.Deal?> getDealById(dynamic id) async {
    try {
      final req = ModelQueries.list(Deals.classType, where: Deals.ID.eq(id.toString()));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        return old.Deal.fromMap(res.data!.items.first!.toJson());
      }
    } catch (e) {
      debugPrint('Error getDealById: $e');
    }
    return null;
  }

  Future<List<old.Deal>> getDealsByStage(String stage) async {
    try {
      final req = ModelQueries.list(Deals.classType, where: Deals.STAGE.eq(stage));
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<Deals>().toList() ?? [];
      items.sort((a, b) => (b.updatedAt?.toString() ?? '').compareTo(a.updatedAt?.toString() ?? ''));
      return items.map((m) => old.Deal.fromMap(m.toJson())).toList();
    } catch (e) {
      debugPrint('Error getDealsByStage: $e');
      return [];
    }
  }

  Future<dynamic> createDeal(old.Deal deal) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    final userName = prefs.getString('user_name');

    final Map<String, dynamic> values = deal.toMap();
    values.remove('id');
    if (values['responsible_id'] == null) values['responsible_id'] = userId;
    if (values['responsible_name'] == null) values['responsible_name'] = userName;

    try {
      final newDeal = Deals.fromJson(values);
      final res = await Amplify.API.mutate(request: ModelMutations.create(newDeal).response).response;
      final dealId = res.data?.id;

      if (dealId != null && userId != null) {
        final assignee = DealAssignees(deal_id: dealId, user_id: userId, role: 'Lead');
        await Amplify.API.mutate(request: ModelMutations.create(assignee).response);
      }

      if (dealId != null) {
        await addActivity(oldActivity.DealActivity(
          dealId: dealId,
          type: 'status',
          title: 'Work Created',
          description: 'Project pipeline started at stage: ${deal.stage}',
          createdBy: userId ?? 1,
        ));

        await NotificationService().notifyStakeholders(
          title: 'New Work Created',
          message: '${userName ?? 'A staff member'} created a new work: ${deal.name}',
          dealId: dealId,
        );
      }

      return dealId;
    } catch (e) {
      debugPrint('Error createDeal: $e');
      throw e;
    }
  }

  Future<void> updateDeal(old.Deal deal) async {
    final Map<String, dynamic> values = deal.toMap();
    final id = values.remove('id');
    
    try {
      final req = ModelQueries.list(Deals.classType, where: Deals.ID.eq(id.toString()));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isEmpty == true) return;
      
      final c = res.data!.items.first!;
      final updated = c.copyWith(
        name: values['name'],
        client_id: values['client_id'],
        client_name: values['client_name'],
        contact_info: values['contact_info'],
        company: values['company'],
        work_type: values['work_type'],
        stage: values['stage'],
        responsible_id: values['responsible_id'],
        responsible_name: values['responsible_name'],
        amount: values['amount'] != null ? double.tryParse(values['amount'].toString()) : null,
        currency: values['currency'],
        pipeline: values['pipeline'],
        priority: values['priority'],
        description: values['description'],
        is_won: values['is_won'],
        reg_fee_required: values['reg_fee_required'],
        referred_by: values['referred_by'],
        files_received: values['files_received'],
        contact_status: values['contact_status'],
        files_asked: values['files_asked'],
        est_amount_work: values['est_amount_work'] != null ? double.tryParse(values['est_amount_work'].toString()) : null,
        create_invoice_share: values['create_invoice_share'],
        expense_spent: values['expense_spent'] != null ? double.tryParse(values['expense_spent'].toString()) : null,
        upload_invoice_path: values['upload_invoice_path'],
        send_to_customer: values['send_to_customer'],
        register_no: values['register_no'],
        invoice_amount: values['invoice_amount'] != null ? double.tryParse(values['invoice_amount'].toString()) : null,
        payment_type: values['payment_type'],
        drive_link: values['drive_link'],
        billing_id: values['billing_id'],
        quotation_id: values['quotation_id'],
        payment_received: values['payment_received'] != null ? double.tryParse(values['payment_received'].toString()) : null,
        part_payment_amount: values['part_payment_amount'] != null ? double.tryParse(values['part_payment_amount'].toString()) : null,
        noc_obtained: values['noc_obtained'],
      );
      
      await Amplify.API.mutate(request: ModelMutations.update(updated).response);

      await NotificationService().notifyStakeholders(
        title: 'Work Updated',
        message: 'Work "${deal.name}" has been updated.',
        dealId: deal.id,
      );
    } catch (e) {
      debugPrint('Error updateDeal: $e');
    }
  }

  Future<void> moveDealToStage(dynamic dealId, String fromStage, String toStage) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');

    try {
      final req = ModelQueries.list(Deals.classType, where: Deals.ID.eq(dealId.toString()));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isEmpty == true) return;
      
      final c = res.data!.items.first!;
      final updated = c.copyWith(stage: toStage);
      await Amplify.API.mutate(request: ModelMutations.update(updated).response);

      final hist = DealStageHistory(
        deal_id: dealId.toString(),
        from_stage: fromStage,
        to_stage: toStage,
        changed_by: userId,
      );
      await Amplify.API.mutate(request: ModelMutations.create(hist).response);

      final dealName = c.name ?? 'Unknown Deal';
      final responsibleId = c.responsible_id;
      
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
    } catch (e) {
      debugPrint('Error moveDealToStage: $e');
    }
  }

  Future<void> handoverDeal(dynamic dealId, int fromUserId, int toUserId, String note) async {
    try {
      final handover = DealHandoverHistory(
        deal_id: dealId.toString(),
        from_user_id: fromUserId,
        to_user_id: toUserId,
        note: note,
      );
      await Amplify.API.mutate(request: ModelMutations.create(handover).response);

      // 2. Update primary responsible person
      String toUserName = 'Unknown';
      final uReq = ModelQueries.list(Users.classType, where: Users.ID.eq(toUserId));
      final uRes = await Amplify.API.query(request: uReq).response;
      if (uRes.data?.items.isNotEmpty == true) toUserName = uRes.data!.items.first?.name ?? 'Unknown';

      final dReq = ModelQueries.list(Deals.classType, where: Deals.ID.eq(dealId.toString()));
      final dRes = await Amplify.API.query(request: dReq).response;
      if (dRes.data?.items.isNotEmpty == true) {
        final c = dRes.data!.items.first!;
        final updated = c.copyWith(
          responsible_id: toUserId,
          responsible_name: toUserName,
        );
        await Amplify.API.mutate(request: ModelMutations.update(updated).response);

        // 3. Ensure new person is an assignee with Lead role
        final aReq1 = ModelQueries.list(DealAssignees.classType, where: DealAssignees.DEAL_ID.eq(dealId.toString()).and(DealAssignees.USER_ID.eq(fromUserId)));
        final aRes1 = await Amplify.API.query(request: aReq1).response;
        if (aRes1.data?.items.isNotEmpty == true) {
          final a1 = aRes1.data!.items.first!;
          await Amplify.API.mutate(request: ModelMutations.update(a1.copyWith(role: 'Collaborator').response));
        }

        final aReq2 = ModelQueries.list(DealAssignees.classType, where: DealAssignees.DEAL_ID.eq(dealId.toString()).and(DealAssignees.USER_ID.eq(toUserId)));
        final aRes2 = await Amplify.API.query(request: aReq2).response;
        if (aRes2.data?.items.isNotEmpty == true) {
          final a2 = aRes2.data!.items.first!;
          await Amplify.API.mutate(request: ModelMutations.update(a2.copyWith(role: 'Lead').response));
        } else {
          final newA = DealAssignees(deal_id: dealId.toString(), user_id: toUserId, role: 'Lead');
          await Amplify.API.mutate(request: ModelMutations.create(newA).response);
        }

        String fromUserName = 'Unknown';
        final fReq = ModelQueries.list(Users.classType, where: Users.ID.eq(fromUserId));
        final fRes = await Amplify.API.query(request: fReq).response;
        if (fRes.data?.items.isNotEmpty == true) fromUserName = fRes.data!.items.first?.name ?? 'Unknown';

        final dealName = c.name ?? 'Work';

        await NotificationService().notifyStakeholders(
          title: 'Work Handover',
          message: '$fromUserName handed over work "$dealName" to you ($toUserName). Note: $note',
          type: 'assignment',
          dealId: dealId,
        );
      }
    } catch (e) {
      debugPrint('Error handoverDeal: $e');
    }
  }

  Future<void> addAssignee(dynamic dealId, int userId, {String role = 'Collaborator'}) async {
    try {
      final aReq = ModelQueries.list(DealAssignees.classType, where: DealAssignees.DEAL_ID.eq(dealId.toString()).and(DealAssignees.USER_ID.eq(userId)));
      final aRes = await Amplify.API.query(request: aReq).response;
      if (aRes.data?.items.isNotEmpty == true) {
        final a = aRes.data!.items.first!;
        await Amplify.API.mutate(request: ModelMutations.update(a.copyWith(role: role).response));
      } else {
        final newA = DealAssignees(deal_id: dealId.toString(), user_id: userId, role: role);
        await Amplify.API.mutate(request: ModelMutations.create(newA).response);
      }

      String dealName = 'Work';
      final dReq = ModelQueries.list(Deals.classType, where: Deals.ID.eq(dealId.toString()));
      final dRes = await Amplify.API.query(request: dReq).response;
      if (dRes.data?.items.isNotEmpty == true) dealName = dRes.data!.items.first?.name ?? 'Work';

      await NotificationService().notifyStakeholders(
        dealId: dealId,
        title: 'Work Team Updated',
        message: 'Team for "$dealName" has been updated.',
        type: 'assignment',
      );
    } catch (e) {
      debugPrint('Error addAssignee: $e');
    }
  }

  Future<void> removeAssignee(dynamic dealId, int userId) async {
    try {
      final aReq = ModelQueries.list(DealAssignees.classType, where: DealAssignees.DEAL_ID.eq(dealId.toString()).and(DealAssignees.USER_ID.eq(userId)));
      final aRes = await Amplify.API.query(request: aReq).response;
      if (aRes.data?.items.isNotEmpty == true) {
        await Amplify.API.mutate(request: ModelMutations.delete(aRes.data!.items.first!).response);
      }
    } catch (e) {
      debugPrint('Error removeAssignee: $e');
    }
  }

  Future<List<old.DealAssignee>> getAssignees(dynamic dealId) async {
    try {
      final aReq = ModelQueries.list(DealAssignees.classType, where: DealAssignees.DEAL_ID.eq(dealId.toString()));
      final aRes = await Amplify.API.query(request: aReq).response;
      var items = aRes.data?.items.where((e) => e != null).cast<DealAssignees>().toList() ?? [];
      
      List<old.DealAssignee> result = [];
      for (var a in items) {
        String? uName;
        if (a.user_id != null) {
          final uReq = ModelQueries.list(Users.classType, where: Users.ID.eq(a.user_id));
          final uRes = await Amplify.API.query(request: uReq).response;
          if (uRes.data?.items.isNotEmpty == true) uName = uRes.data!.items.first?.name;
        }
        result.add(old.DealAssignee.fromMap({
          ...a.toJson(),
          'user_name': uName,
        }));
      }
      return result;
    } catch (e) {
      debugPrint('Error getAssignees: $e');
      return [];
    }
  }

  Future<void> addActivity(oldActivity.DealActivity activity) async {
    try {
      final values = activity.toMap();
      values.remove('id');
      values.remove('is_completed');
      values['deal_id'] = values['deal_id']?.toString();
      
      final newAct = DealActivities.fromJson(values);
      await Amplify.API.mutate(request: ModelMutations.create(newAct).response);
    } catch (e) {
      debugPrint('Error addActivity: $e');
    }
  }

  Future<List<oldActivity.DealActivity>> getActivities(dynamic dealId) async {
    try {
      final req = ModelQueries.list(DealActivities.classType, where: DealActivities.DEAL_ID.eq(dealId.toString()));
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<DealActivities>().toList() ?? [];
      items.sort((a, b) => (b.createdAt?.toString() ?? '').compareTo(a.createdAt?.toString() ?? ''));
      
      final users = await getAllUsers();
      final userMap = {for (var u in users) u['id'] as int: u['name'] as String};
      
      return items.map((a) {
        final j = a.toJson();
        final cId = a.created_by;
        if (cId != null) j['creator_name'] = userMap[cId] ?? 'Unknown';
        return oldActivity.DealActivity.fromMap(j);
      }).toList();
    } catch (e) {
      debugPrint('Error getActivities: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVerificationHistory() async {
    try {
      final req = ModelQueries.list(DealActivities.classType);
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null && (e.title == 'Work Verified' || e.title == 'Reverification Needed')).cast<DealActivities>().toList() ?? [];
      items.sort((a, b) => (b.createdAt?.toString() ?? '').compareTo(a.createdAt?.toString() ?? ''));

      final users = await getAllUsers();
      final userMap = {for (var u in users) u['id'] as int: u['name'] as String};
      
      List<Map<String, dynamic>> mapped = [];
      for (var a in items) {
        Map<String, dynamic>? dealData;
        if (a.deal_id != null) {
          final dReq = ModelQueries.list(Deals.classType, where: Deals.ID.eq(a.deal_id.toString()));
          final dRes = await Amplify.API.query(request: dReq).response;
          if (dRes.data?.items.isNotEmpty == true) {
            dealData = dRes.data!.items.first!.toJson();
          }
        }

        mapped.add({
          'id': a.id,
          'deal_id': a.deal_id,
          'deal_name': dealData?['name'] ?? 'Unknown Deal',
          'drive_link': dealData?['drive_link'],
          'sender': dealData?['responsible_name'] ?? 'Unknown',
          'reviewer': userMap[a.created_by] ?? 'Unknown',
          'status': a.title == 'Work Verified' ? 'Verified' : 'Rejected',
          'reason': a.title == 'Work Verified' ? '-' : a.description?.replaceAll('Returned for reverification. Remarks: ', '') ?? '',
          'created_at': a.createdAt?.toString(),
        });
      }
      return mapped;
    } catch (e) {
      debugPrint('Error getVerificationHistory: $e');
      return [];
    }
  }

  Future<void> toggleActivityCompletion(dynamic activityId, bool completed) async {
    try {
      final req = ModelQueries.list(DealActivities.classType, where: DealActivities.ID.eq(activityId.toString()));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final c = res.data!.items.first!;
        await Amplify.API.mutate(request: ModelMutations.update(c.copyWith(is_completed: completed).response));
      }
    } catch (e) {
      debugPrint('Error toggleActivityCompletion: $e');
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
      debugPrint('Error getAllUsers: $e');
      return [];
    }
  }
}
