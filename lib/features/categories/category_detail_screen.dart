import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/features/categories/controllers/category_products_controller.dart';
import 'package:mobile_store_app/features/categories/widgets/category_product_card.dart';
import 'package:mobile_store_app/features/categories/widgets/category_product_delete_dialog.dart';
import 'package:mobile_store_app/features/categories/widgets/category_product_form_dialog.dart';
import 'package:mobile_store_app/features/categories/widgets/category_product_info_dialog.dart';
import 'package:mobile_store_app/features/categories/widgets/category_restock_dialog.dart';
import 'package:mobile_store_app/features/stock/low_stock_screen.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/shared/widgets/loading/boutika_loader.dart';
import 'package:mobile_store_app/utils/message.dart';

/// ============================================================================
/// EMPLOYER CATEGORY DETAIL SCREEN — produits d'une catégorie.
///
/// Structure identique à l'écran d'origine :
///   Scaffold → SafeArea → [en-tête, recherche, KPI, liste ou état vide]
///   + FAB « Nouveau produit » réservé à l'employeur
///
/// Chargement, recherche et compteurs vivent dans
/// [CategoryProductsController] ; les cinq dialogues sont des composants
/// dédiés. Les textes, la géométrie et les messages de succès sont inchangés.
/// ============================================================================
class EmployerCategoryDetailScreen extends StatefulWidget {
  final Category category;
  final String userType;

  const EmployerCategoryDetailScreen({
    super.key,
    required this.category,
    required this.userType,
  });

  @override
  State createState() => _EmployerCategoryDetailsState();
}

class _EmployerCategoryDetailsState extends State<EmployerCategoryDetailScreen> {
  late final CategoryProductsController _controller =
      CategoryProductsController(categoryId: widget.category.id);

  @override
  void initState() {
    super.initState();
    _controller.load(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAddDialog() {
    showCategoryProductFormDialog(
      context,
      categoryId: widget.category.id,
      onSaved: () => _controller.load(context),
    );
  }

  void _openEditDialog(Product product) {
    showCategoryProductFormDialog(
      context,
      categoryId: widget.category.id,
      product: product,
      onSaved: () => _controller.load(context),
    );
  }

  Future<void> _openRestockDialog(Product product) async {
    final CategoryRestockResult? result = await showCategoryRestockDialog(
      context,
      product: product,
      controller: _controller,
    );

    if (result == null || !mounted) return;

    showSuccessMessage(
      "${result.added} unités ajoutées à ${result.product.name}",
      context,
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final bool deleted = await showCategoryProductDeleteDialog(
      context,
      product: product,
    );

    if (!deleted) return;
    _controller.load(context);
  }

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
    ));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(c),
                _buildSearchBar(c),
                _buildStatsRow(c),
                Expanded(child: _buildBody(c)),
              ],
            ),
          ),
          floatingActionButton: (widget.userType == "employer")
              ? _buildFab(c)
              : null,
        );
      },
    );
  }

  // =====================================================================
  // HEADER
  // =====================================================================
  Widget _buildHeader(DashColors c) {
    return AppScreenHeader(
      title: widget.category.name,
      subtitle: "Gestion des produits",
      actions: [
        AppIconButton(
          icon: Icons.warning_amber_rounded,
          badge: _controller.lowStockCount,
          badgeColor: c.danger,
          iconColor:
              _controller.lowStockProducts.isEmpty ? c.textSecondary : c.danger,
          tooltip: "Stock critique",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LowStockProductDetailsScreen(
                  products: _controller.lowStockProducts,
                  userType: widget.userType,
                ),
              ),
            );
          },
        ),
        AppIconButton(
          icon: Icons.refresh_rounded,
          tooltip: "Actualiser",
          onTap: () => _controller.load(context),
        ),
      ],
    );
  }

  // =====================================================================
  // SEARCH BAR
  // =====================================================================
  Widget _buildSearchBar(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: AppSearchField(
        hint: "Rechercher un produit…",
        onChanged: _controller.filter,
      ),
    );
  }

  // =====================================================================
  // STATS ROW (mini KPIs)
  // =====================================================================
  Widget _buildStatsRow(DashColors c) {
    final int total = _controller.totalCount;
    final int lowStock = _controller.lowStockCount;
    final int healthy = _controller.healthyCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.inventory_2_rounded,
              label: "Total",
              value: "$total",
              color: c.primary,
              softColor: c.primarySoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              icon: Icons.check_circle_outline_rounded,
              label: "Normal",
              value: "$healthy",
              color: c.success,
              softColor: c.successSoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              icon: Icons.warning_amber_rounded,
              label: "Critique",
              value: "$lowStock",
              color: c.danger,
              softColor: c.dangerSoft,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // BODY — Loading / Empty / List
  // =====================================================================
  Widget _buildBody(DashColors c) {
    if (_controller.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BouTikaLoader(),
            const SizedBox(height: 16),
            Text(
              "Chargement des produits...",
              style: AppTextStyles.bodySecondary.copyWith(
                color: c.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_controller.filteredProducts.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: "Aucun produit trouvé",
        message: widget.userType == "employer"
            ? "Ajoutez votre premier produit dans cette catégorie."
            : "Cette catégorie ne contient aucun produit.",
        actionLabel:
            widget.userType == "employer" ? "Ajouter un produit" : null,
        onAction: widget.userType == "employer" ? _openAddDialog : null,
      );
    }

    return RefreshIndicator(
      color: c.primary,
      backgroundColor: c.card,
      onRefresh: () async => _controller.load(context),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: _controller.filteredProducts.length,
        itemBuilder: (context, index) {
          final Product product = _controller.filteredProducts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CategoryProductCard(
              product: product,
              c: c,
              userType: widget.userType,
              onEdit: () => _openEditDialog(product),
              onRestock: () => _openRestockDialog(product),
              onDelete: () => _confirmDelete(product),
              onInfo: () =>
                  showCategoryProductInfoDialog(context, product: product),
            ),
          );
        },
      ),
    );
  }

  // =====================================================================
  // FAB
  // =====================================================================
  Widget _buildFab(DashColors c) {
    return FloatingActionButton.extended(
      onPressed: _openAddDialog,
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      icon: Icon(Icons.add_rounded, size: 20, color: c.onPrimary),
      label: Text(
        "Nouveau produit",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: c.onPrimary),
      ),
    );
  }
}
