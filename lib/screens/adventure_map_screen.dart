import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:confetti/confetti.dart';
import '../core/theme/app_colors.dart';
import '../models/place.dart';

/// ═══════════════════════════════════════════════════════
/// 🎬 AdventureMapScreen - Modo Aventura
/// ═══════════════════════════════════════════════════════
///
/// Modo aventura con:
///
/// - Mapas interactivos estilo "misiones"
/// - Zonas desbloqueables de la ciudad
/// - Logros geográficos
/// - Rutas de paseo predefinidas
/// - Tracking de ruta en tiempo real
/// - Animaciones de celebración al completar zonas
class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({super.key});

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  AdventureRoute? _activeRoute;
  List<LatLng> _currentPath = [];
  bool _isTracking = false;
  double _totalDistance = 0;

  // Sample routes around Viña del Mar
  static const _availableRoutes = [
    AdventureRoute(
      id: 'r1',
      name: 'Playa Acapulco Run',
      description:
          'Paseo por la costanera de Playa Acapulco. ¡Perfecto para perros activos!',
      points: [
        LatLng(-33.0300, -71.4650),
        LatLng(-33.0310, -71.4660),
        LatLng(-33.0320, -71.4670),
        LatLng(-33.0330, -71.4680),
        LatLng(-33.0340, -71.4690),
      ],
      distanceKm: 1.5,
      estimatedMinutes: 20,
      badges: ['🏖️', '🌊'],
    ),
    AdventureRoute(
      id: 'r2',
      name: 'Cerro Castillo Trek',
      description: 'Subida al Cerro Castillo con vistas panorámicas.',
      points: [
        LatLng(-33.0150, -71.4100),
        LatLng(-33.0160, -71.4110),
        LatLng(-33.0170, -71.4120),
        LatLng(-33.0180, -71.4130),
      ],
      distanceKm: 2.3,
      estimatedMinutes: 45,
      badges: ['🏔️', '🎯'],
    ),
    AdventureRoute(
      id: 'r3',
      name: 'Parque Alejo Loyola',
      description:
          'Ruta por el parque más grande de Viña. ¡Zonas de juegos incluidas!',
      points: [
        LatLng(-33.0200, -71.4550),
        LatLng(-33.0210, -71.4560),
        LatLng(-33.0220, -71.4570),
        LatLng(-33.0230, -71.4580),
        LatLng(-33.0240, -71.4590),
      ],
      distanceKm: 2.0,
      estimatedMinutes: 30,
      badges: ['🌳', '🎪'],
    ),
    AdventureRoute(
      id: 'r4',
      name: 'Sector 21 - Mirador',
      description: 'Caminata corta pero intensa hacia el mirador.',
      points: [
        LatLng(-33.0500, -71.4200),
        LatLng(-33.0510, -71.4210),
        LatLng(-33.0520, -71.4220),
      ],
      distanceKm: 1.0,
      estimatedMinutes: 15,
      badges: ['👀', '🏆'],
    ),
  ];

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Map with route
          _buildMap(isDark),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              maxBlastForce: 15,
              minBlastForce: 5,
              emissionFrequency: 0.02,
              numberOfParticles: 30,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppColors.beagleBrown,
                AppColors.beagleTan,
                Colors.amber,
                Colors.green,
                Colors.blue,
              ],
            ),
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildHeader(isDark),
            ),
          ),

          // Route list bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildRouteList(isDark),
          ),

          // Active tracking overlay
          if (_isTracking)
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              child: _buildTrackingCard(isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.walkGradient,
            ),
            child: const Text('🗺️', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo Aventura',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isTracking
                      ? '🎯 Tracking activo - $_totalDistance km'
                      : '${_availableRoutes.length} rutas disponibles',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (_isTracking)
            GestureDetector(
              onTap: _stopTracking,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.red.shade100,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stop, size: 18, color: Colors.red.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Parar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(bool isDark) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(-33.0200, -71.4500),
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.petout.app',
        ),

        // Route polylines
        PolylineLayer(
          polylines: [
            // Available routes (gray dashed)
            ..._availableRoutes.map(
              (route) => Polyline(
                points: route.points,
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                strokeWidth: 4,
              ),
            ),

            // Current tracked path (solid)
            if (_currentPath.isNotEmpty)
              Polyline(
                points: _currentPath,
                color: AppColors.beagleBrown,
                strokeWidth: 6,
              ),

            // Active route highlight
            if (_activeRoute != null && !_isTracking)
              Polyline(
                points: _activeRoute!.points,
                color: AppColors.beagleBrown.withValues(alpha: 0.5),
                strokeWidth: 10,
              ),
          ],
        ),

        // Route markers
        MarkerLayer(
          markers: [
            // Start markers for each route
            ..._availableRoutes.map(
              (route) => Marker(
                point: route.points.first,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: route.isCompleted
                        ? Colors.green
                        : AppColors.beagleBrown,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (route.isCompleted
                                    ? Colors.green
                                    : AppColors.beagleBrown)
                                .withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: route.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : const Text('📍', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),

            // End markers
            ..._availableRoutes.map(
              (route) => Marker(
                point: route.points.last,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: route.isCompleted
                        ? Colors.green.shade700
                        : Colors.amber,
                    boxShadow: [
                      BoxShadow(
                        color: (route.isCompleted ? Colors.green : Colors.amber)
                            .withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: route.isCompleted
                        ? const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 20,
                          )
                        : const Text('🏁', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteList(bool isDark) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  '🏆 Rutas de Aventura',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _availableRoutes.length,
              itemBuilder: (context, index) {
                final route = _availableRoutes[index];
                return _RouteCard(
                  route: route,
                  isDark: isDark,
                  onStart: () => _startRoute(route),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.beagleBrown.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.walkGradient,
            ),
            child: const Icon(
              Icons.directions_walk,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activeRoute?.name ?? 'Ruta en progreso',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '🎯 ${_activeRoute?.distanceKm ?? 0} km • ⏱️ ${_totalDistance.toStringAsFixed(1)} km completados',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Live dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startRoute(AdventureRoute route) {
    HapticFeedback.mediumImpact();
    setState(() {
      _activeRoute = route;
      _isTracking = true;
      _currentPath = [];
      _totalDistance = 0;
    });

    // Start tracking path
    _mapController.move(route.points.first, 16);
  }

  void _stopTracking() {
    HapticFeedback.heavyImpact();
    if (_totalDistance > 0) {
      _confettiController.play();
      _showCompletionDialog();
    }
    setState(() {
      _isTracking = false;
      _activeRoute = null;
      _currentPath = [];
      _totalDistance = 0;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              '¡Misión Completada!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Completaste ${_totalDistance.toStringAsFixed(1)} km',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (_activeRoute != null) ...[
              Wrap(
                spacing: 8,
                children: _activeRoute!.badges
                    .map(
                      (b) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.shade100,
                        ),
                        child: Text(b, style: const TextStyle(fontSize: 24)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              const Text('Badges desbloqueados!'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// 🃏 _RouteCard - Tarjeta de Ruta
/// ═══════════════════════════════════════════════════════
class _RouteCard extends StatelessWidget {
  final AdventureRoute route;
  final bool isDark;
  final VoidCallback onStart;

  const _RouteCard({
    required this.route,
    required this.isDark,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppColors.darkElevated : AppColors.beagleCream,
        border: route.isCompleted
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges
          if (route.badges.isNotEmpty)
            Row(
              children: route.badges
                  .map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(b, style: const TextStyle(fontSize: 18)),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 8),

          // Title
          Text(
            route.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            route.description,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),

          // Stats
          Row(
            children: [
              Icon(Icons.straighten, size: 14, color: AppColors.beagleBrown),
              const SizedBox(width: 4),
              Text(
                '${route.distanceKm} km',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: AppColors.beagleBrown,
              ),
              const SizedBox(width: 4),
              Text(
                '${route.estimatedMinutes} min',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Start button
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: route.isCompleted ? null : AppColors.walkGradient,
                color: route.isCompleted ? Colors.green : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    route.isCompleted ? Icons.replay : Icons.play_arrow,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    route.isCompleted ? 'Repetir' : 'Iniciar',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
