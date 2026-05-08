import 'package:equatable/equatable.dart';

enum ActivityType { walk, bath, food }

class Activity extends Equatable {
  final String id;
  final String petId;
  final ActivityType type;
  final DateTime startTime;
  final int durationMinutes;
  final bool completed;

  const Activity({
    required this.id,
    required this.petId,
    required this.type,
    required this.startTime,
    required this.durationMinutes,
    this.completed = false,
  });

  String get emoji {
    switch (type) {
      case ActivityType.walk:
        return '🐕';
      case ActivityType.bath:
        return '🛁';
      case ActivityType.food:
        return '🍖';
    }
  }

  String get name {
    switch (type) {
      case ActivityType.walk:
        return 'PASEO';
      case ActivityType.bath:
        return 'BAÑO';
      case ActivityType.food:
        return 'COMIDA';
    }
  }

  Activity copyWith({
    String? id,
    String? petId,
    ActivityType? type,
    DateTime? startTime,
    int? durationMinutes,
    bool? completed,
  }) {
    return Activity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'type': type.index,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completed': completed,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      petId: json['petId'] as String,
      type: ActivityType.values[json['type'] as int],
      startTime: DateTime.parse(json['startTime'] as String),
      durationMinutes: json['durationMinutes'] as int,
      completed: json['completed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, petId, type, startTime, durationMinutes, completed];
}
