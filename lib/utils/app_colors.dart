import 'package:flutter/material.dart';

/// État du thème partagé par toute l'application.
///
/// Conservé à l'identique : toutes les vues existantes s'y abonnent déjà
/// via `ValueListenableBuilder`. Aucune logique métier ne change ici,
/// seule la couche visuelle (palette, thèmes, tokens) est repensée.
final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(false);

// =====================================================================
// THÈME MATÉRIEL — « BouTika Premium »
// ---------------------------------------------------------------------
// Direction artistique anti-fatigue (shifts de 8-10 h) :
//  • Jamais de blanc pur #FFFFFF ni de noir pur #000000 sur de grandes
//    surfaces : gris perle chaud en clair, ardoise mate en sombre.
//  • Encre Slate (#1E293B) plutôt que noir pur pour les textes.
//  • Marque : Vert Émeraude noble (#10B981), apaisant et « fintech ».
//  • Coins doux (12-16), bordures fines, ombres diffuses, cibles ≥ 48 px.
// =====================================================================
ThemeData buildAppTheme(bool dark) {
  final scheme = ColorScheme.fromSeed(
    seedColor: dark ? AppColors.darkPrimary : AppColors.primary,
    brightness: dark ? Brightness.dark : Brightness.light,
  );

  final textPrimary = dark ? AppColors.darkTextPrimary : AppColors.textDark;
  final textSecondary =
      dark ? AppColors.darkTextSecondary : AppColors.textGrey;
  final primary = dark ? AppColors.darkPrimary : AppColors.primary;
  final card = dark ? AppColors.darkCard : AppColors.card;
  final background = dark ? AppColors.darkBackground : AppColors.background;
  final border = dark ? AppColors.darkBorder : AppColors.border;
  final fieldFill =
      dark ? AppColors.darkFieldFill : AppColors.fieldFill;

  // Hiérarchie typographique globale (Medium titres / Regular corps).
  final baseTextTheme = (dark ? ThemeData.dark() : ThemeData.light())
      .textTheme
      .apply(bodyColor: textPrimary, displayColor: textPrimary);

  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: scheme.copyWith(
      primary: primary,
      surface: card,
      error: dark ? AppColors.darkDanger : AppColors.danger,
    ),
    scaffoldBackgroundColor: background,
    canvasColor: background,
    cardColor: card,
    dividerColor: border,
    fontFamily: 'Inter',
    textTheme: baseTextTheme.copyWith(
      // Totaux / prix : Bold assumé.
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      // Titres d'écran / de section : Medium-Bold équilibré.
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: -0.2,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      // Corps : Regular aéré (interlignage doux pour la lecture prolongée).
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.5),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        height: 1.45,
        color: textSecondary,
      ),
      // Micro-labels (KPI, badges) : capitales espacées.
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: textSecondary,
      ),
    ),

    // ── Barre d'application : mate, sans ombre dure ──────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: textPrimary, size: 22),
      actionsIconTheme: IconThemeData(color: primary, size: 22),
    ),

    // ── Cartes : fond doux + bordure fine, pas d'ombre dure ──────────
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        side: BorderSide(color: border, width: 1),
      ),
    ),

    // ── Champs de saisie : 48 px min, coins 14, focus émeraude ───────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16, // ≈ 52 px de hauteur tactile
      ),
      hintStyle: TextStyle(color: textSecondary, fontSize: 13.5),
      labelStyle: TextStyle(color: textSecondary, fontSize: 14),
      floatingLabelStyle: TextStyle(
        color: primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: primary,
      suffixIconColor: textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(color: border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(
          color: dark ? AppColors.darkDanger : AppColors.danger,
          width: 1.3,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(
          color: dark ? AppColors.darkDanger : AppColors.danger,
          width: 1.6,
        ),
      ),
    ),

    // ── Dialogues : galets 20 px, ombre diffuse ──────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: card,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        side: BorderSide(color: border, width: 1),
      ),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: TextStyle(
        color: textSecondary,
        fontSize: 13.5,
        height: 1.5,
      ),
    ),

    // ── Bottom sheets : poignée arrondie, coins 24 ───────────────────
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      elevation: 0,
      modalBarrierColor: Colors.black.withOpacity(dark ? 0.55 : 0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PremiumRadii.xl),
        ),
      ),
    ),

    // ── Navigation basse ─────────────────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: card,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
    ),

    // ── Bouton flottant : pastille émeraude mate ─────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.md),
      ),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
      extendedTextStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),

    // ── Boutons primaires : 52 px, coins 14, zéro ombre dure ─────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: textSecondary.withOpacity(0.25),
        disabledForegroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumRadii.input),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),

    // ── Boutons secondaires : contour fin, fond carte ────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        backgroundColor: card,
        minimumSize: const Size(64, 52),
        side: BorderSide(color: border, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumRadii.input),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textSecondary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumRadii.sm),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    // ── Listes ───────────────────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      minVerticalPadding: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.sm),
      ),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14.5,
      ),
      subtitleTextStyle: TextStyle(color: textSecondary, fontSize: 12.5),
      iconColor: primary,
    ),

    // ── Snackbars flottantes ─────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? AppColors.darkCardElevated : textPrimary,
      elevation: 0,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
      ),
    ),

    // ── Chips / badges ───────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: dark
          ? AppColors.darkCardElevated
          : AppColors.primarySoft,
      labelStyle: TextStyle(
        color: dark ? AppColors.darkTextPrimary : AppColors.textDark,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: border, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    iconTheme: IconThemeData(color: textSecondary, size: 22),
    primaryIconTheme: IconThemeData(color: primary, size: 22),

    dividerTheme: DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),

    // ── Indicateurs de progression : émeraude ────────────────────────
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: border,
      circularTrackColor: border,
    ),

    // ── Switch / cases : émeraude ────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primary
            : border,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primary
            : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      side: BorderSide(color: border, width: 1.5),
    ),

    // ── Onglets ──────────────────────────────────────────────────────
    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: textSecondary,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: primary, width: 2.5),
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimary,
        borderRadius: BorderRadius.circular(PremiumRadii.sm),
      ),
      textStyle: TextStyle(
        color: background,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// =====================================================================
// PALETTE ANTI-FATIGUE — « Perle & Ardoise » + Émeraude
// ---------------------------------------------------------------------
//  • Clair : fond gris perle chaud (#F2F4F7), cartes blanc feutré
//    (#FCFDFE — jamais #FFFFFF pur), encre Slate (#1E293B).
//  • Sombre : ardoise profonde mate (#0F172A / #1A2438), jamais #000000.
//  • Marque : Émeraude noble (#10B981) — CTA, focus, badges, succès.
// =====================================================================
class AppColors {
  // -------------------------------------------------------------------
  // LIGHT — perle chaude, encre slate, émeraude
  // -------------------------------------------------------------------

  /// Vert Émeraude — marque, CTA, focus, états actifs.
  static const primary = Color(0xFF10B981);

  /// Émeraude profond — extrémité de dégradés, états pressés.
  static const primaryDeep = Color(0xFF0B8A63);

  /// Voile émeraude — fonds doux derrière icônes, chips, badges.
  static const primarySoft = Color(0xFFDDF5E9);

  /// Terracotta sophistiqué — dépenses, alertes stock, accents chauds.
  static const accent = Color(0xFFC2703D);
  static const accentSoft = Color(0xFFF9EBDD);

  /// Rouge doux — suppressions, déconnexion, erreurs.
  static const danger = Color(0xFFD95C5C);
  static const dangerSoft = Color(0xFFFBEAEA);

  /// Vert succès — validations de vente (déclinaison de la marque).
  static const success = Color(0xFF0E9F6E);
  static const successSoft = Color(0xFFDEF7EC);

  /// Bleu Cobalt doux — informations, liens, données.
  static const info = Color(0xFF3B82F6);
  static const infoSoft = Color(0xFFE3EEFD);

  /// Ambre miel — avertissements.
  static const warning = Color(0xFFD9A021);
  static const warningSoft = Color(0xFFFBF3DC);

  /// Fond général — gris perle chaud (jamais de blanc pur).
  static const background = Color(0xFFF2F4F7);

  /// Fond des cartes — blanc feutré (jamais #FFFFFF).
  static const card = Color(0xFFFCFDFE);

  /// Fond des champs sur carte — blanc réservé aux petites surfaces
  /// (zones de saisie) pour préserver le contraste sans agresser l'œil
  /// sur les grandes zones.
  static const fieldFill = Color(0xFFFFFFFF);

  /// Séparateurs / bordures — fins et discrets.
  static const border = Color(0xFFE3E8EF);

  /// Textes — encre Slate, jamais de noir pur.
  static const textDark = Color(0xFF1E293B);
  static const textGrey = Color(0xFF64748B);

  // -------------------------------------------------------------------
  // DARK — ardoise profonde mate, émeraude lumineuse
  // -------------------------------------------------------------------

  /// Émeraude lumineuse — lisible sur ardoise sombre.
  static const darkPrimary = Color(0xFF34D399);
  static const darkPrimaryDeep = Color(0xFF10B981);
  static const darkPrimarySoft = Color(0xFF0C2B22);

  /// Terracotta clair.
  static const darkAccent = Color(0xFFE09A63);
  static const darkAccentSoft = Color(0xFF2C1E10);

  /// Rouge doux lumineux.
  static const darkDanger = Color(0xFFF27E7E);
  static const darkDangerSoft = Color(0xFF331414);

  /// Vert succès lumineux.
  static const darkSuccess = Color(0xFF5FD6A4);
  static const darkSuccessSoft = Color(0xFF0E2A1F);

  /// Cobalt lumineux.
  static const darkInfo = Color(0xFF6EA8FE);
  static const darkInfoSoft = Color(0xFF12233D);

  /// Ambre lumineux.
  static const darkWarning = Color(0xFFE3B341);
  static const darkWarningSoft = Color(0xFF2A210B);

  /// Fond général dark — ardoise profonde mate (jamais #000000).
  static const darkBackground = Color(0xFF0F172A);

  /// Carte dark — niveau 1.
  static const darkCard = Color(0xFF1A2438);

  /// Carte dark — niveau 2 (éléments surélevés, chips).
  static const darkCardElevated = Color(0xFF232F47);

  /// Fond des champs en sombre — creusé, plus profond que la carte.
  static const darkFieldFill = Color(0xFF141D31);

  /// Bordures dark.
  static const darkBorder = Color(0xFF2C3A54);

  /// Textes dark — blanc cassé + slate clair.
  static const darkTextPrimary = Color(0xFFE9EEF5);
  static const darkTextSecondary = Color(0xFF8B98AD);
}

// =====================================================================
// TOKENS PREMIUM — rayons, espacements, ombres, durées
// ---------------------------------------------------------------------
// Grille stricte 8 / 16 / 24 : toutes les vues respirent de la même
// façon. Ombres diffuses à faible opacité (jamais d'`elevation' dure).
// =====================================================================

/// Rayons de coins doux — aspect moderne et apaisant.
class PremiumRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double input = 14;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 100;

  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}

