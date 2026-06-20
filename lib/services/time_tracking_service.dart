import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

class TimeTrackingService with WindowListener {
  static final TimeTrackingService _instance = TimeTrackingService._internal();
  static TimeTrackingService get instance => _instance;

  TimeTrackingService._internal();

  Timer? _tickTimer;
  Timer? _syncTimer;
  DateTime? _lastActivityTime;
  
  int _activeSeconds = 0;
  int _idleSeconds = 0;
  String _status = 'Active'; // Active, Idle, Minimized, Offline
  
  bool _isTracking = false;
  int? _currentSessionId;

  void startTracking(int sessionId) {
    if (_isTracking) stopTracking();
    debugPrint('Started TimeTracking for session $sessionId');
    _isTracking = true;
    _currentSessionId = sessionId;
    _activeSeconds = 0;
    _idleSeconds = 0;
    _status = 'Active';
    _lastActivityTime = DateTime.now();

    windowManager.addListener(this);

    // Tick every second to accumulate time
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });

    // Sync to DB every minute
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      syncToDatabase();
    });
  }

  void stopTracking() {
    if (!_isTracking) return;
    debugPrint('Stopping TimeTracking for session $_currentSessionId');
    _isTracking = false;
    _tickTimer?.cancel();
    _syncTimer?.cancel();
    windowManager.removeListener(this);
    
    if (_currentSessionId != null) {
      _status = 'Offline';
      syncToDatabase(isLogout: true);
    }
    _currentSessionId = null;
  }

  void registerActivity() {
    if (!_isTracking || _status == 'Minimized') return;
    _lastActivityTime = DateTime.now();
    if (_status == 'Idle') {
      _status = 'Active';
      syncToDatabase(); // Immediate sync on state change
    }
  }

  void _tick() {
    if (!_isTracking) return;

    if (_status == 'Minimized') {
      _idleSeconds++;
    } else {
      // Check for Idle (e.g., 3 minutes of no activity)
      if (_lastActivityTime != null && DateTime.now().difference(_lastActivityTime!).inMinutes >= 3) {
        if (_status == 'Active') {
          _status = 'Idle';
          syncToDatabase(); // Immediate sync on state change
        }
        _idleSeconds++;
      } else {
        _activeSeconds++;
      }
    }
  }

  Future<void> syncToDatabase({bool isLogout = false}) async {
    if (_currentSessionId == null) return;

    final updateData = {
      'status': _status,
      'active_seconds': _activeSeconds,
      'idle_seconds': _idleSeconds,
    };

    if (isLogout) {
      updateData['logout_time'] = DateTime.now().toIso8601String();
      updateData['is_active'] = false;
    }

    try {
      await Supabase.instance.client
          .from('user_sessions')
          .update(updateData)
          .eq('id', _currentSessionId!);
    } catch (e) {
      debugPrint('Error syncing time tracker: $e');
    }
  }

  @override
  void onWindowMinimize() {
    if (!_isTracking) return;
    _status = 'Minimized';
    syncToDatabase();
  }

  @override
  void onWindowRestore() {
    if (!_isTracking) return;
    _status = 'Active';
    _lastActivityTime = DateTime.now();
    syncToDatabase();
  }
}
