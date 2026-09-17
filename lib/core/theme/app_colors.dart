import 'package:flutter/material.dart';

// ============================================================================
// APP COLORS — Palette « Calm Premium » (agencement inspiré des apps haut de
// gamme) : base NEUTRE CHAUDE + encre quasi-noire + accents minuscules.
//
// Principe anti-fatigue oculaire :
//  • La couleur ne porte JAMAIS de grandes surfaces : fonds neutres, cartes
//    blanches, textes encre/gris.
//  • L'accent n'apparaît que par petites touches (pastille, point, icône).
//  • Les dégradés sont des « washes » très pâles (≈ 4 % de teinte), jamais
//    des aplats saturés.
//  • Saturation maximale volontairement basse : aucune couleur « fluo ».
//
// Rôles :
//  • `ink`    → actions (boutons pillules noirs), icônes actives, titres.
//  • `primary`→ teal profond DÉSATURÉ : états interactifs (focus, progress,
//               sélection) et marque BouTiKa — utilisé avec parcimonie.
//  • `accent` → corail doux : alertes, pastilles, points, chiffres clés.
//
// ⚠️ Compatibilité : tous les anciens noms (primary, accent, danger, card,
//    navy, darkPrimary, …) restent disponibles — aucun écran n'est cassé.
// ============================================================================

/// État du thème partagé par toute l'application.
final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(false);

// ============================================================================
// PALETTE STATIC — accès direct (préférable : DashColors pour le theming)
// ============================================================================
class AppColors {
  AppColors._();

  // -------------------------------------------------------------------
  // NEUTRES — LIGHT (base chaude, très douce)
  // -------------------------------------------------------------------

  /// Fond général — blanc cassé chaud (jamais blanc pur)
  static const Color background = Color(0xFFF7F6F3);

  /// Voile haut d'écran (dégradé très pâle, teinte corail à 4 %)
  static const Color backgroundWash = Color(0xFFF9F2EE);

