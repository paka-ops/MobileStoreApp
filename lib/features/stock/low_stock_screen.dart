import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/features/stock/controllers/low_stock_controller.dart';
import 'package:mobile_store_app/features/stock/widgets/low_stock_card.dart';
import 'package:mobile_store_app/features/stock/widgets/low_stock_header.dart';
import 'package:mobile_store_app/features/stock/widgets/low_stock_info_dialog.dart';
import 'package:mobile_store_app/features/stock/widgets/low_stock_stats_row.dart';
import 'package:mobile_store_app/features/stock/widgets/restock_product_dialog.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/utils/message.dart';

/// ============================================================================
/// LOW STOCK PRODUCT DETAILS SCREEN — produits nécessitant un restockage.
///
/// Structure identique à l'écran d'origine :
///   Scaffold → SafeArea → [en-tête, recherche, compteurs, liste ou état vide]
///   + style de barre d'état recalculé à chaque build comme avant
///
/// Recherche, compteurs et restockage vivent dans [LowStockController] ; les
/// deux dialogues sont des composants dédiés.
///
/// Comportements conservés :
///   • recherche incrémentale sur le nom (insensible à la casse)
///   • « Tout va bien ! » dès que la liste filtrée est vide
///   • succès du restockage → « X.XX unités ajoutées à {nom} »
/// ============================================================================
class LowStockProductDetailsScreen extends StatefulWidget {
  final List<Product> products;
  final String userType;

  const LowStockProductDetailsScreen({
    super.key,
    required this.products,
    required this.userType,
  });

  @override
  State<LowStockProductDetailsScreen> createState() =>
      _LowStockProductDetailsScreenState();
}

class _LowStockProductDetailsScreenState
    extends State<LowStockProductDetailsScreen> {
  late final LowStockController _controller =
      LowStockController(products: widget.products);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openRestockDialog(Product product) async {
    final RestockResult? result = await showRestockProductDialog(
      context: context,
      product: product,
      controller: _controller,
    );

    if (result == null || !mounted) return;

    showSuccessMessage(
      "${result.addedQuantity.toStringAsFixed(2)} unités ajoutées à ${result.product.name}",
      context,
    );
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
                LowStockHeader(hasNoAlerts: _controller.totalAlerts == 0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: AppSearchField(
                    hint: "Rechercher un produit…",
                    onChanged: _controller.filter,
                  ),
                ),
                LowStockStatsRow(
                  total: _controller.totalAlerts,
                  critical: _controller.criticalAlerts,
                  low: _controller.lowAlerts,
                ),
                Expanded(child: _buildBody(c)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(DashColors c) {
    if (_controller.filteredProducts.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: "Tout va bien !",
        message: "Aucun produit en stock critique pour le moment.",
        iconColor: c.success,
        iconSoftColor: c.successSoft,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: _controller.filteredProducts.length,
      itemBuilder: (context, index) {
        final Product product = _controller.filteredProducts[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LowStockCard(
            product: product,
            onRestock: () => _openRestockDialog(product),
            onInfo: () => showLowStockInfoDialog(context, product),
          ),
        );
      },
    );
  }
}
