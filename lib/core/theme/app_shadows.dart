import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x1F3A2F1A),
      blurRadius: 28,
      spreadRadius: -8,
      offset: Offset(0, 14),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x2A3B2E1D),
      blurRadius: 34,
      spreadRadius: -10,
      offset: Offset(0, 18),
    ),
    BoxShadow(
      color: Color(0x14D4AF37),
      blurRadius: 20,
      spreadRadius: -8,
      offset: Offset(0, 6),
    ),
  ];

  static const LinearGradient subtleOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x88FFFFFF),
      Color(0x22FFFFFF),
    ],
  );

  static Border border() => Border.all(color: AppColors.border);
}

