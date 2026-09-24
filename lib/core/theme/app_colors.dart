import 'package:flutter/material.dart';

// ============================================================================
// APP COLORS — palette unique de l'application (design system « Lavande »).
//
// Identité visuelle :
//   • Fond dégradé LAVANDE très clair (#E8E4F3 → #F5F5F7)
//   • Surfaces blanches, texte encre (#1A1A1A), gris iOS (#8E8E93)
//   • Accents PINK (#E91E8C) et PURPLE (#9C27B0) utilisés avec parcimonie
//   • Badges rouges (#FF3B30), étoiles ambre (#FFC107), vert validation (#4CAF50)
//   • Pills : piste #F2F2F7, texte actif #000000, inactif #AEAEB2
//
// Rôles sémantiques (API conservée — aucun écran cassé) :
//   ink     → actions (boutons pillules noirs), icônes actives, titres
//   primary → violet (marque, états interactifs : focus, progression)
//   accent  → rose (alertes douces, points, chiffres clés)
//   card    → surface blanche ; fill → zone remplie neutre ; border → trait fin
//
// ⚠️ Tous les anciens noms restent disponibles : primary, accent, danger, card,
//    navy, darkPrimary, pastels… La valeur change, jamais le nom.
// ============================================================================

/// État du thème partagé par toute l'application.
final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(false);

// ============================================================================
// PALETTE STATIC — accès direct (préférable : DashColors pour le theming)
// ============================================================================
class AppColors {
  AppColors._();

  // -------------------------------------------------------------------
  // COULEURS PRINCIPALES (spécification)
  // -------------------------------------------------------------------

  /// Lavande clair — haut du dégradé de fond
  static const Color primaryGradientStart = Color(0xFFE8E4F3);

  /// Blanc cassé — bas du dégradé de fond
  static const Color primaryGradientEnd = Color(0xFFF5F5F7);

  /// Fond général de l'écran
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Surface des cartes
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Dégradé de fond principal de l'application.
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // -------------------------------------------------------------------
  // ACCENTS
  // -------------------------------------------------------------------
  static const Color accentPink = Color(0xFFE91E8C);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color badgeRed = Color(0xFFFF3B30);
  static const Color accentGreen = Color(0xFF4CAF50);

  // -------------------------------------------------------------------
  // TEXTES
  // -------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFB0B0B5);

  // -------------------------------------------------------------------
  // ÉTOILES / RATING
  // -------------------------------------------------------------------
  static const Color starYellow = Color(0xFFFFC107);

  // -------------------------------------------------------------------
  // BOUTONS / PILLS
  // -------------------------------------------------------------------
  static const Color pillBackground = Color(0xFFF2F2F7);
  static const Color pillActiveText = Color(0xFF000000);
  static const Color pillInactiveText = Color(0xFFAEAEB2);

  // -------------------------------------------------------------------
  // NEUTRES (surfaces, traits)
  // -------------------------------------------------------------------

  /// Fond général (alias historique de [backgroundLight]).
  static const Color background = backgroundLight;

  /// Voile haut d'écran — bas du dégradé lavande.
  static const Color backgroundWash = primaryGradientEnd;

  /// Cartes — blanc pur.
  static const Color card = cardBackground;
  static const Color cardElevated = cardBackground;

  /// Zones remplies sans bordure (recherche, chips neutres).
  static const Color fill = pillBackground;
  static const Color fillStrong = Color(0xFFE8E8ED);

  /// Bordures / lignes fines.
  static const Color border = Color(0xFFE5E5EA);
  static const Color borderLight = border;
  static const Color hairline = Color(0xFFEFEFF3);
  static const Color divider = hairline;

  /// Textes (alias sémantiques).
  static const Color textDark = textPrimary;
  static const Color textGrey = textSecondary;
  static const Color textTertiary = textLight;

