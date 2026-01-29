/// Profile model representing user profile data
class ProfileModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String? dailyWorkoutGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.dailyWorkoutGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Display name with fallback
  String get displayName => fullName ?? email ?? 'Pengguna';

  /// Workout goal with fallback
  String get workoutGoalDisplay => dailyWorkoutGoal ?? 'Belum diatur';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString(),
      fullName: json['full_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      dailyWorkoutGoal: json['daily_workout_goal']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'daily_workout_goal': dailyWorkoutGoal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? dailyWorkoutGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dailyWorkoutGoal: dailyWorkoutGoal ?? this.dailyWorkoutGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

