import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ============================================================================
/// APP TEXT STYLES — hiérarchie typographique premium.
///
/// Police : Inter (déclarée dans le thème). Si la police n'est pas embarquée
/// dans le projet, Flutter retombe automatiquement sur la police système —
/// le design reste cohérent.
/// ============================================================================
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // ---- Display / Titres ------------------------------------------------------
  /// 40 / Bold — écrans héro (rarement utilisé)
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// 32 / Bold
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// 24 / SemiBold
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  /// 20 / SemiBold — titres de pages
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  // ---- Corps -----------------------------------------------------------------
  /// 16 / Regular
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  /// 14 / Regular
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  /// 12 / Regular
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  /// 11 / Medium — labels de sections
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.35,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  /// 11 / Bold / espacement large — surtitres « ÉTAT DU STOCK »
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  /// 15 / SemiBold — libellés de boutons
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // ---- Variantes numériques -------------------------------------------------
  /// Montants / KPI — 18 / ExtraBold / chiffres tabulaires
  static const TextStyle amount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
  );

  /// Petit montant — 14 / Bold
  static const TextStyle amountSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w700,
  );

  // ---- Helpers ---------------------------------------------------------------
  /// Applique une couleur à un style (immutabilité préservée).
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  /// Style de titre de carte (15.5 / SemiBold)
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.5,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );
}
