import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/fasting_schedule_model.dart';

/// Repository for fasting schedule operations
class FastingRepository {
  final SupabaseClient _client;

  FastingRepository(this._client);

  /// Get all fasting schedules for a user
  Future<List<FastingScheduleModel>> getFastingSchedules(String userId) async {
    final response = await _client
        .from('fasting_schedules')
        .select()
        .eq('user_id', userId)
        .order('fasting_date', ascending: true);

    return (response as List)
        .map((json) => FastingScheduleModel.fromJson(json))
        .toList();
  }

  /// Get upcoming fasting schedules (from today onwards)
  Future<List<FastingScheduleModel>> getUpcomingFastingSchedules(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final response = await _client
        .from('fasting_schedules')
        .select()
        .eq('user_id', userId)
        .gte('fasting_date', today.toIso8601String().split('T')[0])
        .order('fasting_date', ascending: true);

    return (response as List)
        .map((json) => FastingScheduleModel.fromJson(json))
        .toList();
  }

  /// Get fasting schedule for a specific date
  Future<FastingScheduleModel?> getFastingByDate(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];

    final response = await _client
        .from('fasting_schedules')
        .select()
        .eq('user_id', userId)
        .eq('fasting_date', dateStr)
        .maybeSingle();

    if (response == null) return null;
    return FastingScheduleModel.fromJson(response);
  }

  /// Add a new fasting schedule
  Future<FastingScheduleModel> addFastingSchedule({
    required String userId,
    required FastingType fastingType,
    required DateTime fastingDate,
    String? notes,
  }) async {
    debugPrint('[FastingRepository] Adding fasting schedule...');
    debugPrint('[FastingRepository] user_id: $userId, type: ${fastingType.value}');
    
    final insertData = {
      'user_id': userId,
      'fasting_type': fastingType.value,
      'fasting_date': fastingDate.toIso8601String().split('T')[0],
      'notes': notes,
    };
    debugPrint('[FastingRepository] Insert data: $insertData');
    
    final response = await _client
        .from('fasting_schedules')
        .insert(insertData)
        .select()
        .single();

    debugPrint('[FastingRepository] Success! Response: $response');
    return FastingScheduleModel.fromJson(response);
  }

  /// Update fasting schedule completion status
  Future<FastingScheduleModel> updateCompletionStatus({
    required String scheduleId,
    required bool isCompleted,
  }) async {
    final response = await _client
        .from('fasting_schedules')
        .update({'is_completed': isCompleted})
        .eq('id', scheduleId)
        .select()
        .single();

    return FastingScheduleModel.fromJson(response);
  }

  /// Delete a fasting schedule
  Future<void> deleteFastingSchedule(String scheduleId) async {
    await _client
        .from('fasting_schedules')
        .delete()
        .eq('id', scheduleId);
  }

  /// Get next fasting schedule
  Future<FastingScheduleModel?> getNextFastingSchedule(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final response = await _client
        .from('fasting_schedules')
        .select()
        .eq('user_id', userId)
        .gte('fasting_date', today.toIso8601String().split('T')[0])
        .eq('is_completed', false)
        .order('fasting_date', ascending: true)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return FastingScheduleModel.fromJson(response);
  }
}
