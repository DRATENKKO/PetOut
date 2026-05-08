import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../models/activity.dart';

class ActivityCard extends StatefulWidget {
  final ActivityType type;
  final VoidCallback onTap;
  final bool isCompact;
  final void Function(int minutes)? onDurationChanged;

  const ActivityCard({
    super.key,
    required this.type,
    required this.onTap,
    this.isCompact = false,
    this.onDurationChanged,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;
  int _customDuration = 0;

  int get _defaultDuration {
    switch (widget.type) {
      case ActivityType.walk:
        return 30;
      case ActivityType.bath:
        return 15;
      case ActivityType.food:
        return 5;
    }
  }

  @override
  void initState() {
    super.initState();
    _customDuration = _defaultDuration;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient get _gradient {
    switch (widget.type) {
      case ActivityType.walk:
        return AppColors.walkGradient;
      case ActivityType.bath:
        return AppColors.bathGradient;
      case ActivityType.food:
        return AppColors.foodGradient;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case ActivityType.walk:
        return Icons.pets;
      case ActivityType.bath:
        return Icons.bathtub_outlined;
      case ActivityType.food:
        return Icons.restaurant_outlined;
    }
  }

  String get _name {
    switch (widget.type) {
      case ActivityType.walk:
        return 'PASEAR';
      case ActivityType.bath:
        return 'BAÑO';
      case ActivityType.food:
        return 'COMIDA';
    }
  }

  String get _subtitle {
    if (_customDuration != _defaultDuration) {
      return '$_customDuration minutos';
    }
    switch (widget.type) {
      case ActivityType.walk:
        return '30 minutos';
      case ActivityType.bath:
        return '15 minutos';
      case ActivityType.food:
        return '5 minutos';
    }
  }

  Future<void> _showDurationPicker() async {
    HapticFeedback.mediumImpact();

    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DurationPickerSheet(
        initialDuration: _customDuration,
        activityType: widget.type,
      ),
    );

    if (result != null) {
      setState(() => _customDuration = result);
      widget.onDurationChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: _showDurationPicker,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.97 : _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: _gradient,
                boxShadow: [
                  BoxShadow(
                    color: _gradient.colors.first.withValues(alpha: _glowAnimation.value),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: isDark ? AppColors.darkCard : Colors.white,
                ),
                padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
                child: Row(
                  children: [
                    Container(
                      width: widget.isCompact ? 48 : 64,
                      height: widget.isCompact ? 48 : 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: _gradient,
                        boxShadow: [
                          BoxShadow(
                            color: _gradient.colors.first.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _icon,
                        size: widget.isCompact ? 24 : 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _name,
                                style: TextStyle(
                                  fontSize: widget.isCompact ? 16 : 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.beagleBlack,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              if (_customDuration != _defaultDuration) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: _gradient.colors.first.withValues(alpha: 0.2),
                                  ),
                                  child: Text(
                                    'Personalizado',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _gradient.colors.first,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subtitle,
                            style: TextStyle(
                              fontSize: widget.isCompact ? 12 : 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.darkBackground.withValues(alpha: 0.5)
                            : AppColors.beagleCream.withValues(alpha: 0.5),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 28,
                        color: _gradient.colors.first,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DurationPickerSheet extends StatefulWidget {
  final int initialDuration;
  final ActivityType activityType;

  const _DurationPickerSheet({
    required this.initialDuration,
    required this.activityType,
  });

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  late int _selectedMinutes;
  late FixedExtentScrollController _scrollController;

  List<int> get _availableMinutes {
    switch (widget.activityType) {
      case ActivityType.walk:
        return [5, 10, 15, 20, 25, 30, 45, 60, 90, 120];
      case ActivityType.bath:
        return [5, 10, 15, 20, 25, 30, 45, 60];
      case ActivityType.food:
        return [1, 2, 3, 5, 10, 15, 20];
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialDuration;
    final initialIndex = _availableMinutes.indexOf(_selectedMinutes);
    _scrollController = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        color: isDark ? AppColors.darkCard : Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
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
            'Seleccionar duración',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.beagleBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mantén presionado para cambiar',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 60,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMinutes = _availableMinutes[index]);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: _availableMinutes.length,
                      builder: (context, index) {
                        final minutes = _availableMinutes[index];
                        final isSelected = minutes == _selectedMinutes;
                        return Center(
                          child: Text(
                            '$minutes',
                            style: TextStyle(
                              fontSize: isSelected ? 36 : 24,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.beagleBrown
                                  : (isDark ? Colors.white54 : AppColors.textMuted),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  'minutos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selectedMinutes),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.beagleBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
