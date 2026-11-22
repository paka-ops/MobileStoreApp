/// ============================================================================
/// STORE CATEGORY CARD — carte de catégorie de l'inventaire boutiquier.
///
/// Reprise à l'identique de la classe privée `_StoreCategoryCard`, avec ses
/// deux helpers de pastel (`_pastelFor`, `_pastelIcon`) qui n'étaient utilisés
/// que par elle. Aucun changement visuel ni logique.
/// ============================================================================
import 'package:flutter/material.dart';
import 'package:mobile_store_app/features/store_detail/widgets/store_category_action_button.dart';
import 'package:mobile_store_app/shared/models/category.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/features/store_detail/widgets/store_category_card.dart';

// ===========================================================================
// HELPERS PASTEL — présentation uniquement (aucun impact métier)
// ===========================================================================
/// Pastel déterministe par catégorie (même couleur à chaque affichage).
Color _pastelFor(String name, DashColors colors) {
  int sum = 0;
  for (final int unit in name.codeUnits) {
    sum += unit;
  }
  return colors.pastelAt(sum);
}

/// Teinte d'icône contrastée dérivée du pastel.
Color _pastelIcon(Color pastel) {
  final HSLColor hsl = HSLColor.fromColor(pastel);
  return hsl
      .withLightness((hsl.lightness - 0.30).clamp(0.0, 1.0))
      .withSaturation((hsl.saturation + 0.12).clamp(0.0, 1.0))
      .toColor();
}

// ===========================================================================
// CATEGORY CARD
// ===========================================================================
class StoreCategoryCard extends StatefulWidget {
  final Category category;
  final String userType;
  final DashColors colors;
  final VoidCallback onEdit;
  final VoidCallback onManage;

  const StoreCategoryCard({
    required this.category,
    required this.userType,
    required this.colors,
    required this.onEdit,
    required this.onManage,
  });

  @override
  State<StoreCategoryCard> createState() => _StoreCategoryCardState();
}

class _StoreCategoryCardState extends State<StoreCategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors   = widget.colors;
    final category = widget.category;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: _expanded ? colors.floatingShadow : colors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: AppSizes.categoryIcon,
                    height: AppSizes.categoryIcon,
                    decoration: BoxDecoration(
                      color: _pastelFor(category.name, colors),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.category_rounded,
                        color: _pastelIcon(_pastelFor(category.name, colors)),
                        size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.productTitle.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text("Gérer le stock et les prix",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySecondary
                                .copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colors.fill,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.textSecondary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu extensible
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOut,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: colors.hairline),
                  const SizedBox(height: 14),
                  OverlineLabel(text: "Description"),
                  const SizedBox(height: 8),
                  Text(
                    category.description ??
                        "Aucune description fournie.",
                    style: AppTextStyles.bodySecondary.copyWith(
                        color: colors.textPrimary,
                        height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (widget.userType == "employer")
                        Expanded(
                          child: StoreCategoryActionButton(
                            icon: Icons.edit_outlined,
                            label: "Modifier",
                            filled: false,
                            colors: colors,
                            onTap: widget.onEdit,
                          ),
                        ),
                      if (widget.userType == "employer")
                        const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: StoreCategoryActionButton(
                          icon: Icons.inventory_2_outlined,
                          label: "Gérer les produits",
                          filled: true,
                          colors: colors,
                          onTap: widget.onManage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
