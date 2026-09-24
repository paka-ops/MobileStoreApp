import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ============================================================================
/// APP TEXT STYLES — hiérarchie typographique unique de l'application.
///
/// Police : **SF Pro Display** (spécification), avec liste de repli explicite.
/// SF Pro n'étant pas distribuable avec l'application, le texte se résout dans
/// l'ordre : `SF Pro Display` → `Poppins` → `Inter` → `Roboto` → police système.
/// Sur iOS/macOS, la police système EST SF Pro : le rendu est donc natif.
///
/// ➜ Pour embarquer SF Pro pour de vrai : déposer les `.ttf` dans
///   `assets/fonts/` et les déclarer sous la famille « SF Pro Display » dans
///   `pubspec.yaml`. Aucun code à modifier.
///
/// Hiérarchie (spec) : titre 22/w700 · produit 14/w500 · prix 16/w700 ·
/// corps secondaire 13/w400 · pillule 12/w500.
///
/// ⚠️ Tous les anciens noms (display, h1…h3, body, caption, overline, button,
///    amount, cardTitle, withColor…) sont conservés : la valeur change,
///    jamais le nom.
/// ============================================================================
class AppTextStyles {
  AppTextStyles._();

  /// Famille déclarée dans le thème (ThemeData.fontFamily).
  static const String fontFamily = 'SF Pro Display';

  /// Repli explicite — aucune erreur si SF Pro est absente.
  static const List<String> fontFamilyFallback = <String>[
    'Poppins',
    'Inter',
    'Roboto',
  ];

  // ==========================================================================
  // STYLES DE LA SPÉCIFICATION
  // ==========================================================================

  /// 22 / w700 — titre d'écran ou d'en-tête (« Ma Boutique »)
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.4,
  );

  /// 14 / w500 — libellé produit / catégorie
  static const TextStyle productTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 16 / w700 — prix / montant mis en avant
  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 13 / w400 — texte secondaire (descriptions, sous-titres)
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// 12 / w500 — libellé de pillule / onglet
  static const TextStyle pillText = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ==========================================================================
  // ÉCHELLE DE BASE
  // ==========================================================================

  /// 32 / Bold — écrans héro (rarement utilisé)
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 32,
    height: 1.18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );

  /// 28 / Bold
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// 22 / Bold
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  /// 19 / SemiBold — titres de pages
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 19,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  // ---- Corps ---------------------------------------------------------------
  /// 16 / Regular
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  /// 14 / Regular
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  /// 13 / Regular
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  /// 12 / Regular
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  /// 11 / SemiBold / espacement large — surtitres « ÉTAT DU STOCK »
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  /// 15 / SemiBold — libellés de boutons
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // ==========================================================================
  // STYLES DU DESIGN SYSTEM
  // ==========================================================================

  /// 13 / Medium — petite ligne grise au-dessus d'un titre
  /// (« Bonjour, Amanda », « Total balance »)
  static const TextStyle eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  /// Compatibilité : le « greeting » du header est désormais l'eyebrow.
  static const TextStyle greeting = eyebrow;

  /// 26 / Bold — grand chiffre (solde, total du jour)
  static const TextStyle metric = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 20 / Bold — valeur principale d'un en-tête (nom de boutique, profil)
  static const TextStyle name = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// 17 / Bold — titre de section (« Transactions », « Dépenses »)
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// 14.5 / Medium — sous-titre d'en-tête (localisation, rôle)
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14.5,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  /// 15 / SemiBold — titre d'une carte / d'une ligne
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  /// 13 / Regular — texte secondaire d'une ligne
  static const TextStyle tileSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  /// 12 / Medium — labels « Date », « Heure », métadonnées
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  /// 12 / SemiBold — texte de puce / badge de statut
  static const TextStyle chip = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  /// 13 / Bold — note posée près d'une étoile
  static const TextStyle rating = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  /// 17 / Bold — lettrage de marque (« BouTiKa »)
  static const TextStyle brand = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  // ---- Variantes numériques -------------------------------------------------
  /// Montant principal — 15 / Bold / chiffres tabulaires
  static const TextStyle amount = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Petit montant — 13.5 / SemiBold
  static const TextStyle amountSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13.5,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Grand chiffre de statistique (fiches profil / détail)
  static const TextStyle statValue = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16.5,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  // ---- Helpers ---------------------------------------------------------------
  /// Applique une couleur à un style (immutabilité préservée).
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  /// Raccourci : style ad hoc pour les rares cas hors échelle.
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
}

/// ============================================================================
/// TEXT STYLES THÉMÉS — raccourcis couleurs.
///
///   final t = AppTextTheme(context);
///   Text("Bonjour", style: t.eyebrow)
/// ============================================================================
class AppTextTheme {
  final DashColors c;

  AppTextTheme(BuildContext context) : c = DashColors(context);

  TextStyle get eyebrow =>
      AppTextStyles.eyebrow.copyWith(color: c.textSecondary);
  TextStyle get greeting =>
      AppTextStyles.eyebrow.copyWith(color: c.textSecondary);
  TextStyle get name => AppTextStyles.name.copyWith(color: c.textPrimary);
  TextStyle get metric => AppTextStyles.metric.copyWith(color: c.textPrimary);
  TextStyle get title =>
      AppTextStyles.sectionTitle.copyWith(color: c.textPrimary);
  TextStyle get subtitle =>
      AppTextStyles.subtitle.copyWith(color: c.textSecondary);
  TextStyle get cardTitle =>
      AppTextStyles.cardTitle.copyWith(color: c.textPrimary);
  TextStyle get body => AppTextStyles.body.copyWith(color: c.textPrimary);
  TextStyle get muted => AppTextStyles.body.copyWith(color: c.textSecondary);
  TextStyle get label => AppTextStyles.label.copyWith(color: c.textSecondary);
  TextStyle get tileTitle =>
      AppTextStyles.cardTitle.copyWith(color: c.textPrimary);
  TextStyle get tileSubtitle =>
      AppTextStyles.tileSubtitle.copyWith(color: c.textSecondary);
}
