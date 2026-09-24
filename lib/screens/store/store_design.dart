import 'package:flutter/material.dart';

/// ============================================================================
/// STORE DESIGN SYSTEM — jetons visuels DÉDIÉS à `store_page.dart`.
///
/// ⚠️ Périmètre : ce fichier est une déclinaison LOCALE du design system.
///    Il ne remplace pas `core/theme/app_colors.dart` (qui reste la palette de
///    référence des autres écrans). Seule la page Boutique consomme ces jetons.
///
/// Contenu (valeurs exactes de la spécification) :
///   • StoreColors      → palette (lavande / pink / purple / neutres)
///   • StoreTextStyles  → typographie SF Pro Display
///   • StoreDimensions  → rayons, espacements, ombres
///   • StorePalette     → résolveur clair / sombre (comme DashColors)
///
/// Aucune logique métier ici : uniquement des constantes de présentation.
/// ============================================================================

// ---------------------------------------------------------------------------
// 1. PALETTE
// ---------------------------------------------------------------------------
class StoreColors {
  StoreColors._();

  // ------------------------------------------------------------------
  // Couleurs principales
  // ------------------------------------------------------------------

  /// Lavande clair — haut du dégradé de fond
  static const Color primaryGradientStart = Color(0xFFE8E4F3);

  /// Blanc cassé — bas du dégradé de fond
  static const Color primaryGradientEnd = Color(0xFFF5F5F7);

  /// Fond général de l'écran
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Surface des cartes
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ------------------------------------------------------------------
  // Accents
  // ------------------------------------------------------------------
  static const Color accentPink = Color(0xFFE91E8C);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color badgeRed = Color(0xFFFF3B30);
  static const Color accentGreen = Color(0xFF4CAF50);

  // ------------------------------------------------------------------
  // Textes
  // ------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFB0B0B5);

  // ------------------------------------------------------------------
  // Étoiles / Rating
  // ------------------------------------------------------------------
  static const Color starYellow = Color(0xFFFFC107);

  // ------------------------------------------------------------------
  // Boutons / Pills
  // ------------------------------------------------------------------
  static const Color pillBackground = Color(0xFFF2F2F7);
  static const Color pillActiveText = Color(0xFF000000);
  static const Color pillInactiveText = Color(0xFFAEAEB2);

  // ------------------------------------------------------------------
  // Dégradé de fond principal
  // ------------------------------------------------------------------
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ------------------------------------------------------------------
  // Dérivés (mêmes familles, pour les fonds teintés et les séparateurs)
  // ------------------------------------------------------------------

  /// Séparateur neutre très clair (hairline)
  static const Color divider = Color(0xFFEFEFF3);

  /// Bordure fine neutre
  static const Color borderLight = Color(0xFFE5E5EA);

  /// Fonds teintés des accents (pastilles d'icônes)
  static const Color accentPinkSoft = Color(0xFFFDEBF5);
  static const Color accentPurpleSoft = Color(0xFFF4E9F7);
  static const Color accentGreenSoft = Color(0xFFE8F5E9);
  static const Color badgeRedSoft = Color(0xFFFFEBEA);
  static const Color starYellowSoft = Color(0xFFFFF7E0);

