/// Wishlist item model
class WishlistItemModel {
  final String id;
  final String userId;
  final String itemName;
  final double? price;
  final String? imageUrl;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final String? notes;
  final DateTime createdAt;

  const WishlistItemModel({
    required this.id,
    required this.userId,
    required this.itemName,
    this.price,
    this.imageUrl,
    this.isPurchased = false,
    this.purchasedAt,
    this.notes,
    required this.createdAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemName: json['item_name'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      imageUrl: json['image_url'] as String?,
      isPurchased: json['is_purchased'] as bool? ?? false,
      purchasedAt: json['purchased_at'] != null
          ? DateTime.parse(json['purchased_at'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_name': itemName,
      'price': price,
      'image_url': imageUrl,
      'is_purchased': isPurchased,
      'purchased_at': purchasedAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'item_name': itemName,
      'price': price,
      'image_url': imageUrl,
      'notes': notes,
    };
  }

  WishlistItemModel copyWith({
    String? id,
    String? userId,
    String? itemName,
    double? price,
    String? imageUrl,
    bool? isPurchased,
    DateTime? purchasedAt,
    String? notes,
    DateTime? createdAt,
  }) {
    return WishlistItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
