import 'package:flutter/material.dart';

// ============================================================================
// APP COLORS — Palette premium de BouTiKa (clair + sombre)
//
// Principes :
//  • Couleurs NON fatigantes : saturations modérées, bases grisées.
//  • Aucun noir/blanc pur pour les surfaces et les textes.
//  • Chaque couleur sémantique possède une variante « soft » (fond teinté).
// ============================================================================

/// État du thème partagé par toute l'application.
final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(false);

// ============================================================================
// PALETTE STATIC — accès direct (préférable : DashColors pour le theming)
// ============================================================================
class AppColors {
  // -------------------------------------------------------------------
  // LIGHT
  // -------------------------------------------------------------------

  /// Indigo royal doux — couleur signature (boutons, éléments actifs)
  static const Color primary = Color(0xFF3E63DD);
  static const Color primarySoft = Color(0xFFE9EEFE);

  /// Couleur du texte / contenu posé sur la couleur primaire
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Camel chaleureux — accent de marque (dépenses, badges, highlights)
  static const Color accent = Color(0xFFC08552);
  static const Color accentSoft = Color(0xFFF6ECE3);

  /// Rouge doux — suppression, erreurs
  static const Color danger = Color(0xFFDE4A52);
  static const Color dangerSoft = Color(0xFFFDEDEE);

  /// Vert doux — validations, succès
  static const Color success = Color(0xFF2F9E68);
  static const Color successSoft = Color(0xFFE8F6EE);

  /// Bleu info
  static const Color info = Color(0xFF4A8DDC);
  static const Color infoSoft = Color(0xFFEAF2FB);

  /// Ambre warning
  static const Color warning = Color(0xFFDE911D);
  static const Color warningSoft = Color(0xFFFDF4E1);

  /// Fond général — gris très clair neutre
  static const Color background = Color(0xFFF6F7F9);

  /// Surface des cartes — blanc
  static const Color card = Color(0xFFFFFFFF);

  /// Surface « élevée » (inputs, éléments sur cartes)
  static const Color cardElevated = Color(0xFFFFFFFF);

  /// Bordures — gris ultra léger
  static const Color border = Color(0xFFE7EAEE);

  /// Texte principal — anthracite (pas de noir pur)
  static const Color textDark = Color(0xFF22262D);

  /// Texte secondaire
  static const Color textGrey = Color(0xFF6E7681);

  // -------------------------------------------------------------------
  // DARK — anthracite profond, indigo lumineux
  // -------------------------------------------------------------------

  /// Indigo lumineux — texte/buttons sombres
  static const Color darkPrimary = Color(0xFF8A9EF4);
  static const Color darkPrimarySoft = Color(0xFF212A4E);

  /// Contenu posé sur la couleur primaire en mode sombre (contraste ↑)
  static const Color darkOnPrimary = Color(0xFF0D1226);

  static const Color darkAccent = Color(0xFFD9A876);
  static const Color darkAccentSoft = Color(0xFF2B2118);

  static const Color darkDanger = Color(0xFFF0767D);
  static const Color darkDangerSoft = Color(0xFF331D20);

  static const Color darkSuccess = Color(0xFF52C186);
  static const Color darkSuccessSoft = Color(0xFF16301F);

  static const Color darkInfo = Color(0xFF7FB1EA);
  static const Color darkInfoSoft = Color(0xFF1A2634);

  static const Color darkWarning = Color(0xFFEDB24E);
  static const Color darkWarningSoft = Color(0xFF2F2611);

  /// Fond général — anthracite bleuté très sombre (jamais noir pur)
  static const Color darkBackground = Color(0xFF0E1116);

  /// Cartes — niveau 1
  static const Color darkCard = Color(0xFF161B22);

  /// Cartes — niveau 2 (inputs, zones élevées)
  static const Color darkCardElevated = Color(0xFF1E242D);

  /// Bordures sombres — subtiles
  static const Color darkBorder = Color(0xFF272E39);

  /// Textes sombres
  static const Color darkTextPrimary = Color(0xFFE9ECF2);
  static const Color darkTextSecondary = Color(0xFF8C93A0);
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

  // ---- Accent (camel) ------------------------------------------------------
  Color get accent => _isDark ? AppColors.darkAccent : AppColors.accent;
  Color get accentSoft =>
      _isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;

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
  Color get border => _isDark ? AppColors.darkBorder : AppColors.border;

  // ---- Textes --------------------------------------------------------------
  Color get textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  Color get textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textGrey;

  // ---- Ombres adaptées au thème -------------------------------------------
  /// Ombre standard pour les cartes
  List<BoxShadow> get cardShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
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

  /// Ombre légère (bottom nav, top bar)
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
  Color get badgeBg =>
      _isDark ? AppColors.darkCardElevated : const Color(0xFFF0F1F4);

  // ---- Nouveaux helpers premium -------------------------------------------
  /// Couleur de surface des barrières (dialogs / sheets)
  Color get barrier => Colors.black.withValues(alpha: _isDark ? 0.6 : 0.45);

  /// Couleurs du shimmer
  Color get shimmerBase =>
      _isDark ? const Color(0xFF1E242D) : const Color(0xFFE9ECF1);
  Color get shimmerHighlight =>
      _isDark ? const Color(0xFF2A3140) : const Color(0xFFF8FAFC);

  /// Halo utilisé derrière les illustrations / hero
  Color get glow =>
      primary.withValues(alpha: _isDark ? 0.16 : 0.10);

  /// Ligne fine intérieure (séparateurs discrets)
  Color get hairline =>
      _isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05);
}
