import 'package:flutter/material.dart';

/// App palette: a clean white theme with an unusual-yet-pleasant azure accent.
/// High contrast and saturated, distinct category hues keep markers easy to
/// tell apart for older users.
class AppColors {
  AppColors._();

  // Brand / accents.
  static const Color primary = Color(0xFF0A6CCB); // deep azure
  static const Color primaryDark = Color(0xFF075299);
  static const Color accent = Color(0xFF18B6E6); // bright cyan-blue
  static const Color accentSoft = Color(0xFFE3F3FB);

  // Surfaces.
  static const Color background = Color(0xFFF6FAFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEDF3F8);

  // Text.
  static const Color textPrimary = Color(0xFF12222F);
  static const Color textSecondary = Color(0xFF53697A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Feedback.
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFE2533B);
  static const Color border = Color(0xFFD7E3EC);

  // Category colors (one distinct hue per water-point type).
  static const Color categoryDrinkingWater = Color(0xFF0A6CCB); // Бьювет
  static const Color categoryWaterPoint = Color(0xFF0E9C8A); // Водокачка
  static const Color categoryVending = Color(0xFF7A5AF0); // Автомат
  static const Color categoryOther = Color(0xFF53697A);
}