  /// Encre — boutons pillules, icônes actives, surfaces fortes.
  static const Color ink = textPrimary;
  static const Color inkSoft = Color(0xFF333336);
  static const Color onInk = Color(0xFFFFFFFF);

  // -------------------------------------------------------------------
  // MARQUE (primary = violet) & ACCENT (accent = rose)
  // -------------------------------------------------------------------
  static const Color primary = accentPurple;
  static const Color primarySoft = Color(0xFFF4E9F7);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color accent = accentPink;
  static const Color accentSoft = Color(0xFFFDEBF5);
  static const Color accentDeep = Color(0xFFC2185B);

  /// Étoile de notation (ambre).
  static const Color rating = starYellow;
  static const Color ratingSoft = Color(0xFFFFF7E0);

  // -------------------------------------------------------------------
  // SÉMANTIQUES
  // -------------------------------------------------------------------
  static const Color danger = badgeRed;
  static const Color dangerSoft = Color(0xFFFFEBEA);

  static const Color success = accentGreen;
  static const Color successSoft = Color(0xFFE8F5E9);

  static const Color info = Color(0xFF5E5CE6);
  static const Color infoSoft = Color(0xFFEAE9FD);

  static const Color warning = Color(0xFFFF9F0A);
  static const Color warningSoft = Color(0xFFFFF3E0);

  /// Alias de l'encre (compatibilité avec l'ancienne API `navy`).
  static const Color navy = ink;
  static const Color navySoft = inkSoft;
  static const Color onNavy = onInk;

  // -------------------------------------------------------------------
  // PASTELS — fonds d'icônes (teintes claires de la famille)
  // -------------------------------------------------------------------
  static const Color pastelPeach = accentSoft; // rose très clair
  static const Color pastelBlue = Color(0xFFE8F0FE);
  static const Color pastelViolet = primarySoft;
  static const Color pastelMint = successSoft;
  static const Color pastelSand = ratingSoft;
  static const Color pastelRose = dangerSoft;
  static const Color pastelGrey = pillBackground;
  static const Color pastelSky = Color(0xFFEAF3FB);
  static const Color pastelLavender = primaryGradientStart;

  /// Anciens noms conservés (mêmes teintes de la famille).
  static const Color pastelRed = pastelRose;
  static const Color pastelOrange = pastelSand;
  static const Color pastelTeal = pastelMint;
  static const Color pastelGreen = pastelMint;
  static const Color pastelAmber = pastelSand;

  /// Ordre de cyclage des grilles de catégories.
  static const List<Color> pastels = <Color>[
    pastelViolet,
    pastelPeach,
    pastelMint,
    pastelSand,
    pastelBlue,
    pastelLavender,
    pastelRose,
    pastelGrey,
  ];

  // -------------------------------------------------------------------
  // DÉGRADÉS
  // -------------------------------------------------------------------

