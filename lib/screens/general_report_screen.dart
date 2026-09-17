import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show DashColors;

class GeneralReportScreen extends StatelessWidget {
  final String storeId;
  final List<Order> orders;
  final String userType;

  const GeneralReportScreen({super.key, required this.storeId, required this.userType, required this.orders});

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
        title: Text(
            "Rapport Général",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5, letterSpacing: -0.2, color: colors.textPrimary)
        ),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Vue d'ensemble", colors),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildKPICard(colors, "Ventes Totales", "${result['sales']} CFA", Icons.payments_rounded, colors.success)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildKPICard(colors, "Ordres Totaux", "${result['totalOrder']}", Icons.shopping_bag_rounded, colors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildKPICard(colors, "Panier Moyen", "${result['panierMoyen']!.toStringAsFixed(2)} F", Icons.trending_up_rounded, colors.accent)),
                  const SizedBox(width: 12),
                  if (userType == "employer")
                    Expanded(child: _buildKPICard(colors, "Bénéfices", "${result['revenue']} CFA", Icons.account_balance_wallet_rounded, const Color(0xFF8A7CB8))),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Performance Hebdomadaire", colors),
              const SizedBox(height: 16),
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
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: colors.textPrimary),
    );
  }

  Widget _buildKPICard(DashColors colors, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16.5,
              letterSpacing: -0.2,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bar_chart_rounded, size: 30, color: colors.primary.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 12),
            Text(
              "Graphique de performance",
              style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              "Bientôt disponible",
              style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
