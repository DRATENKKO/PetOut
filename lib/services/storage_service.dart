import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/activity.dart';
import '../models/achievement.dart';

class StorageService {
  static const String _petsKey = 'pets';
  static const String _activitiesKey = 'activities';
  static const String _achievementsKey = 'achievements';
  static const String _selectedPetKey = 'selectedPet';
  static const String _onboardingKey = 'onboardingComplete';
  static const String _streakKey = 'currentStreak';
  static const String _lastActivityDateKey = 'lastActivityDate';
  static const String _localeKey = 'locale';
  static const String _selectedBreedThemeKey = 'selectedBreedThemeId';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Pet>> getPets() async {
    final String? petsJson = _prefs.getString(_petsKey);
    if (petsJson == null) return [];
    final List<dynamic> petsList = jsonDecode(petsJson);
    return petsList
        .map((e) => Pet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePets(List<Pet> pets) async {
    final String petsJson = jsonEncode(pets.map((e) => e.toJson()).toList());
    await _prefs.setString(_petsKey, petsJson);
  }

  Future<void> addPet(Pet pet) async {
    final pets = await getPets();
    pets.add(pet);
    await savePets(pets);
  }

  Future<void> updatePet(Pet pet) async {
    final pets = await getPets();
    final index = pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      pets[index] = pet;
      await savePets(pets);
    }
  }

  Future<void> deletePet(String petId) async {
    final pets = await getPets();
    pets.removeWhere((p) => p.id == petId);
    await savePets(pets);
  }

  Future<List<Activity>> getActivities() async {
    final String? activitiesJson = _prefs.getString(_activitiesKey);
    if (activitiesJson == null) return [];
    final List<dynamic> activitiesList = jsonDecode(activitiesJson);
    return activitiesList
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveActivities(List<Activity> activities) async {
    final String activitiesJson = jsonEncode(
      activities.map((e) => e.toJson()).toList(),
    );
    await _prefs.setString(_activitiesKey, activitiesJson);
  }

  Future<void> addActivity(Activity activity) async {
    final activities = await getActivities();
    activities.add(activity);
    await saveActivities(activities);
  }

  Future<List<Activity>> getActivitiesForPet(String petId) async {
    final activities = await getActivities();
    return activities.where((a) => a.petId == petId).toList();
  }

  Future<List<Activity>> getActivitiesForToday(String petId) async {
    final activities = await getActivitiesForPet(petId);
    final now = DateTime.now();
    return activities
        .where(
          (a) =>
              a.startTime.year == now.year &&
              a.startTime.month == now.month &&
              a.startTime.day == now.day &&
              a.completed,
        )
        .toList();
  }

  Future<List<Achievement>> getAchievements() async {
    final String? achievementsJson = _prefs.getString(_achievementsKey);
    if (achievementsJson == null) return _getDefaultAchievements();
    final List<dynamic> achievementsList = jsonDecode(achievementsJson);
    return achievementsList
        .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<Achievement> _getDefaultAchievements() {
    return const [
      Achievement(
        id: 'first_walk',
        title: 'Primer Paseo',
        emoji: '🏅',
        description: 'Completaste tu primer paseo',
      ),
      Achievement(
        id: 'first_bath',
        title: 'Primer Baño',
        emoji: '🛁',
        description: 'Completaste tu primer baño',
      ),
      Achievement(
        id: 'first_meal',
        title: 'Primera Comida',
        emoji: '🍖',
        description: 'Registraste tu primera comida',
      ),
      Achievement(
        id: 'streak_3',
        title: '3 Días Seguidos',
        emoji: '🔥',
        description: '3 días seguidos de actividades',
      ),
      Achievement(
        id: 'streak_7',
        title: '7 Días Seguidos',
        emoji: '🔥',
        description: '7 días seguidos de actividades',
      ),
      Achievement(
        id: 'streak_30',
        title: 'Mes de Amor',
        emoji: '💎',
        description: '30 días seguidos de actividades',
      ),
      Achievement(
        id: 'pro_bather',
        title: 'Bañista Pro',
        emoji: '🛁',
        description: '10 baños completados',
      ),
      Achievement(
        id: 'food_lover',
        title: 'Amante de la Comida',
        emoji: '🍖',
        description: '50 comidas registradas',
      ),
      Achievement(
        id: 'walker',
        title: 'Caminante',
        emoji: '🐕',
        description: '20 paseos completados',
      ),
    ];
  }

  Future<void> saveAchievements(List<Achievement> achievements) async {
    final String achievementsJson = jsonEncode(
      achievements.map((e) => e.toJson()).toList(),
    );
    await _prefs.setString(_achievementsKey, achievementsJson);
  }

  Future<void> unlockAchievement(String achievementId) async {
    final achievements = await getAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && !achievements[index].unlocked) {
      achievements[index] = achievements[index].copyWith(
        unlocked: true,
        unlockedAt: DateTime.now(),
      );
      await saveAchievements(achievements);
    }
  }

  Future<String?> getSelectedPetId() async {
    return _prefs.getString(_selectedPetKey);
  }

  Future<void> setSelectedPetId(String petId) async {
    await _prefs.setString(_selectedPetKey, petId);
  }

  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_onboardingKey, complete);
  }

  Future<int> getCurrentStreak() async {
    return _prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> updateStreak() async {
    final lastDateStr = _prefs.getString(_lastActivityDateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDateStr == null) {
      await _prefs.setInt(_streakKey, 1);
      await _prefs.setString(_lastActivityDateKey, today.toIso8601String());
      return;
    }

    final lastDate = DateTime.parse(lastDateStr);
    final lastDateDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

    if (lastDateDay == today) {
      return;
    }

    final difference = today.difference(lastDateDay).inDays;

    if (difference == 1) {
      final currentStreak = _prefs.getInt(_streakKey) ?? 0;
      await _prefs.setInt(_streakKey, currentStreak + 1);
    } else {
      await _prefs.setInt(_streakKey, 1);
    }

    await _prefs.setString(_lastActivityDateKey, today.toIso8601String());
  }

  Future<String> getLocale() async {
    return _prefs.getString(_localeKey) ?? 'es';
  }

  Future<void> setLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }

  Future<String?> getSelectedBreedThemeId() async {
    return _prefs.getString(_selectedBreedThemeKey);
  }

  Future<void> setSelectedBreedThemeId(String breedId) async {
    await _prefs.setString(_selectedBreedThemeKey, breedId);
  }
}
