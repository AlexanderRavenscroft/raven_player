import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_colors.dart';
import 'package:raven_player/core/theme/app_typography.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,

    fontFamily: AppTypography.primaryFont,
    textTheme: AppTypography.textTheme,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      surface: AppColors.lightSurface,
      surfaceContainer: AppColors.lightSurfaceContainer,
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,

    fontFamily: AppTypography.primaryFont,
    textTheme: AppTypography.textTheme,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      surface: AppColors.darkSurface,
      surfaceContainer: AppColors.darkSurfaceContainer,
    ),
  );
}
