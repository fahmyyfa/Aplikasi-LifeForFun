import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_provider.dart';
import '../data/models/wishlist_item_model.dart';
import '../data/repositories/wishlist_repository.dart';

/// Provider for WishlistRepository
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return WishlistRepository(client);
});

/// State for wishlist data
class WishlistState {
  final List<WishlistItemModel> items;
  final double totalValue;
  final bool isLoading;
  final String? error;

  const WishlistState({
    this.items = const [],
    this.totalValue = 0,
    this.isLoading = false,
    this.error,
  });

  /// Get unpurchased items count
  int get unpurchasedCount => items.where((item) => !item.isPurchased).length;

  /// Get purchased items count
  int get purchasedCount => items.where((item) => item.isPurchased).length;

  WishlistState copyWith({
    List<WishlistItemModel>? items,
    double? totalValue,
    bool? isLoading,
    String? error,
  }) {
    return WishlistState(
      items: items ?? this.items,
      totalValue: totalValue ?? this.totalValue,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for wishlist operations
class WishlistNotifier extends AsyncNotifier<WishlistState> {
  late WishlistRepository _repository;

  @override
  Future<WishlistState> build() async {
    _repository = ref.read(wishlistRepositoryProvider);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      return const WishlistState();
    }

    return _loadWishlistData(user.id);
  }

  Future<WishlistState> _loadWishlistData(String userId) async {
    try {
      final items = await _repository.getWishlistItems(userId);
      final totalValue = await _repository.getTotalWishlistValue(userId);

      return WishlistState(
        items: items,
        totalValue: totalValue,
      );
    } catch (e) {
      return WishlistState(error: e.toString());
    }
  }

  /// Add a new wishlist item
  Future<void> addWishlistItem({
    required String name,
    double? price,
    String? notes,
    String? imageUrl,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();

    try {
      await _repository.addWishlistItem(
        userId: user.id,
        name: name,
        price: price,
        notes: notes,
        imageUrl: imageUrl,
      );

      // Reload data
      state = AsyncData(await _loadWishlistData(user.id));
    } catch (e) {
      state = AsyncData(WishlistState(error: e.toString()));
    }
  }

  /// Mark item as purchased
  Future<void> markAsPurchased(String itemId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await _repository.markAsPurchased(itemId);
      state = AsyncData(await _loadWishlistData(user.id));
    } catch (e) {
      // Handle error
    }
  }

  /// Delete wishlist item
  Future<void> deleteWishlistItem(String itemId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await _repository.deleteWishlistItem(itemId);
      state = AsyncData(await _loadWishlistData(user.id));
    } catch (e) {
      // Handle error
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    state = AsyncData(await _loadWishlistData(user.id));
  }
}

/// Provider for WishlistNotifier
final wishlistNotifierProvider = AsyncNotifierProvider<WishlistNotifier, WishlistState>(() {
  return WishlistNotifier();
});

/// Provider for wishlist count (for dashboard)
final wishlistCountProvider = Provider<int>((ref) {
  final wishlistState = ref.watch(wishlistNotifierProvider);
  return wishlistState.valueOrNull?.unpurchasedCount ?? 0;
});
