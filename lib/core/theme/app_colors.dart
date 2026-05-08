import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════
/// 🎨 AppColors - Sistema de Diseño Premium PetOut
/// ═══════════════════════════════════════════════════════
///
/// Sistema de colores diseñado para una app premium de mascotas.
/// Palette cálida basada en tonos café/dorado inspirada en perros Beagle.
/// Soporta modo claro y oscuro con colores semánticos consistentes.
class AppColors {
  // ═══════════════════════════════════════════════════════
  // 🟤 Colores Primarios - Marrón Beagle
  // ═══════════════════════════════════════════════════════
  static const Color beagleBrown = Color(0xFFC4813A);
  static const Color beagleBrownLight = Color(0xFFD4A574);
  static const Color beagleBrownDark = Color(0xFFA66A2A);

  // ═══════════════════════════════════════════════════════
  // 🟡 Colores Secundarios - Dorado/Tan
  // ═══════════════════════════════════════════════════════
  static const Color beagleTan = Color(0xFFE8C07D);
  static const Color beagleTanLight = Color(0xFFF5DEB3);
  static const Color beagleCream = Color(0xFFF5EBE0);

  // ═══════════════════════════════════════════════════════
  // ⚫⚪ Neutros
  // ═══════════════════════════════════════════════════════
  static const Color beagleBlack = Color(0xFF1A1A1A);
  static const Color beagleWhite = Color(0xFFFFFFFF);
  static const Color beagleLightBrown = Color(0xFFD4A574);

  // ═══════════════════════════════════════════════════════
  // 🎯 Colores Semánticos
  // ═══════════════════════════════════════════════════════
  static const Color primary = beagleBrown;
  static const Color secondary = beagleTan;
  static const Color background = beagleCream;
  static const Color cardBackground = beagleWhite;
  static const Color textPrimary = beagleBlack;
  static const Color textSecondary = Color(0xFF5A5A5A);
  static const Color textMuted = Color(0xFF8A8A8A);

  // ═══════════════════════════════════════════════════════
  // 🌙 Dark Mode - Paleta Oscura Premium
  // ═══════════════════════════════════════════════════════
  static const Color darkBackground = Color(0xFF0A0A0B);
  static const Color darkSurface = Color(0xFF141417);
  static const Color darkCard = Color(0xFF1C1C1F);
  static const Color darkElevated = Color(0xFF252528);
  static const Color darkAccent = beagleBrown;
  static const Color darkTextPrimary = beagleWhite;
  static const Color darkTextSecondary = Color(0xFFA1A1A6);
  static const Color darkTextMuted = Color(0xFF6E6E73);

  // ═══════════════════════════════════════════════════════
  // 🎬 Gradientes por Actividad
  // ═══════════════════════════════════════════════════════

  // 🚶 Paseo - Marrones cálidos (energía y naturaleza)
  static const LinearGradient walkGradient = LinearGradient(
    colors: [Color(0xFF8B5A2B), Color(0xFFD4A574)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient walkGradientDark = LinearGradient(
    colors: [Color(0xFF6B4423), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🛁 Baño - Azules frescos (limpieza y calma)
  static const LinearGradient bathGradient = LinearGradient(
    colors: [Color(0xFF4A90A4), Color(0xFF7EC8E3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient bathGradientDark = LinearGradient(
    colors: [Color(0xFF2E6B7F), Color(0xFF5BA3B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🍖 Comida - Dorados apetitosos (nutrición)
  static const LinearGradient foodGradient = LinearGradient(
    colors: [Color(0xFFB8860B), Color(0xFFE8C07D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient foodGradientDark = LinearGradient(
    colors: [Color(0xFF8B6914), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════
  // 👤 Avatar y Perfil
  // ═══════════════════════════════════════════════════════
  static const LinearGradient avatarGradient = LinearGradient(
    colors: [beagleBrown, beagleTan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkAvatarGradient = LinearGradient(
    colors: [beagleBrownDark, beagleBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════
  // ✨ Gradientes Decorativos Premium
  // ═══════════════════════════════════════════════════════
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [beagleBrown, beagleTan, beagleCream],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Efecto shimmer para cards premium
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0x00FFFFFF),
      Color(0x33FFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow sutil para elementos destacados
  static const RadialGradient glowGradient = RadialGradient(
    colors: [
      Color(0x33C4813A),
      Color(0x00C4813A),
    ],
    radius: 1.0,
    center: Alignment.center,
  );
}
