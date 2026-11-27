import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';

/// ============================================================================
/// RESTOCK FILTER BAR — barre de période des mouvements de stock.
///
///   • compteur « N arrivage(s) » tant que le chargement est terminé
///   • pastille de période (icône calendrier 11 + libellé 11 / w600)
///   • bouton calendrier 34 × 34 `primarySoft` bordé
///   • en mode intégré : bouton actualiser 34 × 34 `fill`
///
/// Padding extérieur 20·6·20·4 et toutes les constantes internes identiques à
/// l'écran d'origine.
/// ============================================================================
class RestockFilterBar extends StatelessWidget {
  final bool isLoading;
  final int stockCount;
  final String periodLabel;
  final bool embedded;
  final VoidCallback onSelectPeriod;
  final VoidCallback onRefresh;

  const RestockFilterBar({
    super.key,
    required this.isLoading,
    required this.stockCount,
    required this.periodLabel,
    required this.embedded,
    required this.onSelectPeriod,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      child: Row(
        children: [
          if (!isLoading)
            Text(
              "$stockCount arrivage(s)",
              style: AppTextStyles.label.copyWith(
                fontSize: 11.5,
                color: c.textSecondary,
              ),
            ),
          const Spacer(),
          GestureDetector(
            onTap: onSelectPeriod,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: c.card.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: c.border.withValues(alpha: 0.85)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 11,
                    color: c.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    periodLabel,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.textSecondary,
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
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: c.primary.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: c.primary,
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
                    color: c.fill,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: c.textPrimary,
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
