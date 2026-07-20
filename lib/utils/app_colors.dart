import 'package:flutter/material.dart';

class AppColors {
  // =====================================================================
  // LIGHT THEME
  // =====================================================================
  static const primary = Color(0xFF4A7C82);
  static const primarySoft = Color(0xFFEBF2F2);

  static const accent = Color(0xFFC08552);
  static const accentSoft = Color(0xFFF6ECE3);

  static const danger = Color(0xFFC96B6B);
  static const dangerSoft = Color(0xFFFCEAEA);

  static const success = Color(0xFF6FA687);
  static const successSoft = Color(0xFFEAF5EF);

  static const info = Color(0xFF5B8EC9);
  static const infoSoft = Color(0xFFEAF0F9);

  static const warning = Color(0xFFD4A843);
  static const warningSoft = Color(0xFFFDF6E3);

  static const background = Color(0xFFF7F8FA);
  static const card = Colors.white;
  static const border = Color(0xFFEDEEF2);

  static const textDark = Color(0xFF2E333D);
  static const textGrey = Color(0xFF95999E);

  // =====================================================================
  // DARK THEME
  // =====================================================================
  static const darkPrimary = Color(0xFF6AABB3);
  static const darkPrimarySoft = Color(0xFF1A2E30);

  static const darkAccent = Color(0xFFD4A06A);
  static const darkAccentSoft = Color(0xFF2E2218);

  static const darkDanger = Color(0xFFE07878);
  static const darkDangerSoft = Color(0xFF2E1A1A);

  static const darkSuccess = Color(0xFF82C4A0);
  static const darkSuccessSoft = Color(0xFF1A2E22);

  static const darkInfo = Color(0xFF7AAAD6);
  static const darkInfoSoft = Color(0xFF1A2230);

  static const darkWarning = Color(0xFFE0BC5A);
  static const darkWarningSoft = Color(0xFF2E2814);

  static const darkBackground = Color(0xFF0F1216);
  static const darkCard = Color(0xFF1A1D23);
  static const darkCardElevated = Color(0xFF22262E);
  static const darkBorder = Color(0xFF2A2E36);

  static const darkTextPrimary = Color(0xFFE8EAED);
  static const darkTextSecondary = Color(0xFF8A8F96);
}

// =====================================================================
// HELPER — Résout la couleur selon le thème
// =====================================================================
class DashColors {
  final BuildContext context;
  late final bool _isDark;

  DashColors(this.context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;
  }

  Color get primary => _isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get primarySoft =>
      _isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft;

  Color get accent => _isDark ? AppColors.darkAccent : AppColors.accent;
  Color get accentSoft =>
      _isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;

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

  Color get background =>
      _isDark ? AppColors.darkBackground : AppColors.background;
  Color get card => _isDark ? AppColors.darkCard : AppColors.card;
  Color get cardElevated =>
      _isDark ? AppColors.darkCardElevated : AppColors.card;
  Color get border => _isDark ? AppColors.darkBorder : AppColors.border;

  Color get textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  Color get textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textGrey;
}