/// Espacements respirants — grille 8 / 16 / 24.
class PremiumGap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const SizedBox xsH = SizedBox(height: xs);
  static const SizedBox smH = SizedBox(height: sm);
  static const SizedBox mdH = SizedBox(height: md);
  static const SizedBox lgH = SizedBox(height: lg);
  static const SizedBox xlH = SizedBox(height: xl);

  static const SizedBox xsW = SizedBox(width: xs);
  static const SizedBox smW = SizedBox(width: sm);
  static const SizedBox mdW = SizedBox(width: md);
  static const SizedBox lgW = SizedBox(width: lg);
  static const SizedBox xlW = SizedBox(width: xl);

  static const EdgeInsets screen = EdgeInsets.fromLTRB(20, 12, 20, 24);
  static const EdgeInsets card = EdgeInsets.all(18);
}

/// Durées d'animation — micro-transitions feutrées.
class PremiumDurations {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 350);
  static const Curve curve = Curves.easeOutCubic;
}

// =====================================================================
// HELPER — résout la couleur selon le thème courant
// ---------------------------------------------------------------------
// API conservée à 100 % : tous les getters existants sont inchangés.
// De nouveaux getters « premium » s'y ajoutent (dégradés, halo, etc.).
// =====================================================================
class DashColors {
  final BuildContext context;
  late final bool _isDark;

