import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';
import 'app_shadows.dart';

/// ============================================================================
/// APP DIMENSIONS — rayons, espacements et ombres de la spécification.
///
/// Ce fichier est la façade « design tokens » du système : il ne redéfinit
/// rien, il **pointe** vers la source unique (`AppRadius`, `Spacing`,
/// `AppSizes`, `AppShadows`) afin d'éviter toute duplication de valeurs.
///
///   BorderRadius.circular(AppDimensions.radiusMedium)   // 16
///   EdgeInsets.all(AppDimensions.paddingM)              // 16
///
/// Échelle : rayon 12 / 16 / 20 / 100 · padding 4 / 8 / 16 / 24
/// ============================================================================
class AppDimensions {
  AppDimensions._();

  // ---- Border Radius -------------------------------------------------------
  /// 12 px — petits éléments (badges, pastilles, mini-cartes)
  static const double radiusSmall = AppRadius.sm;

  /// 16 px — cartes standard, champs, boutons d'action
  static const double radiusMedium = AppRadius.lg;

  /// 20 px — cartes premium, barres flottantes
  static const double radiusLarge = AppRadius.xl;

  /// 100 px — pilule complète (onglets, chips, boutons pillules)
  static const double radiusPill = AppRadius.pill;

  /// 26 px — coins supérieurs des feuilles modales
  static const double radiusSheet = AppRadius.xxl;

  // ---- Spacing -------------------------------------------------------------
  /// 4 px — micro-espace (icône / texte, gaps internes)
  static const double paddingXS = Spacing.xs;

  /// 8 px — petit espace entre deux éléments liés
  static const double paddingS = Spacing.sm;

  /// 16 px — espace de base (padding interne des cartes)
  static const double paddingM = Spacing.md;

  /// 24 px — marges d'écran, padding de dialogs
  static const double paddingL = Spacing.xl;

  /// Marge horizontale standard d'un écran (20 px)
  static const double screenPadding = AppSizes.screenPadding;

  /// Fraction du dégradé de fond occupée par la lavande.
  static const double gradientLavenderStop = 0.45;

  // ---- Shadows -------------------------------------------------------------
  /// Ombre des cartes — 5 %, blur 10, y 4.
  static const List<BoxShadow> cardShadow = AppShadows.card;

  /// Ombre très légère — 3 %, blur 6, y 2 (pilules actives).
  static const List<BoxShadow> softShadow = AppShadows.soft;

  /// Ombre des éléments flottants — 8 %, blur 20, y 8.
  static const List<BoxShadow> floatingShadow = AppShadows.floating;

  /// Ombre du segment actif d'une barre de pills — 6 %, blur 8, y 2.
  static const List<BoxShadow> activePillShadow = AppShadows.activePill;

  /// Ombre des dialogs / modales — 12 %, blur 28, y 12.
  static const List<BoxShadow> modalShadow = AppShadows.modal;

  // ---- BorderRadius prêts à l'emploi --------------------------------------
  static final BorderRadius rSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius rMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius rLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius rPill = BorderRadius.circular(radiusPill);
  static final BorderRadius rSheet = BorderRadius.vertical(
    top: Radius.circular(radiusSheet),
  );

  // ---- EdgeInsets fréquents -----------------------------------------------
  static const EdgeInsets paddingAllM = EdgeInsets.all(paddingM);
  static const EdgeInsets paddingAllL = EdgeInsets.all(paddingL);
  static const EdgeInsets screenH =
      EdgeInsets.symmetric(horizontal: screenPadding);

  // ---- Fond d'écran --------------------------------------------------------
  /// Dégradé de fond de l'application : lavande clair → blanc cassé.
  static const LinearGradient backgroundGradient = AppColors.backgroundGradient;
}
