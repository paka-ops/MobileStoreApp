import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/core/constants/app_radius.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/core/widgets/loading/shimmer.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart';
import 'package:mobile_store_app/widgets/boutika_loader.dart';

// =====================================================================
// MODÈLE
// =====================================================================
class ProductStats {
  final double totalSold;
  final double totalEntered;
  final double revenue;
  final double ca;
  final List<dynamic> restockHistory;

  const ProductStats({
    required this.totalSold,
    required this.totalEntered,
    required this.revenue,
    required this.restockHistory,
    required this.ca,
  });
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color softColor;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.softColor,
  });
}

// =====================================================================
// SCREEN
// =====================================================================
class ProductStatsScreen extends StatefulWidget {
  final Product product;
  const ProductStatsScreen({super.key, required this.product});

  @override
  State<ProductStatsScreen> createState() => _ProductStatsScreenState();
}

class _ProductStatsScreenState extends State<ProductStatsScreen> {
  late Future<ProductStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchProductStats();
  }

  Future<ProductStats> _fetchProductStats() async {
    final List<dynamic> data = await ProductService().getStatsForProduct(
      widget.product.id,
      context,
    );

    double totalSold = 0.0;
    double totalEntered = 0.0;
    double revenue = 0.0;
    double ca = 0.0;

    for (var stock in data) {
      final double sold =
          (stock['totalSell'] as num?)?.toDouble() ?? 0.0;
      final double baseStock =
          (stock['baseStock'] as num?)?.toDouble() ?? 0.0;
      final double previousStock =
          (stock['previousStock'] as num?)?.toDouble() ?? 0.0;
      final double sellingPrice =
          (stock['sellingPrice'] as num?)?.toDouble() ?? 0.0;
      final double buyingPrice =
          (stock['buyingPrice'] as num?)?.toDouble() ?? 0.0;

      totalSold += sold;
      totalEntered += baseStock - previousStock;
      revenue += sold * sellingPrice - sold * buyingPrice;
      ca += sold * sellingPrice;
    }

    return ProductStats(
      totalSold: totalSold,
      totalEntered: totalEntered,
      revenue: revenue,
      restockHistory: data,
      ca: ca,
    );
  }

  double _getStockRestant() {
    final double baseStock =
    (widget.product.stock?.baseStock ?? 0).toDouble();
    final double totalSell =
    (widget.product.stock?.totalSell ?? 0).toDouble();
    return (baseStock - totalSell).clamp(0, double.infinity);
  }

  Color _stockColor(DashColors c, double qty) {
    if (qty <= 5) return c.danger;
    if (qty <= 15) return c.warning;
    return c.success;
  }

  Color _stockSoftColor(DashColors c, double qty) {
    if (qty <= 5) return c.dangerSoft;
    if (qty <= 15) return c.warningSoft;
    return c.successSoft;
  }

  String _stockLabel(double qty) {
    if (qty <= 5) return "Stock critique";
    if (qty <= 15) return "Stock bas";
    return "Stock sain";
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final double stockRestant = _getStockRestant();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(c),
            Expanded(
              child: FutureBuilder<ProductStats>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoading(c);
                  }
                  if (snapshot.hasError) {
                    return _buildError(c, snapshot.error);
                  }
                  if (!snapshot.hasData) {
                    return _buildNoData(c);
                  }

                  return _buildContent(c, snapshot.data!, stockRestant);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // HEADER
  // =====================================================================
  Widget _buildHeader(DashColors c) {
    return AppScreenHeader(
      title: widget.product.name,
      subtitle: "Statistiques du produit",
      actions: [
        AppIconButton(
          icon: Icons.refresh_rounded,
          tooltip: "Actualiser",
          onTap: () => setState(() {
            _statsFuture = _fetchProductStats();
          }),
        ),
      ],
    );
  }

  // =====================================================================
  // STATES : Loading / Error / No data
  // =====================================================================
  Widget _buildLoading(DashColors c) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        const SizedBox(height: 8),
        // Squelette hero
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerBox(width: 52, height: 52, radius: 16),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(
                            width: double.infinity,
                            height: 16,
                            radius: AppRadius.xs),
                        const SizedBox(height: 8),
                        const ShimmerBox(
                            width: 110, height: 12, radius: AppRadius.xs),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ShimmerBox(
                  width: double.infinity,
                  height: 10,
                  radius: AppRadius.xs),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const StatGridSkeleton(),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              const BouTikaLoader(),
              const SizedBox(height: 14),
              Text(
                "Chargement des statistiques...",
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(DashColors c, Object? error) {
    return ErrorState(
      message: "$error",
      onRetry: () =>
          setState(() => _statsFuture = _fetchProductStats()),
    );
  }

  Widget _buildNoData(DashColors c) {
    return EmptyState(
      icon: Icons.bar_chart_rounded,
      title: "Aucune donnée disponible",
      message:
      "Les statistiques de ce produit ne sont pas encore disponibles.",
    );
  }

  // =====================================================================
  // CONTENU PRINCIPAL
  // =====================================================================
  Widget _buildContent(
      DashColors c, ProductStats stats, double stockRestant) {
    final double saleRate = stats.totalEntered > 0
        ? (stats.totalSold / stats.totalEntered) * 100
        : 0;

    return RefreshIndicator(
      color: c.primary,
      backgroundColor: c.card,
      onRefresh: () async {
        setState(() => _statsFuture = _fetchProductStats());
        await _statsFuture;
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _buildHeroCard(c, stockRestant),
          const SizedBox(height: 24),

          _buildSectionTitle(c, "Vue d'ensemble",
              "Indicateurs clés du produit"),
          const SizedBox(height: 14),
          _buildStatsGrid(c, stats, saleRate),
          const SizedBox(height: 24),

          _buildSectionTitle(
              c, "Historique de restockage", "Derniers mouvements"),
          const SizedBox(height: 14),
          _buildRestockList(c, stats.restockHistory),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // =====================================================================
  // HERO CARD
  // =====================================================================
  Widget _buildHeroCard(DashColors c, double stockRestant) {
    final double stockTotal =
    (widget.product.stock?.baseStock ?? 0).toDouble();
    final double progress =
    stockTotal > 0 ? (stockRestant / stockTotal).clamp(0.0, 1.0) : 0.0;
    final Color statusColor = _stockColor(c, stockRestant);
    final Color statusSoft = _stockSoftColor(c, stockRestant);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: c.border),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: c.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  Icons.shopping_bag_rounded,
                  color: c.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.sell_rounded,
                            size: 13, color: c.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.product.stock?.sellingPrice.toStringAsFixed(0) ?? '0'} F",
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: _stockLabel(stockRestant),
                color: statusColor,
                softColor: statusSoft,
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stock restant",
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${stockRestant.toStringAsFixed(2)} / ${stockTotal.toStringAsFixed(2)} unité(s)",
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: statusColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              if (UserService.userType != 'employee') ...[
                Expanded(
                  child: _priceChip(
                    c,
                    icon: Icons.shopping_cart_outlined,
                    label: "Achat",
                    value:
                    "${widget.product.stock?.buyingPrice?.toStringAsFixed(0) ?? '0'} F",
                    color: c.accent,
                    softColor: c.accentSoft,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: _priceChip(
                  c,
                  icon: Icons.sell_rounded,
                  label: "Vente",
                  value:
                  "${widget.product.stock?.sellingPrice?.toStringAsFixed(0) ?? '0'} F",
                  color: c.primary,
                  softColor: c.primarySoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceChip(
      DashColors c, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
        required Color softColor,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // TITRE DE SECTION
  // =====================================================================
  Widget _buildSectionTitle(DashColors c, String title, String sub) {
    return SectionHeader(title: title, subtitle: sub);
  }

  // =====================================================================
  // GRILLE DE STATS
  // =====================================================================
  Widget _buildStatsGrid(
      DashColors c, ProductStats stats, double saleRate) {
    final List<_StatItem> items = [
      _StatItem(
        title: 'Vendus',
        value: '${stats.totalSold.toStringAsFixed(0)} u',
        icon: Icons.shopping_bag_outlined,
        color: c.info,
        softColor: c.infoSoft,
      ),
      _StatItem(
        title: 'Entrés',
        value: '${stats.totalEntered.toStringAsFixed(0)} u',
        icon: Icons.move_to_inbox_outlined,
        color: c.success,
        softColor: c.successSoft,
      ),
      _StatItem(
        title: "Chiffre d'affaires",
        value: _fmtCurrency(stats.ca),
        icon: Icons.payments_outlined,
        color: c.primary,
        softColor: c.primarySoft,
      ),
      if (UserService.userType != 'employee')
        _StatItem(
          title: 'Marge générée',
          value: _fmtCurrency(stats.revenue),
          icon: Icons.trending_up_rounded,
          color: c.success,
          softColor: c.successSoft,
        ),
      _StatItem(
        title: 'Taux de vente',
        value: '${saleRate.toStringAsFixed(1)} %',
        icon: Icons.speed_rounded,
        color: c.accent,
        softColor: c.accentSoft,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildStatCard(c, items[index]),
    );
  }

  Widget _buildStatCard(DashColors c, _StatItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.softColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const Spacer(),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16.5,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // HISTORIQUE DE RESTOCKAGE
  // =====================================================================
  Widget _buildRestockList(DashColors c, List<dynamic> history) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 40, color: c.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              "Aucun mouvement enregistré",
              style: TextStyle(
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: history.asMap().entries.map((entry) {
        final item = entry.value;

        String date = "Date inconnue";
        if (item['createdAt'] != null) {
          try {
            date = DateFormat('dd MMM yyyy')
                .format(DateTime.parse(item['createdAt']));
          } catch (_) {}
        }

        final double quantityAdded =
            (item['quantityAdded'] as num?)?.toDouble() ?? 0.0;
        final double buyingPrice =
            (item['buyingPrice'] as num?)?.toDouble() ?? 0.0;
        final double sellingPrice =
            (item['sellingPrice'] as num?)?.toDouble() ?? 0.0;
        final double totalSell =
            (item['totalSell'] as num?)?.toDouble() ?? 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: c.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(Icons.inventory_2_rounded,
                      color: c.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: c.successSoft,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Text(
                              "+${quantityAdded.toStringAsFixed(2)} unités",
                              style: TextStyle(
                                color: c.success,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (totalSell > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: c.dangerSoft,
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Text(
                                "-${totalSell.toStringAsFixed(2)} vendus",
                                style: TextStyle(
                                  color: c.danger,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (UserService.userType != 'employee')
                      _priceTag(
                        c,
                        label: "Achat",
                        value: "${buyingPrice.toStringAsFixed(0)} F",
                        color: c.accent,
                      ),
                    if (UserService.userType != 'employee')
                      const SizedBox(height: 4),
                    _priceTag(
                      c,
                      label: "Vente",
                      value: "${sellingPrice.toStringAsFixed(0)} F",
                      color: c.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _priceTag(DashColors c,
      {required String label,
        required String value,
        required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$label : ",
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // HELPERS
  // =====================================================================
  String _fmtCurrency(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M F";
    }
    if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K F";
    }
    return "${amount.toStringAsFixed(0)} F";
  }
}
