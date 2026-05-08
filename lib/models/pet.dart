import 'package:equatable/equatable.dart';

enum PetType { dog, cat, other }

class Pet extends Equatable {
  final String id;
  final String name;
  final PetType type;
  final String? imagePath;
  final DateTime createdAt;

  const Pet({
    required this.id,
    required this.name,
    required this.type,
    this.imagePath,
    required this.createdAt,
  });

  String get emoji {
    switch (type) {
      case PetType.dog:
        return '🐕';
      case PetType.cat:
        return '🐈';
      case PetType.other:
        return '🐾';
    }
  }

  Pet copyWith({
    String? id,
    String? name,
    PetType? type,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PetType.values[json['type'] as int],
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, type, imagePath, createdAt];
}
