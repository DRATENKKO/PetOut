import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_colors.dart';
import '../models/activity.dart';

class StatChart extends StatefulWidget {
  final Map<ActivityType, int> activityCounts;

  const StatChart({
    super.key,
    required this.activityCounts,
  });

  @override
  State<StatChart> createState() => _StatChartState();
}

class _StatChartState extends State<StatChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.activityCounts.values.fold(0, (a, b) => a + b);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 220,
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
          child: total == 0
              ? _buildEmptyState(isDark)
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sectionsSpace: 4,
                          centerSpaceRadius: 45,
                          sections: [
                            PieChartSectionData(
                              value: (widget.activityCounts[ActivityType.walk] ?? 0)
                                  .toDouble(),
                              color: const Color(0xFF8B5A2B),
                              title: _touchedIndex == 0
                                  ? '${widget.activityCounts[ActivityType.walk]}'
                                  : '',
                              radius: _touchedIndex == 0 ? 60 : 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: (widget.activityCounts[ActivityType.bath] ?? 0)
                                  .toDouble(),
                              color: const Color(0xFF4A90A4),
                              title: _touchedIndex == 1
                                  ? '${widget.activityCounts[ActivityType.bath]}'
                                  : '',
                              radius: _touchedIndex == 1 ? 60 : 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: (widget.activityCounts[ActivityType.food] ?? 0)
                                  .toDouble(),
                              color: const Color(0xFFB8860B),
                              title: _touchedIndex == 2
                                  ? '${widget.activityCounts[ActivityType.food]}'
                                  : '',
                              radius: _touchedIndex == 2 ? 60 : 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(
                            icon: Icons.pets,
                            label: 'Paseos',
                            count: widget.activityCounts[ActivityType.walk] ?? 0,
                            color: const Color(0xFF8B5A2B),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14),
                          _buildLegendItem(
                            icon: Icons.bathtub_outlined,
                            label: 'Baños',
                            count: widget.activityCounts[ActivityType.bath] ?? 0,
                            color: const Color(0xFF4A90A4),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14),
                          _buildLegendItem(
                            icon: Icons.restaurant_outlined,
                            label: 'Comidas',
                            count: widget.activityCounts[ActivityType.food] ?? 0,
                            color: const Color(0xFFB8860B),
                            isDark: isDark,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: isDark ? Colors.white24 : AppColors.beagleTan,
          ),
          const SizedBox(height: 12),
          Text(
            'Sin datos aún',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withValues(alpha: 0.15),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.beagleBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
