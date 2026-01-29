import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/daily_log_model.dart';

/// Repository for daily spiritual log operations
class SpiritualRepository {
  final SupabaseClient _client;

  SpiritualRepository(this._client);

  /// Get today's daily log
  Future<DailyLogModel?> getTodayLog(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _client
        .from('daily_logs')
        .select()
        .eq('user_id', userId)
        .eq('log_date', today)
        .maybeSingle();

    if (response == null) return null;
    return DailyLogModel.fromJson(response);
  }

  /// Get logs for a date range
  Future<List<DailyLogModel>> getLogsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _client
        .from('daily_logs')
        .select()
        .eq('user_id', userId)
        .gte('log_date', startDate.toIso8601String().split('T')[0])
        .lte('log_date', endDate.toIso8601String().split('T')[0])
        .order('log_date', ascending: false);

    return (response as List)
        .map((json) => DailyLogModel.fromJson(json))
        .toList();
  }

  /// Create or update today's log
  Future<DailyLogModel> upsertTodayLog({
    required String userId,
    bool? dzikirPagi,
    bool? dzikirPetang,
    String? exerciseType,
    int? exerciseDuration,
    String? exerciseNotes,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Check if log exists
    final existingLog = await getTodayLog(userId);

    if (existingLog != null) {
      // Update existing log
      final updates = <String, dynamic>{};
      if (dzikirPagi != null) updates['dzikir_pagi'] = dzikirPagi;
      if (dzikirPetang != null) updates['dzikir_petang'] = dzikirPetang;
      if (exerciseType != null) updates['exercise_type'] = exerciseType;
      if (exerciseDuration != null) updates['exercise_duration'] = exerciseDuration;
      if (exerciseNotes != null) updates['exercise_notes'] = exerciseNotes;

      final response = await _client
          .from('daily_logs')
          .update(updates)
          .eq('id', existingLog.id)
          .select()
          .single();

      return DailyLogModel.fromJson(response);
    } else {
      // Create new log
      final response = await _client
          .from('daily_logs')
          .insert({
            'user_id': userId,
            'log_date': today,
            'dzikir_pagi': dzikirPagi ?? false,
            'dzikir_petang': dzikirPetang ?? false,
            'exercise_type': exerciseType,
            'exercise_duration': exerciseDuration,
            'exercise_notes': exerciseNotes,
          })
          .select()
          .single();

      return DailyLogModel.fromJson(response);
    }
  }

  /// Toggle dzikir pagi status
  Future<DailyLogModel> toggleDzikirPagi(String userId) async {
    final todayLog = await getTodayLog(userId);
    final newValue = !(todayLog?.dzikirPagi ?? false);
    return upsertTodayLog(userId: userId, dzikirPagi: newValue);
  }

  /// Toggle dzikir petang status
  Future<DailyLogModel> toggleDzikirPetang(String userId) async {
    final todayLog = await getTodayLog(userId);
    final newValue = !(todayLog?.dzikirPetang ?? false);
    return upsertTodayLog(userId: userId, dzikirPetang: newValue);
  }

  /// Log exercise
  Future<DailyLogModel> logExercise({
    required String userId,
    required String exerciseType,
    required int duration,
  }) async {
    return upsertTodayLog(
      userId: userId,
      exerciseType: exerciseType,
      exerciseDuration: duration,
    );
  }

  /// Get weekly summary
  Future<WeeklySummary> getWeeklySummary(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final logs = await getLogsInRange(userId, startOfWeek, endOfWeek);

    int dzikirPagiCount = 0;
    int dzikirPetangCount = 0;
    int exerciseCount = 0;
    int totalExerciseDuration = 0;

    for (final log in logs) {
      if (log.dzikirPagi) dzikirPagiCount++;
      if (log.dzikirPetang) dzikirPetangCount++;
      if (log.exerciseType != null) {
        exerciseCount++;
        totalExerciseDuration += log.exerciseDuration ?? 0;
      }
    }

    return WeeklySummary(
      dzikirPagiCount: dzikirPagiCount,
      dzikirPetangCount: dzikirPetangCount,
      exerciseCount: exerciseCount,
      totalExerciseDuration: totalExerciseDuration,
      daysLogged: logs.length,
    );
  }
}

/// Weekly summary model
class WeeklySummary {
  final int dzikirPagiCount;
  final int dzikirPetangCount;
  final int exerciseCount;
  final int totalExerciseDuration;
  final int daysLogged;

  const WeeklySummary({
    required this.dzikirPagiCount,
    required this.dzikirPetangCount,
    required this.exerciseCount,
    required this.totalExerciseDuration,
    required this.daysLogged,
  });
}
