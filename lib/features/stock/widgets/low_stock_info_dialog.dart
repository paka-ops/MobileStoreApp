import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/features/products/product_details_screen.dart';
import 'package:mobile_store_app/features/stock/controllers/stock_level.dart';
import 'package:mobile_store_app/models/product.dart';

/// ============================================================================
/// LOW STOCK INFO DIALOG — fiche compacte d'un produit en alerte.
///
///   • `Dialog` rayon 22 bordé, padding 24
///   • pastille 16 px (danger si critique, warning sinon) + icône étagère 30
///   • nom 18 / w700, puis trois lignes : prix de vente, stock restant, état
///   • « Fermer » (flex 1) + « Plus d'infos » (flex 2) → `ProductStatsScreen`
///
/// L'état est dérivé de [StockLevel] ; la navigation est déclenchée par le
/// contexte de l'écran appelant (comme dans l'original, après fermeture).
/// ============================================================================
void showLowStockInfoDialog(BuildContext context, Product product) {
  final DashColors c = DashColors(context);
  final StockLevel level = StockLevel.of(product);
  final bool isCritical = level.isCritical;

  showDialog(
    context: context,
    builder: (dialogContext) {
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCritical ? c.dangerSoft : c.warningSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: isCritical ? c.danger : c.warning,
                  size: 30,
                ),
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

              _LowStockInfoRow(
                label: "Prix de vente",
                value: "${product.stock!.sellingPrice} F",
              ),
              _LowStockInfoRow(
                label: "Stock restant",
                value: "${level.quantity.toStringAsFixed(2)} unités",
              ),
              _LowStockInfoRow(
                label: "État",
                value: isCritical ? "Critique" : "Bas",
                valueColor: isCritical ? c.danger : c.warning,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: "Fermer",
                      height: 48,
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.primary(
                      label: "Plus d'infos",
                      height: 48,
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductStatsScreen(product: product),
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
    },
  );
}

/// Ligne d'information du dialogue (valeur dans une puce teintée à 10 %).
class _LowStockInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _LowStockInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

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
