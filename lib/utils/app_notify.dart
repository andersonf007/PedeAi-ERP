import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedeai/theme/color_tokens.dart'; // BrandColors

enum AppNotifyPlacement { bottom, top }

class AppNotify {
  AppNotify._();

  // --- SnackBar flutuante (rodapé) -----------------------------------------
  static void _showSnackBar(
    BuildContext context, {
    required IconData icon,
    required String message,
    required Color bg,
    required Color fg,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final mq = MediaQuery.of(context);

    // empurra o snackbar acima de botões fixos / safe area
    final double offset = bottomOffset ??
        (16 + mq.viewPadding.bottom + (mq.viewInsets.bottom > 0 ? 0 : 64));

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.fromLTRB(16, 0, 16, offset),
          duration: duration ?? const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(
                  label: actionLabel,
                  onPressed: onAction,
                  textColor: fg,
                )
              : null,
        ),
      );

    HapticFeedback.lightImpact();
  }

  // --- MaterialBanner (topo) -----------------------------------------------
  static void _showBanner(
    BuildContext context, {
    required IconData icon,
    required String message,
    required Color bg,
    required Color fg,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..clearMaterialBanners()
      ..showMaterialBanner(
        MaterialBanner(
          backgroundColor: bg,
          elevation: 2,
          content: Row(
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          actions: [
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: () {
                  messenger.hideCurrentMaterialBanner();
                  onAction();
                },
                child: Text(actionLabel, style: TextStyle(color: fg)),
              ),
            IconButton(
              icon: Icon(Icons.close, color: fg),
              onPressed: () => messenger.hideCurrentMaterialBanner(),
            ),
          ],
        ),
      );

    Future.delayed(duration ?? const Duration(seconds: 3), () {
      if (messenger.mounted) messenger.hideCurrentMaterialBanner();
    });

    HapticFeedback.lightImpact();
  }

  // --- Roteador (topo/rodapé) ----------------------------------------------
  static void _notify(
    BuildContext context, {
    required IconData icon,
    required String message,
    required Color bg,
    required Color fg,
    AppNotifyPlacement placement = AppNotifyPlacement.bottom,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
  }) {
    if (placement == AppNotifyPlacement.top) {
      _showBanner(
        context,
        icon: icon,
        message: message,
        bg: bg,
        fg: fg,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
      );
    } else {
      _showSnackBar(
        context,
        icon: icon,
        message: message,
        bg: bg,
        fg: fg,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        bottomOffset: bottomOffset,
      );
    }
  }

  // --- APIs públicas com cores corrigidas ----------------------------------
  /// Sucesso → verde da paleta (legível em qualquer tema)
  static void success(
    BuildContext context,
    String message, {
    AppNotifyPlacement placement = AppNotifyPlacement.bottom,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
  }) {
    const bg = BrandColors.success700;
    const fg = Colors.white;
    _notify(context,
        icon: Icons.check_circle_rounded,
        message: message,
        bg: bg,
        fg: fg,
        placement: placement,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        bottomOffset: bottomOffset);
  }

  /// Informativo → usa a cor da marca (primary)
  static void info(
    BuildContext context,
    String message, {
    AppNotifyPlacement placement = AppNotifyPlacement.bottom,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
  }) {
    final cs = Theme.of(context).colorScheme;
    _notify(context,
        icon: Icons.info_rounded,
        message: message,
        bg: cs.primary,
        fg: cs.onPrimary,
        placement: placement,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        bottomOffset: bottomOffset);
  }

  /// Alerta (não-crítico) → âmbar/danger da paleta
  static void warn(
    BuildContext context,
    String message, {
    AppNotifyPlacement placement = AppNotifyPlacement.bottom,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
  }) {
    const bg = BrandColors.danger700; // âmbar escuro
    const fg = Colors.white;
    _notify(context,
        icon: Icons.warning_amber_rounded,
        message: message,
        bg: bg,
        fg: fg,
        placement: placement,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        bottomOffset: bottomOffset);
  }

  /// Erro (crítico) → **ColorScheme.error** (vermelho)
  static void error(
    BuildContext context,
    String message, {
    AppNotifyPlacement placement = AppNotifyPlacement.bottom,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
  }) {
    final cs = Theme.of(context).colorScheme;
    _notify(context,
        icon: Icons.error_rounded,
        message: message,
        bg: cs.error,
        fg: cs.onError,
        placement: placement,
        duration: duration ?? const Duration(seconds: 5),
        actionLabel: actionLabel,
        onAction: onAction,
        bottomOffset: bottomOffset);
  }
}
