import 'package:flutter/material.dart';

/// ============================================================================
/// AppDurations — durées d'animation standardisées.
/// ============================================================================
class AppDurations {
  AppDurations._();

  /// 100 ms — hover, micro-feedback
  static const Duration instant = Duration(milliseconds: 100);

  /// 150 ms — press/hover state
  static const Duration fast = Duration(milliseconds: 150);

  /// 200 ms — transitions simples (containers, chips)
  static const Duration normal = Duration(milliseconds: 200);

  /// 300 ms — transitions complexes (cards, sheets)
  static const Duration medium = Duration(milliseconds: 300);

  /// 400 ms — animations d'entrée
  static const Duration slow = Duration(milliseconds: 400);

  /// 500 ms — transitions de page
  static const Duration page = Duration(milliseconds: 350);

  /// Shimmer loop
  static const Duration shimmer = Duration(milliseconds: 1600);
}

/// ============================================================================
/// AppCurves — courbes d'animation standardisées.
/// ============================================================================
class AppCurves {
  AppCurves._();

  /// Standard — allers-retours
  static const Curve standard = Curves.easeInOut;

  /// Entrée d'élément
  static const Curve entrance = Curves.easeOut;

  /// Sortie d'élément
  static const Curve exit = Curves.easeIn;

  /// Entrée avec léger overshot (cards, boutons)
  static const Curve emphasized = Curves.easeOutCubic;

  /// Appui bouton (scale down)
  static const Curve press = Curves.easeOut;
}
