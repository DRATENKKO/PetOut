import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_colors.dart';
import '../cubit/pet_cubit.dart';
import '../cubit/timer_cubit.dart';
import '../cubit/stats_cubit.dart';
import '../models/pet.dart';
import '../models/activity.dart';
import '../widgets/activity_card.dart';
import '../widgets/care_insight_card.dart';
import 'timer_screen.dart';
import 'stats_screen.dart';
import 'map_screen.dart';
import 'adventure_map_screen.dart';
import 'photo_gallery_screen.dart';
import 'theme_selector_screen.dart';

/// ═══════════════════════════════════════════════════════
/// 🏠 HomeScreen - Pantalla Principal Premium
/// ═══════════════════════════════════════════════════════
///
/// Pantalla principal de la app con:
/// - Saludo personalizado con animación
/// - Selector de mascota con avatar premium
/// - Cards de actividades con gradientes animados
/// - Acceso rápido a estadísticas
/// - Estado vacío elegante
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _greetingScaleAnimation;

  final Map<ActivityType, int> _customDurations = {
    ActivityType.walk: 30,
    ActivityType.bath: 15,
    ActivityType.food: 5,
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _greetingScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // 🎯 Helper Methods
  // ═══════════════════════════════════════════════════════

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Buenos días';
    if (hour >= 12 && hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '☀️';
    if (hour >= 12 && hour < 18) return '🌤️';
    return '🌙';
  }

  String _getSubtitle() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '¿Qué haremos hoy?';
    if (hour >= 12 && hour < 18) return '¿Cómo está tu peludo?';
    return 'Buenas noches, amigo 🐕';
  }

  int _defaultDurationFor(ActivityType type) {
    switch (type) {
      case ActivityType.walk:
        return 30;
      case ActivityType.bath:
        return 15;
      case ActivityType.food:
        return 5;
    }
  }

  Future<void> _markActivityDone(ActivityType type, Pet pet) async {
    final storage = context.read<PetCubit>().storage;
    final duration = _customDurations[type] ?? _defaultDurationFor(type);

    final activity = Activity(
      id: 'manual_${DateTime.now().microsecondsSinceEpoch}',
      petId: pet.id,
      type: type,
      startTime: DateTime.now(),
      durationMinutes: duration,
      completed: true,
    );

    await storage.addActivity(activity);
    await storage.updateStreak();
    if (!mounted) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${activity.name.toLowerCase()} registrado para ${pet.name} · $duration min',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToTimer(ActivityType type, Pet pet) {
    HapticFeedback.mediumImpact();
    final duration = _customDurations[type] ?? _defaultDurationFor(type);

    context.read<TimerCubit>().startTimer(
      petId: pet.id,
      type: type,
      durationMinutes: duration,
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TimerScreen(activityType: type),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _navigateToStats(BuildContext context, Pet pet) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BlocProvider(
          create: (_) => StatsCubit(context.read<PetCubit>().storage),
          child: StatsScreen(pet: pet),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _onDurationChanged(ActivityType type, int minutes) {
    setState(() => _customDurations[type] = minutes);
  }

  // ═══════════════════════════════════════════════════════
  // 🎨 Build Methods
  // ═══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: BlocBuilder<PetCubit, PetState>(
        builder: (context, state) {
          if (state is PetLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is PetLoaded) {
            if (state.pets.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            final pets = state.pets;
            final selectedPet = state.selectedPet ?? pets.first;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<PetCubit>().loadPets();
                  context.read<StatsCubit>().refreshStats(selectedPet.id);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(isDark),
                              const SizedBox(height: 32),
                              _buildPetSection(
                                pets,
                                selectedPet,
                                isDark,
                                state,
                              ),
                              const SizedBox(height: 24),
                              _buildCareCoachSection(isDark, selectedPet),
                              const SizedBox(height: 24),
                              _buildTodayMomentumSection(isDark, selectedPet),
                              const SizedBox(height: 24),
                              _buildExploreSection(isDark, selectedPet),
                              const SizedBox(height: 32),
                              _buildActivitiesSection(isDark, selectedPet),
                              const SizedBox(height: 24),
                              _buildQuickStats(isDark, selectedPet),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.avatarGradient,
            ),
            child: const Center(
              child: Text('🐕', style: TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppColors.darkAccent : AppColors.beagleBrown,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // 📱 Header Section
  // ─────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return SlideTransition(
      position: _slideAnimation,
      child: Row(
        children: [
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaleTransition(
                  scale: _greetingScaleAnimation,
                  child: Row(
                    children: [
                      Text(
                        _getGreetingEmoji(),
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getSubtitle(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Settings/Pets button
          GestureDetector(
            onTap: () => _showPetsSheet(context),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark ? AppColors.darkCard : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(Icons.pets, color: AppColors.beagleBrown, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // 🐕 Pet Section
  // ─────────────────────────────────────────────────────
  Widget _buildPetSection(
    List<Pet> pets,
    Pet selectedPet,
    bool isDark,
    PetLoaded state,
  ) {
    return Column(
      children: [
        // Main avatar
        GestureDetector(
          onTap: () => _showPetsSheet(context),
          child: ScaleTransition(
            scale: _greetingScaleAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.beagleBrown.withValues(alpha: 0.2),
                        AppColors.beagleBrown.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Avatar circle
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isDark
                        ? AppColors.darkAvatarGradient
                        : AppColors.avatarGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.beagleBrown.withValues(alpha: 0.35),
                        blurRadius: 35,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.beagleCream,
                      ),
                      child: ClipOval(
                        child: selectedPet.imagePath != null
                            ? Image.file(
                                File(selectedPet.imagePath!),
                                width: 148,
                                height: 148,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Text(
                                    selectedPet.emoji,
                                    style: const TextStyle(fontSize: 70),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  selectedPet.emoji,
                                  style: const TextStyle(fontSize: 70),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                // Name badge
                Positioned(
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: isDark ? AppColors.darkCard : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedPet.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit_outlined,
                          size: 15,
                          color: AppColors.beagleBrown,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Pet selector dots
        if (pets.length > 1) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pets.length, (index) {
              final isSelected = pets[index].id == selectedPet.id;
              return GestureDetector(
                onTap: () => context.read<PetCubit>().selectPet(pets[index].id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: isSelected ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: isSelected ? AppColors.avatarGradient : null,
                    color: isSelected
                        ? null
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : AppColors.beagleTan.withValues(alpha: 0.4)),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Future<_CareSnapshot> _loadCareSnapshot(String petId) async {
    final storage = context.read<PetCubit>().storage;
    final todayActivities = await storage.getActivitiesForToday(petId);
    final allActivities = await storage.getActivitiesForPet(petId);
    final streak = await storage.getCurrentStreak();

    int todayCount(ActivityType type) => todayActivities
        .where((activity) => activity.type == type && activity.completed)
        .length;
    int totalCount(ActivityType type) => allActivities
        .where((activity) => activity.type == type && activity.completed)
        .length;

    final walkToday = todayCount(ActivityType.walk);
    final bathToday = todayCount(ActivityType.bath);
    final foodToday = todayCount(ActivityType.food);

    ActivityType suggested = ActivityType.walk;
    if (foodToday == 0) {
      suggested = ActivityType.food;
    } else if (walkToday == 0) {
      suggested = ActivityType.walk;
    } else if (bathToday == 0) {
      suggested = ActivityType.bath;
    }

    final todayMinutes = todayActivities.fold<int>(
      0,
      (total, activity) => total + activity.durationMinutes,
    );

    return _CareSnapshot(
      walkToday: walkToday,
      bathToday: bathToday,
      foodToday: foodToday,
      walkTotal: totalCount(ActivityType.walk),
      bathTotal: totalCount(ActivityType.bath),
      foodTotal: totalCount(ActivityType.food),
      todayMinutes: todayMinutes,
      streak: streak,
      suggestedActivity: suggested,
    );
  }

  Widget _buildCareCoachSection(bool isDark, Pet selectedPet) {
    return FutureBuilder<_CareSnapshot>(
      future: _loadCareSnapshot(selectedPet.id),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: isDark ? AppColors.darkCard : Colors.white,
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.beagleBrown,
                ),
              ),
            ),
          );
        }

        return CareInsightCard(
          pet: selectedPet,
          walkCount: data.walkToday,
          bathCount: data.bathToday,
          foodCount: data.foodToday,
          suggestedActivity: data.suggestedActivity,
          isDark: isDark,
          onStartSuggested: () =>
              _navigateToTimer(data.suggestedActivity, selectedPet),
          onMarkDone: () =>
              _markActivityDone(data.suggestedActivity, selectedPet),
        );
      },
    );
  }

  Widget _buildTodayMomentumSection(bool isDark, Pet selectedPet) {
    return FutureBuilder<_CareSnapshot>(
      future: _loadCareSnapshot(selectedPet.id),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final completed = data == null
            ? 0
            : [
                data.walkToday > 0,
                data.bathToday > 0,
                data.foodToday > 0,
              ].where((done) => done).length;
        final minutes = data?.todayMinutes ?? 0;
        final streak = data?.streak ?? 0;
        final message = switch (completed) {
          0 =>
            'Parte chico: registra comida o un paseo corto y ya queda encaminado.',
          1 =>
            'Buen inicio. Una acción más y la rutina se siente mucho más ordenada.',
          2 => 'Casi listo el día. Solo falta una actividad para cerrar 3/3.',
          _ =>
            'Día redondo para ${selectedPet.name}. Mantén el ritmo sin sobrepensarlo.',
        };

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? AppColors.darkCard : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.beagleBrown.withValues(
                    alpha: isDark ? 0.22 : 0.12,
                  ),
                ),
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: AppColors.beagleBrown,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoy: $completed/3 · ${minutes}min · racha $streak',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExploreSection(bool isDark, Pet selectedPet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: AppColors.avatarGradient,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Explorar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.22,
          children: [
            _QuickActionTile(
              title: 'Mapa pet friendly',
              subtitle: 'Vet, parques y tiendas',
              icon: Icons.map_rounded,
              color: const Color(0xFF2E7D5A),
              isDark: isDark,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MapScreen())),
            ),
            _QuickActionTile(
              title: 'Aventura',
              subtitle: 'Rutas y logros',
              icon: Icons.explore_rounded,
              color: const Color(0xFF8B5A2B),
              isDark: isDark,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdventureMapScreen()),
              ),
            ),
            _QuickActionTile(
              title: 'Galería',
              subtitle: 'Momentos de ${selectedPet.name}',
              icon: Icons.photo_library_rounded,
              color: const Color(0xFF4A90A4),
              isDark: isDark,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PhotoGalleryScreen()),
              ),
            ),
            _QuickActionTile(
              title: 'Temas',
              subtitle: 'Razas y estilos',
              icon: Icons.palette_rounded,
              color: const Color(0xFFB8860B),
              isDark: isDark,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ThemeSelectorScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // 🎬 Activities Section
  // ─────────────────────────────────────────────────────
  Widget _buildActivitiesSection(bool isDark, Pet selectedPet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: AppColors.avatarGradient,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Actividades',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Activity cards
        ActivityCard(
          type: ActivityType.walk,
          onTap: () => _navigateToTimer(ActivityType.walk, selectedPet),
          onDurationChanged: (min) =>
              _onDurationChanged(ActivityType.walk, min),
        ),
        ActivityCard(
          type: ActivityType.bath,
          onTap: () => _navigateToTimer(ActivityType.bath, selectedPet),
          onDurationChanged: (min) =>
              _onDurationChanged(ActivityType.bath, min),
        ),
        ActivityCard(
          type: ActivityType.food,
          onTap: () => _navigateToTimer(ActivityType.food, selectedPet),
          onDurationChanged: (min) =>
              _onDurationChanged(ActivityType.food, min),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // 📊 Quick Stats Section
  // ─────────────────────────────────────────────────────
  Widget _buildQuickStats(bool isDark, Pet selectedPet) {
    return FutureBuilder<_CareSnapshot>(
      future: _loadCareSnapshot(selectedPet.id),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final walkTotal = data?.walkTotal ?? 0;
        final bathTotal = data?.bathTotal ?? 0;
        final foodTotal = data?.foodTotal ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: AppColors.avatarGradient,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Resumen real',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _navigateToStats(context, selectedPet),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: isDark ? AppColors.darkCard : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      emoji: '🚶',
                      label: 'Paseos',
                      value: '$walkTotal',
                      color: const Color(0xFF8B5A2B),
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildStatItem(
                      emoji: '🛁',
                      label: 'Baños',
                      value: '$bathTotal',
                      color: const Color(0xFF4A90A4),
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildStatItem(
                      emoji: '🍖',
                      label: 'Comidas',
                      value: '$foodTotal',
                      color: const Color(0xFFB8860B),
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildStatItem(
                      emoji: '📊',
                      label: 'Stats',
                      value: '',
                      color: AppColors.beagleBrown,
                      isDark: isDark,
                      showArrow: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    bool showArrow = false,
  }) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 10, color: color),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 65,
      color: isDark ? Colors.white12 : AppColors.beagleCream,
    );
  }

  // ─────────────────────────────────────────────────────
  // 🐾 Empty State
  // ─────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated container with glow
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.avatarGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.beagleBrown.withValues(alpha: 0.35),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐕', style: TextStyle(fontSize: 70)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '¡Añade tu primera mascota!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Presiona el botón + para comenzar\ncon el seguimiento de actividades',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _showPetsSheet(context),
              icon: const Icon(Icons.add, size: 22),
              label: const Text('Añadir Mascota'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.beagleBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 8,
                shadowColor: AppColors.beagleBrown.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // 📋 Bottom Sheet - Pet Selector
  // ─────────────────────────────────────────────────────
  void _showPetsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          color: isDark ? AppColors.darkCard : Colors.white,
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
            const SizedBox(height: 24),
            Text(
              'Mis Mascotas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<PetCubit, PetState>(
                builder: (context, state) {
                  if (state is PetLoaded) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: state.pets.length,
                      itemBuilder: (context, index) {
                        final pet = state.pets[index];
                        final isSelected = pet.id == state.selectedPet?.id;

                        return GestureDetector(
                          onTap: () {
                            context.read<PetCubit>().selectPet(pet.id);
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: isSelected
                                  ? (isDark
                                        ? AppColors.darkElevated
                                        : AppColors.beagleCream)
                                  : (isDark
                                        ? AppColors.darkSurface
                                        : Colors.grey.shade100),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.beagleBrown,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.avatarGradient,
                                  ),
                                  child: Center(
                                    child: Text(
                                      pet.emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        pet.type.name.toUpperCase(),
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
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.beagleBrown,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareSnapshot {
  final int walkToday;
  final int bathToday;
  final int foodToday;
  final int walkTotal;
  final int bathTotal;
  final int foodTotal;
  final int todayMinutes;
  final int streak;
  final ActivityType suggestedActivity;

  const _CareSnapshot({
    required this.walkToday,
    required this.bathToday,
    required this.foodToday,
    required this.walkTotal,
    required this.bathTotal,
    required this.foodTotal,
    required this.todayMinutes,
    required this.streak,
    required this.suggestedActivity,
  });
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? AppColors.darkCard : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