  /// Dégradé de marque (violet → rose) — logo, CTA de mise en avant.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [accentPurple, accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dégradé encre (pilules et boutons d'action forts).
  static const LinearGradient inkGradient = LinearGradient(
    colors: [Color(0xFF232326), Color(0xFF121214)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // -------------------------------------------------------------------
  // DARK — neutres profonds de la même famille
  // -------------------------------------------------------------------

  static const Color darkBackground = Color(0xFF121214);
  static const Color darkBackgroundWash = Color(0xFF1B1826);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkCardElevated = Color(0xFF2C2C2E);
  static const Color darkFill = Color(0xFF2C2C2E);
  static const Color darkFillStrong = Color(0xFF3A3A3C);
  static const Color darkBorder = Color(0xFF38383A);
  static const Color darkHairline = Color(0xFF2C2C2E);
  static const Color darkDivider = darkHairline;

  static const Color darkTextPrimary = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFF9A9AA1);
  static const Color darkTextTertiary = Color(0xFF6E6E73);

  /// En mode sombre, l'encre s'inverse : pastille claire + texte sombre.
  static const Color darkInk = Color(0xFFF2F2F7);
  static const Color darkInkSoft = Color(0xFFDCDCDE);
  static const Color darkOnInk = Color(0xFF1A1A1A);

  static const Color darkPrimary = Color(0xFFCE93D8);
  static const Color darkPrimarySoft = Color(0xFF2E2133);
  static const Color darkOnPrimary = Color(0xFF1A1A1A);

  static const Color darkAccentPink = Color(0xFFFF6FB5);
  static const Color darkAccent = darkAccentPink;
  static const Color darkAccentSoft = Color(0xFF33202B);
  static const Color darkAccentDeep = Color(0xFFFF8FC5);

  static const Color darkBadgeRed = Color(0xFFFF6B61);
  static const Color darkDanger = darkBadgeRed;
  static const Color darkDangerSoft = Color(0xFF3A2320);

  static const Color darkAccentGreen = Color(0xFF81C784);
  static const Color darkSuccess = darkAccentGreen;
  static const Color darkSuccessSoft = Color(0xFF1E3221);

  static const Color darkStarYellow = Color(0xFFFFD54F);
  static const Color darkRating = darkStarYellow;
  static const Color darkRatingSoft = Color(0xFF38321C);

  static const Color darkInfo = Color(0xFF9FA8FF);
  static const Color darkInfoSoft = Color(0xFF262A3D);

  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkWarningSoft = Color(0xFF332A1A);

  static const Color darkNavy = darkInk;
  static const Color darkNavySoft = darkInkSoft;
  static const Color darkOnNavy = darkOnInk;

  // Pastels sombres (teintes profondes, jamais vives)
  static const Color darkPastelPeach = darkAccentSoft;
  static const Color darkPastelBlue = Color(0xFF1D2531);
  static const Color darkPastelViolet = darkPrimarySoft;
  static const Color darkPastelMint = darkSuccessSoft;
  static const Color darkPastelSand = darkRatingSoft;
  static const Color darkPastelRose = darkDangerSoft;
  static const Color darkPastelGrey = darkFill;
  static const Color darkPastelSky = Color(0xFF1D2A31);
  static const Color darkPastelLavender = Color(0xFF241F33);

  static const Color darkPastelRed = darkPastelRose;
  static const Color darkPastelOrange = darkPastelSand;
  static const Color darkPastelTeal = darkPastelMint;
  static const Color darkPastelGreen = darkPastelMint;
  static const Color darkPastelAmber = darkPastelSand;

  static const List<Color> darkPastels = <Color>[
    darkPastelViolet,
    darkPastelPeach,
    darkPastelMint,
    darkPastelSand,
    darkPastelBlue,
    darkPastelLavender,
    darkPastelRose,
    darkPastelGrey,
  ];
}

// ============================================================================
// DASH COLORS — résolveur contextuel clair / sombre
//
// Usage : final c = DashColors(context);  puis c.ink, c.card, c.accent…
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

  // ---- Encre (actions, icônes actives) -------------------------------------
  Color get ink => _isDark ? AppColors.darkInk : AppColors.ink;
  Color get inkSoft => _isDark ? AppColors.darkInkSoft : AppColors.inkSoft;
  Color get onInk => _isDark ? AppColors.darkOnInk : AppColors.onInk;

  /// Alias historiques
  Color get navy => ink;
  Color get navySoft => inkSoft;
  Color get onNavy => onInk;

  // ---- Primaire (violet de marque) -----------------------------------------
  Color get primary => _isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get primarySoft =>
      _isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft;
  Color get onPrimary =>
      _isDark ? AppColors.darkOnPrimary : AppColors.onPrimary;

  // ---- Accent (rose) -------------------------------------------------------
  Color get accent => _isDark ? AppColors.darkAccent : AppColors.accent;
  Color get accentSoft =>
      _isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;
  Color get accentDeep =>
      _isDark ? AppColors.darkAccentDeep : AppColors.accentDeep;

