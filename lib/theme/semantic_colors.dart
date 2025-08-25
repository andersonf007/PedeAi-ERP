import 'package:flutter/material.dart';
import 'color_tokens.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  // success
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  // warning (observação: na sua paleta “warning” é VERMELHO)
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  // danger (na sua paleta é âmbar/dourado)
  final Color danger;
  final Color onDanger;
  final Color dangerContainer;
  final Color onDangerContainer;

  // opcional: info
  final Color info;
  final Color onInfo;

  const AppSemanticColors({
    // success
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    // warning (vermelho na sua paleta)
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    // danger (âmbar na sua paleta)
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
    required this.onDangerContainer,
    // info
    required this.info,
    required this.onInfo,
  });

  // light
  factory AppSemanticColors.light() => const AppSemanticColors(
        // verdes
        success: BrandColors.success700,
        onSuccess: Colors.white,
        successContainer: BrandColors.success100,
        onSuccessContainer: BrandColors.success900,

        // WARNING = vermelho na sua paleta
        warning: BrandColors.warning500,
        onWarning: Colors.white,
        warningContainer: BrandColors.warning50,
        onWarningContainer: BrandColors.warning900,

        // DANGER = âmbar na sua paleta
        danger: BrandColors.danger500,
        onDanger: Colors.white,
        dangerContainer: BrandColors.danger50,
        onDangerContainer: BrandColors.danger900,

        // info (usei a cor da marca)
        info: BrandColors.primary500,
        onInfo: Colors.white,
      );

  // dark
  factory AppSemanticColors.dark() => const AppSemanticColors(
        success: BrandColors.success500,
        onSuccess: Colors.white,
        successContainer: BrandColors.success700,
        onSuccessContainer: BrandColors.neutral50,

        warning: BrandColors.warning300,
        onWarning: BrandColors.neutral900,
        warningContainer: BrandColors.warning700,
        onWarningContainer: BrandColors.neutral50,

        danger: BrandColors.danger300,
        onDanger: BrandColors.neutral900,
        dangerContainer: BrandColors.danger700,
        onDangerContainer: BrandColors.neutral50,

        info: BrandColors.primary500,
        onInfo: Colors.white,
      );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
    Color? onDangerContainer,
    Color? info,
    Color? onInfo,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      onDangerContainer: onDangerContainer ?? this.onDangerContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    Color lerpC(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemanticColors(
      success: lerpC(success, other.success),
      onSuccess: lerpC(onSuccess, other.onSuccess),
      successContainer: lerpC(successContainer, other.successContainer),
      onSuccessContainer: lerpC(onSuccessContainer, other.onSuccessContainer),
      warning: lerpC(warning, other.warning),
      onWarning: lerpC(onWarning, other.onWarning),
      warningContainer: lerpC(warningContainer, other.warningContainer),
      onWarningContainer: lerpC(onWarningContainer, other.onWarningContainer),
      danger: lerpC(danger, other.danger),
      onDanger: lerpC(onDanger, other.onDanger),
      dangerContainer: lerpC(dangerContainer, other.dangerContainer),
      onDangerContainer: lerpC(onDangerContainer, other.onDangerContainer),
      info: lerpC(info, other.info),
      onInfo: lerpC(onInfo, other.onInfo),
    );
  }
}
