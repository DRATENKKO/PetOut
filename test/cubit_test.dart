import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_out/cubit/pet_cubit.dart';
import 'package:pet_out/cubit/timer_cubit.dart';
import 'package:pet_out/cubit/stats_cubit.dart';
import 'package:pet_out/models/pet.dart';
import 'package:pet_out/models/activity.dart';
import 'package:pet_out/services/storage_service.dart';
import 'package:pet_out/services/notification_service.dart';
import 'package:pet_out/services/sound_service.dart';

class MockStorageService extends Mock implements StorageService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockSoundService extends Mock implements SoundService {}

class FakePet extends Fake implements Pet {}

class FakeActivity extends Fake implements Activity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePet());
    registerFallbackValue(FakeActivity());
    registerFallbackValue(Duration.zero);
  });

  group('PetCubit', () {
    late MockStorageService storage;
    late PetCubit cubit;

    setUp(() {
      storage = MockStorageService();
      cubit = PetCubit(storage);
    });

    tearDown(() async {
      await cubit.close();
    });

    blocTest<PetCubit, PetState>(
      'emits PetLoaded with empty list when no pets',
      build: () {
        when(() => storage.getPets()).thenAnswer((_) async => []);
        when(() => storage.getSelectedPetId()).thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) => cubit.loadPets(),
      expect: () => [
        isA<PetLoading>(),
        isA<PetLoaded>().having((s) => s.pets.isEmpty, 'pets empty', true),
      ],
    );

    blocTest<PetCubit, PetState>(
      'emits PetLoaded with pets and selects first when none selected',
      build: () {
        final pets = [
          Pet(
            id: '1',
            name: 'Luna',
            type: PetType.dog,
            createdAt: DateTime.now(),
          ),
        ];
        when(() => storage.getPets()).thenAnswer((_) async => pets);
        when(() => storage.getSelectedPetId()).thenAnswer((_) async => null);
        when(() => storage.setSelectedPetId(any())).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.loadPets(),
      expect: () => [
        isA<PetLoading>(),
        isA<PetLoaded>().having((s) => s.pets.length, 'pets count', 1),
      ],
    );

    blocTest<PetCubit, PetState>(
      'adds pet and reloads',
      build: () {
        when(() => storage.getPets()).thenAnswer((_) async => []);
        when(() => storage.getSelectedPetId()).thenAnswer((_) async => null);
        when(() => storage.addPet(any())).thenAnswer((_) async {});
        when(() => storage.setSelectedPetId(any())).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) async {
        await cubit.addPet(name: 'Max', type: PetType.dog);
      },
      expect: () => [isA<PetLoading>(), isA<PetLoaded>()],
    );

    blocTest<PetCubit, PetState>(
      'deletes pet and reloads',
      build: () {
        when(() => storage.getPets()).thenAnswer((_) async => []);
        when(() => storage.getSelectedPetId()).thenAnswer((_) async => null);
        when(() => storage.deletePet(any())).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.deletePet('1'),
      expect: () => [isA<PetLoading>(), isA<PetLoaded>()],
    );
  });

  group('TimerCubit', () {
    late MockStorageService storage;
    late MockNotificationService notifications;
    late MockSoundService sound;

    setUp(() {
      storage = MockStorageService();
      notifications = MockNotificationService();
      sound = MockSoundService();

      when(() => storage.addActivity(any())).thenAnswer((_) async {});
      when(() => storage.updateStreak()).thenAnswer((_) async {});
      when(
        () => storage.getActivitiesForPet(any()),
      ).thenAnswer((_) async => []);
      when(() => storage.getCurrentStreak()).thenAnswer((_) async => 0);
      when(
        () => sound.startBarkingRepeat(
          intervalSeconds: any(named: 'intervalSeconds'),
        ),
      ).thenReturn(null);
      when(() => sound.stopBarking()).thenReturn(null);
      when(() => sound.dispose()).thenAnswer((_) async {});
      when(
        () => notifications.startRepeatingNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          interval: any(named: 'interval'),
        ),
      ).thenReturn(null);
      when(() => notifications.stopRepeatingNotification()).thenReturn(null);
      when(
        () => notifications.showTimerRunningNotification(
          title: any(named: 'title'),
          body: any(named: 'body'),
          isOngoing: any(named: 'isOngoing'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => notifications.scheduleTimerEndNotification(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});
    });

    blocTest<TimerCubit, TimerState>(
      'starts timer and emits TimerRunning',
      build: () => TimerCubit(storage, notifications, sound),
      act: (cubit) => cubit.startTimer(
        petId: '1',
        type: ActivityType.walk,
        durationMinutes: 1,
      ),
      expect: () => [
        isA<TimerRunning>().having((s) => s.totalSeconds, 'totalSeconds', 60),
      ],
    );

    blocTest<TimerCubit, TimerState>(
      'pauses and resumes timer',
      build: () => TimerCubit(storage, notifications, sound),
      act: (cubit) {
        cubit.startTimer(
          petId: '1',
          type: ActivityType.walk,
          durationMinutes: 1,
        );
        cubit.pauseTimer();
        cubit.resumeTimer();
      },
      expect: () => [
        isA<TimerRunning>().having((s) => s.isPaused, 'isPaused', false),
        isA<TimerRunning>().having((s) => s.isPaused, 'isPaused', true),
        isA<TimerRunning>().having((s) => s.isPaused, 'isPaused', false),
      ],
    );

    blocTest<TimerCubit, TimerState>(
      'adds minutes to timer',
      build: () => TimerCubit(storage, notifications, sound),
      act: (cubit) {
        cubit.startTimer(
          petId: '1',
          type: ActivityType.walk,
          durationMinutes: 1,
        );
        cubit.addMinutes(5);
      },
      expect: () => [
        isA<TimerRunning>().having((s) => s.totalSeconds, 'totalSeconds', 60),
        isA<TimerRunning>().having((s) => s.totalSeconds, 'totalSeconds', 360),
      ],
    );

    blocTest<TimerCubit, TimerState>(
      'starts in infinite mode and can switch back to finite countdown',
      build: () => TimerCubit(storage, notifications, sound),
      act: (cubit) {
        cubit.startTimer(
          petId: '1',
          type: ActivityType.walk,
          durationMinutes: 30,
          isInfinite: true,
        );
        cubit.setInfiniteMode(false);
      },
      expect: () => [
        isA<TimerRunning>()
            .having((s) => s.isInfinite, 'isInfinite', true)
            .having((s) => s.elapsedSeconds, 'elapsedSeconds', 0),
        isA<TimerRunning>()
            .having((s) => s.isInfinite, 'isInfinite', false)
            .having((s) => s.remainingSeconds, 'remainingSeconds', 1800),
      ],
    );
  });

  group('StatsCubit', () {
    late MockStorageService storage;
    late StatsCubit cubit;

    setUp(() {
      storage = MockStorageService();
      cubit = StatsCubit(storage);
    });

    tearDown(() async {
      await cubit.close();
    });

    blocTest<StatsCubit, StatsState>(
      'emits StatsLoaded with empty data',
      build: () {
        when(
          () => storage.getActivitiesForPet(any()),
        ).thenAnswer((_) async => []);
        when(() => storage.getAchievements()).thenAnswer((_) async => []);
        when(() => storage.getCurrentStreak()).thenAnswer((_) async => 0);
        return cubit;
      },
      act: (cubit) => cubit.loadStats('1'),
      expect: () => [
        isA<StatsLoading>(),
        isA<StatsLoaded>()
            .having((s) => s.activities.isEmpty, 'activities empty', true)
            .having((s) => s.currentStreak, 'streak', 0),
      ],
    );

    blocTest<StatsCubit, StatsState>(
      'calculates activity counts correctly',
      build: () {
        final activities = [
          Activity(
            id: '1',
            petId: '1',
            type: ActivityType.walk,
            startTime: DateTime.now(),
            durationMinutes: 30,
            completed: true,
          ),
          Activity(
            id: '2',
            petId: '1',
            type: ActivityType.walk,
            startTime: DateTime.now(),
            durationMinutes: 30,
            completed: true,
          ),
          Activity(
            id: '3',
            petId: '1',
            type: ActivityType.bath,
            startTime: DateTime.now(),
            durationMinutes: 15,
            completed: true,
          ),
        ];
        when(
          () => storage.getActivitiesForPet('1'),
        ).thenAnswer((_) async => activities);
        when(() => storage.getAchievements()).thenAnswer((_) async => []);
        when(() => storage.getCurrentStreak()).thenAnswer((_) async => 3);
        return cubit;
      },
      act: (cubit) => cubit.loadStats('1'),
      expect: () => [
        isA<StatsLoading>(),
        isA<StatsLoaded>()
            .having((s) => s.activityCounts[ActivityType.walk], 'walks', 2)
            .having((s) => s.activityCounts[ActivityType.bath], 'baths', 1)
            .having((s) => s.activityCounts[ActivityType.food], 'meals', 0)
            .having((s) => s.currentStreak, 'streak', 3),
      ],
    );

    blocTest<StatsCubit, StatsState>(
      'refreshStats reloads data',
      build: () {
        when(
          () => storage.getActivitiesForPet(any()),
        ).thenAnswer((_) async => []);
        when(() => storage.getAchievements()).thenAnswer((_) async => []);
        when(() => storage.getCurrentStreak()).thenAnswer((_) async => 0);
        return cubit;
      },
      act: (cubit) => cubit.refreshStats('1'),
      expect: () => [isA<StatsLoading>(), isA<StatsLoaded>()],
    );
  });
}
