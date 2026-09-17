import 'package:flutter/material.dart';

/// ============================================================================
/// APP SHADOWS — ombres standardisées « soft elevation » du design system.
///
/// Règle : BoxShadow(color: noir 5 %, blurRadius: 20, offset: (0, 8)).
/// En mode sombre, préférez les ombres thémées de `DashColors`
/// (`c.cardShadow`, `c.floatingShadow`) qui s'assombrissent automatiquement.
/// ============================================================================
class AppShadows {
  AppShadows._();

  /// Ombre de carte — effet « soft elevation » (spec : blur 20, y 8, 5 %).
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000), // noir 5 %
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Ombre pour éléments flottants (FAB, barres flottantes, tags en overlay).
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1F000000), // noir 12 %
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  /// Ombre prononcée des surfaces navy flottantes (bottom nav).
  static const List<BoxShadow> floatNav = [
    BoxShadow(
      color: Color(0x2E000000), // noir 18 %
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  /// Ombre de dialog / modal
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x24000000), // noir 14 %
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  /// Ombre colorée douce (halo autour d'un élément coloré — FAB teal, boutons)
  static List<BoxShadow> glow(Color color, {double alpha = 0.25}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}
