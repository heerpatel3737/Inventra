import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.foreground,
        onPrimary: AppColors.surface,
        secondary: AppColors.accentGold,
        onSecondary: AppColors.foreground,
        surface: AppColors.surface,
        onSurface: AppColors.foreground,
        surfaceContainerHighest: AppColors.surfaceSoft,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.accentGold,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.textTheme().titleLarge?.copyWith(
          color: AppColors.accentGold,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: AppTypography.textTheme().bodyMedium?.copyWith(
          color: AppColors.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: AppTypography.textTheme().bodyMedium?.copyWith(
          color: AppColors.mutedForeground,
        ),
        prefixIconColor: AppColors.info,
        suffixIconColor: AppColors.info,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.accentGold),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.surface,
        labelStyle: AppTypography.textTheme().bodyMedium,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
        elevation: 6,
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = lightTheme();

    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.foregroundDark,
        onPrimary: AppColors.backgroundDark,
        secondary: AppColors.accentGold,
        onSecondary: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.foregroundDark,
        surfaceContainerHighest: AppColors.surfaceSoftDark,
        outline: AppColors.borderDark,
        outlineVariant: AppColors.borderDark,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme(
        headingColor: AppColors.foregroundDark,
        bodyColor: AppColors.mutedForegroundDark,
        labelColor: AppColors.accentGold,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.accentGold,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.textTheme(
          headingColor: AppColors.foregroundDark,
          bodyColor: AppColors.mutedForegroundDark,
          labelColor: AppColors.accentGold,
        ).titleLarge?.copyWith(
          color: AppColors.accentGold,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        labelStyle: AppTypography.textTheme(
          headingColor: AppColors.foregroundDark,
          bodyColor: AppColors.mutedForegroundDark,
          labelColor: AppColors.accentGold,
        ).bodyMedium?.copyWith(
          color: AppColors.mutedForegroundDark,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: AppTypography.textTheme(
          headingColor: AppColors.foregroundDark,
          bodyColor: AppColors.mutedForegroundDark,
          labelColor: AppColors.accentGold,
        ).bodyMedium?.copyWith(
          color: AppColors.mutedForegroundDark.withValues(alpha: 0.72),
        ),
        prefixIconColor: AppColors.mutedForegroundDark,
        suffixIconColor: AppColors.mutedForegroundDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.accentGold),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: const BorderSide(color: AppColors.borderDark),
        backgroundColor: AppColors.surfaceDark,
        labelStyle: AppTypography.textTheme(
          headingColor: AppColors.foregroundDark,
          bodyColor: AppColors.mutedForegroundDark,
          labelColor: AppColors.accentGold,
        ).bodyMedium,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borderDark),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceDark,
        textStyle: AppTypography.textTheme(
          headingColor: AppColors.foregroundDark,
          bodyColor: AppColors.mutedForegroundDark,
          labelColor: AppColors.accentGold,
        ).bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
      ),
    );
  }
}
