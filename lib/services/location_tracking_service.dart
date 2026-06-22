import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart';
import '../amplify_outputs.dart';

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

  // Initialize Amplify in background isolate
  try {
    if (!Amplify.isConfigured) {
      await Amplify.addPlugins([
        AmplifyAPI(modelProvider: ModelProvider.instance),
      ]);
      await Amplify.configure(amplifyConfig);
    }
  } catch (e) {
    debugPrint('Amplify config error in background: $e');
  }

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
        final dateStr = DateTime.now().toIso8601String().split('T')[0];
        
        final req = ModelQueries.list(
          StaffAttendance.classType, 
          where: StaffAttendance.USER_ID.eq(finalUserId).and(StaffAttendance.ATTENDANCE_DATE.eq(dateStr))
        );
        final res = await Amplify.API.query(request: req).response;
        
        if (res.data?.items.isNotEmpty == true) {
          final item = res.data!.items.firstWhere((element) => element?.check_out_time == null, orElse: () => null);
          if (item != null) {
            final updated = item.copyWith(check_out_time: DateTime.now().toUtc().toIso8601String());
            await Amplify.API.mutate(request: ModelMutations.update(updated));
            debugPrint('Auto checked out user $finalUserId due to app kill.');
          }
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
          final uReq = ModelQueries.list(StaffLocations.classType, where: StaffLocations.USER_ID.eq(finalUserId));
          final uRes = await Amplify.API.query(request: uReq).response;
          if (uRes.data?.items.isNotEmpty == true) {
            final c = uRes.data!.items.first!;
            final updated = c.copyWith(
              latitude: position.latitude,
              longitude: position.longitude,
              updated_at: nowIso
            );
            await Amplify.API.mutate(request: ModelMutations.update(updated));
          } else {
            final newLoc = StaffLocations(
              user_id: finalUserId,
              latitude: position.latitude,
              longitude: position.longitude,
              updated_at: nowIso
            );
            await Amplify.API.mutate(request: ModelMutations.create(newLoc));
          }

          // 2. Append to route history
          final newHist = LocationHistory(
            user_id: finalUserId,
            latitude: position.latitude,
            longitude: position.longitude,
            recorded_at: nowIso
          );
          await Amplify.API.mutate(request: ModelMutations.create(newHist));
          
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
