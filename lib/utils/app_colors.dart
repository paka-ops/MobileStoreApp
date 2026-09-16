// ============================================================================
// COMPATIBILITÉ — ce fichier est conservé pour ne pas casser les imports
// existants (`package:mobile_store_app/utils/app_colors.dart`).
//
// Toute l'implémentation du design system vit désormais dans `lib/core/` :
//   • core/theme/app_colors.dart  → palette + DashColors + appDarkMode
//   • core/theme/app_theme.dart   → buildAppTheme (ThemeData complet)
//
// ➜ Pour tout nouveau code, importez directement `core/theme/...`.
// ============================================================================

export 'package:mobile_store_app/core/theme/app_colors.dart'
    show appDarkMode, AppColors, DashColors;

export 'package:mobile_store_app/core/theme/app_theme.dart'
    show buildAppTheme, PremiumPageTransitionsBuilder;
