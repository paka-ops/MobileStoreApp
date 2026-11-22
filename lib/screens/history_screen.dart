import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store_app/core/constants/app_durations.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/screens/order_story_screen.dart';
import 'package:mobile_store_app/screens/spending_page.dart';
import 'package:mobile_store_app/screens/stock_history_screen.dart';
import 'package:mobile_store_app/screens/withdrawal_page.dart';

/// ============================================================================
/// HISTORY SCREEN — Écran unifié regroupant tous les historiques de la
/// boutique (Ventes, Stock, Dépenses, Retraits) avec barre de navigation
/// horizontale premium translucide et PageView synchronisé.
/// ============================================================================
class HistoryScreen extends StatefulWidget {
  final String storeId;
  final String userType;
  final List<Category> categories;
  final List<Product> products;

  /// Onglet affiché à l'ouverture (0: Ventes, 1: Stock, 2: Dépenses, 3: Retraits).
  final int initialIndex;

  /// `true` lorsqu'intégré dans l'IndexedStack d'un écran parent (ex: StoreDetailScreen).
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

class _HistoryTabMeta {
  final String label;
  final String subtitle;
  final IconData icon;
  final IconData activeIcon;

  const _HistoryTabMeta({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.activeIcon,
  });
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const List<_HistoryTabMeta> _tabs = <_HistoryTabMeta>[
    _HistoryTabMeta(
      label: "Ventes",
      subtitle: "Historique des commandes",
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    _HistoryTabMeta(
      label: "Stock",
      subtitle: "Mouvements et arrivages",
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
    ),
    _HistoryTabMeta(
      label: "Dépenses",
      subtitle: "Historique des dépenses",
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
    ),
    _HistoryTabMeta(
      label: "Retraits",
      subtitle: "Historique des retraits",
      icon: Icons.savings_outlined,
      activeIcon: Icons.savings_rounded,
    ),
  ];

  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _tabs.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      final int target = widget.initialIndex.clamp(0, _tabs.length - 1);
      if (target != _currentIndex) {
        _currentIndex = target;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(target);
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: AppDurations.normal,
      curve: AppCurves.standard,
    );
  }

  Color _accentForIndex(int index, DashColors c) {
    switch (index) {
      case 0:
        return c.primary;
      case 1:
        return c.info;
      case 2:
        return c.accent;
      case 3:
        return c.success;
      default:
        return c.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        final DashColors c = DashColors(context);

        final Widget content = Column(
          children: [
            if (!widget.embedded)
              AppScreenHeader(
                title: "Historiques",
                subtitle: _tabs[_currentIndex].subtitle,
              ),
            _buildPremiumNavBar(c),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  if (_currentIndex != index) {
                    setState(() => _currentIndex = index);
                  }
                },
                children: [
                  _KeepAliveHistoryTab(
                    child: OrderStoryScreen(
                      storeId: widget.storeId,
                      userType: widget.userType,
                      categories: widget.categories,
                      embedded: true,
                    ),
                  ),
                  _KeepAliveHistoryTab(
                    child: RestockHistoryScreen(
                      products: widget.products,
                      embedded: true,
                    ),
                  ),
                  _KeepAliveHistoryTab(
                    child: ExpensesScreen(
                      storeId: widget.storeId,
                      embedded: true,
                    ),
                  ),
                  _KeepAliveHistoryTab(
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

        if (widget.embedded) {
          return content;
        }

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: content,
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BARRE DE NAVIGATION HORIZONTALE PREMIUM (verre dépoli + pilule animée)
  // ---------------------------------------------------------------------------
  Widget _buildPremiumNavBar(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: c.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: c.card.withValues(alpha: c.isDark ? 0.65 : 0.72),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: c.isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.80),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(_tabs.length, (index) {
                  final _HistoryTabMeta tab = _tabs[index];
                  final bool selected = index == _currentIndex;
                  final Color accent = _accentForIndex(index, c);

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onTabSelected(index),
                      child: AnimatedContainer(
                        duration: AppDurations.normal,
                        curve: AppCurves.standard,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? (c.isDark
                                  ? c.cardElevated.withValues(alpha: 0.92)
                                  : c.card.withValues(alpha: 0.96))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: selected
                              ? Border.all(
                                  color: accent.withValues(alpha: 0.18),
                                  width: 1,
                                )
                              : null,
                          boxShadow: selected ? c.activePillShadow : null,
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  selected ? tab.activeIcon : tab.icon,
                                  size: 15,
                                  color: selected ? accent : c.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  tab.label,
                                  maxLines: 1,
                                  style: AppTextStyles.pillText.copyWith(
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? c.pillActiveText
                                        : c.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Préserve l'état (données chargées, position de scroll) de chaque page
/// d'historique lors des glissements dans le [PageView].
class _KeepAliveHistoryTab extends StatefulWidget {
  final Widget child;

  const _KeepAliveHistoryTab({required this.child});

  @override
  State<_KeepAliveHistoryTab> createState() => _KeepAliveHistoryTabState();
}

class _KeepAliveHistoryTabState extends State<_KeepAliveHistoryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
