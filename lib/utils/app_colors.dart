// ============================================================================
// COMPATIBILITÉ — ce fichier est conservé pour ne pas casser les imports
// existants (`package:mobile_store_app/utils/app_colors.dart`).
//
// Toute l'implémentation du design system vit dans `lib/core/` :
//   • core/theme/app_colors.dart      → palette + DashColors + appDarkMode
//   • core/theme/app_text_styles.dart → typographie (SF Pro Display)
//   • core/theme/app_dimensions.dart  → rayons, espacements, ombres
//   • core/theme/app_shadows.dart     → ombres « soft elevation »
//   • core/theme/app_decorations.dart → décorations prêtes à l'emploi
//   • core/theme/app_theme.dart       → buildAppTheme (ThemeData complet)
//   • core/constants/app_spacing.dart → Spacing, AppRadius, AppSizes
//   • core/widgets/common/app_background.dart → dégradé de fond global
//
// ➜ Pour tout nouveau code, importez directement `core/theme/...`.
// ============================================================================

export 'package:mobile_store_app/core/theme/app_colors.dart'
    show appDarkMode, AppColors, DashColors;

export 'package:mobile_store_app/core/theme/app_text_styles.dart'
    show AppTextStyles, AppTextTheme;

export 'package:mobile_store_app/core/theme/app_dimensions.dart'
    show AppDimensions;

export 'package:mobile_store_app/core/theme/app_shadows.dart' show AppShadows;

export 'package:mobile_store_app/core/theme/app_decorations.dart'
    show AppDecorations, AppGradients;

export 'package:mobile_store_app/core/constants/app_spacing.dart'
    show Spacing, AppRadius, AppSizes;

export 'package:mobile_store_app/core/theme/app_theme.dart'
    show buildAppTheme, PremiumPageTransitionsBuilder;

export 'package:mobile_store_app/core/widgets/common/app_background.dart'
    show AppBackground;
