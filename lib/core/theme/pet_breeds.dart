import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════
/// 🎨 PetBreeds - Sistema de Temas por Raza
/// ═══════════════════════════════════════════════════════
///
/// Sistema de temas visuales basados en diferentes
/// razas de mascotas con paletas de colores únicas.
///
/// Usar: PetBreed.of(context).currentBreed
class PetBreeds {
  // Lista de todas las razas/temas disponibles
  static final List<PetBreed> allBreeds = [
    // 🐕 Perros
    PetBreed(
      id: 'beagle',
      name: 'Beagle',
      emoji: '🐕',
      description: 'El clásico café/dorado',
      colors: AppColorsBeagle(),
    ),
    PetBreed(
      id: 'husky',
      name: 'Husky',
      emoji: '🐺',
      description: 'Azul ártico y blanco',
      colors: AppColorsHusky(),
    ),
    PetBreed(
      id: 'golden',
      name: 'Golden Retriever',
      emoji: '🦮',
      description: 'Dorado cálido y crema',
      colors: AppColorsGolden(),
    ),
    PetBreed(
      id: 'pastor',
      name: 'Pastor Alemán',
      emoji: '🐕‍🦺',
      description: ' Negro y fuego',
      colors: AppColorsPastor(),
    ),
    PetBreed(
      id: 'bulldog',
      name: 'Bulldog',
      emoji: '🐶',
      description: 'Grises elegantes',
      colors: AppColorsBulldog(),
    ),
    PetBreed(
      id: 'dalmata',
      name: 'Dálmata',
      emoji: '🐩',
      description: 'Blanco y negro puro',
      colors: AppColorsDalmata(),
    ),
    PetBreed(
      id: 'kiltro',
      name: 'Kiltro',
      emoji: '🐾',
      description: 'Tierra, parque y barrio',
      colors: AppColorsJungla(),
    ),
    PetBreed(
      id: 'mezcla_chica',
      name: 'Mezcla pequeña',
      emoji: '🐶',
      description: 'Suave y liviano',
      colors: AppColorsGolden(),
    ),
    PetBreed(
      id: 'mezcla_grande',
      name: 'Mezcla grande',
      emoji: '🐕',
      description: 'Firme y tranquilo',
      colors: AppColorsBulldog(),
    ),
    // 🐈 Gatos
    PetBreed(
      id: 'siames',
      name: 'Siamés',
      emoji: '🐱',
      description: 'Azul ojos y crema',
      colors: AppColorsSiames(),
    ),
    PetBreed(
      id: 'persa',
      name: 'Persa',
      emoji: '😺',
      description: 'Rosa y dorado suave',
      colors: AppColorsPersa(),
    ),
    // 🌟 Especiales
    PetBreed(
      id: 'arcobal',
      name: 'Arcoíris',
      emoji: '🦄',
      description: 'Colores vibrantes',
      colors: AppColorsArcobal(),
    ),
    PetBreed(
      id: 'nocturn',
      name: 'Nocturn',
      emoji: '🌙',
      description: 'Dark mode mejorado',
      colors: AppColorsNocturn(),
    ),
    // 🌿 Naturaleza
    PetBreed(
      id: 'jungla',
      name: 'Jungla',
      emoji: '🌿',
      description: 'Verdes naturales',
      colors: AppColorsJungla(),
    ),
    PetBreed(
      id: 'oceano',
      name: 'Océano',
      emoji: '🌊',
      description: 'Azules acuáticos',
      colors: AppColorsOceano(),
    ),
  ];

  static PetBreed byId(String id) {
    return allBreeds.firstWhere(
      (breed) => breed.id == id,
      orElse: () => allBreeds.first,
    );
  }
}

/// Modelo de Raza/Tema
class PetBreed {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final AppBreedColors colors;

  const PetBreed({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.colors,
  });
}

/// Colores de cada raza
class AppBreedColors {
  // Primary colors
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;

  // Secondary colors
  final Color secondary;
  final Color secondaryLight;

  // Backgrounds
  final Color background;
  final Color cardBackground;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Dark mode
  final Color darkBackground;
  final Color darkSurface;
  final Color darkCard;
  final Color darkElevated;
  final Color darkTextPrimary;
  final Color darkTextSecondary;
  final Color darkTextMuted;