  /// Dégradé d'écran : lavande en tête, puis blanc cassé (le dégradé de la
  /// spécification remplit le haut avant de se fondre dans le fond général).
  static const LinearGradient screenGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd, backgroundLight],
    stops: [0.0, 0.45, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Dégradé encre (pilules et boutons d'action forts)
  static const LinearGradient inkGradient = LinearGradient(
    colors: [Color(0xFF232326), Color(0xFF121214)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Pastels d'icônes — teintes claires des accents ci-dessus.
  static const List<Color> pastels = <Color>[
    accentPurpleSoft,
    accentPinkSoft,
    accentGreenSoft,
    starYellowSoft,
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    badgeRedSoft,
    pillBackground,
  ];

  // ------------------------------------------------------------------
  // Variantes SOMBRE (le mode sombre reste supporté)
  // ------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF121214);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkFill = Color(0xFF2C2C2E);
  static const Color darkBorder = Color(0xFF38383A);
  static const Color darkHairline = Color(0xFF2C2C2E);
  static const Color darkDivider = Color(0xFF2C2C2E);

  static const Color darkTextPrimary = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFF9A9AA1);
  static const Color darkTextTertiary = Color(0xFF6E6E73);

  /// En sombre, l'encre s'inverse : pastille claire, texte sombre.
  static const Color darkInk = Color(0xFFF2F2F7);
  static const Color darkOnInk = Color(0xFF1A1A1A);

  static const Color darkAccentPink = Color(0xFFFF6FB5);
  static const Color darkAccentPurple = Color(0xFFCE93D8);
  static const Color darkBadgeRed = Color(0xFFFF6B61);
  static const Color darkAccentGreen = Color(0xFF81C784);

  static const Color darkAccentPinkSoft = Color(0xFF33202B);
  static const Color darkAccentPurpleSoft = Color(0xFF2A2130);
  static const Color darkAccentGreenSoft = Color(0xFF1E3221);
  static const Color darkBadgeRedSoft = Color(0xFF3A2320);
  static const Color darkStarYellowSoft = Color(0xFF38321C);

  static const LinearGradient darkScreenGradient = LinearGradient(
    colors: [Color(0xFF1B1826), darkBackground],
    stops: [0.0, 0.45],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const List<Color> darkPastels = <Color>[
    darkAccentPurpleSoft,
    darkAccentPinkSoft,
    darkAccentGreenSoft,
    darkStarYellowSoft,
    Color(0xFF1D2531),
    Color(0xFF281F2E),
    darkBadgeRedSoft,
    darkFill,
  ];
}

// ---------------------------------------------------------------------------
// 2. TYPOGRAPHIE
// ---------------------------------------------------------------------------
/// Polices : **SF Pro Display** (spécification).
///
/// SF Pro n'étant pas distribuable avec l'application, une liste de repli est
/// déclarée : `Poppins` (déjà embarquée via `google_fonts` et utilisée par le
/// reste de l'app) puis `Inter`, puis la police système. Pour activer SF Pro
/// pour de vrai : déposer les `.ttf` dans `assets/fonts/` et les déclarer dans
/// `pubspec.yaml` sous la famille « SF Pro Display ».
class StoreTextStyles {
  StoreTextStyles._();

  static const String fontFamily = 'SF Pro Display';

  /// Repli explicite (aucune erreur si SF Pro est absente).
  static const List<String> fontFamilyFallback = <String>['Poppins', 'Inter'];

  // ------------------------------------------------------------------
  // Styles de la spécification
  // ------------------------------------------------------------------

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: StoreColors.textPrimary,
  );

  static const TextStyle productTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: StoreColors.textPrimary,
  );

  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: StoreColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: StoreColors.textSecondary,
  );

  static const TextStyle pillText = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ------------------------------------------------------------------
  // Déclinaisons (même échelle, pour les libellés de la page)
  // ------------------------------------------------------------------

  /// 13 / w500 — petite ligne grise du header
  static const TextStyle eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: StoreColors.textSecondary,
  );

  /// 17.5 / w600 — titre fort (nom de boutique)
  static const TextStyle name = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 17.5,
    fontWeight: FontWeight.w600,
    color: StoreColors.textPrimary,
  );

  /// 15 / w600 — titre de section
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: StoreColors.textPrimary,
  );

  /// 14 / w600 — titre de carte / de ligne
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: StoreColors.textPrimary,
  );

  /// 26 / w700 — grand chiffre (KPI)
  static const TextStyle metric = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: StoreColors.textPrimary,
  );

  /// 12 / w500 — libellé gris
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: StoreColors.textSecondary,
  );

  /// 11 / w600 / espacé — surtitre
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.9,
    color: StoreColors.textLight,
  );

  /// 12 / w400 — métadonnée très discrète
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: StoreColors.textLight,
  );

  /// 11.5 / w600 — pastille / badge de statut
  static const TextStyle chip = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
  );

  /// 14 / w600 — libellé de bouton
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// 12 / w500 — libellé d'onglet
  static const TextStyle tab = pillText;

  /// 16 / w700 — prix mis en avant
  static const TextStyle priceLarge = price;

  /// Applique une couleur sans casser l'immutabilité.
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);
}

