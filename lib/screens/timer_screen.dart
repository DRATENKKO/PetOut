import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../core/theme/app_colors.dart';
import '../models/activity.dart';
import '../cubit/timer_cubit.dart';

class TimerScreen extends StatefulWidget {
  final ActivityType activityType;

  const TimerScreen({super.key, required this.activityType});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  late ConfettiController _confettiController;
  late Animation<double> _pulseAnimation;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  LinearGradient get _gradient {
    switch (widget.activityType) {
      case ActivityType.walk:
        return AppColors.walkGradient;
      case ActivityType.bath:
        return AppColors.bathGradient;
      case ActivityType.food:
        return AppColors.foodGradient;
    }
  }

  String get _activityName {
    switch (widget.activityType) {
      case ActivityType.walk:
        return 'PASEAR';
      case ActivityType.bath:
        return 'BAÑO';
      case ActivityType.food:
        return 'COMIDA';
    }
  }

  IconData get _activityIcon {
    switch (widget.activityType) {
      case ActivityType.walk:
        return Icons.pets;
      case ActivityType.bath:
        return Icons.bathtub_outlined;
      case ActivityType.food:
        return Icons.restaurant_outlined;
    }
  }

  void _onTimerComplete() {
    setState(() => _showConfetti = true);
    _confettiController.play();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocConsumer<TimerCubit, TimerState>(
      listener: (context, state) {
        if (state is TimerCompleted) {
          _onTimerComplete();
        }
      },
      builder: (context, state) {
        if (state is! TimerRunning && state is! TimerCompleted) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isCompleted = state is TimerCompleted;
        final runningState = state is TimerRunning ? state : null;
        final remainingSeconds = runningState?.remainingSeconds ?? 0;
        final totalSeconds = runningState?.totalSeconds ?? 1;
        final progress = runningState?.progress ?? 1.0;
        final isPaused = runningState?.isPaused ?? false;

        return Scaffold(
          body: Stack(
            children: [
              _buildAnimatedBackground(isDark, size),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, isDark, isCompleted),
                    Expanded(
                      child: Center(
                        child: isCompleted
                            ? _buildCompletionView(isDark)
                            : _buildTimerView(
                                context,
                                remainingSeconds,
                                totalSeconds,
                                progress,
                                isDark,
                              ),
                      ),
                    ),
                    if (!isCompleted)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                        child: Column(
                          children: [
                            _buildControls(context, isPaused, isDark),
                            const SizedBox(height: 16),
                            _buildAddTimeButton(context, isDark),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (_showConfetti) _buildConfetti(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(bool isDark, Size size) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkBackground,
                      AppColors.darkCard,
                      _gradient.colors.first.withValues(alpha: 0.3),
                    ]
                  : [
                      AppColors.beagleCream,
                      AppColors.beagleCream,
                      _gradient.colors.last.withValues(alpha: 0.15),
                    ],
              stops: [
                0.0,
                0.5 + 0.1 * math.sin(_gradientController.value * 2 * math.pi),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.read<TimerCubit>().resetTimer();
              Navigator.of(context).pop();
            },
            style: IconButton.styleFrom(
              backgroundColor:
                  isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark ? AppColors.darkCard : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _gradient,
                  ),
                  child: Icon(
                    _activityIcon,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _activityName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTimerView(
    BuildContext context,
    int remainingSeconds,
    int totalSeconds,
    double progress,
    bool isDark,
  ) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _gradient.colors.first.withValues(alpha: 0.2),
                      blurRadius: 50,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: const Size(280, 280),
                painter: _TimerPainter(
                  progress: progress,
                  gradient: _gradient,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.beagleCream,
                  strokeWidth: 14,
                ),
              ),
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkCard : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.beagleBlack,
                          letterSpacing: 2,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Restante',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, bool isPaused, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (isPaused) {
              context.read<TimerCubit>().resumeTimer();
            } else {
              context.read<TimerCubit>().pauseTimer();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _gradient,
              boxShadow: [
                BoxShadow(
                  color: _gradient.colors.first.withValues(alpha: 0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddTimeButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<TimerCubit>().addMinutes(5);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          border: Border.all(
            color: isDark ? Colors.white24 : AppColors.beagleTan.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              color: isDark ? Colors.white : AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '+5 minutos',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionView(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _gradient,
            boxShadow: [
              BoxShadow(
                color: _gradient.colors.first.withValues(alpha: 0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Center(
            child: Text('🎉', style: TextStyle(fontSize: 80)),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          '¡Completado!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                _gradient.colors.first.withValues(alpha: 0.3),
                _gradient.colors.last.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _activityIcon,
                size: 24,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                _activityName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            context.read<TimerCubit>().stopBarking();
            context.read<TimerCubit>().resetTimer();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _gradient.colors.first,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Volver al inicio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildConfetti() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: math.pi / 2,
        maxBlastForce: 8,
        minBlastForce: 3,
        emissionFrequency: 0.03,
        numberOfParticles: 40,
        gravity: 0.12,
        shouldLoop: false,
        colors: [
          AppColors.beagleBrown,
          AppColors.beagleTan,
          AppColors.secondary,
          Colors.white,
        ],
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final LinearGradient gradient;
  final Color backgroundColor;
  final double strokeWidth;

  _TimerPainter({
    required this.progress,
    required this.gradient,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradientPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        gradientPaint,
      );

      final glowPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = strokeWidth + 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
