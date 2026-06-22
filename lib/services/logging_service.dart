import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';

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
        );
        await Amplify.API.mutate(request: ModelMutations.create(logEntry)).response;
      }
    } catch (e) {
      debugPrint('Logging error: $e');
    }
  }
}
