import 'package:flutter/material.dart';

/// ============================================================================
/// APP SHADOWS — ombres « soft elevation » (très diffuses, jamais marquées).
///
/// Recette premium : une ombre ne doit pas se voir. On garde un noir à
/// 4–8 % avec un grand flou, ce qui donne du relief sans fatiguer l'œil.
/// En mode sombre, préférez `DashColors.cardShadow` / `floatingShadow`.
/// ============================================================================
class AppShadows {
  AppShadows._();

  /// Ombre de carte — 4 % noir, blur 20, y 8.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000), // noir 4 %
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Ombre pour éléments flottants (FAB, barres, tags) — 8 %, blur 26, y 12.
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x14000000), // noir 8 %
      blurRadius: 26,
      offset: Offset(0, 12),
    ),
  ];

  /// Ombre des surfaces flottantes larges (bottom nav).
  static const List<BoxShadow> floatNav = [
    BoxShadow(
      color: Color(0x14000000), // noir 8 %
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  /// Ombre de dialog / modal — 12 %, blur 32, y 12.
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  /// Ombre colorée très douce (halo discret sous un élément teinté).
  static List<BoxShadow> glow(Color color, {double alpha = 0.12}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
}
