import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/pet_breeds.dart';
import 'cubit/pet_cubit.dart';
import 'cubit/timer_cubit.dart';
import 'cubit/stats_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

class PetOutApp extends StatefulWidget {
  final StorageService storageService;
  final NotificationService notificationService;
  final SoundService soundService;

  const PetOutApp({
    super.key,
    required this.storageService,
    required this.notificationService,
    required this.soundService,
  });

  @override
  State<PetOutApp> createState() => _PetOutAppState();
}

class _PetOutAppState extends State<PetOutApp> {
  bool _showOnboarding = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _showOnboarding = !(await widget.storageService.isOnboardingComplete());
    setState(() => _isInitialized = true);
  }

  void _onOnboardingComplete() {
    widget.storageService.setOnboardingComplete(true);
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PetCubit>(
          create: (context) => PetCubit(widget.storageService)..loadPets(),
        ),
        BlocProvider<TimerCubit>(
          create: (context) => TimerCubit(
            widget.storageService,
            widget.notificationService,
            widget.soundService,
          ),
        ),
        BlocProvider<StatsCubit>(
          create: (context) => StatsCubit(widget.storageService),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(widget.storageService)..loadTheme(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final selectedBreedId = themeState is ThemeLoaded
              ? themeState.selectedBreedId
              : 'beagle';
          final breedColors = PetBreeds.byId(selectedBreedId).colors;

          return MaterialApp(
            title: 'PetOut',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightThemeFor(breedColors),
            darkTheme: AppTheme.darkThemeFor(breedColors),
            themeMode: ThemeMode.system,
            home: _isInitialized
                ? (_showOnboarding
                      ? OnboardingScreen(onComplete: _onOnboardingComplete)
                      : const HomeScreen())
                : const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }
}
