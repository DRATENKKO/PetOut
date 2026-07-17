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
  final bool isInfinite;
  final int elapsedSeconds;
  final DateTime? scheduledEndTime;

  TimerRunning({
    required this.activity,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isPaused = false,
    this.isInfinite = false,
    this.elapsedSeconds = 0,
    this.scheduledEndTime,
  });

  double get progress {
    if (isInfinite || totalSeconds <= 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }

  String get displayTime {
    final secondsToShow = isInfinite ? elapsedSeconds : remainingSeconds;
    final minutes = secondsToShow ~/ 60;
    final seconds = secondsToShow % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    activity,
    remainingSeconds,
    totalSeconds,
    isPaused,
    isInfinite,
    elapsedSeconds,
    scheduledEndTime,
  ];
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
  int? _scheduledEndNotificationId;

  TimerCubit(
    this._storageService,
    this._notificationService,
    this._soundService,
  ) : super(TimerInitial());

  void startTimer({
    required String petId,
    required ActivityType type,
    required int durationMinutes,
    DateTime? scheduledEndTime,
    bool isInfinite = false,
  }) {
    _timer?.cancel();
    if (_scheduledEndNotificationId != null) {
      _notificationService.cancelNotification(_scheduledEndNotificationId!);
      _scheduledEndNotificationId = null;
    }
    try {
      unawaited(_notificationService.requestPermissions());
    } catch (_) {
      // Tests/mocks may not implement permission prompts; timer still works.
    }

    final activity = Activity(
      id: _uuid.v4(),
      petId: petId,
      type: type,
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
    );

    final totalSeconds = durationMinutes * 60;
    final endTime =
        scheduledEndTime ??
        (isInfinite
            ? null
            : DateTime.now().add(Duration(seconds: totalSeconds)));

    emit(
      TimerRunning(
        activity: activity,
        remainingSeconds: isInfinite ? 0 : totalSeconds,
        totalSeconds: totalSeconds,
        isInfinite: isInfinite,
        elapsedSeconds: 0,
        scheduledEndTime: endTime,
      ),
    );

    _notificationService.showTimerRunningNotification(
      title: isInfinite
          ? 'PetOut activo: ${activity.name}'
          : 'PetOut contando: ${activity.name}',
      body: isInfinite
          ? 'Contador infinito activo. Puedes volver a PetOut cuando quieras.'
          : 'Termina aproximadamente a las ${_formatTime(endTime!)}. Te avisaremos si sales de la app.',
      isOngoing: true,
    );

    if (!isInfinite && endTime != null) {
      _scheduledEndNotificationId = activity.id.hashCode & 0x7fffffff;
      _notificationService.scheduleTimerEndNotification(
        id: _scheduledEndNotificationId!,
        scheduledDate: endTime,
        title: '⏰ ${activity.name} listo',
        body:
            'Tu contador terminó. Abre PetOut para registrarlo y revisar la rutina.',
      );
    }

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is TimerRunning) {
        final currentState = state as TimerRunning;

        if (currentState.isPaused) return;

        if (currentState.isInfinite) {
          emit(
            TimerRunning(
              activity: currentState.activity,
              remainingSeconds: 0,
              totalSeconds: currentState.totalSeconds,
              isPaused: currentState.isPaused,
              isInfinite: true,
              elapsedSeconds: currentState.elapsedSeconds + 1,
              scheduledEndTime: currentState.scheduledEndTime,
            ),
          );
          return;
        }

        final remaining = currentState.scheduledEndTime != null
            ? currentState.scheduledEndTime!
                  .difference(DateTime.now())
                  .inSeconds
            : currentState.remainingSeconds - 1;

        if (remaining <= 0) {
          _timer?.cancel();
          _completeTimer(currentState.activity);
        } else {
          emit(
            TimerRunning(
              activity: currentState.activity,
              remainingSeconds: remaining,
              totalSeconds: currentState.totalSeconds,
              isPaused: currentState.isPaused,
              isInfinite: false,
              elapsedSeconds: currentState.elapsedSeconds,
              scheduledEndTime: currentState.scheduledEndTime,
            ),
          );
        }
      }
    });
  }

  void pauseTimer() {
    if (state is TimerRunning) {
      final currentState = state as TimerRunning;
      emit(
        TimerRunning(
          activity: currentState.activity,
          remainingSeconds: currentState.remainingSeconds,
          totalSeconds: currentState.totalSeconds,
          isPaused: true,
          isInfinite: currentState.isInfinite,
          elapsedSeconds: currentState.elapsedSeconds,
          scheduledEndTime: currentState.scheduledEndTime,
        ),
      );
    }
  }

  void resumeTimer() {
    if (state is TimerRunning) {
      final currentState = state as TimerRunning;
      emit(
        TimerRunning(
          activity: currentState.activity,
          remainingSeconds: currentState.remainingSeconds,
          totalSeconds: currentState.totalSeconds,
          isPaused: false,
          isInfinite: currentState.isInfinite,
          elapsedSeconds: currentState.elapsedSeconds,
          scheduledEndTime: currentState.scheduledEndTime,
        ),
      );
    }
  }

  void addMinutes(int minutes) {
    if (state is TimerRunning) {
      final currentState = state as TimerRunning;
      emit(
        TimerRunning(
          activity: currentState.activity,
          remainingSeconds: currentState.remainingSeconds + (minutes * 60),
          totalSeconds: currentState.totalSeconds + (minutes * 60),
          isPaused: currentState.isPaused,
          isInfinite: currentState.isInfinite,
          elapsedSeconds: currentState.elapsedSeconds,
          scheduledEndTime: currentState.isInfinite
              ? currentState.scheduledEndTime
              : currentState.scheduledEndTime?.add(Duration(minutes: minutes)),
        ),
      );
    }
  }

  void setDurationMinutes(int minutes) {
    if (state is! TimerRunning) return;
    final currentState = state as TimerRunning;
    if (currentState.isInfinite) return;

    final safeMinutes = minutes.clamp(1, 180);
    final totalSeconds = safeMinutes * 60;
    final endTime = DateTime.now().add(Duration(seconds: totalSeconds));

    if (_scheduledEndNotificationId != null) {
      _notificationService.cancelNotification(_scheduledEndNotificationId!);
    }
    _scheduledEndNotificationId =
        currentState.activity.id.hashCode & 0x7fffffff;

    emit(
      TimerRunning(
        activity: currentState.activity.copyWith(durationMinutes: safeMinutes),
        remainingSeconds: totalSeconds,
        totalSeconds: totalSeconds,
        isPaused: currentState.isPaused,
        isInfinite: false,
        elapsedSeconds: 0,
        scheduledEndTime: endTime,
      ),
    );

    _notificationService.showTimerRunningNotification(
      title: 'PetOut contando: ${currentState.activity.name}',
      body: 'Nuevo tiempo: $safeMinutes min. Te avisaremos al terminar.',
      isOngoing: true,
    );

    _notificationService.scheduleTimerEndNotification(
      id: _scheduledEndNotificationId!,
      scheduledDate: endTime,
      title: '⏰ ${currentState.activity.name} listo',
      body:
          'Tu contador terminó. Abre PetOut para registrarlo y revisar la rutina.',
    );
  }

  void setInfiniteMode(bool enabled) {
    if (state is! TimerRunning) return;
    final currentState = state as TimerRunning;

    final endTime = enabled
        ? null
        : DateTime.now().add(Duration(seconds: currentState.totalSeconds));

    if (_scheduledEndNotificationId != null) {
      _notificationService.cancelNotification(_scheduledEndNotificationId!);
      _scheduledEndNotificationId = null;
    }

    emit(
      TimerRunning(
        activity: currentState.activity,
        remainingSeconds: enabled ? 0 : currentState.totalSeconds,
        totalSeconds: currentState.totalSeconds,
        isPaused: currentState.isPaused,
        isInfinite: enabled,
        elapsedSeconds: enabled ? currentState.elapsedSeconds : 0,
        scheduledEndTime: endTime,
      ),
    );

    _notificationService.showTimerRunningNotification(
      title: enabled
          ? 'PetOut activo: ${currentState.activity.name}'
          : 'PetOut contando: ${currentState.activity.name}',
      body: enabled
          ? 'Contador infinito activo. No terminará hasta que tú lo pares.'
          : 'Vuelve cuando quieras. Te avisaremos al terminar.',
      isOngoing: true,
    );

    if (!enabled && endTime != null) {
      _scheduledEndNotificationId =
          currentState.activity.id.hashCode & 0x7fffffff;
      _notificationService.scheduleTimerEndNotification(
        id: _scheduledEndNotificationId!,
        scheduledDate: endTime,
        title: '⏰ ${currentState.activity.name} listo',
        body:
            'Tu contador terminó. Abre PetOut para registrarlo y revisar la rutina.',
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _completeTimer(Activity activity) async {
    final completedActivity = activity.copyWith(completed: true);
    await _storageService.addActivity(completedActivity);
    await _storageService.updateStreak();

    await _checkAchievements(completedActivity);
    await _notificationService.cancelNotification(998);
    if (_scheduledEndNotificationId != null) {
      await _notificationService.cancelNotification(
        _scheduledEndNotificationId!,
      );
      _scheduledEndNotificationId = null;
    }

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
    final activities = await _storageService.getActivitiesForPet(
      activity.petId,
    );
    final completedActivities = activities.where((a) => a.completed).toList();

    final walks = completedActivities
        .where((a) => a.type == ActivityType.walk)
        .length;
    final baths = completedActivities
        .where((a) => a.type == ActivityType.bath)
        .length;
    final meals = completedActivities
        .where((a) => a.type == ActivityType.food)
        .length;

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
    _notificationService.cancelNotification(998);
    if (_scheduledEndNotificationId != null) {
      _notificationService.cancelNotification(_scheduledEndNotificationId!);
      _scheduledEndNotificationId = null;
    }
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