  // Gradients
  final LinearGradient walkGradient;
  final LinearGradient walkGradientDark;
  final LinearGradient bathGradient;
  final LinearGradient bathGradientDark;
  final LinearGradient foodGradient;
  final LinearGradient foodGradientDark;
  final LinearGradient avatarGradient;
  final LinearGradient darkAvatarGradient;

  const AppBreedColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.background,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkCard,
    required this.darkElevated,
    required this.darkTextPrimary,
    required this.darkTextSecondary,
    required this.darkTextMuted,
    required this.walkGradient,
    required this.walkGradientDark,
    required this.bathGradient,
    required this.bathGradientDark,
    required this.foodGradient,
    required this.foodGradientDark,
    required this.avatarGradient,
    required this.darkAvatarGradient,
  });
}

/// ═══════════════════════════════════════════════════════
// 🐕 BEAGLE - Café/Dorado Original
/// ═══════════════════════════════════════════════════════
class AppColorsBeagle extends AppBreedColors {
  AppColorsBeagle()
    : super(
        primary: Color(0xFFC4813A),
        primaryLight: Color(0xFFD4A574),
        primaryDark: Color(0xFFA66A2A),
        secondary: Color(0xFFE8C07D),
        secondaryLight: Color(0xFFF5DEB3),
        background: Color(0xFFF5EBE0),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF1A1A1A),
        textSecondary: Color(0xFF5A5A5A),
        textMuted: Color(0xFF8A8A8A),
        darkBackground: Color(0xFF0A0A0B),
        darkSurface: Color(0xFF141417),
        darkCard: Color(0xFF1C1C1F),
        darkElevated: Color(0xFF252528),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFA1A1A6),
        darkTextMuted: Color(0xFF6E6E73),
        walkGradient: const LinearGradient(
          colors: [Color(0xFF8B5A2B), Color(0xFFD4A574)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF6B4423), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF4A90A4), Color(0xFF7EC8E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF2E6B7F), Color(0xFF5BA3B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFFB8860B), Color(0xFFE8C07D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFF8B6914), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFFC4813A), Color(0xFFE8C07D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFFA66A2A), Color(0xFFC4813A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🐺 HUSKY - Azul Ártico
/// ═══════════════════════════════════════════════════════
class AppColorsHusky extends AppBreedColors {
  AppColorsHusky()
    : super(
        primary: Color(0xFF4A90D9),
        primaryLight: Color(0xFF7AB3F0),
        primaryDark: Color(0xFF2E6BA8),
        secondary: Color(0xFFE8F4FD),
        secondaryLight: Color(0xFFF5FBFF),
        background: Color(0xFFF0F6FC),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF1A2A3A),
        textSecondary: Color(0xFF4A5A6A),
        textMuted: Color(0xFF8A9AB0),
        darkBackground: Color(0xFF0A0F14),
        darkSurface: Color(0xFF141824),
        darkCard: Color(0xFF1C2430),
        darkElevated: Color(0xFF252C3A),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFA1B0C0),
        darkTextMuted: Color(0xFF6A7A8A),
        walkGradient: const LinearGradient(
          colors: [Color(0xFF2E6BA8), Color(0xFF7AB3F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF1E4B78), Color(0xFF4A90D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF1E4B78), Color(0xFF4A90D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF152A45), Color(0xFF2E6BA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFF4A90D9), Color(0xFF7AB3F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFF2E6BA8), Color(0xFF4A90D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFF4A90D9), Color(0xFF7AB3F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFF2E6BA8), Color(0xFF4A90D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🦮 GOLDEN RETRIEVER - Dorado Cálido
/// ═══════════════════════════════════════════════════════
class AppColorsGolden extends AppBreedColors {
  AppColorsGolden()
    : super(
        primary: Color(0xFFD4A020),
        primaryLight: Color(0xFFE8C050),
        primaryDark: Color(0xFFB8860B),
        secondary: Color(0xFFFFF0D0),
        secondaryLight: Color(0xFFFFF8E8),
        background: Color(0xFFFFF9F0),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF2A2000),
        textSecondary: Color(0xFF5A4A1A),
        textMuted: Color(0xFF8A7A4A),
        darkBackground: Color(0xFF0F0A00),
        darkSurface: Color(0xFF1A1408),
        darkCard: Color(0xFF252010),
        darkElevated: Color(0xFF302818),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFE8D888),
        darkTextMuted: Color(0xFFA89858),
        walkGradient: const LinearGradient(
          colors: [Color(0xFFB8860B), Color(0xFFE8C050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF8B6914), Color(0xFFD4A020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF8B6914), Color(0xFFD4A020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF6B5010), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFFD4A020), Color(0xFFE8C050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFFB8860B), Color(0xFFD4A020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFFD4A020), Color(0xFFE8C050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFFB8860B), Color(0xFFD4A020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🐕‍🦺 PASTOR ALEMAN - Negro y Fuego
/// ═══════════════════════════════════════════════════════
class AppColorsPastor extends AppBreedColors {
  AppColorsPastor()
    : super(
        primary: Color(0xFFE05020),
        primaryLight: Color(0xFFFF7050),
        primaryDark: Color(0xFFB83010),
        secondary: Color(0xFFF0E0D0),
        secondaryLight: Color(0xFFFFF0E8),
        background: Color(0xFFF8F4F0),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF1A1000),
        textSecondary: Color(0xFF5A4030),
        textMuted: Color(0xFF8A7060),
        darkBackground: Color(0xFF0A0800),
        darkSurface: Color(0xFF141008),
        darkCard: Color(0xFF1C1810),
        darkElevated: Color(0xFF252018),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFE8C0A0),
        darkTextMuted: Color(0xFFA89070),
        walkGradient: const LinearGradient(
          colors: [Color(0xFFB83010), Color(0xFFFF7050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF8B2008), Color(0xFFE05020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF8B2008), Color(0xFFE05020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF601808), Color(0xFFB83010)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFFE05020), Color(0xFFFF7050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFFB83010), Color(0xFFE05020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFFE05020), Color(0xFFFF7050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFFB83010), Color(0xFFE05020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🐶 BULLDOG - Grises Elegantes
/// ═══════════════════════════════════════════════════════
class AppColorsBulldog extends AppBreedColors {
  AppColorsBulldog()
    : super(
        primary: Color(0xFF6A6A7A),
        primaryLight: Color(0xFF9A9AAA),
        primaryDark: Color(0xFF4A4A5A),
        secondary: Color(0xFFE8E8F0),
        secondaryLight: Color(0xFFF5F5FA),
        background: Color(0xFFF0F0F5),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF2A2A3A),
        textSecondary: Color(0xFF5A5A6A),
        textMuted: Color(0xFF8A8A9A),
        darkBackground: Color(0xFF0A0A10),
        darkSurface: Color(0xFF14141A),
        darkCard: Color(0xFF1C1C22),
        darkElevated: Color(0xFF25252A),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFB0B0C0),
        darkTextMuted: Color(0xFF707080),
        walkGradient: const LinearGradient(
          colors: [Color(0xFF4A4A5A), Color(0xFF9A9AAA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF3A3A4A), Color(0xFF6A6A7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF3A3A4A), Color(0xFF6A6A7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF2A2A3A), Color(0xFF4A4A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFF6A6A7A), Color(0xFF9A9AAA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFF4A4A5A), Color(0xFF6A6A7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFF6A6A7A), Color(0xFF9A9AAA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFF4A4A5A), Color(0xFF6A6A7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🐩 DALMATA - Blanco y Negro
/// ═══════════════════════════════════════════════════════
class AppColorsDalmata extends AppBreedColors {
  AppColorsDalmata()
    : super(
        primary: Color(0xFF1A1A2A),
        primaryLight: Color(0xFF4A4A5A),
        primaryDark: Color(0xFF101018),
        secondary: Color(0xFFF8F8F8),
        secondaryLight: Color(0xFFFFFFFF),
        background: Color(0xFFFAFAFA),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF1A1A1A),
        textSecondary: Color(0xFF4A4A4A),
        textMuted: Color(0xFF8A8A8A),
        darkBackground: Color(0xFF050508),
        darkSurface: Color(0xFF0A0A0F),
        darkCard: Color(0xFF101015),
        darkElevated: Color(0xFF15151A),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFC0C0C0),
        darkTextMuted: Color(0xFF707070),
        walkGradient: const LinearGradient(
          colors: [Color(0xFF1A1A2A), Color(0xFF4A4A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF101018), Color(0xFF1A1A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF101018), Color(0xFF1A1A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF080810), Color(0xFF101018)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFF1A1A2A), Color(0xFF4A4A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFF101018), Color(0xFF1A1A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFF1A1A2A), Color(0xFF4A4A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFF101018), Color(0xFF1A1A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🐱 SIAMÉS - Azul Ojos
/// ═══════════════════════════════════════════════════════
class AppColorsSiames extends AppBreedColors {
  AppColorsSiames()
    : super(
        primary: Color(0xFF8B9DCF),
        primaryLight: Color(0xFFBBC4E8),
        primaryDark: Color(0xFF6A7DB0),
        secondary: Color(0xFFF5F0E8),
        secondaryLight: Color(0xFFFFF8F0),
        background: Color(0xFFFAF8F5),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF2A3040),
        textSecondary: Color(0xFF5A6070),
        textMuted: Color(0xFF8A909A),
        darkBackground: Color(0xFF0F1218),
        darkSurface: Color(0xFF1A1F28),
        darkCard: Color(0xFF222832),
        darkElevated: Color(0xFF2C3340),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFB0B8C0),
        darkTextMuted: Color(0xFF707880),
        walkGradient: const LinearGradient(
          colors: [Color(0xFF6A7DB0), Color(0xFFBBC4E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF5060A0), Color(0xFF8B9DCF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF5060A0), Color(0xFF8B9DCF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF405080), Color(0xFF6A7DB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFF8B9DCF), Color(0xFFBBC4E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFF6A7DB0), Color(0xFF8B9DCF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFF8B9DCF), Color(0xFFBBC4E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFF6A7DB0), Color(0xFF8B9DCF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 😺 PERSA - Rosa Suave
/// ═══════════════════════════════════════════════════════
class AppColorsPersa extends AppBreedColors {
  AppColorsPersa()
    : super(
        primary: Color(0xFFE8A0B8),
        primaryLight: Color(0xFFFFC0D8),
        primaryDark: Color(0xFFD08098),
        secondary: Color(0xFFFFF0F4),
        secondaryLight: Color(0xFFFFF8FA),
        background: Color(0xFFFFF8FA),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF3A2030),
        textSecondary: Color(0xFF6A4050),
        textMuted: Color(0xFF9A7080),
        darkBackground: Color(0xFF140810),
        darkSurface: Color(0xFF1C1018),
        darkCard: Color(0xFF241520),
        darkElevated: Color(0xFF2C1828),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFF0D0E0),
        darkTextMuted: Color(0xFFB090A0),
        walkGradient: const LinearGradient(
          colors: [Color(0xFFD08098), Color(0xFFFFC0D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFFB06078), Color(0xFFE8A0B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFFB06078), Color(0xFFE8A0B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF905060), Color(0xFFD08098)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFFE8A0B8), Color(0xFFFFC0D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFFD08098), Color(0xFFE8A0B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFFE8A0B8), Color(0xFFFFC0D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFFD08098), Color(0xFFE8A0B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🦄 ARCOÍRIS - Colores Vibrantes
/// ═══════════════════════════════════════════════════════
class AppColorsArcobal extends AppBreedColors {
  AppColorsArcobal()
    : super(
        primary: Color(0xFFE040FB),
        primaryLight: Color(0xFFFF80FC),
        primaryDark: Color(0xFFAA00DD),
        secondary: Color(0xFF80D8FF),
        secondaryLight: Color(0xFFB4F0FF),
        background: Color(0xFFF8F0FF),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF2A0050),
        textSecondary: Color(0xFF5A20A0),
        textMuted: Color(0xFF9050C0),
        darkBackground: Color(0xFF08000F),
        darkSurface: Color(0xFF100018),
        darkCard: Color(0xFF180022),
        darkElevated: Color(0xFF20002C),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFF0C0FF),
        darkTextMuted: Color(0xFFB080C0),
        walkGradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFFCC5050), Color(0xFFDDAA00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF6BFF6B), Color(0xFF6BFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF50CC50), Color(0xFF50CCCC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFF6B6BFF), Color(0xFFFF6BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFF5050DD), Color(0xFFDD50DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFFE040FB), Color(0xFF80D8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFFAA00DD), Color(0xFF40C0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🌙 NOCTURN - Dark Mode Mejorado
/// ═══════════════════════════════════════════════════════
class AppColorsNocturn extends AppBreedColors {
  AppColorsNocturn()
    : super(
        primary: Color(0xFFBB86FC),
        primaryLight: Color(0xFFDEA8FF),
        primaryDark: Color(0xFF9A50E0),
        secondary: Color(0xFF03DAC6),
        secondaryLight: Color(0xFF64FFEE),
        background: Color(0xFF121212),
        cardBackground: Color(0xFF1E1E1E),
        textPrimary: Color(0xFFFFFFFF),
        textSecondary: Color(0xFFB0B0B0),
        textMuted: Color(0xFF707070),
        darkBackground: Color(0xFF000000),
        darkSurface: Color(0xFF0A0A0A),
        darkCard: Color(0xFF141414),
        darkElevated: Color(0xFF1A1A1A),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFE0E0E0),
        darkTextMuted: Color(0xFF808080),
        walkGradient: const LinearGradient(
          colors: [Color(0xFF9A50E0), Color(0xFFBB86FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF7030B0), Color(0xFF9A50E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF018786), Color(0xFF03DAC6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF015655), Color(0xFF018786)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFFBB86FC), Color(0xFFDEA8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFF9A50E0), Color(0xFFBB86FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFFBB86FC), Color(0xFF03DAC6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFF9A50E0), Color(0xFF018786)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🌿 JUNGLA - Verdes Naturales
/// ═══════════════════════════════════════════════════════
class AppColorsJungla extends AppBreedColors {
  AppColorsJungla()
    : super(
        primary: Color(0xFF2E7D32),
        primaryLight: Color(0xFF60AD3B),
        primaryDark: Color(0xFF1B5E20),
        secondary: Color(0xFFC8E6C9),
        secondaryLight: Color(0xFFE8F5E9),
        background: Color(0xFFF1F8E9),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF1B3A1B),
        textSecondary: Color(0xFF4A6A4A),
        textMuted: Color(0xFF7A9A7A),
        darkBackground: Color(0xFF050F05),
        darkSurface: Color(0xFF0A1A0A),
        darkCard: Color(0xFF122012),
        darkElevated: Color(0xFF1A2C1A),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFC0E0C0),
        darkTextMuted: Color(0xFF80A080),
        walkGradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF60AD3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF144018), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF144018), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF0F2A10), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF60AD3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF60AD3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}

/// ═══════════════════════════════════════════════════════
// 🌊 OCÉANO - Azules Acuáticos
/// ═══════════════════════════════════════════════════════
class AppColorsOceano extends AppBreedColors {
  AppColorsOceano()
    : super(
        primary: Color(0xFF0277BD),
        primaryLight: Color(0xFF03A5D4),
        primaryDark: Color(0xFF01579B),
        secondary: Color(0xFFE0F7FA),
        secondaryLight: Color(0xFFF0FAFF),
        background: Color(0xFFF0F9FF),
        cardBackground: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF012A40),
        textSecondary: Color(0xFF2A5060),
        textMuted: Color(0xFF5A8090),
        darkBackground: Color(0xFF010A10),
        darkSurface: Color(0xFF021420),
        darkCard: Color(0xFF031828),
        darkElevated: Color(0xFF042030),
        darkTextPrimary: Color(0xFFFFFFFF),
        darkTextSecondary: Color(0xFFC0E0F0),
        darkTextMuted: Color(0xFF70A0B0),
        walkGradient: const LinearGradient(
          colors: [Color(0xFF01579B), Color(0xFF03A5D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        walkGradientDark: const LinearGradient(
          colors: [Color(0xFF014070), Color(0xFF0277BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradient: const LinearGradient(
          colors: [Color(0xFF014070), Color(0xFF0277BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        bathGradientDark: const LinearGradient(
          colors: [Color(0xFF012A50), Color(0xFF01579B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradient: const LinearGradient(
          colors: [Color(0xFF0277BD), Color(0xFF03A5D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foodGradientDark: const LinearGradient(
          colors: [Color(0xFF01579B), Color(0xFF0277BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        avatarGradient: const LinearGradient(
          colors: [Color(0xFF0277BD), Color(0xFF03A5D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        darkAvatarGradient: const LinearGradient(
          colors: [Color(0xFF01579B), Color(0xFF0277BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}
