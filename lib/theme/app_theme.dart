import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'spacing_tokens.dart';
import 'typography.dart';

/// -----------------------------
/// TEMA CLARO
/// -----------------------------
ThemeData buildLightTheme() {
  // ColorScheme moderno: sem usar background/onBackground (deprecados).
  const light = ColorScheme(
    brightness: Brightness.light,
    primary: BrandColors.primary500,
    onPrimary: Colors.white,
    primaryContainer: BrandColors.primary100,
    onPrimaryContainer: BrandColors.primary900,

    secondary: BrandColors.neutral500,
    onSecondary: Colors.white,
    secondaryContainer: BrandColors.neutral100,
    onSecondaryContainer: BrandColors.neutral900,

    error: BrandColors.warning500,
    onError: Colors.white,
    errorContainer: BrandColors.warning50,
    onErrorContainer: BrandColors.warning900,

    // Use somente surface/onSurface no lugar de background/onBackground
    surface: Colors.white,
    onSurface: BrandColors.neutral900,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: light,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: light.onSurface,
      displayColor: light.onSurface,
    ),
    inputDecorationTheme: _inputTheme(light, isDark: false),
    elevatedButtonTheme: _elevated(light),
    outlinedButtonTheme: _outlined(light),
    textButtonTheme: _textButton(light),
    appBarTheme: _appBar(light),
    cardTheme: _cardTheme(light), // agora CardThemeData
    iconTheme: IconThemeData(color: light.onSurface),
    listTileTheme: ListTileThemeData(
      iconColor: light.onSurface,
      textColor: light.onSurface,
    ),
    popupMenuTheme: _popup(light),
    dividerTheme: DividerThemeData(
      color: light.onSurface.withValues(alpha: 0.12),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: light.surface,
      surfaceTintColor: Colors.transparent,
    ),
    extensions: const [AppSpacing()],
  );
}

/// -----------------------------
/// TEMA ESCURO
/// -----------------------------
ThemeData buildDarkTheme() {
  // Mais saturado no dark para não ficar "opaco".
  const dark = ColorScheme(
    brightness: Brightness.dark,

    primary: BrandColors.primary500,
    onPrimary: Colors.white,
    primaryContainer: BrandColors.primary700,
    onPrimaryContainer: BrandColors.neutral50,

    secondary: BrandColors.neutral400,
    onSecondary: BrandColors.neutral900,
    secondaryContainer: BrandColors.neutral700,
    onSecondaryContainer: BrandColors.neutral50,

    error: BrandColors.warning300,
    onError: BrandColors.neutral900,
    errorContainer: BrandColors.warning700,
    onErrorContainer: BrandColors.neutral50,

    // Use somente surface/onSurface no lugar de background/onBackground
    surface: BrandColors.neutral800,
    onSurface: BrandColors.neutral50,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: dark,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: dark.onSurface,
      displayColor: dark.onSurface,
    ),
    inputDecorationTheme: _inputTheme(dark, isDark: true),
    elevatedButtonTheme: _elevated(dark),
    outlinedButtonTheme: _outlined(dark),
    textButtonTheme: _textButton(dark),
    appBarTheme: _appBar(dark),
    cardTheme: _cardTheme(dark), // agora CardThemeData
    iconTheme: IconThemeData(color: dark.onSurface),
    listTileTheme: ListTileThemeData(
      iconColor: dark.onSurface,
      textColor: dark.onSurface,
    ),
    popupMenuTheme: _popup(dark),
    dividerTheme: DividerThemeData(
      color: dark.onSurface.withValues(alpha: 0.12),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: dark.surface,
      surfaceTintColor: Colors.transparent,
    ),
    extensions: const [AppSpacing()],
  );
}

/// -----------------------------
/// SUBTEMAS / HELPERS
/// -----------------------------

InputDecorationTheme _inputTheme(ColorScheme cs, {required bool isDark}) {
  // Fundo dos inputs (inclui o search) com leve "tint" do primary
  final tintedFill = Color.alphaBlend(
    cs.primary.withValues(alpha: isDark ? 0.10 : 0.06),
    cs.surface,
  );

  return InputDecorationTheme(
    filled: true,
    fillColor: tintedFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

    // cores de ícone/hint
    prefixIconColor: cs.onSurface.withValues(alpha: 0.65),
    suffixIconColor: cs.onSurface.withValues(alpha: 0.65),
    hintStyle: TextStyle(
      color: cs.onSurface.withValues(alpha: 0.65),
      fontWeight: FontWeight.w400,
    ),

    // bordas
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: cs.onSurface.withValues(alpha: 0.18),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cs.primary, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cs.error, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cs.error, width: 1.2),
    ),
  );
}

ElevatedButtonThemeData _elevated(ColorScheme cs) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

OutlinedButtonThemeData _outlined(ColorScheme cs) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: cs.onSurface,
      side: BorderSide(color: cs.onSurface.withValues(alpha: 0.30)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

TextButtonThemeData _textButton(ColorScheme cs) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: cs.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    ),
  );
}

AppBarTheme _appBar(ColorScheme cs) {
  // Adeus background/onBackground; viva surface/onSurface.
  return AppBarTheme(
    backgroundColor: cs.surface,
    foregroundColor: cs.onSurface,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: cs.onSurface),
    titleTextStyle: AppTypography.textTheme.titleMedium?.copyWith(
      color: cs.onSurface,
      fontWeight: FontWeight.bold,
    ),
    scrolledUnderElevation: 0,
  );
}

// ATENÇÃO: agora retorna CardThemeData (não CardTheme).
CardThemeData _cardTheme(ColorScheme cs) {
  return CardThemeData(
    color: cs.surface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.zero,
  );
}

PopupMenuThemeData _popup(ColorScheme cs) {
  return PopupMenuThemeData(
    color: cs.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: TextStyle(color: cs.onSurface),
  );
}
