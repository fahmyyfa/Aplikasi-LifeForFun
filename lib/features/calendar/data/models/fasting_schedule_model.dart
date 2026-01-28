/// Fasting type enum
enum FastingType {
  seninKamis,
  ayyamulBidh,
  daud,
  custom;

  String get displayName {
    switch (this) {
      case FastingType.seninKamis:
        return 'Senin-Kamis';
      case FastingType.ayyamulBidh:
        return 'Ayyamul Bidh';
      case FastingType.daud:
        return 'Puasa Daud';
      case FastingType.custom:
        return 'Lainnya';
    }
  }

  String get value {
    switch (this) {
      case FastingType.seninKamis:
        return 'senin_kamis';
      case FastingType.ayyamulBidh:
        return 'ayyamul_bidh';
      case FastingType.daud:
        return 'daud';
      case FastingType.custom:
        return 'custom';
    }
  }

  static FastingType fromValue(String value) {
    switch (value) {
      case 'senin_kamis':
        return FastingType.seninKamis;
      case 'ayyamul_bidh':
        return FastingType.ayyamulBidh;
      case 'daud':
        return FastingType.daud;
      default:
        return FastingType.custom;
    }
  }
}

/// Fasting schedule model
class FastingScheduleModel {
  final String id;
  final String userId;
  final FastingType fastingType;
  final DateTime fastingDate;
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;

  const FastingScheduleModel({
    required this.id,
    required this.userId,
    required this.fastingType,
    required this.fastingDate,
    this.isCompleted = false,
    this.notes,
    required this.createdAt,
  });

  factory FastingScheduleModel.fromJson(Map<String, dynamic> json) {
    return FastingScheduleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fastingType: FastingType.fromValue(json['fasting_type'] as String),
      fastingDate: DateTime.parse(json['fasting_date'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fasting_type': fastingType.value,
      'fasting_date': fastingDate.toIso8601String().split('T')[0],
      'is_completed': isCompleted,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'fasting_type': fastingType.value,
      'fasting_date': fastingDate.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }

  FastingScheduleModel copyWith({
    String? id,
    String? userId,
    FastingType? fastingType,
    DateTime? fastingDate,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
  }) {
    return FastingScheduleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fastingType: fastingType ?? this.fastingType,
      fastingDate: fastingDate ?? this.fastingDate,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
