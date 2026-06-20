import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  final _client = Supabase.instance.client;

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
        await _client.from('activity_logs').insert({
          'user_id': userId,
          'action': action,
          'target_type': targetType,
          'target_id': targetId,
          'details': details,
        });
      }
    } catch (e) {
      print('Logging error: $e');
    }
  }
}
