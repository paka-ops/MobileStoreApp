import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/features/stock/controllers/restock_history_controller.dart';
import 'package:mobile_store_app/features/stock/widgets/restock_card.dart';
import 'package:mobile_store_app/features/stock/widgets/restock_fab.dart';
import 'package:mobile_store_app/features/stock/widgets/restock_filter_bar.dart';
import 'package:mobile_store_app/features/stock/widgets/restock_period_dialog.dart';
import 'package:mobile_store_app/shared/models/product.dart';
import 'package:mobile_store_app/shared/models/stock.dart';
import 'package:mobile_store_app/shared/widgets/loading/boutika_loader.dart';

/// ============================================================================
/// RESTOCK HISTORY SCREEN — historique des arrivages de stock.
///
/// Structure identique à l'écran d'origine :
///   [en-tête hors mode intégré avec action « Actualiser »] → barre de période
///   → loader / état vide / liste de cartes dépliables
///   + FAB « Nouvel Arrivage » (FAB du `Scaffold` ou `Positioned` en intégré)
///
/// Données, période et chargement vivent dans [RestockHistoryController].
/// ============================================================================
class RestockHistoryScreen extends StatefulWidget {
  final List<Product> products;
  final bool embedded;

  const RestockHistoryScreen({
    super.key,
    required this.products,
    this.embedded = false,
  });

  @override
  State<RestockHistoryScreen> createState() => _RestockHistoryScreenState();
}

class _RestockHistoryScreenState extends State<RestockHistoryScreen> {
  late final RestockHistoryController _controller =
      RestockHistoryController(products: widget.products);

  @override
  void initState() {
    super.initState();
    unawaited(_controller.load(context));
  }

  @override
  void didUpdateWidget(covariant RestockHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _controller.updateProducts(widget.products);
      unawaited(_controller.load(context));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openPeriodDialog() async {
    final RestockPeriod? period = await showRestockPeriodDialog(
      context: context,
      initialStart: _controller.startDate,
      initialEnd: _controller.endDate,
    );

    if (period == null || !mounted) return;
    await _controller.applyPeriod(context, period);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final DashColors c = DashColors(context);

        final Widget content = Column(
          children: [
            if (!widget.embedded)
              AppScreenHeader(
                title: "Mouvements de Stock",
                subtitle: "Historique des arrivages",
                actions: [
                  AppIconButton(
                    icon: Icons.refresh_rounded,
                    tooltip: "Actualiser",
                    onTap: () => unawaited(_controller.load(context)),
                  ),
                ],
              ),
            RestockFilterBar(
              isLoading: _controller.isLoading,
              stockCount: _controller.stocks.length,
              periodLabel: _controller.periodLabel,
              embedded: widget.embedded,
              onSelectPeriod: _openPeriodDialog,
              onRefresh: () => unawaited(_controller.load(context)),
            ),
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: BouTikaLoader())
                  : _controller.stocks.isEmpty
                      ? EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: "Pas de restockage trouvé",
                          message:
                              "Aucun mouvement de stock sur la période sélectionnée.",
                          actionLabel: "Actualiser",
                          onAction: () => unawaited(_controller.load(context)),
                        )
                      : _buildRestockList(c),
            ),
          ],
        );

        if (!widget.embedded) {
          return Scaffold(
            body: SafeArea(child: content),
            floatingActionButton: const RestockFab(),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            content,
            const Positioned(
              right: 20,
              bottom: 16,
              child: RestockFab(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestockList(DashColors c) {
    return RefreshIndicator(
      color: c.primary,
      backgroundColor: c.card,
      onRefresh: () => _controller.load(context),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: _controller.stocks.length,
        itemBuilder: (context, index) {
          final Stock stock = _controller.stocks[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RestockCard(
              stock: stock,
              productName: _controller.productNameFor(stock.productId),
              addedQty: _controller.addedQuantityFor(stock),
              showBuyingPrice: !_controller.isEmployee,
            ),
          );
        },
      ),
    );
  }
}
