import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../features/calendar/data/models/fasting_schedule_model.dart';

/// Notification Service for scheduling fasting reminders
/// Triggers H-1 (one day before) at 20:00 local time
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Channel ID for fasting notifications
  static const String _fastingChannelId = 'fasting_reminders';
  static const String _fastingChannelName = 'Pengingat Puasa';
  static const String _fastingChannelDescription = 'Notifikasi pengingat puasa H-1 pukul 20:00';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    _isInitialized = true;
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _fastingChannelId,
      _fastingChannelName,
      description: _fastingChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to calendar screen or show fasting details
    // This can be handled via a callback or navigation service
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Calculate notification time: H-1 at 20:00 local time
  /// For fasting on Feb 2, notification triggers on Feb 1 at 20:00
  tz.TZDateTime _calculateNotificationTime(DateTime fastingDate) {
    final local = tz.local;
    
    // H-1 (one day before)
    final notificationDate = fastingDate.subtract(const Duration(days: 1));
    
    // Set time to 20:00 (8 PM)
    final scheduledTime = tz.TZDateTime(
      local,
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      20, // 20:00 hours
      0,  // 0 minutes
      0,  // 0 seconds
    );

    return scheduledTime;
  }

  /// Check if notification time is in the future
  bool _isNotificationTimeValid(tz.TZDateTime notificationTime) {
    final now = tz.TZDateTime.now(tz.local);
    return notificationTime.isAfter(now);
  }

  /// Schedule a single fasting notification
  Future<void> scheduleFastingNotification({
    required int notificationId,
    required DateTime fastingDate,
    required String fastingType,
  }) async {
    await initialize();

    final notificationTime = _calculateNotificationTime(fastingDate);

    // Skip if notification time has passed
    if (!_isNotificationTimeValid(notificationTime)) {
      return;
    }

    // Notification content
    const title = 'Persiapan Puasa Besok';
    final body = 'Besok adalah jadwal puasa $fastingType. '
        'Jangan lupa niat dan sahur malam ini ya!';

    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      _fastingChannelId,
      _fastingChannelName,
      channelDescription: _fastingChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        'Besok adalah jadwal puasa. Jangan lupa niat dan sahur malam ini ya!',
        contentTitle: title,
        summaryText: 'Pengingat Puasa',
      ),
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      notificationTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Reschedule all fasting notifications from database
  /// Call this when app opens or when fasting schedule changes
  Future<void> rescheduleAllNotifications(SupabaseClient client, String userId) async {
    await initialize();

    // Cancel existing notifications first
    await cancelAllNotifications();

    // Fetch upcoming fasting schedules from Supabase
    final now = DateTime.now();
    final response = await client
        .from('fasting_schedules')
        .select()
        .eq('user_id', userId)
        .gte('fasting_date', now.toIso8601String().split('T')[0])
        .order('fasting_date', ascending: true);

    if ((response as List).isEmpty) {
      return;
    }

    // Schedule notifications for each upcoming fasting
    for (int i = 0; i < response.length; i++) {
      final schedule = FastingScheduleModel.fromJson(response[i]);
      
      // Skip completed fasting
      if (schedule.isCompleted) continue;

      await scheduleFastingNotification(
        notificationId: schedule.id.hashCode.abs() % 100000, // Unique ID from UUID
        fastingDate: schedule.fastingDate,
        fastingType: schedule.fastingType.displayName,
      );
    }
  }

  /// Show immediate test notification
  Future<void> showTestNotification() async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      _fastingChannelId,
      _fastingChannelName,
      channelDescription: _fastingChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Test Notifikasi',
      'Notifikasi pengingat puasa berfungsi dengan baik!',
      notificationDetails,
    );
  }
}
