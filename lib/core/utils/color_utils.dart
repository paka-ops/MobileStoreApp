import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// ============================================================================
/// APP COLOR UTILS — teintes dérivées déterministes du design system.
///
/// Trois recettes sont utilisées par les composants visuels et étaient
/// dupliquées dans plusieurs fichiers. Elles sont regroupées ici **sans aucun
/// changement de formule** : mêmes arrondis HSL, mêmes bornes, donc mêmes
/// couleurs produites.
///
///   1. [pastelForName]        → pastel stable déduit d'un nom (boutiques)
///   2. [iconTint]             → teinte d'icône contrastée (L −0.30 / S +0.12)
///   3. [categoryIconTint]     → variante des tuiles catégories (L −0.32 / S +0.10)
/// ============================================================================
class AppColorUtils {
  AppColorUtils._();

  /// Pastel déterministe associé à un nom : la somme des points de code des
  /// caractères indexe la palette pastel (cyclique).
  ///
  /// Deux boutiques portant le même nom obtiennent donc toujours la même
  /// teinte, et l'ordre des boutiques n'influence pas la couleur.
  static Color pastelForName(String name, DashColors colors) {
    int sum = 0;
    for (final int unit in name.codeUnits) {
      sum += unit;
    }
    return colors.pastelAt(sum);
  }

  /// Teinte d'icône contrastée dérivée d'un pastel :
  /// luminosité −[lightnessDelta] (bornée à 0), saturation +[saturationDelta]
  /// (bornée à 1). Formule historique des widgets de liste et de boutique.
  static Color iconTint(
    Color pastel, {
    double lightnessDelta = 0.30,
    double saturationDelta = 0.12,
  }) {
    final HSLColor hsl = HSLColor.fromColor(pastel);
    return hsl
        .withLightness((hsl.lightness - lightnessDelta).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + saturationDelta).clamp(0.0, 1.0))
        .toColor();
  }

  /// Variante utilisée par les tuiles de catégorie (légèrement plus sombre et
  /// moins saturée que [iconTint]).
  static Color categoryIconTint(Color pastel) =>
      iconTint(pastel, lightnessDelta: 0.32, saturationDelta: 0.10);
}