  /// Accents nommés de la spécification (rose / violet / vert / rouge).
  Color get accentPink =>
      _isDark ? AppColors.darkAccentPink : AppColors.accentPink;
  Color get accentPurple => primary;
  Color get accentGreen =>
      _isDark ? AppColors.darkAccentGreen : AppColors.accentGreen;
  Color get accentPinkSoft =>
      _isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;
  Color get accentPurpleSoft => primarySoft;
  Color get accentGreenSoft =>
      _isDark ? AppColors.darkSuccessSoft : AppColors.successSoft;
  Color get accentPinkSoftDeep => accentSoft;

  /// Badge rouge (pastilles de notification / compteurs).
  Color get badgeRed => _isDark ? AppColors.darkBadgeRed : AppColors.badgeRed;
  Color get badgeRedSoft => dangerSoft;

  /// Étoile de notation.
  Color get starYellow =>
      _isDark ? AppColors.darkStarYellow : AppColors.starYellow;
  Color get starYellowSoft => ratingSoft;

  // ---- Notation ------------------------------------------------------------
  Color get rating => _isDark ? AppColors.darkRating : AppColors.rating;
  Color get ratingSoft =>
      _isDark ? AppColors.darkRatingSoft : AppColors.ratingSoft;

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

  /// Alias explicites de la spécification.
  Color get backgroundLight => background;
  Color get cardBackground => card;

  /// Voile très pâle utilisé en haut d'écran (dégradé doux).
  Color get backgroundWash =>
      _isDark ? AppColors.darkBackgroundWash : AppColors.backgroundWash;

  Color get card => _isDark ? AppColors.darkCard : AppColors.card;
  Color get cardElevated =>
      _isDark ? AppColors.darkCardElevated : AppColors.cardElevated;
  Color get fill => _isDark ? AppColors.darkFill : AppColors.fill;
  Color get fillStrong =>
      _isDark ? AppColors.darkFillStrong : AppColors.fillStrong;
  Color get border => _isDark ? AppColors.darkBorder : AppColors.border;
  Color get hairline => _isDark ? AppColors.darkHairline : AppColors.hairline;
  Color get divider => hairline;

  /// Piste et textes des pills (onglets / filtres).
  Color get pillBackground => fill;
  Color get pillActiveText =>
      _isDark ? AppColors.darkTextPrimary : AppColors.pillActiveText;
  Color get pillInactiveText =>
      _isDark ? AppColors.darkTextTertiary : AppColors.pillInactiveText;

  // ---- Textes --------------------------------------------------------------
  Color get textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  Color get textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textGrey;
  Color get textTertiary =>
      _isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
  Color get textLight => textTertiary;

  // ---- Bouton primaire (pilule encre) --------------------------------------
  /// Fond du bouton primaire — noir doux en clair, pastille claire en sombre.
  Color get buttonPrimary => ink;

  /// Texte du bouton primaire.
  Color get buttonOnPrimary => onInk;

  /// Bordure fine (détache la pastille claire en mode sombre).
  Color get buttonPrimaryBorder =>
      _isDark ? Colors.transparent : Colors.transparent;

  // ---- Barre de navigation flottante (claire, premium) --------------------
  /// Surface de la barre : blanc en clair, carte sombre en sombre.
  Color get navSurface => card;

  /// Pastille de l'onglet actif : gris très clair / voile blanc en sombre.
  Color get navPill => fill;

  /// Icône active (encre) / inactive (gris).
  Color get navActive => ink;
  Color get navInactive =>
      _isDark ? const Color(0xFF7E7E86) : AppColors.pillInactiveText;

  /// Compatibilité (ancienne barre navy)
  Color get navOnNavy => onInk;
  Color get navOnNavyMuted => _isDark
      ? Colors.white.withValues(alpha: 0.55)
      : Colors.black.withValues(alpha: 0.42);

