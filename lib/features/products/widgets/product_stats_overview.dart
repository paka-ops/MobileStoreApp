import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/features/products/controllers/product_stats_calculator.dart';

/// Indicateur de la grille de synthèse.
class ProductStatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color softColor;

  const ProductStatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.softColor,
  });
}

/// ============================================================================
/// PRODUCT STATS OVERVIEW — grille 2 × N des indicateurs du produit.
///
///   • « Vendus », « Entrés », « Chiffre d'affaires », « Marge générée »
///     (masquée pour un employé), « Taux de vente »
///   • grille `crossAxisCount: 2`, espaces 10, ratio 1.55, non défilante
///   • cartes rayon 16 bordées : pastille d'icône 8 px, valeur 16.5 / w800,
///     libellé 11 / w600
///
/// Les libellés et formats (`u`, montants compacts, `%` à une décimale) sont
/// ceux de l'écran d'origine.
/// ============================================================================
class ProductStatsOverview extends StatelessWidget {
  final ProductStats stats;
  final double saleRate;
  final bool showBuyingPrice;

  const ProductStatsOverview({
    super.key,
    required this.stats,
    required this.saleRate,
    required this.showBuyingPrice,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    final List<ProductStatItem> items = [
      ProductStatItem(
        title: 'Vendus',
        value: '${stats.totalSold.toStringAsFixed(0)} u',
        icon: Icons.shopping_bag_outlined,
        color: c.info,
        softColor: c.infoSoft,
      ),
      ProductStatItem(
        title: 'Entrés',
        value: '${stats.totalEntered.toStringAsFixed(0)} u',
        icon: Icons.move_to_inbox_outlined,
        color: c.success,
        softColor: c.successSoft,
      ),
      ProductStatItem(
        title: "Chiffre d'affaires",
        value: ProductStatsCalculator.formatCurrency(stats.ca),
        icon: Icons.payments_outlined,
        color: c.primary,
        softColor: c.primarySoft,
      ),
      if (showBuyingPrice)
        ProductStatItem(
          title: 'Marge générée',
          value: ProductStatsCalculator.formatCurrency(stats.revenue),
          icon: Icons.trending_up_rounded,
          color: c.success,
          softColor: c.successSoft,
        ),
      ProductStatItem(
        title: 'Taux de vente',
        value: '${saleRate.toStringAsFixed(1)} %',
        icon: Icons.speed_rounded,
        color: c.accent,
        softColor: c.accentSoft,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _ProductStatCard(item: items[index]),
    );
  }
}

/// Carte d'un indicateur (pastille d'icône, valeur, libellé).
class _ProductStatCard extends StatelessWidget {
  final ProductStatItem item;

  const _ProductStatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.softColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const Spacer(),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16.5,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
