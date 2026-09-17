import 'package:flutter/material.dart';

// ============================================================================
// APP COLORS — Palette BouTiKa « Teal / Navy » (design system premium).
//
// Principes :
//  • Accent primaire TEAL dégradé (#0D9488 → #10B981) pour la marque.
//  • Bouton primaire NAVY (#0F172A) : contraste fort, aspect premium.
//  • Fonds gris très clair (#FAFAFA), cartes blanches, ombres douces.
//  • Pastels d'icônes (rose / rouge / violet / orange / bleu / teal…).
//  • Chaque couleur sémantique possède une variante « soft » (fond teinté)
//    ET une variante sombre dédiée (mode sombre complet conservé).
//
// ⚠️ Compatibilité : tous les anciens noms (primary, accent, danger, card,
//    darkPrimary, …) sont conservés — aucun écran existant n'est cassé.
// ============================================================================

/// État du thème partagé par toute l'application.
final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(false);

// ============================================================================
// PALETTE STATIC — accès direct (préférable : DashColors pour le theming)
// ============================================================================
class AppColors {
  AppColors._();

  // -------------------------------------------------------------------
  // LIGHT
  // -------------------------------------------------------------------

  /// Teal signature — couleur d'accent (icônes actives, focus, liens)
  static const Color primary = Color(0xFF0D9488);
  static const Color primarySoft = Color(0xFFCCFBF1);

  /// Couleur du texte / contenu posé sur la couleur primaire
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Départ du dégradé d'accent (teal)
  static const Color gradientStart = Color(0xFF0D9488);

  /// Arrivée du dégradé d'accent (émeraude)
  static const Color gradientEnd = Color(0xFF10B981);

  /// Ambre chaleureux — accent secondaire (dépenses, badges, highlights)
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentSoft = Color(0xFFFEF3C7);

  /// Étoile de notation / rating
  static const Color rating = Color(0xFFFBBF24);
  static const Color ratingSoft = Color(0xFFFEF3C7);

  /// Rouge doux — suppression, erreurs
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEE2E2);

  /// Vert doux — validations, succès, statut « Confirmé »
  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFDCFCE7);

  /// Bleu info
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFDBEAFE);

  /// Orange warning
  static const Color warning = Color(0xFFEA580C);
  static const Color warningSoft = Color(0xFFFFEDD5);

  /// Navy — fond du bouton primaire et des surfaces « flottantes » sombres
  static const Color navy = Color(0xFF0F172A);
  static const Color navySoft = Color(0xFF1E293B);
  static const Color onNavy = Color(0xFFFFFFFF);

  /// Fond général — gris très clair neutre
  static const Color background = Color(0xFFFAFAFA);

  /// Surface des cartes — blanc
  static const Color card = Color(0xFFFFFFFF);

  /// Surface « élevée » (inputs, éléments sur cartes)
  static const Color cardElevated = Color(0xFFFFFFFF);

  /// Champs de recherche / zones remplies sans bordure
  static const Color fill = Color(0xFFF3F4F6);

  /// Bordures — gris ultra léger
  static const Color border = Color(0xFFEDEFF3);

  /// Ligne fine (séparateurs discrets)
  static const Color hairline = Color(0xFFF1F3F6);

  /// Texte principal — encre bleutée (pas de noir pur)
  static const Color textDark = Color(0xFF1A1A2E);

  /// Texte secondaire
  static const Color textGrey = Color(0xFF9CA3AF);

  // -------------------------------------------------------------------
  // PASTELS — fonds arrondis des icônes de catégories (light)
  // -------------------------------------------------------------------
  static const Color pastelRose = Color(0xFFFCE7F3);
  static const Color pastelRed = Color(0xFFFEE2E2);
  static const Color pastelViolet = Color(0xFFEDE9FE);
  static const Color pastelOrange = Color(0xFFFFEDD5);
  static const Color pastelBlue = Color(0xFFDBEAFE);
  static const Color pastelTeal = Color(0xFFCCFBF1);
  static const Color pastelGreen = Color(0xFFDCFCE7);
  static const Color pastelAmber = Color(0xFFFEF3C7);

  /// Fonds pastels dans l'ordre de cyclage des grilles de catégories.
  static const List<Color> pastels = <Color>[
    pastelRose,
    pastelBlue,
    pastelViolet,
    pastelOrange,
    pastelTeal,
    pastelGreen,
    pastelRed,
    pastelAmber,
  ];

  // -------------------------------------------------------------------
  // DARK — navy profond, teal lumineux
  // -------------------------------------------------------------------

  /// Teal lumineux — accents en mode sombre
  static const Color darkPrimary = Color(0xFF2DD4BF);
  static const Color darkPrimarySoft = Color(0xFF0F2E2A);

  /// Contenu posé sur la couleur primaire en mode sombre (contraste ↑)
  static const Color darkOnPrimary = Color(0xFF04211D);

  static const Color darkGradientStart = Color(0xFF0D9488);
  static const Color darkGradientEnd = Color(0xFF10B981);

  static const Color darkAccent = Color(0xFFFBBF24);
  static const Color darkAccentSoft = Color(0xFF3A2E12);

  static const Color darkRating = Color(0xFFFBBF24);
  static const Color darkRatingSoft = Color(0xFF3A2E12);

  static const Color darkDanger = Color(0xFFF87171);
  static const Color darkDangerSoft = Color(0xFF3B1E20);

  static const Color darkSuccess = Color(0xFF4ADE80);
  static const Color darkSuccessSoft = Color(0xFF123524);

  static const Color darkInfo = Color(0xFF60A5FA);
  static const Color darkInfoSoft = Color(0xFF1B2A45);

  static const Color darkWarning = Color(0xFFFB923C);
  static const Color darkWarningSoft = Color(0xFF3B2A18);

  /// Navy du bouton primaire en mode sombre (surface distincte du fond)
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color darkNavySoft = Color(0xFF273449);
  static const Color darkOnNavy = Color(0xFFFFFFFF);

  /// Fond général — navy très sombre (jamais noir pur)
  static const Color darkBackground = Color(0xFF0B1120);

  /// Cartes — niveau 1
  static const Color darkCard = Color(0xFF111C2E);

  /// Cartes — niveau 2 (inputs, zones élevées)
  static const Color darkCardElevated = Color(0xFF16233A);

  /// Zones remplies (recherche) en mode sombre
  static const Color darkFill = Color(0xFF16233A);

  /// Bordures sombres — subtiles
  static const Color darkBorder = Color(0xFF22314A);

  static const Color darkHairline = Color(0xFF1B2739);

  /// Textes sombres
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // -------------------------------------------------------------------
  // PASTELS — variantes sombres (fond teinté, contraste conservé)
  // -------------------------------------------------------------------
  static const Color darkPastelRose = Color(0xFF3B1B33);
  static const Color darkPastelRed = Color(0xFF3D1F20);
  static const Color darkPastelViolet = Color(0xFF2A2350);
  static const Color darkPastelOrange = Color(0xFF3B2A18);
  static const Color darkPastelBlue = Color(0xFF1B2C4A);
  static const Color darkPastelTeal = Color(0xFF11362F);
  static const Color darkPastelGreen = Color(0xFF14361F);
  static const Color darkPastelAmber = Color(0xFF3A2F14);

  static const List<Color> darkPastels = <Color>[
    darkPastelRose,
    darkPastelBlue,
    darkPastelViolet,
    darkPastelOrange,
    darkPastelTeal,
    darkPastelGreen,
    darkPastelRed,
    darkPastelAmber,
  ];
}

