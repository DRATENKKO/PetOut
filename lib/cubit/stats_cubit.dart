import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/activity.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';

abstract class StatsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final List<Activity> activities;
  final List<Achievement> achievements;
  final int currentStreak;
  final Map<ActivityType, int> activityCounts;

  StatsLoaded({
    required this.activities,
    required this.achievements,
    required this.currentStreak,
    required this.activityCounts,
  });

  int get totalActivities => activities.length;

  List<Activity> get completedActivities =>
      activities.where((a) => a.completed).toList();

  @override
  List<Object?> get props => [activities, achievements, currentStreak, activityCounts];
}

class StatsError extends StatsState {
  final String message;

  StatsError(this.message);

  @override
  List<Object?> get props => [message];
}

class StatsCubit extends Cubit<StatsState> {
  final StorageService _storageService;

  StatsCubit(this._storageService) : super(StatsInitial());

  Future<void> loadStats(String petId) async {
    emit(StatsLoading());
    try {
      final activities = await _storageService.getActivitiesForPet(petId);
      final achievements = await _storageService.getAchievements();
      final currentStreak = await _storageService.getCurrentStreak();

      final Map<ActivityType, int> activityCounts = {
        ActivityType.walk: 0,
        ActivityType.bath: 0,
        ActivityType.food: 0,
      };

      for (final activity in activities.where((a) => a.completed)) {
        activityCounts[activity.type] = (activityCounts[activity.type] ?? 0) + 1;
      }

      emit(StatsLoaded(
        activities: activities,
        achievements: achievements,
        currentStreak: currentStreak,
        activityCounts: activityCounts,
      ));
    } catch (e) {
      emit(StatsError(e.toString()));
    }
  }

  Future<void> refreshStats(String petId) async {
    await loadStats(petId);
  }
}
