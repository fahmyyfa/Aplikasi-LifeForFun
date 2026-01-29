/// Transaction type enum
enum TransactionType {
  income,
  expense;

  String get value {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
    }
  }
}

/// Transaction model for finance tracking
class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String category;
  final String? description;
  final DateTime transactionDate;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    this.description,
    required this.transactionDate,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'category': category,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'category': category,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    String? category,
    String? description,
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Transaction categories
class TransactionCategories {
  static const List<String> income = [
    'Gaji',
    'Freelance',
    'Investasi',
    'Bonus',
    'Hadiah',
    'Lainnya',
  ];

  static const List<String> expense = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Tagihan',
    'Wishlist',
    'Lainnya',
  ];
}
