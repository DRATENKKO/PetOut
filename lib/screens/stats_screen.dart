import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_colors.dart';
import '../models/pet.dart';
import '../models/activity.dart';
import '../models/achievement.dart';
import '../cubit/stats_cubit.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/activity_timeline.dart';
import '../widgets/stat_chart.dart';

class StatsScreen extends StatefulWidget {
  final Pet pet;

  const StatsScreen({super.key, required this.pet});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<StatsCubit>().loadStats(widget.pet.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareAchievement(Achievement achievement) {
    Share.share(
      '🏆 ¡Desbloqueé "${achievement.title}" en PetOut! ${achievement.emoji}\n\n${achievement.description}',
      subject: 'PetOut Achievement',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        title: Text(
          widget.pet.name,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.beagleBrown,
          indicatorWeight: 3,
          labelColor: AppColors.beagleBrown,
          unselectedLabelColor: isDark ? Colors.white54 : AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Logros'),
            Tab(text: 'Historia'),
          ],
        ),
      ),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StatsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(state, isDark),
                _buildAchievementsTab(state, isDark),
                _buildHistoryTab(state, isDark),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSummaryTab(StatsLoaded state, bool isDark) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await context.read<StatsCubit>().refreshStats(widget.pet.id);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStreakCard(state.currentStreak, isDark),
            const SizedBox(height: 24),
            Text(
              'Distribución de Actividades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            StatChart(activityCounts: state.activityCounts),
            const SizedBox(height: 24),
            Text(
              'Total Completadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTotalStats(state, isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(int streak, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: streak > 0
            ? LinearGradient(
                colors: [const Color(0xFFFF6B35), const Color(0xFFFF8E53)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: streak > 0 ? null : (isDark ? AppColors.darkCard : Colors.white),
        boxShadow: [
          BoxShadow(
            color: (streak > 0 ? const Color(0xFFFF6B35) : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(streak > 0 ? '🔥' : '💤', style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w700,
              color: streak > 0
                  ? Colors.white
                  : (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
          Text(
            streak == 1 ? 'día seguido' : 'días seguidos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: streak > 0
                  ? Colors.white70
                  : (isDark ? Colors.white54 : AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalStats(StatsLoaded state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTotalStatItem(
            icon: Icons.pets,
            emoji: '🐕',
            count: state.activityCounts[ActivityType.walk] ?? 0,
            label: 'Paseos',
            color: const Color(0xFF8B5A2B),
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 60,
            color: isDark ? Colors.white12 : AppColors.beagleCream,
          ),
          _buildTotalStatItem(
            icon: Icons.bathtub_outlined,
            emoji: '🛁',
            count: state.activityCounts[ActivityType.bath] ?? 0,
            label: 'Baños',
            color: const Color(0xFF4A90A4),
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 60,
            color: isDark ? Colors.white12 : AppColors.beagleCream,
          ),
          _buildTotalStatItem(
            icon: Icons.restaurant_outlined,
            emoji: '🍖',
            count: state.activityCounts[ActivityType.food] ?? 0,
            label: 'Comidas',
            color: const Color(0xFFB8860B),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalStatItem({
    required IconData icon,
    required String emoji,
    required int count,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab(StatsLoaded state, bool isDark) {
    final unlockedAchievements = state.achievements
        .where((a) => a.unlocked)
        .toList();
    final lockedAchievements = state.achievements
        .where((a) => !a.unlocked)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unlockedAchievements.isNotEmpty) ...[
            Text(
              'Desbloqueados (${unlockedAchievements.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: unlockedAchievements.map((achievement) {
                return AchievementBadge(
                  achievement: achievement,
                  isUnlocked: true,
                  onTap: () => _shareAchievement(achievement),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
          Text(
            'Bloqueados (${lockedAchievements.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: lockedAchievements.map((achievement) {
              return AchievementBadge(
                achievement: achievement,
                isUnlocked: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(StatsLoaded state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad Reciente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ActivityTimeline(activities: state.activities, maxItems: 20),
        ],
      ),
    );
  }
}
