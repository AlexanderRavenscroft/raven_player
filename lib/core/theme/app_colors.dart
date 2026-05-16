import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';

class AppColors {
  // Global Thme Colors
  static const Color primary = Color(0xff311E83);
  static const Color success = Color(0xff34C759);
  static const Color error = Color(0xffF14141);
  static const Color secondary = Color(0xffffbf00);

  // Light Theme Colors
  static const Color lightTextPrimary = Color(0xffffffff);
  static const Color lightTextSurface = Color(0xff000000);
  static const Color lightBackgroundPrimary = Color(0xffededed);
  static const Color lightBackgroundSecondary = Color(0xffbfc2ca);

  // Dark Theme Colors
  static const Color darkTextPrimary = Color(0xffffffff);
  static const Color darkTextSurface = Color(0xffffffff);
  static const Color darkBackgroundPrimary = Color(0xff121212);
  static const Color darkBackgroundSecondary = Color(0xff35383f);
}

//* Light Theme
ThemeData lightMode = ThemeData(
  textTheme: AppTypography.textTheme,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.success,
    error: AppColors.error,

    // Texts
    onPrimary: AppColors.lightTextPrimary,
    onSurface: AppColors.lightTextSurface,
    onSurfaceVariant: AppColors.lightTextSurface,

    // Background & Cards
    surface: AppColors.lightBackgroundPrimary,
    surfaceContainer: AppColors.lightBackgroundSecondary,
  ),
);

//* Dark Theme
ThemeData darkMode = ThemeData(
  textTheme: AppTypography.textTheme,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.success,
    error: AppColors.error,

    // Texts
    onPrimary: AppColors.darkTextPrimary,
    onSurface: AppColors.darkTextSurface,
    onSurfaceVariant: AppColors.darkTextSurface,

    // Background & Cards
    surface: AppColors.darkBackgroundPrimary,
    surfaceContainer: AppColors.darkBackgroundSecondary,
  ),
);
