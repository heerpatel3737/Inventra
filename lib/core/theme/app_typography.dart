import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTypography {
  static TextTheme textTheme({
    Color? headingColor,
    Color? bodyColor,
    Color? labelColor,
  }) {
    final titleColor = headingColor ?? AppColors.foreground;
    final bodyColorValue = bodyColor ?? AppColors.mutedForeground;
    final labelColorValue = labelColor ?? AppColors.info;

    return TextTheme(
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 38,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: titleColor,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: titleColor,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: titleColor,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: titleColor,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: titleColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 14,
        height: 1.6,
        color: bodyColorValue,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 12.5,
        letterSpacing: 0.3,
        height: 1.5,
        color: bodyColorValue,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: labelColorValue,
      ),
    );
  }
}
