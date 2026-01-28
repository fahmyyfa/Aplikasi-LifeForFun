import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/providers/notification_provider.dart';

/// Settings screen for notification preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationEnabled = ref.watch(notificationEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notification Settings Section
          Text('Notifikasi', style: AppTypography.h4),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Fasting Reminder Toggle
                SwitchListTile(
                  title: const Text('Pengingat Puasa'),
                  subtitle: Text(
                    'Notifikasi H-1 pukul 20:00',
                    style: AppTypography.bodySmall,
                  ),
                  value: notificationEnabled,
                  onChanged: (value) {
                    ref.read(notificationNotifierProvider.notifier).toggleNotifications(value);
                  },
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Test Notification
                ListTile(
                  title: const Text('Test Notifikasi'),
                  subtitle: Text(
                    'Kirim notifikasi percobaan',
                    style: AppTypography.bodySmall,
                  ),
                  trailing: const Icon(Icons.send_outlined),
                  onTap: () async {
                    await ref.read(notificationNotifierProvider.notifier).sendTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifikasi test dikirim')),
                      );
                    }
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.science_outlined,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          Text('Tentang', style: AppTypography.h4),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Versi Aplikasi'),
                  subtitle: Text('1.0.0', style: AppTypography.bodySmall),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Developer'),
                  subtitle: Text('Fahmi Alfaqih', style: AppTypography.bodySmall),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
