import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/constants/api_constants.dart';
import 'core/services/notification_service.dart';

/// Main entry point for Fahmi Alfaqih Personal Productivity App
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  // Initialize Supabase
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  // Initialize Notification Service
  await NotificationService().initialize();

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: FahmiAlfaqihApp(),
    ),
  );
}

/// Root application widget
class FahmiAlfaqihApp extends ConsumerStatefulWidget {
  const FahmiAlfaqihApp({super.key});

  @override
  ConsumerState<FahmiAlfaqihApp> createState() => _FahmiAlfaqihAppState();
}

class _FahmiAlfaqihAppState extends ConsumerState<FahmiAlfaqihApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reschedule notifications when app comes to foreground
      _rescheduleNotifications();
    }
  }

  Future<void> _initializeNotifications() async {
    // Request permissions
    await NotificationService().requestPermissions();
    // Schedule notifications
    _rescheduleNotifications();
  }

  void _rescheduleNotifications() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      NotificationService().rescheduleAllNotifications(
        Supabase.instance.client,
        user.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Fahmi Alfaqih App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
