import 'package:latlong2/latlong.dart';

/// ═══════════════════════════════════════════════════════
/// 📍 Place - Modelo para Lugares en el Mapa
/// ═══════════════════════════════════════════════════════

enum PlaceType {
  veterinary,
  petStore,
  park,
  grooming,
  emergencyVet,
}

class Place {
  final String id;
  final String name;
  final String address;
  final PlaceType type;
  final LatLng location;
  final double? rating;
  final String? phone;
  final String? imageUrl;
  final bool isOpen;

  const Place({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.location,
    this.rating,
    this.phone,
    this.imageUrl,
    this.isOpen = true,
  });

  String get typeIcon {
    switch (type) {
      case PlaceType.veterinary: return '🏥';
      case PlaceType.petStore: return '🛒';
      case PlaceType.park: return '🌳';
      case PlaceType.grooming: return '✂️';
      case PlaceType.emergencyVet: return '🚨';
    }
  }

  String get typeName {
    switch (type) {
      case PlaceType.veterinary: return 'Veterinario';
      case PlaceType.petStore: return 'Tienda de mascotas';
      case PlaceType.park: return 'Parque';
      case PlaceType.grooming: return 'Peluquería';
      case PlaceType.emergencyVet: return 'Veterinario 24h';
    }
  }
}

/// ═══════════════════════════════════════════════════════
/// 🗺️ AdventureRoute - Ruta de Paseo
/// ═══════════════════════════════════════════════════════

class AdventureRoute {
  final String id;
  final String name;
  final String description;
  final List<LatLng> points;
  final double distanceKm;
  final int estimatedMinutes;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? imageUrl;
  final List<String> badges;

  const AdventureRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.distanceKm,
    required this.estimatedMinutes,
    this.isCompleted = false,
    this.completedAt,
    this.imageUrl,
    this.badges = const [],
  });
}

/// ═══════════════════════════════════════════════════════
/// 📸 ActivityPhoto - Foto por Actividad
/// ═══════════════════════════════════════════════════════

class ActivityPhoto {
  final String id;
  final String activityId;
  final String imagePath;
  final DateTime takenAt;
  final String? caption;

  const ActivityPhoto({
    required this.id,
    required this.activityId,
    required this.imagePath,
    required this.takenAt,
    this.caption,
  });
}