// ---------------------------------------------------------------------------
// 3. DIMENSIONS (rayons, espacements, ombres)
// ---------------------------------------------------------------------------
class StoreDimensions {
  StoreDimensions._();

  // ---- Border Radius -------------------------------------------------------
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusPill = 100.0;

  /// Feuilles modales (bas d'écran) — ajout local, valeur de l'ancien UI.
  static const double radiusSheet = 26.0;

  // ---- Spacing -------------------------------------------------------------
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;

  /// Marge horizontale d'écran de l'ancien UI (20 px).
  static const double screenPadding = 20.0;

  /// Décalage du dégradé : hauteur de lavande en tête d'écran.
  static const double gradientLavenderStop = 0.45;

  // ---- Shadows -------------------------------------------------------------
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// Éléments flottants (nav, FAB) — un cran au-dessus des cartes.
  static List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Pilule active (onglet / segment) — ombre très douce posée.
  static List<BoxShadow> activePillShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ---- BorderRadius prêts à l'emploi --------------------------------------
  static final BorderRadius rSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius rMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius rLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius rPill = BorderRadius.circular(radiusPill);
  static final BorderRadius rSheet = BorderRadius.vertical(
    top: Radius.circular(radiusSheet),
  );

  // ---- Edgeinsets fréquents ------------------------------------------------
  static const EdgeInsets paddingAllM = EdgeInsets.all(paddingM);
  static const EdgeInsets paddingAllL = EdgeInsets.all(paddingL);
  static const EdgeInsets screenH =
      EdgeInsets.symmetric(horizontal: screenPadding);
}

// ---------------------------------------------------------------------------
// 4. RÉSOLVEUR CLAIR / SOMBRE
// ---------------------------------------------------------------------------
///   final p = StorePalette(context);
///   Container(color: p.card, decoration: BoxDecoration(gradient: p.gradient))
///
/// Le mode sombre est conservé : les jetons basculent automatiquement.
class StorePalette {
  final BuildContext context;
  final bool isDark;

  StorePalette(this.context) : isDark = _resolveDark(context);

  /// Tolérant : un context hors MaterialApp ne fait pas planter le rendu.
  static bool _resolveDark(BuildContext context) {
    try {
      return Theme.of(context).brightness == Brightness.dark;
    } catch (_) {
      return false;
    }
  }

  // ---- Surfaces / fonds ----------------------------------------------------
  Color get background =>
      isDark ? StoreColors.darkBackground : StoreColors.backgroundLight;
  Color get card => isDark ? StoreColors.darkCard : StoreColors.cardBackground;
  Color get cardElevated => card;
  Color get cardBackground => card;
  Color get fill => isDark ? StoreColors.darkFill : StoreColors.pillBackground;
  Color get pillBackground =>
      isDark ? StoreColors.darkFill : StoreColors.pillBackground;
  Color get border => isDark ? StoreColors.darkBorder : StoreColors.borderLight;
  Color get hairline => isDark ? StoreColors.darkHairline : StoreColors.divider;
  Color get divider => isDark ? StoreColors.darkDivider : StoreColors.divider;

  /// Dégradé de fond de la page (lavande → blanc cassé en clair).
  LinearGradient get gradient => isDark
      ? StoreColors.darkScreenGradient
      : StoreColors.screenGradient;

