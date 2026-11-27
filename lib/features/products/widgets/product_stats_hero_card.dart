import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/features/products/controllers/product_stats_calculator.dart';
import 'package:mobile_store_app/shared/models/product.dart';

/// ============================================================================
/// PRODUCT STATS HERO CARD — carte d'identité et de stock d'un produit.
///
///   • pastille produit 52 × 52 (icône 26), nom 17 / w800, prix de vente 12.5
///   • `StatusPill` d'état de stock
///   • ligne « Stock restant » + jauge 10 px teintée par l'état
///   • puces de prix « Achat » (masquée pour un employé) et « Vente »
///
/// La progression est bornée à [0,1] sur le stock de base, comme avant.
/// ============================================================================
class ProductStatsHeroCard extends StatelessWidget {
  final Product product;
  final double stockRestant;
  final bool showBuyingPrice;

  const ProductStatsHeroCard({
    super.key,
    required this.product,
    required this.stockRestant,
    required this.showBuyingPrice,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    final double stockTotal = (product.stock?.baseStock ?? 0).toDouble();
    final double progress =
        stockTotal > 0 ? (stockRestant / stockTotal).clamp(0.0, 1.0) : 0.0;
    final ProductStockStatus status = ProductStockStatus(stockRestant);
    final Color statusColor = status.color(c);
    final Color statusSoft = status.softColor(c);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: c.border),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: c.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  Icons.shopping_bag_rounded,
                  color: c.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.sell_rounded,
                          size: 13,
                          color: c.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${product.stock?.sellingPrice.toStringAsFixed(0) ?? '0'} F",
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: status.label,
                color: statusColor,
                softColor: statusSoft,
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stock restant",
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  "${stockRestant.toStringAsFixed(2)} / ${stockTotal.toStringAsFixed(2)} unité(s)",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: statusColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              if (showBuyingPrice) ...[
                Expanded(
                  child: _ProductPriceChip(
                    icon: Icons.shopping_cart_outlined,
                    label: "Achat",
                    value:
                        "${product.stock?.buyingPrice?.toStringAsFixed(0) ?? '0'} F",
                    color: c.accent,
                    softColor: c.accentSoft,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: _ProductPriceChip(
                  icon: Icons.sell_rounded,
                  label: "Vente",
                  value:
                      "${product.stock?.sellingPrice?.toStringAsFixed(0) ?? '0'} F",
                  color: c.primary,
                  softColor: c.primarySoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Puce de prix (icône 16, libellé 10.5, valeur 14 / w800).
class _ProductPriceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color softColor;

  const _ProductPriceChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
