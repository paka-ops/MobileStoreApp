import 'package:flutter/material.dart';

/// ============================================================================
/// APP SHADOWS — ombres standardisées (sobres, premium).
///
/// Préférez [AppShadows.card] / [AppShadows.floating] en mode clair ; en mode
/// sombre, les ombres sont automatiquement plus profondes via DashColors.
/// ============================================================================
class AppShadows {
  AppShadows._();

  /// Ombre de carte discrète
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D101828), // noir 5%
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  /// Ombre pour éléments flottants (FAB, barres flottantes)
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x14101828), // noir 8%
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  /// Ombre de dialog / modal
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x1F101828), // noir 12%
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  /// Ombre colorée douce (halo autour d'un élément coloré)
  static List<BoxShadow> glow(Color color, {double alpha = 0.25}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
