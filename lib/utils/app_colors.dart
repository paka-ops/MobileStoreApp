import 'package:flutter/material.dart';

/// État du thème partagé par toute l'application.
final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(false);

ThemeData buildAppTheme(bool dark) {
  final scheme = ColorScheme.fromSeed(
    seedColor: dark ? AppColors.darkPrimary : AppColors.primary,
    brightness: dark ? Brightness.dark : Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor:
    dark ? AppColors.darkBackground : AppColors.background,
    canvasColor:
    dark ? AppColors.darkBackground : AppColors.background,
    cardColor: dark ? AppColors.darkCard : AppColors.card,
    dividerColor: dark ? AppColors.darkBorder : AppColors.border,
    fontFamily: 'Inter',
    appBarTheme: AppBarTheme(
      backgroundColor:
      dark ? AppColors.darkBackground : AppColors.background,
      foregroundColor:
      dark ? AppColors.darkTextPrimary : AppColors.textDark,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? AppColors.darkCardElevated : const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: dark ? AppColors.darkBorder : AppColors.border,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: dark ? AppColors.darkPrimary : AppColors.primary,
          width: 1.5,
        ),
      ),
      labelStyle: TextStyle(
        color: dark ? AppColors.darkTextSecondary : AppColors.textGrey,
        fontSize: 14,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? AppColors.darkCard : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 8,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: dark ? AppColors.darkCard : AppColors.card,
      selectedItemColor:
      dark ? AppColors.darkPrimary : AppColors.primary,
      unselectedItemColor:
      dark ? AppColors.darkTextSecondary : AppColors.textGrey,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor:
      dark ? AppColors.darkPrimary : AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
        dark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor:
        dark ? AppColors.darkTextSecondary : AppColors.textGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor:
      dark ? AppColors.darkCardElevated : AppColors.textDark,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor:
      dark ? AppColors.darkCardElevated : const Color(0xFFF0F0F0),
      labelStyle: TextStyle(
        color: dark ? AppColors.darkTextPrimary : AppColors.textDark,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    iconTheme: IconThemeData(
      color: dark ? AppColors.darkTextSecondary : AppColors.textGrey,
      size: 22,
    ),
    dividerTheme: DividerThemeData(
      color: dark ? AppColors.darkBorder : AppColors.border,
      thickness: 1,
      space: 1,
    ),
  );
}

// =====================================================================
// PALETTE
// =====================================================================
class AppColors {
  // -------------------------------------------------------------------
  // LIGHT — calé sur l'UI générée (bleu #2196F3, fond #EFF2F5)
  // -------------------------------------------------------------------

  /// Bleu principal (boutons, sélection nav, icônes actives)
  static const primary     = Color(0xFF2196F3);
  static const primarySoft = Color(0xFFE8F4FD); // fond doux derrière icônes

  /// Orange accent (dépenses, badge stock faible)
  static const accent     = Color(0xFFC08552);
  static const accentSoft = Color(0xFFF6ECE3);

  /// Rouge danger (suppression, déconnexion)
  static const danger     = Color(0xFFC96B6B);
  static const dangerSoft = Color(0xFFFCEAEA);

  /// Vert succès (validation vente)
  static const success     = Color(0xFF6FA687);
  static const successSoft = Color(0xFFEAF5EF);

  /// Info (non utilisé directement mais gardé pour cohérence)
  static const info     = Color(0xFF5B8EC9);
  static const infoSoft = Color(0xFFEAF0F9);

  /// Warning
  static const warning     = Color(0xFFD4A843);
  static const warningSoft = Color(0xFFFDF6E3);

  /// Fond général — gris très clair de l'image
  static const background = Color(0xFFEFF2F5);

  /// Fond des cartes — blanc pur
  static const card = Colors.white;

  /// Séparateurs / bordures — très discrets
  static const border = Color(0xFFE8ECF0);

  /// Textes
  static const textDark = Color(0xFF1A1D23); // titres, contenu principal
  static const textGrey = Color(0xFF8A8F96); // sous-titres, labels secondaires

  // -------------------------------------------------------------------
  // DARK — tons profonds, bleu lumineux
  // -------------------------------------------------------------------

  /// Bleu principal dark — légèrement plus lumineux pour lisibilité
  static const darkPrimary     = Color(0xFF42A5F5);
  static const darkPrimarySoft = Color(0xFF0D2137);

  /// Orange accent dark
  static const darkAccent     = Color(0xFFD4A06A);
  static const darkAccentSoft = Color(0xFF2A1E0F);

  /// Rouge danger dark
  static const darkDanger     = Color(0xFFE07878);
  static const darkDangerSoft = Color(0xFF2E1515);

  /// Vert succès dark
  static const darkSuccess     = Color(0xFF82C4A0);
  static const darkSuccessSoft = Color(0xFF0F2219);

  /// Info dark
  static const darkInfo     = Color(0xFF7AAAD6);
  static const darkInfoSoft = Color(0xFF0F1C2E);

  /// Warning dark
  static const darkWarning     = Color(0xFFE0BC5A);
  static const darkWarningSoft = Color(0xFF251E09);

  /// Fond général dark — très sombre, quasi noir
  static const darkBackground = Color(0xFF0D1117);

  /// Carte dark — niveau 1
  static const darkCard = Color(0xFF161B22);

  /// Carte dark — niveau 2 (éléments surélevés, inputs)
  static const darkCardElevated = Color(0xFF1E2530);

  /// Bordures dark
  static const darkBorder = Color(0xFF2A3140);

  /// Textes dark
  static const darkTextPrimary   = Color(0xFFE6EDF3);
  static const darkTextSecondary = Color(0xFF7D8590);
}

// =====================================================================
// HELPER — résout la couleur selon le thème courant
// =====================================================================
class DashColors {
  final BuildContext context;
  late final bool _isDark;

  DashColors(this.context) {
    _isDark = appDarkMode.value;
  }

  // Primaire
  Color get primary     => _isDark ? AppColors.darkPrimary     : AppColors.primary;
  Color get primarySoft => _isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft;

  // Accent
  Color get accent     => _isDark ? AppColors.darkAccent     : AppColors.accent;
  Color get accentSoft => _isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;

  // Danger
  Color get danger     => _isDark ? AppColors.darkDanger     : AppColors.danger;
  Color get dangerSoft => _isDark ? AppColors.darkDangerSoft : AppColors.dangerSoft;

  // Succès
  Color get success     => _isDark ? AppColors.darkSuccess     : AppColors.success;
  Color get successSoft => _isDark ? AppColors.darkSuccessSoft : AppColors.successSoft;

  // Info
  Color get info     => _isDark ? AppColors.darkInfo     : AppColors.info;
  Color get infoSoft => _isDark ? AppColors.darkInfoSoft : AppColors.infoSoft;

  // Warning
  Color get warning     => _isDark ? AppColors.darkWarning     : AppColors.warning;
  Color get warningSoft => _isDark ? AppColors.darkWarningSoft : AppColors.warningSoft;

  // Surfaces
  Color get background   => _isDark ? AppColors.darkBackground   : AppColors.background;
  Color get card         => _isDark ? AppColors.darkCard         : AppColors.card;
  Color get cardElevated => _isDark ? AppColors.darkCardElevated : AppColors.card;
  Color get border       => _isDark ? AppColors.darkBorder       : AppColors.border;

  // Textes
  Color get textPrimary   => _isDark ? AppColors.darkTextPrimary   : AppColors.textDark;
  Color get textSecondary => _isDark ? AppColors.darkTextSecondary : AppColors.textGrey;

  // ── Ombres adaptées au thème ──────────────────────────────────────
  /// Ombre standard pour les cartes
  List<BoxShadow> get cardShadow => _isDark
      ? [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ]
      : [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Ombre légère (bottom nav, top bar)
  List<BoxShadow> get subtleShadow => _isDark
      ? [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 8,
      offset: const Offset(0, -2),
    ),
  ]
      : [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 12,
      offset: const Offset(0, -3),
    ),
  ];

  // ── Couleur du fond pill greeting (top bar) ───────────────────────
  Color get greetingPill => _isDark
      ? const Color(0xFFE65100)   // orange foncé en dark
      : Colors.orange;

  // ── Couleur icônes top bar ────────────────────────────────────────
  Color get topBarIcon =>
      _isDark ? AppColors.darkTextPrimary : Colors.black87;

  // ── Fond boutons icônes top bar ───────────────────────────────────
  Color get topBarIconBg =>
      _isDark ? AppColors.darkCard : Colors.white;

  // ── Fond général pill / badge ─────────────────────────────────────
  Color get badgeBg =>
      _isDark ? AppColors.darkCardElevated : const Color(0xFFF0F0F0);
}