import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:collection/collection.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors, PremiumRadii;
import 'package:mobile_store_app/widgets/premium_kit.dart';

// =====================================================================
// ANALYSES PAR CATÉGORIE — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : regroupement des produits par catégorie, calculs
// CA/bénéfice et masquage employeur — tout est conservé. Seule la
// présentation change (cartes feutrées, barre de rentabilité douce).
// =====================================================================
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
        title: const Text("Analyses par Catégorie"),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            Category category = categories[index];
            Map<String, num> result =
                _getSalesInformationByCategory(category);

            return _buildEnhancedCategoryCard(
              category.name,
              result['sales'] ?? 0,
              result['revenues'] ?? 0,
              _getCategoryColor(index, colors),
              colors,
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(String name, num sales, num revenue,
      Color color, DashColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          // En-tête de la carte — voile teinté feutré.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                PremiumIconTile(
                  icon: Icons.category_rounded,
                  color: color,
                  softColor: color.withOpacity(0.14),
                  size: 44,
                  iconSize: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                      letterSpacing: -0.2,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Statistiques Ventes vs Bénéfice.
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStatItem("VENTES (CA)", sales, colors.primary, colors),
                if (userType == "employer") ...[
                  Container(width: 1, height: 44, color: colors.border),
                  _buildStatItem(
                      "BÉNÉFICE NET", revenue, colors.success, colors),
                ],
              ],
            ),
          ),
          // Barre visuelle de rentabilité (Bénéfice/Vente).
          if (sales > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value:
                          (revenue / sales).clamp(0, 1).toDouble(),
                      backgroundColor: colors.background,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Marge : ${((revenue / sales).clamp(0, 1) * 100).toStringAsFixed(1)} %",
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, num value, Color color, DashColors colors) {
    return Expanded(
      child: Column(
        children: [
          PremiumMicroLabel(label),
          const SizedBox(height: 8),
          Text(
            "${value.toStringAsFixed(0)} F",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  void _filterOrderProductsByCategory(
      List<Order> orders, List<Category> categories) {
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

  // Palette premium adossée au thème (même signature d'origine enrichie).
  Color _getCategoryColor(int index, DashColors colors) {
    List<Color> palette = [
      colors.primary, // émeraude
      colors.accent, // terracotta
      colors.info, // cobalt
      const Color(0xFF8A7CB8), // violet doux
      colors.warning, // ambre
      colors.success, // vert succès
    ];
    return palette[index % palette.length];
  }
}
