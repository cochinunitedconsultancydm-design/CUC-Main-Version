import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ModelProvider.dart';
import 'package:cuc_app/services/backup_aware_api.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  Future<void> logAction({
    required String action,
    required String targetType,
    String? targetId,
    String? details,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('current_user_id');
      final userName = prefs.getString('user_name');
      
      if (userId == null || userId == 0) {
        final idStr = prefs.getString('current_user_id_str');
        if (idStr != null) {
          userId = int.tryParse(idStr);
        }
      }
      
      String finalDetails = details ?? '';
      if (userName != null && userName.isNotEmpty) {
        finalDetails = finalDetails.isEmpty ? '[User: $userName]' : '$finalDetails [User: $userName]';
      } else if (finalDetails.isEmpty) {
        finalDetails = 'Action logged';
      }
      
      final logEntry = ActivityLogs(
        user_id: userId ?? 0,
        action: action,
        target_type: targetType,
        target_id: targetId,
        details: finalDetails,
        created_at: DateTime.now().toIso8601String(),
      );
      await BackupAwareApi().create(logEntry);
    } catch (e) {
      debugPrint('Logging error: $e');
    }
  }
}
