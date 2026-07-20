import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/order.dart';

// ---------------------------------------------------------------------
// PALETTE — désaturée, confortable pour de longues sessions de travail
// ---------------------------------------------------------------------
class AppColors {
  static const primary = Color(0xFF4A7C82);       // teal désaturé, doux
  static const primarySoft = Color(0xFFEBF2F2);
  static const accent = Color(0xFFC08552);         // terracotta doux (dépenses/alertes)
  static const accentSoft = Color(0xFFF6ECE3);
  static const danger = Color(0xFFC96B6B);
  static const success = Color(0xFF6FA687);

  static const background = Color(0xFFF7F8FA);
  static const card = Colors.white;
  static const border = Color(0xFFEDEEF2);

  static const textDark = Color(0xFF2E333D);
  static const textGrey = Color(0xFF95999E);
}

class GeneralReportScreen extends StatelessWidget {
  final String storeId;
  final List<Order> orders;
  final String userType;

  const GeneralReportScreen({super.key, required this.storeId, required this.userType, required this.orders});

  // Logique de calcul conservée et étendue pour faire fonctionner l'écran
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
    Map<String, num> result = _computeResult(orders);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
            "Rapport Général",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Vue d'ensemble"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildKPICard("Ventes Totales", "${result['sales']} CFA", Icons.payments, AppColors.success)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildKPICard("Ordres Totaux", "${result['totalOrder']}", Icons.shopping_bag, AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildKPICard("Panier Moyen", "${result['panierMoyen']!.toStringAsFixed(2)} F", Icons.trending_up, AppColors.accent)),
                  const SizedBox(width: 12),
                  if (userType == "employer")
                    Expanded(child: _buildKPICard("Bénéfices", "${result['revenue']} CFA", Icons.account_balance_wallet, const Color(0xFF8A7CB8))),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Performance Hebdomadaire"),
              const SizedBox(height: 16),
              _buildChartPlaceholder(), // Un placeholder pour un graphique
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    // Placeholder stylisé en attendant l'intégration du vrai graphique
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.textGrey.withOpacity(0.5)),
            const SizedBox(height: 8),
            const Text(
              "Graphique de performance",
              style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text("Graphique de ventes (Lundi - Dimanche)", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
  Map<String, num> _computeResult(List<Order> orders) {
    double sales = 0.0;
    double revenue = 0.0;

    // 1. On calcule les totaux globaux
    for (var order in orders) {
      if (order.products.isNotEmpty) {
        order.products.forEach((product, quantity) {
          double sellingPrice = product.stock?.sellingPrice ?? 0;
          double buyingPrice = product.stock?.buyingPrice ?? 0;

          // Cumul du Chiffre d'Affaires
          sales += sellingPrice * quantity;

          // Cumul du Bénéfice (Prix Vente - Prix Achat) * Quantité
          revenue += (sellingPrice - buyingPrice) * quantity;
        });
      }
    }

    // 2. Calcul des indicateurs de synthèse
    int totalOrders = orders.length;
    // On évite la division par zéro si la liste est vide
    double panierMoyen = totalOrders > 0 ? sales / totalOrders : 0.0;

    // 3. Retour des résultats
    return {
      "sales": sales,
      "revenue": revenue,
      "totalOrder": totalOrders,
      "panierMoyen": panierMoyen,
    };
  }

