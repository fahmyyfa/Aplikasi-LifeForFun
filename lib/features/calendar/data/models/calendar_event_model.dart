/// Calendar event model
class CalendarEventModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? eventTime; // Format: HH:mm
  final DateTime createdAt;

  const CalendarEventModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.eventDate,
    this.eventTime,
    required this.createdAt,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventTime: json['event_time'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'event_time': eventTime,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'event_time': eventTime,
    };
  }

  CalendarEventModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? eventDate,
    String? eventTime,
    DateTime? createdAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
