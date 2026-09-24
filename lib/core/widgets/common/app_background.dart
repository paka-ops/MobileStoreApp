import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// ============================================================================
/// APP BACKGROUND — toile de fond unique de l'application.
///
/// Rend le **dégradé lavande** de la spécification derrière TOUTES les pages :
///
///   lavande #E8E4F3  →  blanc cassé #F5F5F7  →  fond #FAFAFA
///
/// En mode sombre, le dégradé devient neutre profond (#1B1826 → #121214).
///
/// Branché une seule fois dans `MaterialApp.builder`, il évite d'avoir à
/// répéter un `Container(decoration: …)` dans chaque `Scaffold` : les écrans
/// utilisent un `Scaffold` transparent et le fond apparaît naturellement.
///
/// Les widgets ayant besoin du dégradé par eux-mêmes (sheets, dialogs, cartes
/// héro) utilisent `DashColors.backgroundGradient` / `AppGradients.page(c)`.
/// ============================================================================
class AppBackground extends StatelessWidget {
  /// Contenu affiché au-dessus du dégradé (généralement le Navigator).
  final Widget child;

  /// Force un thème clair même si l'appareil est en mode sombre.
  final bool forceLight;

  const AppBackground({
    super.key,
    required this.child,
    this.forceLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, isDarkValue, _) {
        final bool isDark = forceLight ? false : isDarkValue;
        return DecoratedBox(
          decoration: BoxDecoration(gradient: gradientFor(isDark)),
          child: child,
        );
      },
    );
  }

  /// Dégradé de fond selon le mode — utilisable hors widget tree.
  static LinearGradient gradientFor(bool isDark) => isDark
      ? const LinearGradient(
          colors: [AppColors.darkBackgroundWash, AppColors.darkBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : AppColors.backgroundGradient;
}
