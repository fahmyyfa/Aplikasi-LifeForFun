import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('Belum ada wishlist', style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            )),
            const SizedBox(height: 8),
            Text('Mulai catat barang impian Anda', style: AppTypography.bodySmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addWishlist),
        icon: const Icon(Icons.add),
        label: const Text('Wishlist'),
      ),
    );
  }
}
