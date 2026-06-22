import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme.dart';
import 'package:flutter/foundation.dart';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'amplify_outputs.dart';
import 'models/ModelProvider.dart';
import 'package:window_manager/window_manager.dart';

import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/manager_dashboard_screen.dart';
import 'screens/delivery_dashboard_screen.dart';
import 'services/time_tracking_service.dart';
import 'services/location_tracking_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || 
                  defaultTargetPlatform == TargetPlatform.linux || 
                  defaultTargetPlatform == TargetPlatform.macOS)) {
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1366, 768),
      minimumSize: Size(1200, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });
  }

  try {
    final apiPlugin = AmplifyAPI(options: APIPluginOptions(modelProvider: ModelProvider.instance));
    final authPlugin = AmplifyAuthCognito();
    final storagePlugin = AmplifyStorageS3();
    
    await Amplify.addPlugins([apiPlugin, authPlugin, storagePlugin]);
    await Amplify.configure(amplifyConfig);
    debugPrint('✅ Amplify configured successfully');
  } on AmplifyAlreadyConfiguredException {
    // This is OK during development hot restarts - plugins are already initialized
    debugPrint('⚠️ Amplify already configured (hot restart detected) - continuing');
  } catch (e, stacktrace) {
    debugPrint('====================================');
    debugPrint('❌ Could not configure Amplify: $e');
    debugPrint('Stacktrace: $stacktrace');
    debugPrint('====================================');
  }

  // Initialize local notifications for mobile
  await NotificationService().initLocalNotifications();

  // Wire up desktop notification toast support
  NotificationService.scaffoldMessengerKey = _scaffoldMessengerKey;

  // Initialize location tracking service
  await LocationTrackingService().initialize();

  // Force login on every startup to track time accurately
  // This also gracefully logs out any session that was previously killed unexpectedly
  await AuthService().logout();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || 
                    defaultTargetPlatform == TargetPlatform.linux || 
                    defaultTargetPlatform == TargetPlatform.macOS)) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App is being swiped away / killed
      try {
        FlutterBackgroundService().invoke('app_killed');
      } catch (e) {
        debugPrint('Failed to send app_killed: $e');
      }
    }
  }

  @override
  void onWindowClose() async {
    // Flush time tracker and logout before exiting
    TimeTrackingService.instance.stopTracking();
    await AuthService().logout();
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => TimeTrackingService.instance.registerActivity(),
      onPointerMove: (_) => TimeTrackingService.instance.registerActivity(),
      onPointerHover: (_) => TimeTrackingService.instance.registerActivity(),
      onPointerSignal: (_) => TimeTrackingService.instance.registerActivity(),
      child: MaterialApp(
        title: 'Cochin United',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        theme: AppTheme.lightTheme(),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return FutureBuilder<bool>(
      future: auth.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }
        
        if (snapshot.data == true) {
          return FutureBuilder<String?>(
            future: auth.getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                );
              }
              
              final role = roleSnapshot.data;
              if (role == 'admin') return const AdminDashboardScreen();
              if (role == 'manager') return const ManagerDashboardScreen();
              if (role == 'delivery') return const DeliveryDashboardScreen();
              // Default to DashboardScreen for accountant and others
              return const DashboardScreen();
            },
          );
        }
        
        return const LoginScreen();
      },
    );
  }
}
