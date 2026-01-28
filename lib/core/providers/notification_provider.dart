import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';
import 'supabase_provider.dart';

/// Provider for NotificationService singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for notification enabled/disabled state
/// User can toggle this in Settings
final notificationEnabledProvider = StateProvider<bool>((ref) {
  return true; // Default: notifications enabled
});

/// Provider to reschedule all notifications
/// Call this when app starts or when fasting schedule changes
final rescheduleNotificationsProvider = FutureProvider.autoDispose<void>((ref) async {
  final isEnabled = ref.watch(notificationEnabledProvider);
  if (!isEnabled) return;

  final notificationService = ref.read(notificationServiceProvider);
  final client = ref.read(supabaseClientProvider);
  final user = ref.read(currentUserProvider);

  if (user == null) return;

  await notificationService.rescheduleAllNotifications(client, user.id);
});

/// Provider to request notification permissions
final requestNotificationPermissionProvider = FutureProvider.autoDispose<bool>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  return await notificationService.requestPermissions();
});

/// Notifier for managing notification state
class NotificationNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    return ref.read(notificationEnabledProvider);
  }

  /// Toggle notifications on/off
  Future<void> toggleNotifications(bool enabled) async {
    ref.read(notificationEnabledProvider.notifier).state = enabled;

    final notificationService = ref.read(notificationServiceProvider);

    if (enabled) {
      // Reschedule all notifications
      final client = ref.read(supabaseClientProvider);
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await notificationService.rescheduleAllNotifications(client, user.id);
      }
    } else {
      // Cancel all notifications
      await notificationService.cancelAllNotifications();
    }

    state = AsyncData(enabled);
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.showTestNotification();
  }

  /// Manually reschedule notifications
  Future<void> reschedule() async {
    final isEnabled = ref.read(notificationEnabledProvider);
    if (!isEnabled) return;

    final notificationService = ref.read(notificationServiceProvider);
    final client = ref.read(supabaseClientProvider);
    final user = ref.read(currentUserProvider);

    if (user != null) {
      await notificationService.rescheduleAllNotifications(client, user.id);
    }
  }
}

/// Provider for NotificationNotifier
final notificationNotifierProvider = AsyncNotifierProvider<NotificationNotifier, bool>(() {
  return NotificationNotifier();
});
