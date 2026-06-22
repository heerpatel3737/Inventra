import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF9F8F6);
  static const Color foreground = Color(0xFF1A1A1A);
  static const Color mutedBackground = Color(0xFFEBE5DE);
  static const Color mutedForeground = Color(0xFF6C6863);
  static const Color accentGold = Color(0xFFD4AF37);

  static const Color backgroundDark = Color(0xFF12110F);
  static const Color foregroundDark = Color(0xFFF7F3EE);
  static const Color mutedForegroundDark = Color(0xFFD8D0C7);
  static const Color surfaceDark = Color(0xFF1E1A16);
  static const Color surfaceSoftDark = Color(0xFF28241F);
  static const Color borderDark = Color(0xFF3F372F);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF3EFEA);
  static const Color border = Color(0xFFD9D3CC);
  static const Color info = Color(0xFF7B8AA3);
  static const Color success = Color(0xFF2E7D57);
  static const Color warning = Color(0xFFC2862E);
  static const Color danger = Color(0xFFB65151);

  static const List<Color> heroGradient = [
    Color(0xFFFAF8F3),
    Color(0xFFF0E9DF),
  ];

  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8F5EF),
  ];

  // Backward-compatible aliases for existing widgets.
  static const Color primary = foreground;
  static const Color body = mutedForeground;
  static const Color title = foreground;
  static const List<Color> gradientIndigo = heroGradient;
}

