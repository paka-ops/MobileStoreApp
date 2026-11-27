import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';

/// ============================================================================
/// EXPENSE FILTER SECTION — barre de période des dépenses.
///
///   • compteur « N dépense(s) » hors chargement
///   • pastille de période (calendrier 11 + libellé 11 / w600)
///   • bouton calendrier 34 × 34 `primarySoft` bordé
///   • en mode intégré : bouton actualiser 34 × 34 `fill`
///
/// Padding extérieur horizontal 4 et constantes identiques à l'original.
/// ============================================================================
class ExpenseFilterSection extends StatelessWidget {
  final bool isLoading;
  final int expenseCount;
  final String periodLabel;
  final bool embedded;
  final VoidCallback onSelectPeriod;
  final VoidCallback onRefresh;

  const ExpenseFilterSection({
    super.key,
    required this.isLoading,
    required this.expenseCount,
    required this.periodLabel,
    required this.embedded,
    required this.onSelectPeriod,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (!isLoading)
            Text(
              "$expenseCount dépense(s)",
              style: AppTextStyles.label.copyWith(
                fontSize: 11.5,
                color: colors.textSecondary,
              ),
            ),
          const Spacer(),
          GestureDetector(
            onTap: onSelectPeriod,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: colors.card.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.85),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 11,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    periodLabel,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: "Changer la période",
            child: InkWell(
              onTap: onSelectPeriod,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: colors.primary,
                  size: 17,
                ),
              ),
            ),
          ),
          if (embedded) ...[
            const SizedBox(width: 6),
            Tooltip(
              message: "Actualiser",
              child: InkWell(
                onTap: onRefresh,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.fill,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: colors.textPrimary,
                    size: 17,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
