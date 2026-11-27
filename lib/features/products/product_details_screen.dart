import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/features/products/controllers/product_stats_calculator.dart';
import 'package:mobile_store_app/features/products/controllers/product_stats_controller.dart';
import 'package:mobile_store_app/features/products/widgets/product_restock_history_list.dart';
import 'package:mobile_store_app/features/products/widgets/product_stats_header.dart';
import 'package:mobile_store_app/features/products/widgets/product_stats_hero_card.dart';
import 'package:mobile_store_app/features/products/widgets/product_stats_loading.dart';
import 'package:mobile_store_app/features/products/widgets/product_stats_overview.dart';
import 'package:mobile_store_app/shared/models/product.dart';
import 'package:mobile_store_app/shared/services/user_service.dart';

/// ============================================================================
/// PRODUCT STATS SCREEN — statistiques détaillées d'un produit.
///
/// Structure identique à l'écran d'origine :
///   Scaffold → SafeArea → [en-tête, contenu selon l'état]
///   • chargement → squelette + loader
///   • erreur     → `ErrorState` (message exact + « Réessayer »)
///   • données    → `RefreshIndicator` contenant la carte hero, la grille
///                  d'indicateurs et l'historique des mouvements
///
/// Les calculs sont dans [ProductStatsCalculator], le cycle de chargement dans
/// [ProductStatsController] : l'écran ne fait que composer.
///
/// Le style de barre d'état est recalculé à chaque build, comme avant.
/// ============================================================================
class ProductStatsScreen extends StatefulWidget {
  final Product product;

  const ProductStatsScreen({super.key, required this.product});

  @override
  State<ProductStatsScreen> createState() => _ProductStatsScreenState();
}

class _ProductStatsScreenState extends State<ProductStatsScreen> {
  late final ProductStatsController _controller =
      ProductStatsController(productId: widget.product.id);

  @override
  void initState() {
    super.initState();
    unawaited(_controller.load(context));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                ProductStatsHeader(
                  productName: widget.product.name,
                  onRefresh: () => unawaited(_controller.load(context)),
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
    switch (_controller.status) {
      case ProductStatsStatus.loading:
        return const ProductStatsLoading();
      case ProductStatsStatus.error:
        return ErrorState(
          message: _controller.errorMessage,
          onRetry: () => unawaited(_controller.load(context)),
        );
      case ProductStatsStatus.ready:
        return _buildContent(c, _controller.stats!);
    }
  }

  Widget _buildContent(DashColors c, ProductStats stats) {
    final bool showBuyingPrice = UserService.userType != 'employee';
    final double stockRestant =
        ProductStatsCalculator.remainingStock(widget.product);
    final double saleRate = ProductStatsCalculator.saleRate(stats);

    return RefreshIndicator(
      color: c.primary,
      backgroundColor: c.card,
      onRefresh: () => _controller.load(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ProductStatsHeroCard(
            product: widget.product,
            stockRestant: stockRestant,
            showBuyingPrice: showBuyingPrice,
          ),
          const SizedBox(height: 24),

          const SectionHeader(
            title: "Vue d'ensemble",
            subtitle: "Indicateurs clés du produit",
          ),
          const SizedBox(height: 14),
          ProductStatsOverview(
            stats: stats,
            saleRate: saleRate,
            showBuyingPrice: showBuyingPrice,
          ),
          const SizedBox(height: 24),

          const SectionHeader(
            title: "Historique de restockage",
            subtitle: "Derniers mouvements",
          ),
          const SizedBox(height: 14),
          ProductRestockHistoryList(
            history: stats.restockHistory,
            showBuyingPrice: showBuyingPrice,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
