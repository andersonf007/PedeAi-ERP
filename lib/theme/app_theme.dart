import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'spacing_tokens.dart';
import 'typography.dart';

ThemeData buildLightTheme() {
  const lightColors = ColorScheme(
    brightness: Brightness.light,
    primary: BrandColors.primary500,
    onPrimary: Colors.white,
    primaryContainer: BrandColors.primary100,
    onPrimaryContainer: BrandColors.primary900,
    secondary: BrandColors.neutral500,
    onSecondary: Colors.white,
    secondaryContainer: BrandColors.neutral100,
    onSecondaryContainer: BrandColors.neutral900,
    error: BrandColors.danger500,            // usa tons de “danger” como erro
    onError: Colors.white,
    errorContainer: BrandColors.danger50,
    onErrorContainer: BrandColors.danger900,
    background: BrandColors.neutral50,
    onBackground: BrandColors.neutral900,
    surface: Colors.white,
    onSurface: BrandColors.neutral900,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: lightColors,
    textTheme: AppTypography.textTheme,
    extensions: const [AppSpacing()],
  );
}

ThemeData buildDarkTheme() {
  const darkColors = ColorScheme(
    brightness: Brightness.dark,
    // use a cor mais saturada como acento principal no dark
    primary: BrandColors.primary500,             // era primary300
    onPrimary: Colors.white,                     // era neutral900 (escuro!)
    primaryContainer: BrandColors.primary700,
    onPrimaryContainer: BrandColors.neutral50,

    secondary: BrandColors.neutral400,
    onSecondary: BrandColors.neutral900,
    secondaryContainer: BrandColors.neutral700,
    onSecondaryContainer: BrandColors.neutral50,

    error: BrandColors.danger300,
    onError: BrandColors.neutral900,
    errorContainer: BrandColors.danger700,
    onErrorContainer: BrandColors.neutral50,

    background: BrandColors.neutral800,
    onBackground: BrandColors.neutral50,
    surface: BrandColors.neutral800,
    onSurface: BrandColors.neutral50,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: darkColors,
    textTheme: AppTypography.textTheme,
    extensions: const [AppSpacing()],
  );
}
