import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../auth/providers/auth_provider.dart';

/// Dashboard/Home screen showing summary of all features
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final today = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.userMetadata?['full_name'] ?? 'Fahmi Alfaqih',
                        style: AppTypography.h3,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showLogoutDialog(context, ref),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(today),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 24),

              // Balance Card
              _BalanceCard(),
              const SizedBox(height: 20),

              // Quick Actions
              Text('Status Hari Ini', style: AppTypography.h4),
              const SizedBox(height: 12),

              // Dzikir Status Cards
              Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      title: 'Dzikir Pagi',
                      icon: Icons.wb_sunny_outlined,
                      isCompleted: false, // TODO: Connect to provider
                      color: AppColors.secondary,
                      onTap: () => context.go(AppRoutes.spiritual),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusCard(
                      title: 'Dzikir Petang',
                      icon: Icons.nightlight_outlined,
                      isCompleted: false, // TODO: Connect to provider
                      color: AppColors.accent,
                      onTap: () => context.go(AppRoutes.spiritual),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fasting Schedule Card
              _FastingScheduleCard(),
              const SizedBox(height: 20),

              // Quick Menu
              Text('Menu Cepat', style: AppTypography.h4),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickMenuItem(
                    icon: Icons.add_circle_outline,
                    label: 'Tambah\nPemasukan',
                    color: AppColors.success,
                    onTap: () => context.go(AppRoutes.addTransaction),
                  ),
                  _QuickMenuItem(
                    icon: Icons.remove_circle_outline,
                    label: 'Tambah\nPengeluaran',
                    color: AppColors.error,
                    onTap: () => context.go(AppRoutes.addTransaction),
                  ),
                  _QuickMenuItem(
                    icon: Icons.favorite_outline,
                    label: 'Wishlist\nBaru',
                    color: AppColors.secondary,
                    onTap: () => context.go(AppRoutes.addWishlist),
                  ),
                  _QuickMenuItem(
                    icon: Icons.event_outlined,
                    label: 'Jadwal\nBaru',
                    color: AppColors.accent,
                    onTap: () => context.go(AppRoutes.calendar),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transaksi Terakhir', style: AppTypography.h4),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.finance),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _RecentTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi 👋';
    if (hour < 15) return 'Selamat Siang 👋';
    if (hour < 18) return 'Selamat Sore 👋';
    return 'Selamat Malam 👋';
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

/// Balance summary card
class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Saldo',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Bulan Ini',
                      style: AppTypography.labelSmall.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(0), // TODO: Connect to provider
            style: AppTypography.currency.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _BalanceItem(
                  label: 'Pemasukan',
                  amount: currencyFormat.format(0),
                  icon: Icons.arrow_downward,
                  iconColor: AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _BalanceItem(
                  label: 'Pengeluaran',
                  amount: currencyFormat.format(0),
                  icon: Icons.arrow_upward,
                  iconColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Balance item (income/expense)
class _BalanceItem extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color iconColor;

  const _BalanceItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            Text(
              amount,
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}

/// Status card for dzikir tracking
class _StatusCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isCompleted;
  final Color color;
  final VoidCallback onTap;

  const _StatusCard({
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        size: 14,
                        color: isCompleted ? AppColors.success : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted ? 'Selesai' : 'Belum',
                        style: AppTypography.labelSmall.copyWith(
                          color: isCompleted ? AppColors.success : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fasting schedule card
class _FastingScheduleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jadwal Puasa Terdekat', style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text(
                  'Tidak ada jadwal', // TODO: Connect to provider
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

/// Quick menu item
class _QuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Recent transactions list placeholder
class _RecentTransactionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Connect to finance provider
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada transaksi',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
