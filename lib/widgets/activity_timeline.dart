import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/activity.dart';

class ActivityTimeline extends StatelessWidget {
  final List<Activity> activities;
  final int maxItems;

  const ActivityTimeline({
    super.key,
    required this.activities,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedActivities = List<Activity>.from(activities)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final displayActivities = sortedActivities.take(maxItems).toList();

    if (displayActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: isDark ? Colors.white24 : AppColors.beagleTan,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay actividades aún',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white54 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayActivities.length,
      itemBuilder: (context, index) {
        final activity = displayActivities[index];
        final isLast = index == displayActivities.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(activity.startTime),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      _formatDate(activity.startTime),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : AppColors.textMuted.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _getGradient(activity.type),
                      border: Border.all(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getGradient(activity.type).colors.first.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.beagleTan.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark ? AppColors.darkCard : Colors.white,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.beagleCream,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: _getGradient(activity.type),
                        ),
                        child: Icon(
                          _getIcon(activity.type),
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark ? Colors.white : AppColors.beagleBlack,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${activity.durationMinutes} minutos',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (activity.completed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.secondary.withValues(alpha: 0.15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Listo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  LinearGradient _getGradient(ActivityType type) {
    switch (type) {
      case ActivityType.walk:
        return AppColors.walkGradient;
      case ActivityType.bath:
        return AppColors.bathGradient;
      case ActivityType.food:
        return AppColors.foodGradient;
    }
  }

  IconData _getIcon(ActivityType type) {
    switch (type) {
      case ActivityType.walk:
        return Icons.pets;
      case ActivityType.bath:
        return Icons.bathtub_outlined;
      case ActivityType.food:
        return Icons.restaurant_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);

    if (date == today) {
      return 'Hoy';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