  /// Cartes — blanc pur (seule surface « pure », pour le contraste doux)
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFFFFFF);

  /// Zones remplies sans bordure (recherche, chips neutres)
  static const Color fill = Color(0xFFF1F0EC);
  static const Color fillStrong = Color(0xFFE8E6E1);

  /// Bordures / lignes fines
  static const Color border = Color(0xFFECEAE5);
  static const Color hairline = Color(0xFFF2F0EC);

  /// Textes
  static const Color textDark = Color(0xFF1A1A1F); // encre
  static const Color textGrey = Color(0xFF8B8B92); // secondaire
  static const Color textTertiary = Color(0xFFB3B3B9); // labels discrets

  /// Encre — boutons pillules, icônes actives, surfaces fortes
  static const Color ink = Color(0xFF17171B);
  static const Color inkSoft = Color(0xFF2C2C33);
  static const Color onInk = Color(0xFFFFFFFF);

  // -------------------------------------------------------------------
  // ACCENTS — light (touches discrètes)
  // -------------------------------------------------------------------

  /// Teal profond désaturé — couleur de marque, états interactifs
  static const Color primary = Color(0xFF0F766E);
  static const Color primarySoft = Color(0xFFE7F2F0);

  /// Contenu posé sur la couleur primaire
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Corail doux — alertes, pastilles, points, mise en avant
  static const Color accent = Color(0xFFE0653F);
  static const Color accentSoft = Color(0xFFFBEDE7);
  static const Color accentDeep = Color(0xFFC4512F);

  /// Étoile de notation (ambre adouci)
  static const Color rating = Color(0xFFE0A04A);
  static const Color ratingSoft = Color(0xFFFBF2E3);

  /// Sémantiques (saturations basses)
  static const Color danger = Color(0xFFCF5A55);
  static const Color dangerSoft = Color(0xFFFBECEA);

  static const Color success = Color(0xFF33946A);
  static const Color successSoft = Color(0xFFE8F4EE);

  static const Color info = Color(0xFF5278B8);
  static const Color infoSoft = Color(0xFFEDF2FA);

  static const Color warning = Color(0xFFC88324);
  static const Color warningSoft = Color(0xFFFBF3E6);

  /// Alias de l'encre (compatibilité avec l'ancienne API `navy`)
  static const Color navy = ink;
  static const Color navySoft = inkSoft;
  static const Color onNavy = onInk;

  // -------------------------------------------------------------------
  // PASTELS — fonds d'icônes (désaturés, chauds)
  // -------------------------------------------------------------------
  static const Color pastelPeach = Color(0xFFFBEDE7);
  static const Color pastelBlue = Color(0xFFEDF2FA);
  static const Color pastelViolet = Color(0xFFF3F1FB);
  static const Color pastelMint = Color(0xFFE9F5EF);
  static const Color pastelSand = Color(0xFFFBF3E6);
  static const Color pastelRose = Color(0xFFFCEFF0);
  static const Color pastelGrey = Color(0xFFF3F2EF);
  static const Color pastelSky = Color(0xFFEAF3F9);

  /// Anciens noms conservés (mêmes teintes adoucies)
  static const Color pastelRed = pastelPeach;
  static const Color pastelOrange = pastelSand;
  static const Color pastelTeal = pastelMint;
  static const Color pastelGreen = pastelMint;
  static const Color pastelAmber = pastelSand;

  /// Ordre de cyclage des grilles de catégories
  static const List<Color> pastels = <Color>[
    pastelPeach,
    pastelBlue,
    pastelViolet,
    pastelMint,
    pastelSand,
    pastelSky,
    pastelRose,
    pastelGrey,
  ];

  // -------------------------------------------------------------------
  // DARK — neutre chaud profond
  // -------------------------------------------------------------------

  static const Color darkBackground = Color(0xFF121215);
  static const Color darkBackgroundWash = Color(0xFF171315);
  static const Color darkCard = Color(0xFF1A1A1E);
  static const Color darkCardElevated = Color(0xFF202026);
  static const Color darkFill = Color(0xFF202026);
  static const Color darkFillStrong = Color(0xFF2A2A31);
  static const Color darkBorder = Color(0xFF2B2B32);
  static const Color darkHairline = Color(0xFF23232A);

  static const Color darkTextPrimary = Color(0xFFF2F1EE);
  static const Color darkTextSecondary = Color(0xFF9A9AA1);
  static const Color darkTextTertiary = Color(0xFF6E6E76);

  /// En mode sombre, l'encre s'inverse : pastille claire + texte sombre.
  static const Color darkInk = Color(0xFFF5F4F1);
  static const Color darkInkSoft = Color(0xFFDCDBD7);
  static const Color darkOnInk = Color(0xFF17171B);

  static const Color darkPrimary = Color(0xFF5FB3A8);
  static const Color darkPrimarySoft = Color(0xFF17312E);
  static const Color darkOnPrimary = Color(0xFF06201D);

  static const Color darkAccent = Color(0xFFF08A66);
  static const Color darkAccentSoft = Color(0xFF3A241C);
  static const Color darkAccentDeep = Color(0xFFF2A288);

  static const Color darkRating = Color(0xFFEFB65C);
  static const Color darkRatingSoft = Color(0xFF382C18);

  static const Color darkDanger = Color(0xFFE58B85);
  static const Color darkDangerSoft = Color(0xFF3A2320);

  static const Color darkSuccess = Color(0xFF6BC094);
  static const Color darkSuccessSoft = Color(0xFF17301F);

  static const Color darkInfo = Color(0xFF8AA9D8);
  static const Color darkInfoSoft = Color(0xFF1E2836);

  static const Color darkWarning = Color(0xFFDCA85C);
  static const Color darkWarningSoft = Color(0xFF332A1A);

  static const Color darkNavy = darkInk;
  static const Color darkNavySoft = darkInkSoft;
  static const Color darkOnNavy = darkOnInk;

  // Pastels sombres (teintes profondes, jamais vives)
  static const Color darkPastelPeach = Color(0xFF2A211D);
  static const Color darkPastelBlue = Color(0xFF1D2531);
  static const Color darkPastelViolet = Color(0xFF242138);
  static const Color darkPastelMint = Color(0xFF1B2A24);
  static const Color darkPastelSand = Color(0xFF2B2418);
  static const Color darkPastelRose = Color(0xFF2E2124);
  static const Color darkPastelGrey = Color(0xFF232327);
  static const Color darkPastelSky = Color(0xFF1D2A31);

  static const Color darkPastelRed = darkPastelPeach;
  static const Color darkPastelOrange = darkPastelSand;
  static const Color darkPastelTeal = darkPastelMint;
  static const Color darkPastelGreen = darkPastelMint;
  static const Color darkPastelAmber = darkPastelSand;

  static const List<Color> darkPastels = <Color>[
    darkPastelPeach,
    darkPastelBlue,
    darkPastelViolet,
    darkPastelMint,
    darkPastelSand,
    darkPastelSky,
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

  // ---- Primaire (teal profond désaturé) ------------------------------------
  Color get primary => _isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get primarySoft =>
      _isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft;
  Color get onPrimary =>
      _isDark ? AppColors.darkOnPrimary : AppColors.onPrimary;

  // ---- Accent (corail doux) ------------------------------------------------
  Color get accent => _isDark ? AppColors.darkAccent : AppColors.accent;
  Color get accentSoft =>
      _isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;
  Color get accentDeep =>
      _isDark ? AppColors.darkAccentDeep : AppColors.accentDeep;

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

  // ---- Textes --------------------------------------------------------------
  Color get textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  Color get textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textGrey;
  Color get textTertiary =>
      _isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

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
  Color get navPill =>
      _isDark ? Colors.white.withValues(alpha: 0.10) : AppColors.fill;

  /// Icône active (encre) / inactive (gris).
  Color get navActive => ink;
  Color get navInactive => _isDark
      ? const Color(0xFF7E7E86)
      : const Color(0xFF9A9AA1);

  /// Compatibilité (ancienne barre navy)
  Color get navOnNavy => onInk;
  Color get navOnNavyMuted => _isDark
      ? Colors.white.withValues(alpha: 0.55)
      : Colors.black.withValues(alpha: 0.42);

  /// Ombre de la barre flottante.
  Color get navShadowColor =>
      Colors.black.withValues(alpha: _isDark ? 0.45 : 0.07);

  // ---- Dégradés (washes très pâles — jamais d'aplat saturé) ---------------
  /// Dégradé de marque (teal profond → teal), réservé au logo / héro.
  List<Color> get gradientColors => _isDark
      ? const [Color(0xFF1E5D57), Color(0xFF2E8C82)]
      : const [Color(0xFF0F766E), Color(0xFF2E8C82)];

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

  /// Wash « carte d'info » : teinte pâle → blanc (4–8 % de couleur seulement).
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
  LinearGradient get inkWash => LinearGradient(
        colors: _isDark
            ? const [Color(0xFF26262C), Color(0xFF1B1B20)]
            : const [Color(0xFF23232A), Color(0xFF15151A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Halo très diffus (illustrations) — 6 % maximum.
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

  // ---- Ombres : « soft elevation » (très diffus, jamais marquées) ---------
  /// Ombre standard des cartes — 4 % noir, blur 20, y 8.
  List<BoxShadow> get cardShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];

  /// Ombre des éléments flottants (nav, FAB, tag) — 8 %, blur 24, y 12.
  List<BoxShadow> get floatingShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ];

  /// Ombre légère posée (top bar)
  List<BoxShadow> get subtleShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ];

  // ---- Helpers historiques (compatibilité) --------------------------------
  /// Fond pill greeting (top bar) — désormais neutre et discret
  Color get greetingPill => fill;

  Color get topBarIcon => _isDark ? AppColors.darkTextPrimary : AppColors.ink;

  Color get topBarIconBg => card;

  Color get badgeBg => fill;

  // ---- Helpers premium ----------------------------------------------------
  Color get barrier => Colors.black.withValues(alpha: _isDark ? 0.6 : 0.32);

  Color get shimmerBase =>
      _isDark ? const Color(0xFF202026) : const Color(0xFFEFEEEB);
  Color get shimmerHighlight =>
      _isDark ? const Color(0xFF2A2A31) : const Color(0xFFF8F7F5);
}
