import 'package:flutter/material.dart';

class AppTypography {
  static const String primaryFont = 'Inter';
  static TextTheme get textTheme => const TextTheme(
    //* Display styles
    displayLarge: TextStyle(fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontWeight: FontWeight.normal),
    displaySmall: TextStyle(fontWeight: FontWeight.normal),

    //* Headline styles
    headlineLarge: TextStyle(fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontWeight: FontWeight.normal),

    //* Title styles
    titleLarge: TextStyle(fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontWeight: FontWeight.bold),
    titleSmall: TextStyle(fontWeight: FontWeight.bold),

    //* Body styles
    bodyLarge: TextStyle(fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontWeight: FontWeight.w500),

    //* Label styles
    labelLarge: TextStyle(fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontWeight: FontWeight.normal),
  );
}

extension ResponsiveTextThemeExtension on TextTheme {
  TextTheme responsive(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final scaleFactor = (height / 800).clamp(0.9, 1.2);
    final color = Theme.of(context).colorScheme.onSurface;

    TextStyle? scale(TextStyle? style, double size) {
      return style?.copyWith(
        fontSize: size * scaleFactor,
        color: color,
        fontFamily: AppTypography.primaryFont,
        fontStyle: FontStyle.normal,
      );
    }

    return TextTheme(
      displayLarge: scale(displayLarge, 64),
      displayMedium: scale(displayMedium, 60),
      displaySmall: scale(displaySmall, 56),
      headlineLarge: scale(headlineLarge, 52),
      headlineMedium: scale(headlineMedium, 48),
      headlineSmall: scale(headlineSmall, 44),
      titleLarge: scale(titleLarge, 40),
      titleMedium: scale(titleMedium, 36),
      titleSmall: scale(titleSmall, 32),
      bodyLarge: scale(bodyLarge, 28),
      bodyMedium: scale(bodyMedium, 24),
      bodySmall: scale(bodySmall, 20),
      labelLarge: scale(labelLarge, 16),
      labelMedium: scale(labelMedium, 14),
      labelSmall: scale(labelSmall, 12),
    );
  }
}

extension BuildContextTextThemeExtension on BuildContext {
  TextTheme get appText => Theme.of(this).textTheme.responsive(this);
}

extension TextStyleExtension on TextStyle {
  TextStyle withStyle({
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return copyWith(
      color: color ?? this.color,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
    );
  }
}

extension IconSizeFromTextTheme on BuildContext {
  // Display sizes
  double get displayLarge => appText.displayLarge?.fontSize ?? 64;
  double get displayMedium => appText.displayMedium?.fontSize ?? 60;
  double get displaySmall => appText.displaySmall?.fontSize ?? 56;

  // Headline sizes
  double get headlineLarge => appText.headlineLarge?.fontSize ?? 52;
  double get headlineMedium => appText.headlineMedium?.fontSize ?? 48;
  double get headlineSmall => appText.headlineSmall?.fontSize ?? 44;

  // Title sizes
  double get titleLarge => appText.titleLarge?.fontSize ?? 40;
  double get titleMedium => appText.titleMedium?.fontSize ?? 36;
  double get titleSmall => appText.titleSmall?.fontSize ?? 32;

  // Body sizes
  double get bodyLarge => appText.bodyLarge?.fontSize ?? 28;
  double get bodyMedium => appText.bodyMedium?.fontSize ?? 24;
  double get bodySmall => appText.bodySmall?.fontSize ?? 20;

  // Label sizes
  double get labelLarge => appText.labelLarge?.fontSize ?? 16;
  double get labelMedium => appText.labelMedium?.fontSize ?? 14;
  double get labelSmall => appText.labelSmall?.fontSize ?? 12;
}