// ============================================================================
// DASH COLORS — résolveur contextuel clair / sombre
//
// Usage : final c = DashColors(context);  puis c.primary, c.card, ...
// Réagit au thème courant (via appDarkMode) et reste compatible avec
// tout l'existant de l'application.
// ============================================================================
class DashColors {
  final BuildContext context;
  late final bool _isDark;

  DashColors(this.context) {
    try {
      _isDark = Theme.of(context).brightness == Brightness.dark;
    } catch (_) {
      _isDark = appDarkMode.value;
    }
  }

  bool get isDark => _isDark;

  // ---- Primaire ------------------------------------------------------------
  Color get primary => _isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get primarySoft =>
      _isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft;

  /// Contenu lisible posé sur la couleur primaire
  Color get onPrimary =>
      _isDark ? AppColors.darkOnPrimary : AppColors.onPrimary;

  // ---- Accent (ambre) ------------------------------------------------------
  Color get accent => _isDark ? AppColors.darkAccent : AppColors.accent;
  Color get accentSoft =>
      _isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;

  /// Étoiles de notation
  Color get rating => _isDark ? AppColors.darkRating : AppColors.rating;
  Color get ratingSoft => _isDark ? AppColors.darkRatingSoft : AppColors.ratingSoft;

  // ---- Sémantiques ---------------------------------------------------------
  Color get danger => _isDark ? AppColors.darkDanger : AppColors.danger;
  Color get dangerSoft =>
      _isDark ? AppColors.darkDangerSoft : AppColors.dangerSoft;

  Color get success => _isDark ? AppColors.darkSuccess : AppColors.success;
  Color get successSoft =>
      _isDark ? AppColors.darkSuccessSoft : AppColors.successSoft;

  Color get info => _isDark ? AppColors.darkInfo : AppColors.info;
  Color get infoSoft => _isDark ? AppColors.darkInfoSoft : AppColors.infoSoft;

  Color get warning => _isDark ? AppColors.darkWarning : AppColors.warning;
  Color get warningSoft =>
      _isDark ? AppColors.darkWarningSoft : AppColors.warningSoft;

