import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ModelProvider.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
import 'supabase_backup_service.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  Future<void> logAction({
    required String action,
    required String targetType,
    String? targetId,
    String? details,
    int? userId,
    String? userName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? effectiveUserId = userId ?? prefs.getInt('current_user_id');
      final effectiveUserName = (userName != null && userName.isNotEmpty && userName != 'Unknown')
          ? userName
          : prefs.getString('user_name');
      
      if (effectiveUserId == null || effectiveUserId == 0) {
        final idStr = prefs.getString('current_user_id_str');
        if (idStr != null) {
          effectiveUserId = int.tryParse(idStr);
        }
      }
      
      String finalDetails = details ?? '';
      if (effectiveUserName != null && effectiveUserName.isNotEmpty && effectiveUserName != 'Unknown') {
        if (!finalDetails.contains('[User:')) {
          finalDetails = finalDetails.isEmpty ? '[User: $effectiveUserName]' : '$finalDetails [User: $effectiveUserName]';
        }
      } else if (finalDetails.isEmpty) {
        finalDetails = 'Action logged';
      }
      
      final logEntry = ActivityLogs(
        user_id: effectiveUserId ?? 0,
        action: action,
        target_type: targetType,
        target_id: targetId ?? effectiveUserName,
        details: finalDetails,
        created_at: DateTime.now().toIso8601String(),
      );
      try {
        await BackupAwareApi().create(logEntry);
      } catch (e) {
        // AppSync requires active authentication; during logout or pre-auth, fall back to direct Supabase backup
        try {
          await SupabaseBackupService().backupRecord('ActivityLogs', logEntry.toJson());
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Logging error: $e');
    }
  }
}
