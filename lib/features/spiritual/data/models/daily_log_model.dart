/// Daily log model for spiritual and exercise tracking
class DailyLogModel {
  final String id;
  final String userId;
  final DateTime logDate;
  final bool dzikirPagi;
  final bool dzikirPetang;
  final String? exerciseType;
  final int? exerciseDuration; // in minutes
  final String? exerciseNotes;
  final DateTime createdAt;

  const DailyLogModel({
    required this.id,
    required this.userId,
    required this.logDate,
    this.dzikirPagi = false,
    this.dzikirPetang = false,
    this.exerciseType,
    this.exerciseDuration,
    this.exerciseNotes,
    required this.createdAt,
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      dzikirPagi: json['dhikr_morning'] as bool? ?? false,  // DB column
      dzikirPetang: json['dhikr_evening'] as bool? ?? false,  // DB column
      exerciseType: json['exercise_type'] as String?,
      exerciseDuration: json['exercise_duration'] as int?,
      exerciseNotes: json['exercise_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': logDate.toIso8601String().split('T')[0],
      'dhikr_morning': dzikirPagi,  // DB column
      'dhikr_evening': dzikirPetang,  // DB column
      'exercise_type': exerciseType,
      'exercise_duration': exerciseDuration,
      'exercise_notes': exerciseNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpsertJson() {
    return {
      'user_id': userId,
      'log_date': logDate.toIso8601String().split('T')[0],
      'dhikr_morning': dzikirPagi,  // DB column
      'dhikr_evening': dzikirPetang,  // DB column
      'exercise_type': exerciseType,
      'exercise_duration': exerciseDuration,
      'exercise_notes': exerciseNotes,
    };
  }

  DailyLogModel copyWith({
    String? id,
    String? userId,
    DateTime? logDate,
    bool? dzikirPagi,
    bool? dzikirPetang,
    String? exerciseType,
    int? exerciseDuration,
    String? exerciseNotes,
    DateTime? createdAt,
  }) {
    return DailyLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      dzikirPagi: dzikirPagi ?? this.dzikirPagi,
      dzikirPetang: dzikirPetang ?? this.dzikirPetang,
      exerciseType: exerciseType ?? this.exerciseType,
      exerciseDuration: exerciseDuration ?? this.exerciseDuration,
      exerciseNotes: exerciseNotes ?? this.exerciseNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Exercise types
class ExerciseTypes {
  static const List<String> types = [
    'Jogging',
    'Gym',
    'Yoga',
    'Berenang',
    'Bersepeda',
    'Futsal',
    'Badminton',
    'Jalan Kaki',
    'Push Up',
    'Sit Up',
    'Lainnya',
  ];
}