  DashColors(this.context) {
    _isDark = appDarkMode.value;
  }

  /// Vrai quand le thème sombre est actif.
  bool get isDark => _isDark;

  // Primaire (marque émeraude)
  Color get primary => _isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get primaryDeep =>
      _isDark ? AppColors.darkPrimaryDeep : AppColors.primaryDeep;
  Color get primarySoft =>
      _isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft;

  /// Dégradé de marque — héro, pilules, CTA mis en avant.
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primaryDeep],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Halo émeraude diffus — ombre teintée des CTA principaux.
  List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primary.withOpacity(_isDark ? 0.35 : 0.28),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  // Accent (terracotta)
  Color get accent => _isDark ? AppColors.darkAccent : AppColors.accent;
  Color get accentSoft =>
      _isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;

  // Danger
  Color get danger => _isDark ? AppColors.darkDanger : AppColors.danger;
  Color get dangerSoft =>
      _isDark ? AppColors.darkDangerSoft : AppColors.dangerSoft;

  // Succès
  Color get success => _isDark ? AppColors.darkSuccess : AppColors.success;
  Color get successSoft =>
      _isDark ? AppColors.darkSuccessSoft : AppColors.successSoft;

  // Info
  Color get info => _isDark ? AppColors.darkInfo : AppColors.info;
  Color get infoSoft => _isDark ? AppColors.darkInfoSoft : AppColors.infoSoft;

  // Warning
  Color get warning => _isDark ? AppColors.darkWarning : AppColors.warning;
  Color get warningSoft =>
      _isDark ? AppColors.darkWarningSoft : AppColors.warningSoft;

  // Surfaces
  Color get background =>
      _isDark ? AppColors.darkBackground : AppColors.background;
  Color get card => _isDark ? AppColors.darkCard : AppColors.card;
  Color get cardElevated =>
      _isDark ? AppColors.darkCardElevated : AppColors.card;
  Color get fieldFill =>
      _isDark ? AppColors.darkFieldFill : AppColors.fieldFill;
  Color get border => _isDark ? AppColors.darkBorder : AppColors.border;

  /// Blanc réservé aux textes sur fond de marque (jamais en fond).
  Color get onPrimary => Colors.white;

  // Textes
  Color get textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  Color get textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textGrey;

  /// Texte tertiaire — placeholders, hints très discrets.
  Color get textTertiary => textSecondary.withOpacity(0.65);

  // ── Ombres adaptées au thème ──────────────────────────────────────
  /// Ombre standard des cartes — diffuse, très faible opacité.
  List<BoxShadow> get cardShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ]
      : [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ];

  /// Ombre légère (navigation basse, barre haute).
  List<BoxShadow> get subtleShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ]
      : [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ];

  /// Ombre portée douce vers le haut (sheets, clavier).
  List<BoxShadow> get softShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ]
      : [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ];

  // ── Couleur de fond de la pilule d'accueil (barre haute) ──────────
  /// Émeraude de marque — remplace l'orange agressif, apaise les shifts.
  Color get greetingPill => primary;

  // ── Couleur des icônes de la barre haute ──────────────────────────
  Color get topBarIcon => _isDark ? AppColors.darkTextPrimary : textPrimary;

  // ── Fond des boutons icônes de la barre haute ─────────────────────
  Color get topBarIconBg => _isDark ? AppColors.darkCard : AppColors.card;

  // ── Fond général des pilules / badges ─────────────────────────────
  Color get badgeBg =>
      _isDark ? AppColors.darkCardElevated : const Color(0xFFEDF1F5);

  // ── Décoration carte premium — bordure fine + ombre diffuse ───────
  BoxDecoration cardDecoration({double radius = PremiumRadii.lg}) {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: cardShadow,
    );
  }

  /// Décoration champ premium — réutilisée par les formulaires.
  InputDecoration fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: fieldFill,
      prefixIcon: Icon(icon, color: primary, size: 20),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(color: border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(color: danger, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(color: danger, width: 1.6),
      ),
    );
  }
}
