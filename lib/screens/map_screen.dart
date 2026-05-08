import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../models/place.dart';

/// ═══════════════════════════════════════════════════════
/// 🗺️ MapScreen - Mapa con Veterinarios y Lugares
/// ═══════════════════════════════════════════════════════
///
/// Pantalla de mapa premium que muestra:
/// - Veterinarios más cercanos con direcciones
/// - Tiendas de mascotas
/// - Parques para paseo
/// - Peluquerías caninas
/// - Veterinarios de emergencia 24h
///
/// Usa Google Maps tiles para mejor calidad visual.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  PlaceType _selectedFilter = PlaceType.veterinary;
  Place? _selectedPlace;
  late LatLng _currentCenter;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  // Centro default: Viña del Mar, Chile
  static const _defaultCenter = LatLng(-33.0078, -71.4428);

  @override
  void initState() {
    super.initState();
    _currentCenter = _defaultCenter;

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );

    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Map layer
          _buildMap(isDark),

          // Gradient overlay for better readability
          _buildGradientOverlay(isDark),

          // Top bar with filters
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTopBar(isDark),
                  const SizedBox(height: 16),
                  _buildFilterChips(isDark),
                ],
              ),
            ),
          ),

          // Place info card with animation
          if (_selectedPlace != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_cardAnimation),
                child: ScaleTransition(
                  scale: _cardAnimation,
                  child: _buildPlaceCard(_selectedPlace!, isDark),
                ),
              ),
            ),

          // Bottom navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(isDark),
          ),

          // Loading indicator
          if (_selectedPlace == null)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(child: _buildLocateMeButton(isDark)),
            ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay(bool isDark) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Column(
          children: [
            // Top gradient for status bar
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? AppColors.darkBackground.withValues(alpha: 0.9)
                        : AppColors.background.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Bottom gradient for bottom nav
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    isDark ? AppColors.darkCard : Colors.white,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo/Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppColors.avatarGradient,
            ),
            child: const Center(
              child: Text('🏥', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),

          // Title and location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFilterTitle(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 13,
                      color: AppColors.beagleBrown,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Viña del Mar, Chile',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // My location button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _mapController.move(_defaultCenter, 14);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? AppColors.darkElevated : AppColors.beagleCream,
              ),
              child: Icon(
                Icons.my_location,
                color: AppColors.beagleBrown,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      (
        _selectedFilter == PlaceType.veterinary,
        PlaceType.veterinary,
        '🏥',
        'Vets',
      ),
      (
        _selectedFilter == PlaceType.emergencyVet,
        PlaceType.emergencyVet,
        '🚨',
        '24h',
      ),
      (
        _selectedFilter == PlaceType.petStore,
        PlaceType.petStore,
        '🛒',
        'Tiendas',
      ),
      (_selectedFilter == PlaceType.park, PlaceType.park, '🌳', 'Parques'),
      (
        _selectedFilter == PlaceType.grooming,
        PlaceType.grooming,
        '✂️',
        'Peluq.',
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final (isSelected, type, emoji, label) = filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFilter = type;
                  _selectedPlace = null;
                });
                _cardController.reset();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected
                      ? AppColors.beagleBrown
                      : (isDark ? AppColors.darkCard : Colors.white),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.beagleBrown
                        : (isDark
                              ? AppColors.darkElevated
                              : Colors.transparent),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.beagleBrown.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMap(bool isDark) {
    final places = _getPlacesForType(_selectedFilter);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentCenter,
        initialZoom: 14,
        minZoom: 10,
        maxZoom: 18,
        onTap: (_, _) {
          setState(() => _selectedPlace = null);
          _cardController.reverse();
        },
        onLongPress: (pos, point) {
          // Debug: add custom marker
        },
      ),
      children: [
        // OpenStreetMap tile layer (no API key required)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.petlife.pet_life',
        ),

        // Place markers with clustering potential
        MarkerLayer(
          markers: places.map((place) {
            return Marker(
              point: place.location,
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => _onPlaceTapped(place),
                child: _buildMarkerWidget(place, isDark),
              ),
            );
          }).toList(),
        ),

        // Current location marker (center)
        MarkerLayer(
          markers: [
            Marker(
              point: _defaultCenter,
              width: 20,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.beagleBrown.withValues(alpha: 0.3),
                  border: Border.all(color: AppColors.beagleBrown, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarkerWidget(Place place, bool isDark) {
    final isSelected = _selectedPlace?.id == place.id;
    final size = isSelected ? 54.0 : 44.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? AppColors.beagleBrown
            : (isDark ? AppColors.darkCard : Colors.white),
        border: Border.all(
          color: AppColors.beagleBrown,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSelected ? AppColors.beagleBrown : Colors.black)
                .withValues(alpha: isSelected ? 0.5 : 0.25),
            blurRadius: isSelected ? 16 : 10,
            spreadRadius: isSelected ? 3 : 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          place.typeIcon,
          style: TextStyle(fontSize: isSelected ? 26 : 20),
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Place place, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Place icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: _getGradientForType(place.type),
                        boxShadow: [
                          BoxShadow(
                            color: _getGradientForType(
                              place.type,
                            ).colors.first.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          place.typeIcon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Place info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textMuted,
                            ),
                          ),
                          if (place.rating != null) ...[
                            const SizedBox(height: 8),
                            _buildRatingBadge(place.rating!),
                          ],
                        ],
                      ),
                    ),

                    // Close button
                    GestureDetector(
                      onTap: () {
                        setState(() => _selectedPlace = null);
                        _cardController.reverse();
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.darkElevated
                              : AppColors.beagleCream,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark ? Colors.white60 : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.directions,
                        label: 'Cómo Llegar',
                        gradient: AppColors.walkGradient,
                        secondary: false,
                        onTap: () => _openDirections(place),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.phone,
                        label: place.phone != null ? 'Llamar' : 'Sin teléfono',
                        gradient: null,
                        secondary: true,
                        onTap: place.phone != null
                            ? () => _callPlace(place)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              gradient: _getGradientForType(place.type),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.amber.shade100,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 15, color: Colors.amber.shade700),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    LinearGradient? gradient,
    required bool secondary,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: gradient,
          color: gradient == null
              ? (secondary ? AppColors.beagleCream : null)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: gradient != null
                  ? Colors.white
                  : (onTap != null
                        ? AppColors.textPrimary
                        : AppColors.textMuted),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: gradient != null
                    ? Colors.white
                    : (onTap != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocateMeButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, size: 18, color: AppColors.beagleBrown),
          const SizedBox(width: 8),
          Text(
            'Toca un marcador para ver detalles',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.map, 'Mapa', true, isDark),
              _buildNavItem(Icons.route, 'Rutas', false, isDark),
              _buildNavItem(Icons.camera_alt, 'Fotos', false, isDark),
              _buildNavItem(Icons.palette, 'Temas', false, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.beagleBrown.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.beagleBrown
                  : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppColors.beagleBrown
                  : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // 🔧 Helper Methods
  // ═══════════════════════════════════════════════════════

  String _getFilterTitle() {
    switch (_selectedFilter) {
      case PlaceType.veterinary:
        return 'Veterinarios';
      case PlaceType.emergencyVet:
        return 'Veterinarios 24h';
      case PlaceType.petStore:
        return 'Tiendas de Mascotas';
      case PlaceType.park:
        return 'Parques';
      case PlaceType.grooming:
        return 'Peluquerías Caninas';
    }
  }

  LinearGradient _getGradientForType(PlaceType type) {
    switch (type) {
      case PlaceType.veterinary:
      case PlaceType.emergencyVet:
        return AppColors.bathGradient;
      case PlaceType.petStore:
        return AppColors.walkGradient;
      case PlaceType.park:
        return AppColors.foodGradient;
      case PlaceType.grooming:
        return AppColors.avatarGradient;
    }
  }

  void _onPlaceTapped(Place place) {
    HapticFeedback.mediumImpact();
    setState(() => _selectedPlace = place);
    _mapController.move(place.location, 16);
    _cardController.reset();
    _cardController.forward();
  }

  Future<void> _openDirections(Place place) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.location.latitude},${place.location.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPlace(Place place) async {
    if (place.phone == null) return;
    final url = Uri.parse('tel:${place.phone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  List<Place> _getPlacesForType(PlaceType type) {
    // Veterinarios y servicios en Viña del Mar y alrededores
    final allPlaces = [
      // ═══════════════════════════════════════════════
      // 🏥 VETERINARIOS
      // ═══════════════════════════════════════════════
      const Place(
        id: 'v1',
        name: 'Veterinaria Viña Centro',
        address: 'Av. Valparaíso 1234, Viña del Mar',
        type: PlaceType.veterinary,
        location: LatLng(-33.0078, -71.4428),
        rating: 4.8,
        phone: '+56322345678',
      ),
      const Place(
        id: 'v2',
        name: 'Clínica Veterinaria del Mar',
        address: 'Av. Marina 567, Viña del Mar',
        type: PlaceType.veterinary,
        location: LatLng(-33.0150, -71.4500),
        rating: 4.5,
        phone: '+56322345679',
      ),
      const Place(
        id: 'v3',
        name: 'Veterinaria San Martín',
        address: 'Av. San Martín 890, Viña del Mar',
        type: PlaceType.veterinary,
        location: LatLng(-33.0100, -71.4350),
        rating: 4.6,
        phone: '+56322345680',
      ),
      const Place(
        id: 'v4',
        name: 'Centro Veterinario Valparaíso',
        address: 'Av. Brazil 1234, Valparaíso',
        type: PlaceType.veterinary,
        location: LatLng(-33.0450, -71.4200),
        rating: 4.4,
        phone: '+56322234567',
      ),
      const Place(
        id: 'v5',
        name: 'Veterinaria Quilpué',
        address: 'Av. Santiago 567, Quilpué',
        type: PlaceType.veterinary,
        location: LatLng(-33.0450, -71.4800),
        rating: 4.3,
        phone: '+56322123456',
      ),

      // ═══════════════════════════════════════════════
      // 🚨 VETERINARIOS 24H
      // ═══════════════════════════════════════════════
      const Place(
        id: 'e1',
        name: 'Veterinaria 24 Horas Valparaíso',
        address: 'Av. España 890, Valparaíso',
        type: PlaceType.emergencyVet,
        location: LatLng(-33.0450, -71.4700),
        rating: 4.9,
        phone: '+56322234500',
        isOpen: true,
      ),
      const Place(
        id: 'e2',
        name: 'Clínica de Emergencia Veterinaria Viña',
        address: 'Av. Libertad 1500, Viña del Mar',
        type: PlaceType.emergencyVet,
        location: LatLng(-33.0200, -71.4400),
        rating: 4.7,
        phone: '+56322345700',
        isOpen: true,
      ),
      const Place(
        id: 'e3',
        name: 'Hospital Veterinario 24h',
        address: 'Camino La Trinidad 2345, viña del Mar',
        type: PlaceType.emergencyVet,
        location: LatLng(-33.0300, -71.4200),
        rating: 4.8,
        phone: '+56322345800',
        isOpen: true,
      ),

      // ═══════════════════════════════════════════════
      // 🛒 TIENDAS DE MASCOTAS
      // ═══════════════════════════════════════════════
      const Place(
        id: 's1',
        name: 'Mascotas & Más Viña',
        address: 'Av. Libertad 1234, Viña del Mar',
        type: PlaceType.petStore,
        location: LatLng(-33.0100, -71.4400),
        rating: 4.3,
        phone: '+56322345681',
      ),
      const Place(
        id: 's2',
        name: 'Pet House Chile',
        address: 'Av. Valparaíso 2345, Viña del Mar',
        type: PlaceType.petStore,
        location: LatLng(-33.0050, -71.4450),
        rating: 4.6,
        phone: '+56322345682',
      ),
      const Place(
        id: 's3',
        name: ' zoovet',
        address: 'Av. Marina 890, Viña del Mar',
        type: PlaceType.petStore,
        location: LatLng(-33.0180, -71.4520),
        rating: 4.2,
        phone: '+56322345683',
      ),
      const Place(
        id: 's4',
        name: 'La Casa del Perro',
        address: 'Av. Brasil 567, Valparaíso',
        type: PlaceType.petStore,
        location: LatLng(-33.0480, -71.4250),
        rating: 4.5,
        phone: '+56322234568',
      ),

      // ═══════════════════════════════════════════════
      // 🌳 PARQUES
      // ═══════════════════════════════════════════════
      const Place(
        id: 'p1',
        name: 'Parque Alejo Loyola',
        address: 'Av. Loyola, Viña del Mar',
        type: PlaceType.park,
        location: LatLng(-33.0200, -71.4550),
        rating: 4.7,
      ),
      const Place(
        id: 'p2',
        name: 'Playa Acapulco',
        address: 'Av. del Mar, Viña del Mar',
        type: PlaceType.park,
        location: LatLng(-33.0300, -71.4650),
        rating: 4.6,
      ),
      const Place(
        id: 'p3',
        name: 'Parque Museo de la Voluntad',
        address: 'Camino La Ladera, Viña del Mar',
        type: PlaceType.park,
        location: LatLng(-33.0150, -71.4650),
        rating: 4.8,
      ),
      const Place(
        id: 'p4',
        name: 'Parque Copacaban',
        address: 'Av. Costanera, Viña del Mar',
        type: PlaceType.park,
        location: LatLng(-33.0250, -71.4700),
        rating: 4.4,
      ),
      const Place(
        id: 'p5',
        name: 'Cerro Castillo',
        address: 'Cerro Castillo, Viña del Mar',
        type: PlaceType.park,
        location: LatLng(-33.0160, -71.4100),
        rating: 4.9,
      ),

      // ═══════════════════════════════════════════════
      // ✂️ PELUQUERÍAS
      // ═══════════════════════════════════════════════
      const Place(
        id: 'g1',
        name: 'Spacanino Peluquería Canina',
        address: 'Av. Libertad 890, Viña del Mar',
        type: PlaceType.grooming,
        location: LatLng(-33.0120, -71.4380),
        rating: 4.7,
        phone: '+56322345690',
      ),
      const Place(
        id: 'g2',
        name: 'Mascotas Lindas',
        address: 'Av. Valparaíso 1789, Viña del Mar',
        type: PlaceType.grooming,
        location: LatLng(-33.0080, -71.4440),
        rating: 4.5,
        phone: '+56322345691',
      ),
      const Place(
        id: 'g3',
        name: 'Pet Style Viña',
        address: 'Av. Marina 345, Viña del Mar',
        type: PlaceType.grooming,
        location: LatLng(-33.0170, -71.4480),
        rating: 4.6,
        phone: '+56322345692',
      ),
    ];

    if (type == PlaceType.veterinary) {
      return allPlaces
          .where(
            (p) =>
                p.type == PlaceType.veterinary ||
                p.type == PlaceType.emergencyVet,
          )
          .toList();
    }

    return allPlaces.where((p) => p.type == type).toList();
  }
}
