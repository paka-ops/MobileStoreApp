import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:collection/collection.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show DashColors;

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
    final colors = DashColors(context);
    _filterOrderProductsByCategory(orders, categories);
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          "Analyses par Catégorie",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: colors.textPrimary),
        ),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
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
              colors,
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(
      String name, num sales, num revenue, Color color, DashColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        children: [
          // En-tête de la carte
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.category_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Statistiques Ventes vs Revenus
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStatItem("VENTES (CA)", sales, colors.primary, colors),
                if (userType == "employer") ...[
                  Container(width: 1, height: 40, color: colors.border),
                  _buildStatItem("BÉNÉFICE NET", revenue, colors.success, colors),
                ],
              ],
            ),
          ),
          // Barre visuelle de rentabilité (Bénéfice/Vente)
          if (sales > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (revenue / sales).clamp(0, 1).toDouble(),
                  backgroundColor: colors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, num value, Color color, DashColors colors) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${value.toStringAsFixed(0)} F",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _filterOrderProductsByCategory(List<Order> orders, List<Category> categories) {
    for (var cat in categories) {
      cat.orderContentsByCategory.clear();
    }

    Set categoriesSet = categories.toSet();
    for (var order in orders) {
      order.products.forEach((product, quantity) {
        Category? category = categoriesSet.firstWhereOrNull(
                (element) => element.name == product.category?.name);

        if (category != null) {
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
      const Color(0xFF4A7C82),  // primary
      const Color(0xFFC08552),  // accent
      const Color(0xFF6FA687),  // success
      const Color(0xFF8A7CB8),  // Violet doux
      const Color(0xFFD8A657),  // Or doux
      const Color(0xFF5C8AAE),  // Bleu pétrole doux
    ];
    return colors[index % colors.length];
  }
}
