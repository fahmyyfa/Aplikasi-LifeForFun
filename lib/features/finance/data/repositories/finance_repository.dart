import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction_model.dart';

/// Repository for financial transaction operations
class FinanceRepository {
  final SupabaseClient _client;

  FinanceRepository(this._client);

  /// Get all transactions for a user
  Future<List<TransactionModel>> getTransactions(String userId) async {
    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('transaction_date', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  /// Get transactions for current month
  Future<List<TransactionModel>> getCurrentMonthTransactions(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .gte('transaction_date', startOfMonth.toIso8601String().split('T')[0])
        .lte('transaction_date', endOfMonth.toIso8601String().split('T')[0])
        .order('transaction_date', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  /// Get recent transactions (last 5)
  Future<List<TransactionModel>> getRecentTransactions(String userId, {int limit = 5}) async {
    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('transaction_date', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  /// Add a new transaction
  Future<TransactionModel> addTransaction({
    required String userId,
    required TransactionType type,
    required String category,
    required double amount,
    required DateTime transactionDate,
    String? description,
  }) async {
    final response = await _client
        .from('transactions')
        .insert({
          'user_id': userId,
          'type': type.value,
          'category': category,
          'amount': amount,
          'transaction_date': transactionDate.toIso8601String().split('T')[0],
          'description': description,
        })
        .select()
        .single();

    return TransactionModel.fromJson(response);
  }

  /// Update a transaction
  Future<TransactionModel> updateTransaction({
    required String transactionId,
    TransactionType? type,
    String? category,
    double? amount,
    DateTime? transactionDate,
    String? description,
  }) async {
    final updates = <String, dynamic>{};
    if (type != null) updates['type'] = type.value;
    if (category != null) updates['category'] = category;
    if (amount != null) updates['amount'] = amount;
    if (transactionDate != null) {
      updates['transaction_date'] = transactionDate.toIso8601String().split('T')[0];
    }
    if (description != null) updates['description'] = description;

    final response = await _client
        .from('transactions')
        .update(updates)
        .eq('id', transactionId)
        .select()
        .single();

    return TransactionModel.fromJson(response);
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    await _client
        .from('transactions')
        .delete()
        .eq('id', transactionId);
  }

  /// Calculate balance summary for current month
  Future<BalanceSummary> getBalanceSummary(String userId) async {
    final transactions = await getCurrentMonthTransactions(userId);

    double totalIncome = 0;
    double totalExpense = 0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    return BalanceSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
    );
  }
}

/// Balance summary model
class BalanceSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const BalanceSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });
}
