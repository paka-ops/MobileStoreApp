import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/features/products/product_details_screen.dart';
import 'package:mobile_store_app/shared/models/product.dart';

/// Ouvre la fiche d'informations rapides d'un produit.
///
/// Les informations affichées proviennent du produit tel qu'il est connu dans
/// la liste de la catégorie (aucun appel réseau supplémentaire).
Future<void> showCategoryProductInfoDialog(
  BuildContext context, {
  required Product product,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _CategoryProductInfoDialog(product: product),
  );
}

class _CategoryProductInfoDialog extends StatelessWidget {
  final Product product;

  const _CategoryProductInfoDialog({required this.product});

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final double stock = (product.stock!.baseStock - product.stock!.totalSell);
    final bool isLow = stock <= 5;

    return Dialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.infoSoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(Icons.inventory_2_outlined,
                  color: c.info, size: 28),
            ),
            const SizedBox(height: 18),
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Info rows
            _InfoRow(
              label: "Prix de vente",
              value: "${product.stock!.sellingPrice} F",
            ),
            _InfoRow(label: "Stock restant", value: stock.toStringAsFixed(2)),
            _InfoRow(
              label: "État",
              value: isLow ? "Critique" : "Normal",
              valueColor: isLow ? c.danger : c.success,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: "Fermer",
                    height: 48,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.primary(
                    label: "Plus d'infos",
                    height: 48,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductStatsScreen(product: product),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(
              color: c.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (valueColor ?? c.textPrimary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: AppTextStyles.bodySecondary.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: valueColor ?? c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
