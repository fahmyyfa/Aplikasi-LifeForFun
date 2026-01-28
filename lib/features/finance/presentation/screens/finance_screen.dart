import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../data/models/transaction_model.dart';

/// Finance tracker screen
class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Pemasukan',
                    amount: currencyFormat.format(0),
                    icon: Icons.arrow_downward,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Pengeluaran',
                    amount: currencyFormat.format(0),
                    icon: Icons.arrow_upward,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),

          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Semua',
                  isSelected: _selectedFilter == 'Semua',
                  onTap: () => setState(() => _selectedFilter = 'Semua'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pemasukan',
                  isSelected: _selectedFilter == 'Pemasukan',
                  onTap: () => setState(() => _selectedFilter = 'Pemasukan'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pengeluaran',
                  isSelected: _selectedFilter == 'Pengeluaran',
                  onTap: () => setState(() => _selectedFilter = 'Pengeluaran'),
                ),
                ...TransactionCategories.expense.map((cat) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _FilterChip(
                        label: cat,
                        isSelected: _selectedFilter == cat,
                        onTap: () => setState(() => _selectedFilter = cat),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transactions List
          Expanded(
            child: _TransactionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addTransaction),
        icon: const Icon(Icons.add),
        label: const Text('Transaksi'),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Periode', style: AppTypography.h4),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Hari Ini'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Minggu Ini'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Bulan Ini'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Pilih Tanggal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary card widget
class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: AppTypography.h4.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Transactions list placeholder
class _TransactionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Connect to finance provider
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai catat keuangan Anda',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
