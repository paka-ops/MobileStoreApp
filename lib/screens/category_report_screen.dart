import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:collection/collection.dart';

class CategoryReportScreen extends StatelessWidget {
  final String storeId;
  final List<Category> categories;
  final String userType;
  final List<Order> orders;

  const CategoryReportScreen({
    super.key,
    required this.storeId,
    required this.userType,
    required this.categories,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    _filterOrderProductsByCategory(orders, categories);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Analyses par Catégorie",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          Category category = categories[index];
          Map<String, num> result = _getSalesInformationByCategory(category);

          return _buildEnhancedCategoryCard(
            category.name,
            result['sales'] ?? 0,
            result['revenues'] ?? 0,
            _getCategoryColor(index),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(
      String name, num sales, num revenue, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // En-tête de la carte
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(Icons.category_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          // Statistiques Ventes vs Revenus
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
          children: [
          _buildStatItem("VENTES (CA)", sales, Colors.blueAccent),
          if (userType == "employer") ...[
            Container(width: 1, height: 40, color: Colors.grey[200]),
            _buildStatItem("BÉNÉFICE NET", revenue, Colors.green),
          ],
        ],
      )
          ),
          // Barre visuelle de rentabilité (Bénéfice/Vente)
          if (sales > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (revenue / sales).clamp(0, 1).toDouble(),
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, num value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            "${value.toStringAsFixed(0)} F",
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ],
      ),
    );
  }

  // --- LOGIQUE CONSERVÉE ---
  void _filterOrderProductsByCategory(List<Order> orders, List<Category> categories) {
    // --- ÉTAPE CRUCIALE : On vide les anciens rapports pour éviter le cumul ---
    for (var cat in categories) {
      cat.orderContentsByCategory.clear();
    }

    Set categoriesSet = categories.toSet();
    for (var order in orders) {
      order.products.forEach((product, quantity) {
        Category? category = categoriesSet.firstWhereOrNull(
                (element) => element.name == product.category?.name);

        if (category != null) {
          // On utilise la syntaxe Map correcte {product: quantity}
          category.orderContentsByCategory.add({product: quantity});
        }
      });
    }
  }

  Map<String, num> _getSalesInformationByCategory(Category category) {
    Map<String, num> result = {};
    double sales = 0;
    double revenues = 0;
    category.orderContentsByCategory.forEach((content) {
      content.forEach((product, quantity) {
        sales += (product.stock!.sellingPrice ?? 0) * quantity;
        revenues += ((product.stock!.sellingPrice ?? 0) * quantity) -
            ((product.stock!.buyingPrice ?? 0) * quantity);
      });
    });
    result.putIfAbsent("sales", () => sales);
    result.putIfAbsent("revenues", () => revenues);
    return result;
  }

  Color _getCategoryColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal
    ];
    return colors[index % colors.length];
  }
}