import 'package:flutter/material.dart';

import 'core/risk.dart';

/// Cores do app. O azul foi estimado a partir da imagem do kit:
/// troque pelo valor exato do Figma (clique no elemento > Fill).
class AppColors {
  static const primary = Color(0xFF4054F0);
  static const primaryTint = Color(0xFFE8EBFD);
  static const background = Color(0xFFF5F6FB);
  static const text = Color(0xFF1B1E3C);
  static const textMuted = Color(0xFF6B7090);
  static const border = Color(0xFFE6E8F2);

  // Cores de risco: significam sempre a mesma coisa em todo o app.
  static const ok = Color(0xFF2E9E5B);
  static const okTint = Color(0xFFE3F5EB);
  static const warn = Color(0xFFE59A00);
  static const warnTint = Color(0xFFFFF1D0);
  static const urgent = Color(0xFFD93025);
  static const urgentTint = Color(0xFFFCE4E2);

  // Selo "sem internet": neutro, porque offline é uso normal (não é erro).
  static const offlineTint = Color(0xFFFFF4D6);
  static const offlineText = Color(0xFF7A5A00);
}

extension RiskStyle on Risk {
  Color get color => switch (this) {
        Risk.ok => AppColors.ok,
        Risk.acompanhar => AppColors.warn,
        Risk.encaminharUrgente => AppColors.urgent,
      };

  Color get tint => switch (this) {
        Risk.ok => AppColors.okTint,
        Risk.acompanhar => AppColors.warnTint,
        Risk.encaminharUrgente => AppColors.urgentTint,
      };

  IconData get icon => switch (this) {
        Risk.ok => Icons.check_circle_outline,
        Risk.acompanhar => Icons.schedule,
        Risk.encaminharUrgente => Icons.warning_amber_rounded,
      };
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary)
      .copyWith(primary: AppColors.primary);
  final buttonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: buttonShape,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: buttonShape,
        side: const BorderSide(color: AppColors.primary),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
