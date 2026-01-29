import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_provider.dart';
import '../data/models/daily_log_model.dart';
import '../data/repositories/spiritual_repository.dart';

/// Provider for SpiritualRepository
final spiritualRepositoryProvider = Provider<SpiritualRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SpiritualRepository(client);
});

/// State for spiritual/daily log data
class SpiritualState {
  final DailyLogModel? todayLog;
  final WeeklySummary? weeklySummary;
  final bool isLoading;
  final String? error;

  const SpiritualState({
    this.todayLog,
    this.weeklySummary,
    this.isLoading = false,
    this.error,
  });

  /// Check if dzikir pagi is done today
  bool get isDzikirPagiDone => todayLog?.dzikirPagi ?? false;

  /// Check if dzikir petang is done today
  bool get isDzikirPetangDone => todayLog?.dzikirPetang ?? false;

  /// Check if exercise is done today
  bool get isExerciseDone => todayLog?.exerciseType != null;

  SpiritualState copyWith({
    DailyLogModel? todayLog,
    WeeklySummary? weeklySummary,
    bool? isLoading,
    String? error,
  }) {
    return SpiritualState(
      todayLog: todayLog ?? this.todayLog,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for spiritual operations
class SpiritualNotifier extends AsyncNotifier<SpiritualState> {
  late SpiritualRepository _repository;

  @override
  Future<SpiritualState> build() async {
    _repository = ref.read(spiritualRepositoryProvider);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      return const SpiritualState();
    }

    return _loadSpiritualData(user.id);
  }

  Future<SpiritualState> _loadSpiritualData(String userId) async {
    try {
      final todayLog = await _repository.getTodayLog(userId);
      final weeklySummary = await _repository.getWeeklySummary(userId);

      return SpiritualState(
        todayLog: todayLog,
        weeklySummary: weeklySummary,
      );
    } catch (e) {
      return SpiritualState(error: e.toString());
    }
  }

  /// Toggle dzikir pagi
  Future<void> toggleDzikirPagi() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await _repository.toggleDzikirPagi(user.id);
      state = AsyncData(await _loadSpiritualData(user.id));
    } catch (e) {
      // Handle error
    }
  }

  /// Toggle dzikir petang
  Future<void> toggleDzikirPetang() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await _repository.toggleDzikirPetang(user.id);
      state = AsyncData(await _loadSpiritualData(user.id));
    } catch (e) {
      // Handle error
    }
  }

  /// Log exercise
  Future<void> logExercise({
    required String exerciseType,
    required int duration,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await _repository.logExercise(
        userId: user.id,
        exerciseType: exerciseType,
        duration: duration,
      );
      state = AsyncData(await _loadSpiritualData(user.id));
    } catch (e) {
      // Handle error
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    state = AsyncData(await _loadSpiritualData(user.id));
  }
}

/// Provider for SpiritualNotifier
final spiritualNotifierProvider = AsyncNotifierProvider<SpiritualNotifier, SpiritualState>(() {
  return SpiritualNotifier();
});

/// Provider for today's dzikir status (for dashboard)
final dzikirStatusProvider = Provider<({bool pagi, bool petang})>((ref) {
  final spiritualState = ref.watch(spiritualNotifierProvider);
  final state = spiritualState.valueOrNull;
  return (
    pagi: state?.isDzikirPagiDone ?? false,
    petang: state?.isDzikirPetangDone ?? false,
  );
});