  /// Ombre de la barre flottante.
  Color get navShadowColor =>
      Colors.black.withValues(alpha: _isDark ? 0.45 : 0.07);

  // ---- Dégradés -----------------------------------------------------------
  /// Dégradé de marque (violet → rose), réservé au logo / héro.
  List<Color> get gradientColors => _isDark
      ? const [Color(0xFF7E57C2), Color(0xFFE91E8C)]
      : const [Color(0xFF9C27B0), Color(0xFFE91E8C)];

  LinearGradient get accentGradient => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get accentGradientH => LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// Dégradé de fond de l'écran : lavande → blanc cassé (clair),
  /// neutre profond (sombre). Toutes les pages l'utilisent.
  LinearGradient get backgroundGradient => _isDark
      ? const LinearGradient(
          colors: [AppColors.darkBackgroundWash, AppColors.darkBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  /// Alias court de [backgroundGradient].
  LinearGradient get gradient => backgroundGradient;

  /// Dégradé d'écran long : lavande en tête puis fond général.
  LinearGradient get screenGradient => _isDark
      ? backgroundGradient
      : const LinearGradient(
          colors: [
            AppColors.primaryGradientStart,
            AppColors.primaryGradientEnd,
            AppColors.backgroundLight,
          ],
          stops: [0.0, 0.45, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  /// Wash « carte d'info » : teinte pâle → blanc (la couleur n'est qu'une trace).
  LinearGradient wash({Color? tint}) {
    final Color base = tint ?? accentSoft;
    return LinearGradient(
      colors: [
        base,
        Color.lerp(base, card, 0.55) ?? card,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Wash encre (carte forte, texte blanc) — usage rare et volontaire.
  LinearGradient get inkWash => _isDark
      ? const LinearGradient(
          colors: [Color(0xFF26262C), Color(0xFF1B1B20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : AppColors.inkGradient;

  /// Halo très diffus (illustrations).
  Color get glow => primary.withValues(alpha: _isDark ? 0.10 : 0.06);

  // ---- Pastels (fonds d'icônes) --------------------------------------------
  List<Color> get pastels =>
      _isDark ? AppColors.darkPastels : AppColors.pastels;

  Color pastelAt(int index) {
    final List<Color> p = pastels;
    if (p.isEmpty) return cardElevated;
    final int i = index % p.length;
    return p[i < 0 ? i + p.length : i];
  }

  // ---- Ombres : « soft elevation » (très diffuses, jamais marquées) --------
  /// Ombre standard des cartes — 5 % noir, blur 10, y 4.
  List<BoxShadow> get cardShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];

  /// Ombre très légère (pilules actives, petits éléments posés) — 3 %, blur 6.
  List<BoxShadow> get softShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];

  /// Ombre des éléments flottants (nav, FAB, tag) — 8 %, blur 20, y 8.
  List<BoxShadow> get floatingShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];

  /// Ombre du segment actif d'une barre de pills — 6 %, blur 8, y 2.
  List<BoxShadow> get activePillShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];

  /// Ombre légère posée (top bar)
  List<BoxShadow> get subtleShadow => softShadow;

  // ---- Helpers historiques (compatibilité) --------------------------------
  /// Fond pill greeting (top bar) — désormais neutre et discret
  Color get greetingPill => fill;

  Color get topBarIcon => _isDark ? AppColors.darkTextPrimary : AppColors.ink;

  Color get topBarIconBg => card;

  Color get badgeBg => fill;

  // ---- Helpers premium ----------------------------------------------------
  Color get barrier => Colors.black.withValues(alpha: _isDark ? 0.6 : 0.32);

  Color get shimmerBase =>
      _isDark ? const Color(0xFF202026) : const Color(0xFFEFEFF3);
  Color get shimmerHighlight =>
      _isDark ? const Color(0xFF2A2A31) : const Color(0xFFF8F8FA);
}
