import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/activity.dart';
import '../models/pet.dart';

class CareInsightCard extends StatelessWidget {
  final Pet pet;
  final int walkCount;
  final int bathCount;
  final int foodCount;
  final ActivityType suggestedActivity;
  final VoidCallback onStartSuggested;
  final VoidCallback onMarkDone;
  final bool isDark;

  const CareInsightCard({
    super.key,
    required this.pet,
    required this.walkCount,
    required this.bathCount,
    required this.foodCount,
    required this.suggestedActivity,
    required this.onStartSuggested,
    required this.onMarkDone,
    required this.isDark,
  });

  String get _suggestedTitle {
    switch (suggestedActivity) {
      case ActivityType.walk:
        return 'Toca paseo';
      case ActivityType.bath:
        return 'Baño pendiente';
      case ActivityType.food:
        return 'Hora de comer';
    }
  }

  String get _suggestedDescription {
    switch (suggestedActivity) {
      case ActivityType.walk:
        return '${pet.name} todavía no tiene paseo registrado hoy. Un paseo corto ya suma rutina.';
      case ActivityType.bath:
        return 'Si hoy toca limpieza, deja el baño registrado para no perder el historial.';
      case ActivityType.food:
        return 'Registra la comida para mantener control diario y evitar dudas después.';
    }
  }

  IconData get _icon {
    switch (suggestedActivity) {
      case ActivityType.walk:
        return Icons.directions_walk_rounded;
      case ActivityType.bath:
        return Icons.bathtub_outlined;
      case ActivityType.food:
        return Icons.restaurant_rounded;
    }
  }

  LinearGradient get _gradient {
    switch (suggestedActivity) {
      case ActivityType.walk:
        return AppColors.walkGradient;
      case ActivityType.bath:
        return AppColors.bathGradient;
      case ActivityType.food:
        return AppColors.foodGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedToday = [
      walkCount > 0,
      bathCount > 0,
      foodCount > 0,
    ].where((done) => done).length;
    final progress = completedToday / 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _gradient,
                ),
                child: Icon(_icon, color: Colors.white, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan inteligente de hoy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _suggestedTitle,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$completedToday/3',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: isDark ? Colors.white12 : AppColors.beagleCream,
              valueColor: AlwaysStoppedAnimation<Color>(_gradient.colors.first),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _suggestedDescription,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CareChip(
                  label: 'Paseo',
                  emoji: '🚶',
                  done: walkCount > 0,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CareChip(
                  label: 'Baño',
                  emoji: '🛁',
                  done: bathCount > 0,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CareChip(
                  label: 'Comida',
                  emoji: '🍖',
                  done: foodCount > 0,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMarkDone,
                  icon: const Icon(Icons.check_rounded, size: 19),
                  label: const Text('Ya está hecho'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _gradient.colors.first,
                    side: BorderSide(
                      color: _gradient.colors.first.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onStartSuggested,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Iniciar timer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gradient.colors.first,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CareChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool done;
  final bool isDark;

  const _CareChip({
    required this.label,
    required this.emoji,
    required this.done,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: done
            ? AppColors.beagleBrown.withValues(alpha: isDark ? 0.24 : 0.12)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.beagleCream.withValues(alpha: 0.55)),
        border: Border.all(
          color: done
              ? AppColors.beagleBrown.withValues(alpha: 0.35)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            done ? 'Listo' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: done
                  ? AppColors.beagleBrown
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