  // ---- Surfaces ------------------------------------------------------------
  Color get background =>
      _isDark ? AppColors.darkBackground : AppColors.background;
  Color get card => _isDark ? AppColors.darkCard : AppColors.card;
  Color get cardElevated =>
      _isDark ? AppColors.darkCardElevated : AppColors.cardElevated;
  Color get fill => _isDark ? AppColors.darkFill : AppColors.fill;
  Color get border => _isDark ? AppColors.darkBorder : AppColors.border;

  // ---- Textes --------------------------------------------------------------
  Color get textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  Color get textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textGrey;

  // ---- Navy (bouton primaire, barres flottantes) ---------------------------
  Color get navy => _isDark ? AppColors.darkNavy : AppColors.navy;
  Color get navySoft => _isDark ? AppColors.darkNavySoft : AppColors.navySoft;
  Color get onNavy => _isDark ? AppColors.darkOnNavy : AppColors.onNavy;

  /// Fond du bouton primaire (pilule navy).
  Color get buttonPrimary => navy;

  /// Texte du bouton primaire.
  Color get buttonOnPrimary => onNavy;

  /// Bordure fine du bouton navy en mode sombre (détache la surface du fond).
  Color get buttonPrimaryBorder =>
      _isDark ? Colors.white.withValues(alpha: 0.10) : Colors.transparent;

  /// Fond translucide de la pilule active d'une barre flottante navy.
  Color get navPill => Colors.white.withValues(alpha: _isDark ? 0.16 : 0.14);

  /// Icône active sur une barre flottante navy.
  Color get navOnNavy => Colors.white;

  /// Icône inactive sur une barre flottante navy.
  Color get navOnNavyMuted => Colors.white.withValues(alpha: 0.55);

  /// Ombre prononcée (barres flottantes, FAB)
  Color get navShadowColor => Colors.black.withValues(alpha: _isDark ? 0.55 : 0.22);

  // ---- Dégradés ------------------------------------------------------------
  /// Couleurs du dégradé d'accent (teal → émeraude).
  List<Color> get gradientColors => _isDark
      ? const [AppColors.darkGradientStart, AppColors.darkGradientEnd]
      : const [AppColors.gradientStart, AppColors.gradientEnd];

  /// Dégradé d'accent, diagonal (topLeft → bottomRight).
  LinearGradient get accentGradient => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Dégradé d'accent horizontal (bandeaux, tags pleine largeur).
  LinearGradient get accentGradientH => LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  // ---- Pastels (fonds d'icônes de catégories) ------------------------------
  /// Palette pastel disponible dans le thème courant.
  List<Color> get pastels =>
      _isDark ? AppColors.darkPastels : AppColors.pastels;

  /// Pastel cyclique — `c.pastelAt(index)` pour varier les grilles.
  Color pastelAt(int index) {
    final List<Color> p = pastels;
    if (p.isEmpty) return cardElevated;
    final int i = index % p.length;
    return p[i < 0 ? i + p.length : i];
  }

  // ---- Ombres adaptées au thème -------------------------------------------
  /// Ombre standard des cartes — « soft elevation » (blur 20, y 8, 5 %).
  List<BoxShadow> get cardShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];

  /// Ombre plus appuyée (éléments flottants : nav bar, FAB, price tag).
  List<BoxShadow> get floatingShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ];

  /// Ombre légère (bottom nav posée, top bar)
  List<BoxShadow> get subtleShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ];

  // ---- Helpers historiques (compatibilité) --------------------------------
  /// Couleur du fond pill greeting (top bar)
  Color get greetingPill =>
      _isDark ? const Color(0xFFE65100) : Colors.orange;

  /// Couleur icônes top bar
  Color get topBarIcon =>
      _isDark ? AppColors.darkTextPrimary : Colors.black87;

  /// Fond boutons icônes top bar
  Color get topBarIconBg => _isDark ? AppColors.darkCard : Colors.white;

  /// Fond général pill / badge
  Color get badgeBg => _isDark ? AppColors.darkCardElevated : AppColors.fill;

  // ---- Helpers premium ----------------------------------------------------
  /// Couleur de surface des barrières (dialogs / sheets)
  Color get barrier => Colors.black.withValues(alpha: _isDark ? 0.6 : 0.45);

  /// Couleurs du shimmer
  Color get shimmerBase =>
      _isDark ? const Color(0xFF1E293B) : const Color(0xFFE9ECF1);
  Color get shimmerHighlight =>
      _isDark ? const Color(0xFF2A3A52) : const Color(0xFFF8FAFC);

  /// Halo utilisé derrière les illustrations / hero
  Color get glow => primary.withValues(alpha: _isDark ? 0.16 : 0.10);

  /// Ligne fine intérieure (séparateurs discrets)
  Color get hairline =>
      _isDark ? AppColors.darkHairline : AppColors.hairline;
}
