import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/service/user_service.dart';

class ProductStats {
  final double totalSold;
  final double totalEntered;
  final double revenue;
  final double ca;
  final List<dynamic> restockHistory; // Ajout de l'historique

  ProductStats({
    required this.totalSold,
    required this.totalEntered,
    required this.revenue,
    required this.restockHistory,
    required this.ca,
  });
}

class ProductStatsScreen extends StatefulWidget {
  final Product product;
  const ProductStatsScreen({super.key, required this.product});

  @override
  State<ProductStatsScreen> createState() => _ProductStatsScreenState();
}

class _ProductStatsScreenState extends State<ProductStatsScreen> {
  late Future<ProductStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchProductStats();
  }

  Future<ProductStats> _fetchProductStats() async {
    List<dynamic> data = await ProductService().getStatsForProduct(
      widget.product.id,
      context,
    );
    double totalSold = 0.0;
    double totalEntered = 0.0;
    double revenue = 0.0;
    double ca = 0.0;
    int i = 0;
    for (var stock in data) {
      i += 1;
      print("hello");
      print("voici i $i");
      totalSold += stock['totalSell'] ?? 0.0;
      print("voici total solde = ${totalSold.toStringAsFixed(2)}");
      totalEntered += (stock['baseStock'] - (stock['previousStock'] ?? 0.0));
      revenue +=
          ((stock['totalSell'] ?? 0.0) * (stock['sellingPrice'] ?? 0.0)) -
          ((stock['totalSell'] ?? 0.0) * (stock['buyingPrice'] ?? 0.0));
      ca += (stock['totalSell'] ?? 0.0) * (stock['sellingPrice'] ?? 0.0);
    }
    return ProductStats(
      totalSold: (totalSold ?? 0).toDouble(),
      totalEntered: (totalEntered ?? 0).toDouble(),
      revenue: revenue,
      restockHistory: [], // Assurez-vous que la clé correspond à votre API
      ca: ca,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.product.name),
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<ProductStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          final stats = snapshot.data!;
          final double quantity =
              widget.product.stock!.baseStock - widget.product.stock!.totalSell;
          final double stockRestant = quantity.toDouble() ?? 0.0;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildInfoCard(stockRestant),
              const SizedBox(height: 24),
              _buildSectionLabel("VUE D'ENSEMBLE"),
              const SizedBox(height: 12),
              _buildStatsGrid(stats),
              const SizedBox(height: 24),
              _buildSectionLabel("HISTORIQUE DE RESTOCKAGE"),
              const SizedBox(height: 12),
              _buildRestockList(stats.restockHistory),
            ],
          );
        },
      ),
    );
  }

  // --- COMPOSANTS UI STYLISÉS ---

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard(double stockRestant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${widget.product.stock!.sellingPrice} F",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              _buildStatusBadge(stockRestant),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(double qty) {
    Color color = _getQuantityColor(qty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$qty en stock",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ProductStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Vendus',
          stats.totalSold.toString(),
          Icons.shopping_cart,
          Colors.green,
        ),
        _buildStatCard(
          'Entrés',
          stats.totalEntered.toString(),
          Icons.inventory,
          Colors.blue,
        ),
        _buildStatCard(
          'Ventes totales',
          '${stats.ca.toStringAsFixed(0)} F',
          Icons.payments,
          Colors.orange,
        ),
        ?UserService.userType == 'employee'
            ? null
            : _buildStatCard(
                'Revenue Généré',
                '${stats.revenue.toStringAsFixed(0)} F',
                Icons.monetization_on_rounded,
                Colors.deepPurpleAccent,
              ),
        _buildStatCard(
          'Taux Vente',
          '${(stats.totalSold / (stats.totalEntered > 0 ? stats.totalEntered : 1) * 100).toStringAsFixed(1)} %',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRestockList(List<dynamic> history) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text("Aucun restockage", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: history.map((item) {
        String date = "Date inconnue";
        if (item['createdAt'] != null) {
          date = DateFormat(
            'dd MMM yyyy',
          ).format(DateTime.parse(item['createdAt']));
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "+${item['quantityAdded'] ?? 0}",
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Achat ${item['buyingPrice']} F",
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  Text(
                    "Vente ${item['sellingPrice']} F",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getQuantityColor(double qty) {
    if (qty <= 5) return Colors.red;
    if (qty <= 15) return Colors.orange;
    return Colors.green;
  }
}
