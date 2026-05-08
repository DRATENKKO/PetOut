import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/pet.dart';

class PetAvatar extends StatefulWidget {
  final Pet pet;
  final double size;
  final bool showBorder;
  final bool isSelected;

  const PetAvatar({
    super.key,
    required this.pet,
    this.size = 160,
    this.showBorder = true,
    this.isSelected = false,
  });

  @override
  State<PetAvatar> createState() => _PetAvatarState();
}

class _PetAvatarState extends State<PetAvatar>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isSelected ? _pulseAnimation.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.showBorder
                  ? (isDark ? AppColors.darkAvatarGradient : AppColors.avatarGradient)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.beagleBrown : AppColors.beagleBrown)
                      .withValues(alpha: widget.isSelected ? 0.5 : 0.25),
                  blurRadius: widget.isSelected ? 30 : 20,
                  spreadRadius: widget.isSelected ? 8 : 4,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.showBorder ? 4 : 0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkCard : AppColors.beagleCream,
                  border: Border.all(
                    color: isDark ? AppColors.darkCard : AppColors.beagleCream,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: widget.pet.imagePath != null
                      ? Image.asset(
                          widget.pet.imagePath!,
                          width: widget.size - (widget.showBorder ? 12 : 0),
                          height: widget.size - (widget.showBorder ? 12 : 0),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildContent(),
                        )
                      : _buildContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.beagleTan.withValues(alpha: 0.3),
            AppColors.beagleCream,
          ],
        ),
      ),
      child: Center(
        child: Text(
          widget.pet.emoji,
          style: TextStyle(fontSize: widget.size * 0.5),
        ),
      ),
    );
  }
}
