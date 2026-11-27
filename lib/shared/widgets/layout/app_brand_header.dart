import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';

/// ============================================================================
/// APP BRAND HEADER — en-tête de marque commun aux écrans d'entrée.
///
/// Composition (identique dans l'application d'origine) :
///   • logo BouTiKa 38 px dans un cercle surface + ombre douce
///   • « BouTiKa » (17 / w700) + sous-titre italique 12 / w500
///   • bascule clair / sombre à droite (icône violette)
///
///   AppBrandHeader(subtitle: "ma boutique autrement")
///
/// [padding] vaut par défaut `fromLTRB(20, 16, 20, 10)` (écran d'accueil).
/// Les écrans qui empilent d'autres éléments sous l'en-tête passent
/// `EdgeInsets.zero` et appliquent eux-mêmes la marge extérieure : la
/// géométrie reste alors strictement celle de l'écran d'origine.
/// ============================================================================
class AppBrandHeader extends StatelessWidget {
  /// Sous-titre affiché sous la marque (« Mes Boutiques », signature…).
  final String subtitle;

  /// Marge extérieure de l'en-tête.
  final EdgeInsetsGeometry padding;

  /// Taille du logo (38 px dans toute l'application).
  final double logoSize;

  const AppBrandHeader({
    super.key,
    required this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 10),
    this.logoSize = 38,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
              boxShadow: colors.cardShadow,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/boutika.png',
                height: logoSize,
                width: logoSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "BouTiKa",
                  style:
                      AppTextStyles.brand.copyWith(color: colors.textPrimary),
                ),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: appDarkMode,
            builder: (context, isDark, _) => IconButton(
              tooltip: isDark
                  ? 'Activer le thème clair'
                  : 'Activer le thème sombre',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: () => appDarkMode.value = !isDark,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
