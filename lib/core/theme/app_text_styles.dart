import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// ============================================================================
/// APP TEXT STYLES — hiérarchie typographique du design system.
///
/// Police : **Poppins** (via le package `google_fonts`).
/// Les styles sont `final` (et non `const`) car GoogleFonts résout la police
/// à l'exécution : la famille est téléchargée/mise en cache au premier rendu.
///
/// Si l'appareil est hors ligne au premier lancement, Flutter retombe
/// proprement sur la police système — aucune erreur, aucun écran cassé.
///
/// ⚠️ Tous les anciens noms (display, h1…h3, body, caption, overline, button,
///    amount, cardTitle, withColor) sont conservés à l'identique.
/// ============================================================================
class AppTextStyles {
  AppTextStyles._();

  /// Famille déclarée dans le thème (ThemeData.fontFamily).
  static const String fontFamily = 'Poppins';

  // ==========================================================================
  // ÉCHELLE DE BASE
  // ==========================================================================

  // ---- Display / Titres ------------------------------------------------------
  /// 40 / Bold — écrans héro (rarement utilisé)
  static final TextStyle display = GoogleFonts.poppins(
    fontSize: 40,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
  );

  /// 32 / Bold
  static final TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );

  /// 24 / Bold — titres de section majeurs
  static final TextStyle h2 = GoogleFonts.poppins(
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  /// 20 / Bold — titres de pages
  static final TextStyle h3 = GoogleFonts.poppins(
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  // ---- Corps -----------------------------------------------------------------
  /// 16 / Regular
  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  /// 14 / Regular
  static final TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  /// 13 / Regular — corps compact (listes denses)
  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  /// 12 / Regular — petites descriptions
  static final TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  /// 11 / Bold / espacement large — surtitres « ÉTAT DU STOCK »
  static final TextStyle overline = GoogleFonts.poppins(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  /// 15 / SemiBold — libellés de boutons
  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // ==========================================================================
  // STYLES DU DESIGN SYSTEM (header, cards, listes, labels)
  // ==========================================================================

  /// 24 / Bold — « Bonjour Amanda » : greeting du header
  static final TextStyle greeting = GoogleFonts.poppins(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  /// 22 / Bold — nom principal d'une fiche (profil, produit, boutique)
  static final TextStyle name = GoogleFonts.poppins(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// 16 / Medium — sous-titre de header (localisation, spécialité)
  static final TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  /// 15 / SemiBold — titre d'une carte / d'un item de liste
  static final TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  /// 13 / Medium — texte secondaire d'item de liste
  static final TextStyle tileSubtitle = GoogleFonts.poppins(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  /// 11.5 / Regular — labels « Date », « Heure », métadonnées
  static final TextStyle label = GoogleFonts.poppins(
    fontSize: 11.5,
    height: 1.3,
    fontWeight: FontWeight.w400,
  );

  /// 12 / SemiBold — texte de puce / badge de statut
  static final TextStyle chip = GoogleFonts.poppins(
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  /// 13 / Bold — note de rating posée près d'une étoile
  static final TextStyle rating = GoogleFonts.poppins(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  // ---- Variantes numériques -------------------------------------------------
  /// Montants / KPI — 18 / ExtraBold / chiffres tabulaires
  static final TextStyle amount = GoogleFonts.poppins(
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Petit montant — 14 / Bold
  static final TextStyle amountSmall = GoogleFonts.poppins(
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Grand chiffre de statistique (fiches profil / détail)
  static final TextStyle statValue = GoogleFonts.poppins(
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  // ---- Helpers ---------------------------------------------------------------
  /// Applique une couleur à un style (immutabilité préservée).
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  /// Raccourci : style Poppins ad hoc pour les rares cas hors échelle.
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
}

/// ============================================================================
/// TEXT STYLES THÉMÉS — raccourcis couleurs (headers, listes, labels).
///
///   final t = AppTextTheme(context);
///   Text("Bonjour", style: t.greeting)
/// ============================================================================
class AppTextTheme {
  final DashColors c;

  AppTextTheme(BuildContext context) : c = DashColors(context);

  TextStyle get greeting =>
      AppTextStyles.greeting.copyWith(color: c.textPrimary);
  TextStyle get name => AppTextStyles.name.copyWith(color: c.textPrimary);
  TextStyle get title => AppTextStyles.h3.copyWith(color: c.textPrimary);
  TextStyle get subtitle =>
      AppTextStyles.subtitle.copyWith(color: c.textSecondary);
  TextStyle get cardTitle => AppTextStyles.cardTitle.copyWith(color: c.textPrimary);
  TextStyle get body => AppTextStyles.body.copyWith(color: c.textPrimary);
  TextStyle get muted => AppTextStyles.body.copyWith(color: c.textSecondary);
  TextStyle get label => AppTextStyles.label.copyWith(color: c.textSecondary);
  TextStyle get tileTitle =>
      GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
      );
  TextStyle get tileSubtitle => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: c.textSecondary,
      );
}
