import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/order.dart';
class GeneralReportScreen extends StatelessWidget {
  final String storeId;
  final List<Order> orders;
  final String userType;

  const GeneralReportScreen({super.key, required this.storeId,required this.userType,required this.orders});

  @override
  Widget build(BuildContext context) {
    Map<String,num> result = _computeResult(orders);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Rapport Général", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Vue d'ensemble"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildKPICard("Ventes Totales","${result['sales']} CFA", Icons.payments, Colors.green)),
                const SizedBox(width: 12),
               // Expanded(child: _buildKPICard("Commandes", "${result['totalOrder']}", Icons.shopping_bag, Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildKPICard("Panier Moyen", "19.750 F", Icons.trending_up, Colors.orange)),
                const SizedBox(width: 12),
                ?(userType == "employer")?Expanded(child: _buildKPICard("Bénéfices ", "${result['revenue']} CFA", Icons.account_balance_wallet, Colors.purple)):null,
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Performance Hebdomadaire"),
            const SizedBox(height: 16),
            _buildChartPlaceholder(), // Un placeholder pour un graphique
          ],
        ),
      ),
    );
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
  Map<String,num> _computeResult(List<Order> orders){
    double sales = 0.0;
    double revenue = 0.0;
    int totalOrder = 0;
    Map<String,num> result = {};

    for (var order in orders) {
      if (order.products.isNotEmpty) {
        order.products.forEach((product, quantity) {
          // Calcul du CA : Prix de vente * Quantité
          sales += (product.stock?.sellingPrice ?? 0) * quantity;

          // Calcul du Bénéfice : (Prix Vente - Prix Achat) * Quantité
          revenue += ((product.stock?.sellingPrice ?? 0) - (product.stock?.buyingPrice ?? 0)) * quantity;
        });
      }
    }

    result.putIfAbsent("sales", ()=>sales);
    result.putIfAbsent("revenue", ()=>revenue);
    result.putIfAbsent("totalOrder", ()=>totalOrder);
    return result;
  }
}
