import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_provider.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/finance_repository.dart';

/// Provider for FinanceRepository
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FinanceRepository(client);
});

/// State for finance data
class FinanceState {
  final List<TransactionModel> transactions;
  final List<TransactionModel> recentTransactions;
  final BalanceSummary? balanceSummary;
  final bool isLoading;
  final String? error;

  const FinanceState({
    this.transactions = const [],
    this.recentTransactions = const [],
    this.balanceSummary,
    this.isLoading = false,
    this.error,
  });

  FinanceState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? recentTransactions,
    BalanceSummary? balanceSummary,
    bool? isLoading,
    String? error,
  }) {
    return FinanceState(
      transactions: transactions ?? this.transactions,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      balanceSummary: balanceSummary ?? this.balanceSummary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for finance operations
class FinanceNotifier extends AsyncNotifier<FinanceState> {
  late FinanceRepository _repository;

  @override
  Future<FinanceState> build() async {
    _repository = ref.read(financeRepositoryProvider);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      return const FinanceState();
    }

    return _loadFinanceData(user.id);
  }

  Future<FinanceState> _loadFinanceData(String userId) async {
    try {
      final transactions = await _repository.getCurrentMonthTransactions(userId);
      final recentTransactions = await _repository.getRecentTransactions(userId);
      final balanceSummary = await _repository.getBalanceSummary(userId);

      return FinanceState(
        transactions: transactions,
        recentTransactions: recentTransactions,
        balanceSummary: balanceSummary,
      );
    } catch (e) {
      return FinanceState(error: e.toString());
    }
  }

  /// Add a new transaction
  Future<void> addTransaction({
    required TransactionType type,
    required String category,
    required double amount,
    required DateTime transactionDate,
    String? description,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();

    try {
      await _repository.addTransaction(
        userId: user.id,
        type: type,
        category: category,
        amount: amount,
        transactionDate: transactionDate,
        description: description,
      );

      // Reload data
      state = AsyncData(await _loadFinanceData(user.id));
    } catch (e) {
      state = AsyncData(FinanceState(error: e.toString()));
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await _repository.deleteTransaction(transactionId);
      state = AsyncData(await _loadFinanceData(user.id));
    } catch (e) {
      // Handle error
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    state = AsyncData(await _loadFinanceData(user.id));
  }
}

/// Provider for FinanceNotifier
final financeNotifierProvider = AsyncNotifierProvider<FinanceNotifier, FinanceState>(() {
  return FinanceNotifier();
});

/// Provider for balance summary (for dashboard)
final balanceSummaryProvider = Provider<BalanceSummary?>((ref) {
  final financeState = ref.watch(financeNotifierProvider);
  return financeState.valueOrNull?.balanceSummary;
});

/// Provider for recent transactions (for dashboard)
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final financeState = ref.watch(financeNotifierProvider);
  return financeState.valueOrNull?.recentTransactions ?? [];
});
