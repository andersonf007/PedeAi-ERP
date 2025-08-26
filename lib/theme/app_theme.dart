import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'spacing_tokens.dart';
import 'typography.dart';
import 'semantic_colors.dart';

/// -----------------------------
/// TEMA CLARO
/// -----------------------------
ThemeData buildLightTheme() {
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

    // sua paleta: "warning" vira error
    error: BrandColors.warning500,
    onError: Colors.white,
    errorContainer: BrandColors.warning50,
    onErrorContainer: BrandColors.warning900,

    // use surface/onSurface
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
    cardTheme: _cardTheme(light),
    iconTheme: IconThemeData(color: light.onSurface),
    listTileTheme: ListTileThemeData(
      iconColor: light.onSurface,
      textColor: light.onSurface,
    ),
    popupMenuTheme: _popup(light),
    dividerTheme: DividerThemeData(
      color: light.onSurface.withValues(alpha: 0.12),
    ),
    drawerTheme: const DrawerThemeData(
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    extensions: [
      const AppSpacing(),
      AppSemanticColors.light(),
    ],
  );
}

/// -----------------------------
/// TEMA ESCURO
/// -----------------------------
ThemeData buildDarkTheme() {
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
    cardTheme: _cardTheme(dark),
    iconTheme: IconThemeData(color: dark.onSurface),
    listTileTheme: ListTileThemeData(
      iconColor: dark.onSurface,
      textColor: dark.onSurface,
    ),
    popupMenuTheme: _popup(dark),
    dividerTheme: DividerThemeData(
      color: dark.onSurface.withValues(alpha: 0.12),
    ),
    drawerTheme: const DrawerThemeData(
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    extensions: [
      const AppSpacing(),
      AppSemanticColors.dark(),
    ],
  );
}

/// -----------------------------
/// SUBTEMAS / HELPERS
/// -----------------------------

InputDecorationTheme _inputTheme(ColorScheme cs, {required bool isDark}) {
  // fundo dos inputs com leve “tint” do primary
  final tintedFill = Color.alphaBlend(
    cs.primary.withValues(alpha: isDark ? 0.10 : 0.06),
    cs.surface,
  );

  return InputDecorationTheme(
    filled: true,
    fillColor: tintedFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

    prefixIconColor: cs.onSurface.withValues(alpha: 0.65),
    suffixIconColor: cs.onSurface.withValues(alpha: 0.65),
    hintStyle: TextStyle(
      color: cs.onSurface.withValues(alpha: 0.65),
      fontWeight: FontWeight.w400,
    ),

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

///
/// Adapters para o pacote **flutter_login**
///
/// Adapters para o pacote flutter_login
/// Adapters para o pacote flutter_login
class LoginThemeAdapters {
  /// Card do login (o pacote espera um CardTheme)
  static CardTheme card(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    if (!isDark) {
      // LIGHT: branco puro + micro-sombra e borda suave
      return CardTheme(
        color: Color.alphaBlend(Colors.white.withOpacity(0.10), cs.surface),
        elevation: 0,
        shadowColor: cs.onSurface.withValues(alpha: 1),
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(24, 56, 24, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: cs.onSurface.withValues(alpha: 0.4),
            width: 1.3,
          ),
        ),
      );
    }

    // DARK: leve vidro pra contraste
    return CardTheme(
      color: Color.alphaBlend(Colors.white.withOpacity(0.10), cs.surface),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.fromLTRB(24, 56, 24, 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: cs.onSurface.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
    );
  }

  /// Inputs do login
  static InputDecorationTheme input(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    if (!isDark) {
      // LIGHT: fill quase branco, foco bem definido
      final fill = Color.alphaBlend(cs.primary.withValues(alpha: 0.02), cs.surface);
      return InputDecorationTheme(
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: cs.onSurface.withValues(alpha: 0.60),
        suffixIconColor: cs.onSurface.withValues(alpha: 0.60),
        hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.55)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error),
        ),
      );
    }

    // DARK: um pouco mais de fill pra segurar contraste
    final fill = Color.alphaBlend(cs.primary.withValues(alpha: 0.10), cs.surface);
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIconColor: cs.onSurface.withValues(alpha: 0.70),
      suffixIconColor: cs.onSurface.withValues(alpha: 0.70),
      hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.65)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error),
      ),
    );
  }
}
