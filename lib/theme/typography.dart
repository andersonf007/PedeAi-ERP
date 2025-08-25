import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // Display
  static const displayLarge = TextStyle(
    fontFamily: 'Roboto Slab',
    fontWeight: FontWeight.w500,
    fontSize: 57,
    height: 64 / 57,
    letterSpacing: -0.25,
  );
  static const displayMedium = TextStyle(
    fontFamily: 'Roboto Slab',
    fontWeight: FontWeight.w500,
    fontSize: 45,
    height: 52 / 45,
  );
  static const displaySmall = TextStyle(
    fontFamily: 'Roboto Slab',
    fontWeight: FontWeight.w500,
    fontSize: 36,
    height: 44 / 36,
  );

  // Headline
  static const headlineLarge = TextStyle(
    fontFamily: 'Roboto Slab',
    fontWeight: FontWeight.w500,
    fontSize: 32,
    height: 40 / 32,
  );
  static const headlineMedium = TextStyle(
    fontFamily: 'Roboto Slab',
    fontWeight: FontWeight.w500,
    fontSize: 28,
    height: 36 / 28,
  );
  static const headlineSmall = TextStyle(
    fontFamily: 'Roboto Slab',
    fontWeight: FontWeight.w500,
    fontSize: 24,
    height: 32 / 24,
  );

  // Title
  static const titleLarge = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 22,
    height: 28 / 22,
  );
  static const titleMedium = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.15,
  );
  static const titleSmall = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.1,
  );

  // Label
  static const labelLarge = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20 / 14,
  );
  static const labelMedium = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.5,
  );
  static const labelSmall = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.5,
  );

  // Body
  static const bodyLarge = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24 / 16,
  );
  static const bodyMedium = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
  );
  static const bodySmall = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 16 / 12,
  );

  static const textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );
}
