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
      final userId = prefs.getInt('current_user_id');
      
      if (userId != null) {
        final logEntry = ActivityLogs(
          user_id: userId,
          action: action,
          target_type: targetType,
          target_id: targetId,
          details: details,
          created_at: DateTime.now().toIso8601String(),
        );
        await BackupAwareApi().create(logEntry);
      }
    } catch (e) {
      debugPrint('Logging error: $e');
    }
  }
}