  // ---- Textes --------------------------------------------------------------
  Color get textPrimary =>
      isDark ? StoreColors.darkTextPrimary : StoreColors.textPrimary;
  Color get textSecondary =>
      isDark ? StoreColors.darkTextSecondary : StoreColors.textSecondary;
  Color get textTertiary =>
      isDark ? StoreColors.darkTextTertiary : StoreColors.textLight;
  Color get textLight => textTertiary;

  // ---- Encre (actions fortes, boutons circulaires, pilules) ---------------
  Color get ink => isDark ? StoreColors.darkInk : StoreColors.textPrimary;
  Color get onInk => isDark ? StoreColors.darkOnInk : StoreColors.cardBackground;
  LinearGradient get inkGradient => StoreColors.inkGradient;

  // ---- Accents -------------------------------------------------------------
  Color get accentPink =>
      isDark ? StoreColors.darkAccentPink : StoreColors.accentPink;
  Color get accentPurple =>
      isDark ? StoreColors.darkAccentPurple : StoreColors.accentPurple;
  Color get accentGreen =>
      isDark ? StoreColors.darkAccentGreen : StoreColors.accentGreen;

  Color get accentPinkSoft =>
      isDark ? StoreColors.darkAccentPinkSoft : StoreColors.accentPinkSoft;
  Color get accentPurpleSoft =>
      isDark ? StoreColors.darkAccentPurpleSoft : StoreColors.accentPurpleSoft;
  Color get accentGreenSoft =>
      isDark ? StoreColors.darkAccentGreenSoft : StoreColors.accentGreenSoft;

  /// Alias sémantiques utilisés par la page.
  Color get primary => accentPurple;
  Color get primarySoft => accentPurpleSoft;
  Color get onPrimary => isDark ? StoreColors.darkTextPrimary : Colors.white;
  Color get accent => accentPink;
  Color get accentSoft => accentPinkSoft;
  Color get danger => isDark ? StoreColors.darkBadgeRed : StoreColors.badgeRed;
  Color get dangerSoft =>
      isDark ? StoreColors.darkBadgeRedSoft : StoreColors.badgeRedSoft;
  Color get success =>
      isDark ? StoreColors.darkAccentGreen : StoreColors.accentGreen;
  Color get successSoft => accentGreenSoft;
  Color get badgeRed => danger;
  Color get starYellow => StoreColors.starYellow;

  // ---- Ombres --------------------------------------------------------------
  List<BoxShadow> get cardShadow => StoreDimensions.cardShadow;
  List<BoxShadow> get softShadow => StoreDimensions.softShadow;
  List<BoxShadow> get floatingShadow => StoreDimensions.floatingShadow;
  List<BoxShadow> get activePillShadow => StoreDimensions.activePillShadow;
  Color get barrier => Colors.black.withValues(alpha: isDark ? 0.6 : 0.32);

  // ---- Wash (carte teintée : pastel → blanc) -------------------------------
  LinearGradient wash({Color? tint}) {
    final Color base = tint ?? pastelAt(0);
    return LinearGradient(
      colors: [base, Color.lerp(base, card, 0.55) ?? card],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ---- Pastels -------------------------------------------------------------
  List<Color> get pastels =>
      isDark ? StoreColors.darkPastels : StoreColors.pastels;

  Color pastelAt(int index) {
    final List<Color> p = pastels;
    if (p.isEmpty) return cardElevated;
    final int i = index % p.length;
    return p[i < 0 ? i + p.length : i];
  }

  // ---- Navigation flottante ------------------------------------------------
  Color get navSurface => card;
  Color get navPill => fill;
  Color get navActive => ink;
  Color get navInactive =>
      isDark ? StoreColors.darkTextTertiary : StoreColors.pillInactiveText;
  Color get navShadowColor =>
      Colors.black.withValues(alpha: isDark ? 0.45 : 0.07);
}
