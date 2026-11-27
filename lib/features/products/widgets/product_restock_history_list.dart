import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/features/products/controllers/product_stats_calculator.dart';

/// ============================================================================
/// PRODUCT RESTOCK HISTORY LIST — derniers mouvements du produit.
///
/// Liste vide → carte « Aucun mouvement enregistré » (icône 40 à 40 %
/// d'opacité).
///
/// Sinon, une carte par mouvement : pastille 46 × 46, date `dd MMM yyyy`,
/// badge « +x unités » (succès) et badge « −y vendus » (danger) si des ventes
/// existent, puis prix d'achat (masqué pour un employé) et prix de vente.
///
/// La lecture des champs bruts et le formatage de date sont délégués à
/// [ProductStatsCalculator.movementFrom].
/// ============================================================================
class ProductRestockHistoryList extends StatelessWidget {
  final List<dynamic> history;
  final bool showBuyingPrice;

  const ProductRestockHistoryList({
    super.key,
    required this.history,
    required this.showBuyingPrice,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: c.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              "Aucun mouvement enregistré",
              style: TextStyle(
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: history.map((item) {
        final RestockMovement movement =
            ProductStatsCalculator.movementFrom(item);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: c.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: c.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movement.dateLabel,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: c.successSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "+${movement.quantityAdded.toStringAsFixed(2)} unités",
                              style: TextStyle(
                                color: c.success,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (movement.totalSell > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: c.dangerSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "-${movement.totalSell.toStringAsFixed(2)} vendus",
                                style: TextStyle(
                                  color: c.danger,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showBuyingPrice)
                      _MovementPriceTag(
                        label: "Achat",
                        value:
                            "${movement.buyingPrice.toStringAsFixed(0)} F",
                        color: c.accent,
                      ),
                    if (showBuyingPrice) const SizedBox(height: 4),
                    _MovementPriceTag(
                      label: "Vente",
                      value:
                          "${movement.sellingPrice.toStringAsFixed(0)} F",
                      color: c.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Étiquette de prix d'un mouvement (« Achat : 1 200 F »).
class _MovementPriceTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MovementPriceTag({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$label : ",
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
