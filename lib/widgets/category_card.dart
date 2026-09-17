import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// CATEGORY CARD — tuile de catégorie du design system (grille 3 colonnes).
///
///   • Container blanc, BorderRadius.circular(20), ombre douce
///   • Icône dans un cercle pastel (48 px)
///   • Texte en dessous, centré, FontWeight.w500
///
///   CategoryCard(
///     label: category.name,
///     icon: Icons.category_rounded,
///     index: i,                 // → pastel cyclique automatique
///     badgeCount: products.length,
///     onTap: () => openCategory(category),   // logique inchangée
///   )
///
/// ⚠️ Aucune logique métier : le widget affiche et remonte le tap.
/// ============================================================================
class CategoryCard extends StatelessWidget {
  /// Libellé affiché sous l'icône.
  final String label;

  /// Icône de la catégorie.
  final IconData icon;

  /// Index dans la grille → détermine le pastel (cyclique).
  final int index;

  /// Pastel imposé (sinon déduit de [index]).
  final Color? pastel;

  /// Teinte de l'icône (sinon déduite du pastel).
  final Color? iconColor;

  /// Callback de sélection.
  final VoidCallback? onTap;

  /// Pastille de comptage optionnelle (nombre d'articles…).
  final int badgeCount;

  /// Hauteur de la tuile.
  final double height;

  /// Nombre de lignes max du libellé.
  final int maxLines;

  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    this.index = 0,
    this.pastel,
    this.iconColor,
    this.onTap,
    this.badgeCount = 0,
    this.height = 118,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final Color soft = pastel ?? c.pastelAt(index);

    return PressableScale(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: c.cardShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cercle pastel 48 px contenant l'icône
                Container(
                  width: AppSizes.categoryIcon,
                  height: AppSizes.categoryIcon,
                  decoration:
                      AppDecorations.softIconCircle(softColor: soft),
                  child: Icon(
                    icon,
                    size: 23,
                    color: iconColor ?? _iconColorFor(soft, c),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.chip.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
            if (badgeCount > 0)
              Positioned(
                right: 0,
                top: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  constraints:
                      const BoxConstraints(minWidth: 20, minHeight: 18),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? "99+" : "$badgeCount",
                    style: AppTextStyles.label.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: c.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Teinte d'icône lisible sur un fond pastel (teal de marque par défaut).
  static Color _iconColorFor(Color pastel, DashColors c) {
    // Pastels très clairs → on utilise la teinte soutenue correspondante.
    final int v = pastel.computeLuminance() > 0.7 ? 1 : 0;
    return v == 1 ? _deepTint(pastel) : Colors.white;
  }

  /// Assombrit le pastel pour obtenir une teinte d'icône contrastée.
  static Color _deepTint(Color pastel) {
    final HSLColor hsl = HSLColor.fromColor(pastel);
    return hsl
        .withLightness((hsl.lightness - 0.28).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.10).clamp(0.0, 1.0))
        .toColor();
  }
}

/// ============================================================================
/// CATEGORY GRID — grille 3 colonnes de [CategoryCard] (usage immédiat).
///
///   CategoryGrid(
///     itemCount: categories.length,
///     itemBuilder: (i) => CategoryCard(
///       label: categories[i].name, icon: Icons.category_rounded, index: i,
///       onTap: () => open(categories[i]),
///     ),
///   )
/// ============================================================================
class CategoryGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;

  /// Ratio largeur / hauteur des tuiles (grille 3 colonnes compacte).
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  const CategoryGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.childAspectRatio = 0.86,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }
}
