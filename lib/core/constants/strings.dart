class Strings {
  static const String appName = 'PetOut';

  static const Map<String, String> greetings = {
    'morning': 'Buenos días',
    'afternoon': 'Buenas tardes',
    'evening': 'Buenas noches',
  };

  static const Map<String, String> emojis = {
    'morning': '☀️',
    'afternoon': '🌤️',
    'evening': '🌙',
  };

  static const List<String> onboardingTitles = [
    '¡Bienvenido a PetOut!',
    'Temporizadores Visuales',
    'Manten a tu mascota feliz',
  ];

  static const List<String> onboardingDescriptions = [
    'La app definitiva para cuidar a tu mascota de apartamento',
    'Configura timers para paseos, baños y comidas',
    'Registra actividades y gana achievements',
  ];

  static const List<String> activityNames = [
    'PASEO',
    'BAÑO',
    'COMIDA',
  ];

  static const List<String> activityEmojis = [
    '🐕',
    '🛁',
    '🍖',
  ];

  static const Map<String, int> defaultDurations = {
    'walk': 30,
    'bath': 15,
    'food': 5,
  };

  static const List<String> achievementIds = [
    'first_walk',
    'first_bath',
    'first_meal',
    'streak_3',
    'streak_7',
    'streak_30',
    'pro_bather',
    'food_lover',
    'walker',
  ];

  static const Map<String, Map<String, String>> achievements = {
    'first_walk': {'title': 'Primer Paseo', 'emoji': '🏅', 'description': 'Completaste tu primer paseo'},
    'first_bath': {'title': 'Primer Baño', 'emoji': '🛁', 'description': 'Completaste tu primer baño'},
    'first_meal': {'title': 'Primera Comida', 'emoji': '🍖', 'description': 'Registraste tu primera comida'},
    'streak_3': {'title': '3 Días Seguidos', 'emoji': '🔥', 'description': '3 días seguidos de actividades'},
    'streak_7': {'title': '7 Días Seguidos', 'emoji': '🔥', 'description': '7 días seguidos de actividades'},
    'streak_30': {'title': 'Mes de Amor', 'emoji': '💎', 'description': '30 días seguidos de actividades'},
    'pro_bather': {'title': 'Bañista Pro', 'emoji': '🛁', 'description': '10 baños completados'},
    'food_lover': {'title': 'Amante de la Comida', 'emoji': '🍖', 'description': '50 comidas registradas'},
    'walker': {'title': 'Caminante', 'emoji': '🐕', 'description': '20 paseos completados'},
  };

  static const String localeSpanish = 'es';
  static const String localeEnglish = 'en';
}
