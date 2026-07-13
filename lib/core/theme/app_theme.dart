import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_colors.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/core/theme/app_typography.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,

    fontFamily: AppTypography.primaryFont,
    textTheme: AppTypography.textTheme,

    tooltipTheme: TooltipThemeData(
      preferBelow: false,
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: AppTypography.textTheme.labelMedium!.copyWith(
        color: AppColors.lightOnSurface,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.lightSecondary,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.lightOnSecondary,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      surface: AppColors.lightSurface,
      surfaceContainer: AppColors.lightSurfaceContainer,
      error: AppColors.lightError,
      onError: AppColors.lightOnError,
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,

    fontFamily: AppTypography.primaryFont,
    textTheme: AppTypography.textTheme,

    tooltipTheme: TooltipThemeData(
      preferBelow: false,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: AppTypography.textTheme.labelMedium!.copyWith(
        color: AppColors.darkOnSurface,
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.darkSecondary,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.darkOnSecondary,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      surface: AppColors.darkSurface,
      surfaceContainer: AppColors.darkSurfaceContainer,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
    ),
  );
}
