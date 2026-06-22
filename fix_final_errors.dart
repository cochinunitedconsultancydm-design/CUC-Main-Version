import 'dart:io';

void main() {
  // 1. Fix uploaded_files_screen.dart
  final f1 = File('lib/screens/uploaded_files_screen.dart');
  var text1 = f1.readAsStringSync();
  if (!text1.contains('amplify_storage_s3')) {
    text1 = text1.replaceFirst(
      "import 'package:flutter_animate/flutter_animate.dart';",
      "import 'package:flutter_animate/flutter_animate.dart';\nimport 'package:amplify_storage_s3/amplify_storage_s3.dart';"
    );
    f1.writeAsStringSync(text1);
    print('Fixed uploaded_files_screen.dart');
  }

  // 2. Fix deal_service.dart
  final f2 = File('lib/services/deal_service.dart');
  var text2 = f2.readAsStringSync();
  text2 = text2.replaceAll(
    "DealAssignees(deal_id: dealId, user_id: userId, role: 'Lead')",
    "DealAssignees(deal_id: int.tryParse(dealId.toString()), user_id: userId, role: 'Lead')"
  );
  text2 = text2.replaceAll(
    "DealStageHistory(\n        deal_id: dealId.toString(),",
    "DealStageHistory(\n        deal_id: int.tryParse(dealId.toString()),"
  );
  text2 = text2.replaceAll(
    "DealHandoverHistory(\n        deal_id: dealId.toString(),",
    "DealHandoverHistory(\n        deal_id: int.tryParse(dealId.toString()),"
  );
  text2 = text2.replaceAll(
    "DealAssignees(deal_id: dealId.toString(), user_id: toUserId, role: 'Lead')",
    "DealAssignees(deal_id: int.tryParse(dealId.toString()), user_id: toUserId, role: 'Lead')"
  );
  text2 = text2.replaceAll(
    "DealAssignees(deal_id: dealId.toString(), user_id: userId, role: role)",
    "DealAssignees(deal_id: int.tryParse(dealId.toString()), user_id: userId, role: role)"
  );
  f2.writeAsStringSync(text2);
  print('Fixed deal_service.dart');

  // 3. Fix auth_service.dart
  final f3 = File('lib/services/auth_service.dart');
  var text3 = f3.readAsStringSync();
  text3 = text3.replaceAll(
    "userId: int.tryParse(res.id) ?? 0, \n            loginTime: DateTime.now().toIso8601String(), \n            isActive: true",
    "user_id: int.tryParse(res.id) ?? 0, \n            login_time: DateTime.now().toIso8601String(), \n            is_active: true"
  );
  text3 = text3.replaceAll(
    "logoutTime: DateTime.now().toIso8601String(), isActive: false",
    "logout_time: DateTime.now().toIso8601String(), is_active: false"
  );
  f3.writeAsStringSync(text3);
  print('Fixed auth_service.dart');

  // 4. Fix location_tracking_service.dart
  final f4 = File('lib/services/location_tracking_service.dart');
  var text4 = f4.readAsStringSync();
  text4 = text4.replaceAll(
    "AmplifyAPI(modelProvider: ModelProvider.instance)",
    "AmplifyAPI(options: APIPluginOptions(modelProvider: ModelProvider.instance))"
  );
  f4.writeAsStringSync(text4);
  print('Fixed location_tracking_service.dart');
}
