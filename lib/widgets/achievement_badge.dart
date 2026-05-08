import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/achievement.dart';

class AchievementBadge extends StatefulWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final bool showAnimation;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.isUnlocked = false,
    this.onTap,
    this.showAnimation = true,
  });

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge>
    with TickerProviderStateMixin {
  late AnimationController _unlockController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _unlockController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _unlockController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _unlockController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    if (widget.isUnlocked && widget.showAnimation) {
      _unlockController.forward();
    } else if (widget.isUnlocked) {
      _unlockController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AchievementBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked && !oldWidget.isUnlocked) {
      _unlockController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _unlockController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _unlockController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value * 3.14159,
              child: child,
            ),
          );
        },
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: widget.isUnlocked ? AppColors.avatarGradient : null,
            color: widget.isUnlocked
                ? null
                : (isDark ? AppColors.darkCard : AppColors.beagleCream.withValues(alpha: 0.5)),
            border: Border.all(
              color: widget.isUnlocked
                  ? Colors.transparent
                  : (isDark ? Colors.white24 : AppColors.beagleTan.withValues(alpha: 0.5)),
              width: 2,
            ),
            boxShadow: widget.isUnlocked
                ? [
                    BoxShadow(
                      color: AppColors.beagleBrown.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isUnlocked
                          ? Colors.white.withValues(alpha: 0.2)
                          : (isDark ? Colors.white10 : AppColors.beagleCream),
                    ),
                  ),
                  Text(
                    widget.achievement.emoji,
                    style: TextStyle(
                      fontSize: 32,
                      color: widget.isUnlocked
                          ? null
                          : (isDark ? Colors.white38 : Colors.black26),
                    ),
                  ),
                  if (widget.isUnlocked)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.achievement.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.isUnlocked
                      ? Colors.white
                      : (isDark ? Colors.white54 : AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
