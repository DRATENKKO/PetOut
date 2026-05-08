import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';

abstract class TimerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TimerInitial extends TimerState {}

class TimerRunning extends TimerState {
  final Activity activity;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isPaused;
  final DateTime? scheduledEndTime;

  TimerRunning({
    required this.activity,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isPaused = false,
    this.scheduledEndTime,
  });

  double get progress => 1 - (remainingSeconds / totalSeconds);

  @override
  List<Object?> get props => [activity, remainingSeconds, totalSeconds, isPaused, scheduledEndTime];
}

class TimerCompleted extends TimerState {
  final Activity activity;

  TimerCompleted(this.activity);

  @override
  List<Object?> get props => [activity];
}

class TimerCubit extends Cubit<TimerState> {
  final StorageService _storageService;
  final NotificationService _notificationService;
  final SoundService _soundService;
  final Uuid _uuid = const Uuid();
  Timer? _timer;

  TimerCubit(this._storageService, this._notificationService, this._soundService) : super(TimerInitial());

  void startTimer({
    required String petId,
    required ActivityType type,
    required int durationMinutes,
    DateTime? scheduledEndTime,
  }) {
    _timer?.cancel();

    final activity = Activity(
      id: _uuid.v4(),
      petId: petId,
      type: type,
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
    );

    final totalSeconds = durationMinutes * 60;

    emit(TimerRunning(
      activity: activity,
      remainingSeconds: totalSeconds,
      totalSeconds: totalSeconds,
      scheduledEndTime: scheduledEndTime,
    ));

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is TimerRunning) {
        final currentState = state as TimerRunning;

        if (currentState.isPaused) return;

        if (currentState.remainingSeconds <= 1) {
          _timer?.cancel();
          _completeTimer(currentState.activity);
        } else {
          emit(TimerRunning(
            activity: currentState.activity,
            remainingSeconds: currentState.remainingSeconds - 1,
            totalSeconds: currentState.totalSeconds,
            isPaused: currentState.isPaused,
            scheduledEndTime: currentState.scheduledEndTime,
          ));
        }
      }
    });
  }

  void pauseTimer() {
    if (state is TimerRunning) {
      final currentState = state as TimerRunning;
      emit(TimerRunning(
        activity: currentState.activity,
        remainingSeconds: currentState.remainingSeconds,
        totalSeconds: currentState.totalSeconds,
        isPaused: true,
        scheduledEndTime: currentState.scheduledEndTime,
      ));
    }
  }

  void resumeTimer() {
    if (state is TimerRunning) {
      final currentState = state as TimerRunning;
      emit(TimerRunning(
        activity: currentState.activity,
        remainingSeconds: currentState.remainingSeconds,
        totalSeconds: currentState.totalSeconds,
        isPaused: false,
        scheduledEndTime: currentState.scheduledEndTime,
      ));
    }
  }

  void addMinutes(int minutes) {
    if (state is TimerRunning) {
      final currentState = state as TimerRunning;
      emit(TimerRunning(
        activity: currentState.activity,
        remainingSeconds: currentState.remainingSeconds + (minutes * 60),
        totalSeconds: currentState.totalSeconds + (minutes * 60),
        isPaused: currentState.isPaused,
        scheduledEndTime: currentState.scheduledEndTime,
      ));
    }
  }

  Future<void> _completeTimer(Activity activity) async {
    final completedActivity = activity.copyWith(completed: true);
    await _storageService.addActivity(completedActivity);
    await _storageService.updateStreak();

    await _checkAchievements(completedActivity);

    _soundService.startBarkingRepeat(intervalSeconds: 4);

    _notificationService.startRepeatingNotification(
      id: 999,
      title: '⏰ ¡${activity.name} completado!',
      body: '🐕 ¡Tu mascota ha terminado! - Presiona para silenciar',
      interval: const Duration(seconds: 5),
    );

    emit(TimerCompleted(completedActivity));
  }

  void stopBarking() {
    _soundService.stopBarking();
    _notificationService.stopRepeatingNotification();
  }

  Future<void> _checkAchievements(Activity activity) async {
    final activities = await _storageService.getActivitiesForPet(activity.petId);
    final completedActivities = activities.where((a) => a.completed).toList();

    final walks = completedActivities.where((a) => a.type == ActivityType.walk).length;
    final baths = completedActivities.where((a) => a.type == ActivityType.bath).length;
    final meals = completedActivities.where((a) => a.type == ActivityType.food).length;

    if (walks >= 1) await _storageService.unlockAchievement('first_walk');
    if (baths >= 1) await _storageService.unlockAchievement('first_bath');
    if (meals >= 1) await _storageService.unlockAchievement('first_meal');
    if (walks >= 20) await _storageService.unlockAchievement('walker');
    if (baths >= 10) await _storageService.unlockAchievement('pro_bather');
    if (meals >= 50) await _storageService.unlockAchievement('food_lover');

    final streak = await _storageService.getCurrentStreak();
    if (streak >= 3) await _storageService.unlockAchievement('streak_3');
    if (streak >= 7) await _storageService.unlockAchievement('streak_7');
    if (streak >= 30) await _storageService.unlockAchievement('streak_30');
  }

  void resetTimer() {
    _soundService.stopBarking();
    _notificationService.stopRepeatingNotification();
    _timer?.cancel();
    emit(TimerInitial());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _soundService.dispose();
    return super.close();
  }
}
