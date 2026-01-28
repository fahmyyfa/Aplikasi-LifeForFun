import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_provider.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/notification_service.dart';
import '../data/models/fasting_schedule_model.dart';

/// State for Magic Schedule feature
class MagicScheduleState {
  final bool isProcessing;
  final List<ExtractedScheduleItem> extractedItems;
  final int savedCount;
  final String? error;
  final String? successMessage;

  const MagicScheduleState({
    this.isProcessing = false,
    this.extractedItems = const [],
    this.savedCount = 0,
    this.error,
    this.successMessage,
  });

  MagicScheduleState copyWith({
    bool? isProcessing,
    List<ExtractedScheduleItem>? extractedItems,
    int? savedCount,
    String? error,
    String? successMessage,
  }) {
    return MagicScheduleState(
      isProcessing: isProcessing ?? this.isProcessing,
      extractedItems: extractedItems ?? this.extractedItems,
      savedCount: savedCount ?? this.savedCount,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Notifier for Magic Schedule AI feature
class MagicScheduleNotifier extends StateNotifier<MagicScheduleState> {
  final Ref _ref;
  final GeminiService _geminiService = GeminiService();

  MagicScheduleNotifier(this._ref) : super(const MagicScheduleState());

  /// Pick image from gallery and analyze
  Future<void> pickAndAnalyzeFromGallery() async {
    final image = await _geminiService.pickImageFromGallery();
    if (image != null) {
      await analyzeAndSaveSchedule(image);
    }
  }

  /// Pick image from camera and analyze
  Future<void> pickAndAnalyzeFromCamera() async {
    final image = await _geminiService.pickImageFromCamera();
    if (image != null) {
      await analyzeAndSaveSchedule(image);
    }
  }

  /// Analyze image and save extracted schedules
  Future<void> analyzeAndSaveSchedule(File image) async {
    state = state.copyWith(isProcessing: true, error: null, successMessage: null);

    try {
      // Step 1: Analyze image with Gemini AI
      final extractedItems = await _geminiService.analyzeScheduleImage(image);

      if (extractedItems.isEmpty) {
        state = state.copyWith(
          isProcessing: false,
          error: 'Tidak ada jadwal ditemukan dalam gambar',
        );
        return;
      }

      state = state.copyWith(extractedItems: extractedItems);

      // Step 2: Save to Supabase
      final savedCount = await _saveToSupabase(extractedItems);

      // Step 3: Reschedule notifications for fasting items
      await _rescheduleNotifications();

      state = state.copyWith(
        isProcessing: false,
        savedCount: savedCount,
        successMessage: 'Berhasil menyimpan $savedCount jadwal dari gambar!',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Save extracted items to Supabase (bulk insert)
  Future<int> _saveToSupabase(List<ExtractedScheduleItem> items) async {
    final client = _ref.read(supabaseClientProvider);
    final user = _ref.read(currentUserProvider);

    if (user == null) {
      throw Exception('User not logged in');
    }

    int savedCount = 0;

    // Separate fasting and regular events
    final fastingItems = items.where((item) => item.isFasting).toList();
    final calendarItems = items.where((item) => !item.isFasting).toList();

    // Insert fasting schedules
    if (fastingItems.isNotEmpty) {
      final fastingData = fastingItems.map((item) {
        // Determine fasting type from title
        FastingType fastingType = FastingType.custom;
        final lowerTitle = item.title.toLowerCase();
        
        if (lowerTitle.contains('senin') && lowerTitle.contains('kamis')) {
          fastingType = FastingType.seninKamis;
        } else if (lowerTitle.contains('ayyamul bidh')) {
          fastingType = FastingType.ayyamulBidh;
        } else if (lowerTitle.contains('daud')) {
          fastingType = FastingType.daud;
        }

        return {
          'user_id': user.id,
          'fasting_type': fastingType.value,
          'fasting_date': '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}',
          'notes': item.description ?? item.title,
        };
      }).toList();

      await client.from('fasting_schedules').insert(fastingData);
      savedCount += fastingItems.length;
    }

    // Insert calendar events
    if (calendarItems.isNotEmpty) {
      final calendarData = calendarItems.map((item) {
        return {
          'user_id': user.id,
          'title': item.title,
          'description': item.description,
          'event_date': '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}',
        };
      }).toList();

      await client.from('calendar_events').insert(calendarData);
      savedCount += calendarItems.length;
    }

    return savedCount;
  }

  /// Reschedule all fasting notifications after adding new items
  Future<void> _rescheduleNotifications() async {
    final client = _ref.read(supabaseClientProvider);
    final user = _ref.read(currentUserProvider);

    if (user == null) return;

    await NotificationService().rescheduleAllNotifications(client, user.id);
  }

  /// Clear state
  void clear() {
    state = const MagicScheduleState();
  }
}

/// Provider for MagicScheduleNotifier
final magicScheduleProvider = StateNotifierProvider<MagicScheduleNotifier, MagicScheduleState>((ref) {
  return MagicScheduleNotifier(ref);
});

/// Provider for GeminiService
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});
