import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_provider.dart';
import '../../../core/services/notification_service.dart';
import '../data/models/fasting_schedule_model.dart';
import '../data/repositories/fasting_repository.dart';

/// Provider for FastingRepository
final fastingRepositoryProvider = Provider<FastingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FastingRepository(client);
});

/// State for fasting schedules
class FastingState {
  final List<FastingScheduleModel> schedules;
  final FastingScheduleModel? nextFasting;
  final bool isLoading;
  final String? error;

  const FastingState({
    this.schedules = const [],
    this.nextFasting,
    this.isLoading = false,
    this.error,
  });

  FastingState copyWith({
    List<FastingScheduleModel>? schedules,
    FastingScheduleModel? nextFasting,
    bool? isLoading,
    String? error,
  }) {
    return FastingState(
      schedules: schedules ?? this.schedules,
      nextFasting: nextFasting ?? this.nextFasting,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for fasting schedules
class FastingNotifier extends AsyncNotifier<FastingState> {
  late FastingRepository _repository;

  @override
  Future<FastingState> build() async {
    _repository = ref.read(fastingRepositoryProvider);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      return const FastingState();
    }

    return _loadFastingSchedules(user.id);
  }

  Future<FastingState> _loadFastingSchedules(String userId) async {
    try {
      final schedules = await _repository.getUpcomingFastingSchedules(userId);
      final nextFasting = await _repository.getNextFastingSchedule(userId);

      return FastingState(
        schedules: schedules,
        nextFasting: nextFasting,
      );
    } catch (e) {
      return FastingState(error: e.toString());
    }
  }

  /// Add a new fasting schedule and reschedule notifications
  Future<void> addFastingSchedule({
    required FastingType fastingType,
    required DateTime fastingDate,
    String? notes,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();

    try {
      await _repository.addFastingSchedule(
        userId: user.id,
        fastingType: fastingType,
        fastingDate: fastingDate,
        notes: notes,
      );

      // Reschedule notifications
      await _rescheduleNotifications(user.id);

      // Reload schedules
      state = AsyncData(await _loadFastingSchedules(user.id));
    } catch (e) {
      state = AsyncData(FastingState(error: e.toString()));
    }
  }

  /// Mark fasting as completed
  Future<void> markAsCompleted(String scheduleId, bool completed) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await _repository.updateCompletionStatus(
        scheduleId: scheduleId,
        isCompleted: completed,
      );

      // Reload schedules
      state = AsyncData(await _loadFastingSchedules(user.id));
    } catch (e) {
      // Handle error
    }
  }

  /// Delete a fasting schedule and reschedule notifications
  Future<void> deleteFastingSchedule(String scheduleId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await _repository.deleteFastingSchedule(scheduleId);

      // Reschedule notifications
      await _rescheduleNotifications(user.id);

      // Reload schedules
      state = AsyncData(await _loadFastingSchedules(user.id));
    } catch (e) {
      // Handle error
    }
  }

  /// Reschedule all fasting notifications
  Future<void> _rescheduleNotifications(String userId) async {
    final client = ref.read(supabaseClientProvider);
    await NotificationService().rescheduleAllNotifications(client, userId);
  }

  /// Refresh schedules
  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    state = AsyncData(await _loadFastingSchedules(user.id));
  }
}

/// Provider for FastingNotifier
final fastingNotifierProvider = AsyncNotifierProvider<FastingNotifier, FastingState>(() {
  return FastingNotifier();
});

/// Provider for next fasting schedule (for dashboard)
final nextFastingProvider = Provider<FastingScheduleModel?>((ref) {
  final fastingState = ref.watch(fastingNotifierProvider);
  return fastingState.valueOrNull?.nextFasting;
});
