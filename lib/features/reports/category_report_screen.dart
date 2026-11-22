import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/features/reports/controllers/category_sales_calculator.dart';
import 'package:mobile_store_app/features/reports/widgets/category_analysis_card.dart';
import 'package:mobile_store_app/shared/models/category.dart';
import 'package:mobile_store_app/shared/models/order.dart';

/// ============================================================================
/// CATEGORY REPORT SCREEN — analyses par catégorie.
///
/// Structure identique à l'écran d'origine :
///   AppBar transparente centrée → SafeArea → liste des catégories
///   (ou « Aucune catégorie à analyser »)
///
/// La ventilation des commandes est désormais effectuée **une fois**, à
/// l'initialisation, par [CategorySalesCalculator] (auparavant dans `build()` :
/// même résultat, sans mutation pendant le rendu).
///
/// Couleurs des cartes : `AppColors.categoryAccents`, la palette exacte de
/// l'original (sarcelle, camel, sauge, violet, or, bleu pétrole), cyclique.
/// ============================================================================
class CategoryReportScreen extends StatefulWidget {
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
  State<CategoryReportScreen> createState() => _CategoryReportScreenState();
}

class _CategoryReportScreenState extends State<CategoryReportScreen> {
  @override
  void initState() {
    super.initState();
    CategorySalesCalculator.indexOrdersByCategory(
      widget.orders,
      widget.categories,
    );
  }

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Analyses par Catégorie",
          style: AppTextStyles.heading.copyWith(
            fontSize: 17,
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: widget.categories.isEmpty
            ? Center(
                child: Text(
                  "Aucune catégorie à analyser",
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final Category category = widget.categories[index];
                  final CategorySalesMetrics metrics =
                      CategorySalesCalculator.salesFor(category);

                  return CategoryAnalysisCard(
                    name: category.name,
                    sales: metrics.sales,
                    revenue: metrics.revenues,
                    color: AppColors.categoryAccents[
                        index % AppColors.categoryAccents.length],
                    userType: widget.userType,
                  );
                },
              ),
      ),
    );
  }
}
