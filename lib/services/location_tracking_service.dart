import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationTrackingService {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> initialize() async {
    // Only run on mobile platforms
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'location_tracking', // id
        'Location Tracking', // title
        description: 'Tracking location in background', // description
        importance: Importance.high,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_tracking',
        initialNotificationTitle: 'Location Tracking',
        initialNotificationContent: 'Tracking location in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> startTracking() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    // Check permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    }

    await _service.startService();
  }

  Future<void> stopTracking() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    final isRunning = await _service.isRunning();
    if (isRunning) {
      _service.invoke("stopService");
    }
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Initialize Supabase in background isolate
  await Supabase.initialize(
    url: 'https://bzxtgiqjgfojblezdubd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo',
  );

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Auto check out on app kill
  service.on('app_killed').listen((event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('current_user_id');
      final String? userIdStr = prefs.getString('current_user_id_str');
      final finalUserId = userId ?? (userIdStr != null ? int.tryParse(userIdStr) : null);

      if (finalUserId != null) {
        // Find active check-in and check out
        final res = await Supabase.instance.client
            .from('staff_attendance')
            .select()
            .eq('user_id', finalUserId)
            .eq('attendance_date', DateTime.now().toIso8601String().split('T')[0])
            .isFilter('check_out_time', null)
            .maybeSingle();

        if (res != null) {
          await Supabase.instance.client.from('staff_attendance').update({
            'check_out_time': DateTime.now().toUtc().toIso8601String(),
          }).eq('id', res['id']);
          debugPrint('Auto checked out user $finalUserId due to app kill.');
        }
      }
    } catch (e) {
      debugPrint('Auto checkout error: $e');
    }
    service.stopSelf();
  });

  // Track location every minute
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (!(await service.isForegroundService())) {
        return;
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('current_user_id');
      final String? userIdStr = prefs.getString('current_user_id_str');

      final finalUserId = userId ?? (userIdStr != null ? int.tryParse(userIdStr) : null);

      if (finalUserId != null) {
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 15),
            ),
          );
        } catch (e) {
          debugPrint('Timeout or error getting current position: $e');
          position = await Geolocator.getLastKnownPosition();
        }

        if (position != null) {
          final nowIso = DateTime.now().toUtc().toIso8601String();

        // 1. Update live location
        await Supabase.instance.client.from('staff_locations').upsert({
          'user_id': finalUserId,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updated_at': nowIso,
        });

        // 2. Append to route history
        await Supabase.instance.client.from('location_history').insert({
          'user_id': finalUserId,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'recorded_at': nowIso,
        });
        
        debugPrint('Background location updated and recorded for user $finalUserId: ${position.latitude}, ${position.longitude}');
        } else {
          debugPrint('Failed to get background location for user $finalUserId');
        }
      }
    } catch (e) {
      debugPrint('Error tracking background location: $e');
    }
  });
}
