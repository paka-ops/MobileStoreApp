import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors, PremiumRadii;
import 'package:mobile_store_app/widgets/premium_kit.dart';

// =====================================================================
// RAPPORT GÉNÉRAL — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : calculs CA/panier moyen/bénéfices et visibilité
// employeur — tout est conservé. Seule la présentation change (KPI
// feutrés, section performance, hiérarchie Bold/Medium/Regular).
// =====================================================================
class GeneralReportScreen extends StatelessWidget {
  final String storeId;
  final List<Order> orders;
  final String userType;

  const GeneralReportScreen(
      {super.key,
      required this.storeId,
      required this.userType,
      required this.orders});

  Map<String, num> _computeResult(List<Order> orders) {
    double totalSales = 0;
    double totalRevenue = 0;

    for (var order in orders) {
      order.products.forEach((product, quantity) {
        double sellingPrice = product.stock?.sellingPrice ?? 0;
        double buyingPrice = product.stock?.buyingPrice ?? 0;
        totalSales += sellingPrice * quantity;
        totalRevenue += (sellingPrice - buyingPrice) * quantity;
      });
    }

    int totalOrders = orders.length;
    double panierMoyen = totalOrders > 0 ? totalSales / totalOrders : 0.0;

    return {
      'sales': totalSales,
      'totalOrder': totalOrders,
      'panierMoyen': panierMoyen,
      'revenue': totalRevenue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    Map<String, num> result = _computeResult(orders);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text("Rapport Général"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PremiumMicroLabel("Vue d'ensemble"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildKPICard(
                          "Ventes Totales",
                          "${result['sales']} CFA",
                          Icons.payments_rounded,
                          colors.success,
                          colors.successSoft,
                          colors)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildKPICard(
                          "Ordres Totaux",
                          "${result['totalOrder']}",
                          Icons.shopping_bag_rounded,
                          colors.primary,
                          colors.primarySoft,
                          colors)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildKPICard(
                          "Panier Moyen",
                          "${result['panierMoyen']!.toStringAsFixed(2)} F",
                          Icons.trending_up_rounded,
                          colors.accent,
                          colors.accentSoft,
                          colors)),
                  const SizedBox(width: 12),
                  if (userType == "employer")
                    Expanded(
                        child: _buildKPICard(
                            "Bénéfices",
                            "${result['revenue']} CFA",
                            Icons.account_balance_wallet_rounded,
                            const Color(0xFF8A7CB8),
                            const Color(0xFF8A7CB8).withOpacity(0.12),
                            colors)),
                ],
              ),
              const SizedBox(height: 24),
              const PremiumMicroLabel("Performance Hebdomadaire"),
              const SizedBox(height: 12),
              _buildChartPlaceholder(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, DashColors colors) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color,
      Color softColor, DashColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumIconTile(
            icon: icon,
            color: color,
            softColor: softColor,
            size: 42,
            iconSize: 20,
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.3,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(DashColors colors) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: colors.cardShadow,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 30,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Graphique de performance",
              style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
