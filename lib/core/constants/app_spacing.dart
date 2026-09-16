import 'package:flutter/material.dart';

/// ============================================================================
/// AppSpacing — échelle d'espacement standard de tout le design system.
///
/// Base 4 px. Utilisez ces constantes partout, jamais de valeurs magiques :
///   SizedBox(height: Spacing.md)
///   EdgeInsets.all(Spacing.lg)
/// ============================================================================
class Spacing {
  Spacing._();

  /// 4 px — micro-espace (icône/texte, gaps internes de chips)
  static const double xs = 4;

  /// 8 px — petit espace (entre deux éléments très liés)
  static const double sm = 8;

  /// 12 px — espace compact (separator, items de liste denses)
  static const double smd = 12;

  /// 16 px — espace de base (padding de cartes, gaps standards)
  static const double md = 16;

  /// 20 px — padding interne des cartes premium
  static const double lg = 20;

  /// 24 px — marges d'écran, padding de dialogs
  static const double xl = 24;

  /// 32 px — respiration entre sections
  static const double xxl = 32;

  /// 48 px — grands espaces (hero, empty states)
  static const double xxxl = 48;

  /// 64 px — espace maximal
  static const double huge = 64;

  /// Padding horizontal standard d'un écran mobile
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: xl);

  /// Padding horizontal d'un écran (tablette / large)
  static const EdgeInsets screenHWide = EdgeInsets.symmetric(horizontal: 32);
}

/// ============================================================================
/// AppRadius — rayons de bordure standardisés.
/// ============================================================================
class AppRadius {
  AppRadius._();

  /// 8 px — petits éléments (badges, mini vignettes)
  static const double xs = 8;

  /// 10 px — chips, petites boîtes
  static const double sm = 10;

  /// 12 px — boutons, inputs
  static const double md = 12;

  /// 14 px — boutons larges, champs principaux
  static const double mlg = 14;

  /// 16 px — cartes standard
  static const double lg = 16;

  /// 20 px — cartes premium
  static const double xl = 20;

  /// 26 px — sheets, modals
  static const double xxl = 26;

  /// Pilule complète
  static const double pill = 999;

  /// BorderRadius prêts à l'emploi
  static final BorderRadius rSm = BorderRadius.circular(sm);
  static final BorderRadius rMd = BorderRadius.circular(md);
  static final BorderRadius rLg = BorderRadius.circular(lg);
  static final BorderRadius rXl = BorderRadius.circular(xl);
  static final BorderRadius rSheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}

/// ============================================================================
/// AppSizes — tailles standards (composants, icônes, cibles tactiles).
/// ============================================================================
class AppSizes {
  AppSizes._();

  // ---- Breakpoints responsive ----
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  // ---- Hauteurs de composants ----
  static const double buttonHeight = 52;
  static const double buttonHeightCompact = 44;
  static const double inputHeight = 56;
  static const double appBarHeight = 64;
  static const double bottomNavHeight = 68;
  static const double listItemMinHeight = 64;
  static const double sheetHandleWidth = 40;
  static const double sheetHandleHeight = 4;

  // ---- Cibles tactiles (accessibilité) ----
  static const double touchTarget = 48;
  static const double iconButtonSize = 44;

  // ---- Avatars & pastilles ----
  static const double avatarXs = 28;
  static const double avatarSm = 40;
  static const double avatarMd = 48;
  static const double avatarLg = 64;

  // ---- Icônes ----
  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconHuge = 48;

  // ---- Barres de progression ----
  static const double progressBarHeight = 8;
}
