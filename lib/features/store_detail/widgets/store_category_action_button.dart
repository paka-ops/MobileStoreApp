/// ============================================================================
/// STORE CATEGORY ACTION BUTTON — bouton d'action des cartes de catégorie.
///
/// Reprise à l'identique de la classe privée `_StoreCategoryActionButton`.
/// ============================================================================
import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';

// ===========================================================================
// BOUTON D'ACTION CATÉGORIE
// ===========================================================================
class StoreCategoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final DashColors colors;
  final VoidCallback onTap;

  const StoreCategoryActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? colors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: filled
                ? null
                : Border.all(color: colors.border, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: filled ? colors.onPrimary : colors.textPrimary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    color: filled
                        ? colors.onPrimary
                        : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
