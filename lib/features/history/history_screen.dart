import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/features/history/controllers/history_controller.dart';
import 'package:mobile_store_app/features/history/widgets/history_keep_alive.dart';
import 'package:mobile_store_app/features/history/widgets/history_nav_bar.dart';
import 'package:mobile_store_app/features/order_story/order_story_screen.dart';
import 'package:mobile_store_app/features/spending/spending_screen.dart';
import 'package:mobile_store_app/features/stock/stock_history_screen.dart';
import 'package:mobile_store_app/features/withdrawals/withdrawal_screen.dart';
import 'package:mobile_store_app/shared/models/category.dart';
import 'package:mobile_store_app/shared/models/product.dart';

/// ============================================================================
/// HISTORY SCREEN — écran unifié des quatre historiques de la boutique.
///
/// Structure identique à l'écran d'origine :
///   [en-tête hors mode intégré] → barre de navigation premium → PageView
///   (Ventes, Stock, Dépenses, Retraits) avec conservation d'état.
///
/// La navigation (index, pilule, animation de page, synchronisation de
/// l'`initialIndex`) vit dans [HistoryController] ; l'écran ne compose que.
///
/// Le mode `embedded` conserve son comportement :
///   • `true` → la colonne est renvoyée telle quelle (parent `IndexedStack`)
///   • `false` → `Scaffold` + `SafeArea(bottom: false)`
/// ============================================================================
class HistoryScreen extends StatefulWidget {
  final String storeId;
  final String userType;
  final List<Category> categories;
  final List<Product> products;

  /// Onglet affiché à l'ouverture (0: Ventes, 1: Stock, 2: Dépenses, 3: Retraits).
  final int initialIndex;

  /// `true` lorsqu'intégré dans l'`IndexedStack` d'un écran parent.
  final bool embedded;

  const HistoryScreen({
    super.key,
    required this.storeId,
    required this.userType,
    required this.categories,
    required this.products,
    this.initialIndex = 0,
    this.embedded = false,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryController _controller =
      HistoryController(initialIndex: widget.initialIndex);

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _controller.syncInitialIndex(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final Widget content = Column(
              children: [
                if (!widget.embedded)
                  AppScreenHeader(
                    title: "Historiques",
                    subtitle: _controller.currentTab.subtitle,
                  ),
                HistoryNavBar(
                  currentIndex: _controller.currentIndex,
                  onSelected: _controller.select,
                ),
                Expanded(
                  child: PageView(
                    controller: _controller.pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: _controller.onPageChanged,
                    children: [
                      HistoryKeepAlive(
                        child: OrderStoryScreen(
                          storeId: widget.storeId,
                          userType: widget.userType,
                          categories: widget.categories,
                          embedded: true,
                        ),
                      ),
                      HistoryKeepAlive(
                        child: RestockHistoryScreen(
                          products: widget.products,
                          embedded: true,
                        ),
                      ),
                      HistoryKeepAlive(
                        child: ExpensesScreen(
                          storeId: widget.storeId,
                          embedded: true,
                        ),
                      ),
                      HistoryKeepAlive(
                        child: WithdrawalScreen(
                          storeId: widget.storeId,
                          embedded: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            if (widget.embedded) return content;

            return Scaffold(
              body: SafeArea(
                bottom: false,
                child: content,
              ),
            );
          },
        );
      },
    );
  }
}
