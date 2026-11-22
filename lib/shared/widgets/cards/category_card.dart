import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/utils/color_utils.dart';
import 'package:mobile_store_app/core/utils/formatters.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';

/// ============================================================================
/// CATEGORY CARD — tuile de catégorie du design system (grille 3 colonnes).
///
///   • Carte blanche, rayon `AppRadius.lg`, ombre douce
///   • Icône dans un cercle pastel (32 → 48 px selon la place disponible)
///   • Libellé centré sous l'icône
///
/// **Anti-overflow** : la tuile n'impose AUCUNE hauteur fixe. Elle mesure
/// l'espace disponible et adapte la taille de l'icône ainsi que le nombre de
/// lignes du libellé : elle ne peut pas déborder, quelle que soit la largeur
/// de l'écran ou la taille de police du système.
///
/// Les formules de calcul (padV 12, gap 8, ratio 0.52, seuils 30/16, bornes
/// 32–48) sont identiques à l'implémentation d'origine.
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

  /// Hauteur explicite (optionnelle). Par défaut la tuile remplit son parent.
  final double? height;

  /// Nombre de lignes max du libellé (réduit si l'espace manque).
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
    this.height,
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: c.cardShadow,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Hauteur réellement disponible dans la cellule de grille.
            final double available = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : (height ?? 116);

            const double padV = 12;
            const double gap = 8;

            // L'icône occupe ~40 % de la hauteur, bornée 32 → 48 px.
            final double iconSize =
                ((available - padV * 2 - gap) * 0.52).clamp(32.0, 48.0);

            // Lignes de texte possibles avec l'espace restant.
            final double textSpace = available - padV * 2 - gap - iconSize;
            final int lines =
                textSpace >= 30 ? maxLines : (textSpace >= 16 ? 1 : 0);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: padV,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: constraints.maxHeight.isFinite
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: soft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: iconSize * 0.46,
                          color: iconColor ?? AppColorUtils.categoryIconTint(soft),
                        ),
                      ),
                      if (lines > 0) ...[
                        const SizedBox(height: gap),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: lines,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.chip.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.5,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 18),
                      decoration: BoxDecoration(
                        // Pastille circulaire rouge de la spécification.
                        color: c.badgeRed,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        AppFormatters.badgeCount(badgeCount),
                        style: AppTextStyles.label.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ============================================================================
/// CATEGORY GRID — grille 3 colonnes de [CategoryCard].
///
/// Le ratio par défaut (0.88) laisse assez de hauteur à l'icône et à deux
/// lignes de texte sur les petits écrans ; les tuiles s'adaptent de toute
/// façon à l'espace reçu.
/// ============================================================================
class CategoryGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;

  /// Ratio largeur / hauteur des tuiles (0.88 ≈ tuile légèrement haute).
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const CategoryGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.childAspectRatio = 0.88,
    this.padding = EdgeInsets.zero,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();

    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }
}
