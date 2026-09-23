import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// ============================================================================
/// APP TEXT STYLES — hiérarchie typographique du design system.
///
/// Police : **Poppins** (package `google_fonts`).
/// Les styles sont `final` (GoogleFonts résout la police à l'exécution : elle
/// est téléchargée puis mise en cache au premier rendu).
///
/// Principe « calm premium » (inspiré des apps haut de gamme) :
///   label gris discret  →  valeur encre, grande et nette.
/// Les graisses restent en w500–w700 : jamais de w800/w900 « criards ».
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

  /// 32 / Bold — écrans héro (rarement utilisé)
  static final TextStyle display = GoogleFonts.poppins(
    fontSize: 32,
    height: 1.18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );

  /// 28 / Bold
  static final TextStyle h1 = GoogleFonts.poppins(
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// 22 / Bold
  static final TextStyle h2 = GoogleFonts.poppins(
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  /// 19 / SemiBold — titres de pages
  static final TextStyle h3 = GoogleFonts.poppins(
    fontSize: 19,
    height: 1.3,
    fontWeight: FontWeight.w600,
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

  /// 13 / Regular
  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  /// 12 / Regular
  static final TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  /// 11 / SemiBold / espacement large — surtitres « ÉTAT DU STOCK »
  static final TextStyle overline = GoogleFonts.poppins(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  /// 15 / SemiBold — libellés de boutons
  static final TextStyle button = GoogleFonts.poppins(
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
  static final TextStyle eyebrow = GoogleFonts.poppins(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  /// Compatibilité : le « greeting » du header est désormais l'eyebrow.
  static final TextStyle greeting = eyebrow;

  /// 26 / Bold — grand chiffre (solde, total du jour)
  static final TextStyle metric = GoogleFonts.poppins(
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// 21 / Bold — valeur principale d'un en-tête (nom de boutique, profil)
  static final TextStyle name = GoogleFonts.poppins(
    fontSize: 21,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// 17.5 / Bold — titre de section (« Transactions », « Dépenses »)
  static final TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 17.5,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// 15 / Medium — sous-titre d'en-tête (localisation, rôle)
  static final TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 14.5,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  /// 14.5 / SemiBold — titre d'une carte / d'une ligne
  static final TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 14.5,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  /// 12.5 / Regular — texte secondaire d'une ligne
  static final TextStyle tileSubtitle = GoogleFonts.poppins(
    fontSize: 12.5,
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

  /// 13 / Bold — note posée près d'une étoile
  static final TextStyle rating = GoogleFonts.poppins(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  /// 17 / Bold — lettrage de marque (« BouTiKa »)
  static final TextStyle brand = GoogleFonts.poppins(
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  // ---- Variantes numériques -------------------------------------------------
  /// Montant principal — 15 / Bold / chiffres tabulaires
  static final TextStyle amount = GoogleFonts.poppins(
    fontSize: 15,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Petit montant — 13.5 / SemiBold
  static final TextStyle amountSmall = GoogleFonts.poppins(
    fontSize: 13.5,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Grand chiffre de statistique (fiches profil / détail)
  static final TextStyle statValue = GoogleFonts.poppins(
    fontSize: 16.5,
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
