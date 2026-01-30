import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wishlist_item_model.dart';

/// Repository for wishlist operations
class WishlistRepository {
  final SupabaseClient _client;

  WishlistRepository(this._client);

  /// Get all wishlist items for a user
  Future<List<WishlistItemModel>> getWishlistItems(String userId) async {
    final response = await _client
        .from('wishlist')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => WishlistItemModel.fromJson(json))
        .toList();
  }

  /// Get unpurchased wishlist items
  Future<List<WishlistItemModel>> getUnpurchasedItems(String userId) async {
    final response = await _client
        .from('wishlist')
        .select()
        .eq('user_id', userId)
        .eq('is_purchased', false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => WishlistItemModel.fromJson(json))
        .toList();
  }

  /// Add a new wishlist item
  Future<WishlistItemModel> addWishlistItem({
    required String userId,
    required String name,
    double? price,
    String? notes,
    String? imageUrl,
  }) async {
    debugPrint('[WishlistRepository] Adding wishlist item...');
    debugPrint('[WishlistRepository] user_id: $userId');
    debugPrint('[WishlistRepository] name: $name, price: $price');
    
    try {
      final insertData = {
        'user_id': userId,
        'item_name': name,
        'price': price,
        'notes': notes,
        'image_url': imageUrl,
      };
      
      debugPrint('[WishlistRepository] Insert data: $insertData');
      
      final response = await _client
          .from('wishlist')
          .insert(insertData)
          .select()
          .single();

      debugPrint('[WishlistRepository] Success! Response: $response');
      return WishlistItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('[WishlistRepository] PostgrestException: ${e.message}');
      debugPrint('[WishlistRepository] Code: ${e.code}, Details: ${e.details}');
      debugPrint('[WishlistRepository] Hint: ${e.hint}');
      
      // Re-throw with more descriptive message
      if (e.code == '42501') {
        throw Exception('Izin ditolak (RLS Policy). Pastikan Anda sudah login dan memiliki akses.');
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      debugPrint('[WishlistRepository] Unexpected error: $e');
      rethrow;
    }
  }

  /// Update wishlist item
  Future<WishlistItemModel> updateWishlistItem({
    required String itemId,
    String? name,
    double? price,
    String? notes,
    String? imageUrl,
    bool? isPurchased,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['item_name'] = name;
    if (price != null) updates['price'] = price;
    if (notes != null) updates['notes'] = notes;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (isPurchased != null) {
      updates['is_purchased'] = isPurchased;
      if (isPurchased) {
        updates['purchased_at'] = DateTime.now().toIso8601String();
      }
    }

    final response = await _client
        .from('wishlist')
        .update(updates)
        .eq('id', itemId)
        .select()
        .single();

    return WishlistItemModel.fromJson(response);
  }

  /// Mark item as purchased
  Future<WishlistItemModel> markAsPurchased(String itemId) async {
    return updateWishlistItem(itemId: itemId, isPurchased: true);
  }

  /// Delete wishlist item
  Future<void> deleteWishlistItem(String itemId) async {
    await _client
        .from('wishlist')
        .delete()
        .eq('id', itemId);
  }

  /// Get total wishlist value (unpurchased items only)
  Future<double> getTotalWishlistValue(String userId) async {
    final items = await getUnpurchasedItems(userId);
    double total = 0;
    for (final item in items) {
      total += item.price ?? 0;
    }
    return total;
  }
}

