import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
            // ---- HEADER CUSTOM ----
            _buildHeader(c),
            // ---- BODY ----
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          // Back btn
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: c.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Titre
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
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Statistiques du produit",
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Refresh btn
          GestureDetector(
            onTap: () => setState(() {
              _statsFuture = _fetchProductStats();
            }),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 20,
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // STATES : Loading / Error / No data
  // =====================================================================
  Widget _buildLoading(DashColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BouTikaLoader(),
          const SizedBox(height: 16),
          Text(
            "Chargement des statistiques...",
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(DashColors c, Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  color: c.danger, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              "Erreur de chargement",
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "$error",
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  setState(() => _statsFuture = _fetchProductStats()),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Réessayer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoData(DashColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bar_chart_rounded, color: c.primary, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            "Aucune donnée disponible",
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          // --- HERO CARD ---
          _buildHeroCard(c, stockRestant),
          const SizedBox(height: 24),

          // --- KPI GRID ---
          _buildSectionTitle(c, "Vue d'ensemble",
              "Indicateurs clés du produit"),
          const SizedBox(height: 14),
          _buildStatsGrid(c, stats, saleRate),
          const SizedBox(height: 24),

          // --- RESTOCK HISTORY ---
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icône produit
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.border),
                ),
                child: Icon(
                  Icons.shopping_bag_rounded,
                  color: c.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              // Nom + prix
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
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: statusSoft,
                  borderRadius: BorderRadius.circular(999),
                  border:
                  Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  _stockLabel(stockRestant),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
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
              backgroundColor: statusColor.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 16),

          // Prix achat / vente chips
          Row(
            children: [
              if (UserService.userType != 'employee')
                _priceChip(
                  c,
                  icon: Icons.shopping_cart_outlined,
                  label: "Achat",
                  value:
                  "${widget.product.stock?.buyingPrice?.toStringAsFixed(0) ?? '0'} F",
                  color: c.accent,
                  softColor: c.accentSoft,
                ),
              if (UserService.userType != 'employee')
                const SizedBox(width: 10),
              _priceChip(
                c,
                icon: Icons.sell_rounded,
                label: "Vente",
                value:
                "${widget.product.stock?.sellingPrice?.toStringAsFixed(0) ?? '0'} F",
                color: c.primary,
                softColor: c.primarySoft,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: softColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
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
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // SECTION TITLE
  // =====================================================================
  Widget _buildSectionTitle(DashColors c, String title, String sub) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // STATS GRID (2x2 / 2x3 selon userType)
  // =====================================================================
  Widget _buildStatsGrid(
      DashColors c, ProductStats stats, double saleRate) {
    final bool isEmployee = UserService.userType == 'employee';

    final List<_StatItem> items = [
      _StatItem(
        title: 'Vendus',
        value: stats.totalSold.toStringAsFixed(2),
        icon: Icons.shopping_cart_checkout_rounded,
        color: c.success,
        softColor: c.successSoft,
      ),
      _StatItem(
        title: 'Entrés',
        value: stats.totalEntered.toStringAsFixed(2),
        icon: Icons.inventory_2_outlined,
        color: c.primary,
        softColor: c.primarySoft,
      ),
      _StatItem(
        title: "Chiffre d'affaires",
        value: _fmtCurrency(stats.ca),
        icon: Icons.payments_outlined,
        color: c.warning,
        softColor: c.warningSoft,
      ),
      if (!isEmployee)
        _StatItem(
          title: 'Marge générée',
          value: _fmtCurrency(stats.revenue),
          icon: Icons.auto_graph_rounded,
          color: c.accent,
          softColor: c.accentSoft,
        ),
      _StatItem(
        title: 'Taux de vente',
        value: '${saleRate.toStringAsFixed(1)} %',
        icon: Icons.trending_up_rounded,
        color: c.info,
        softColor: c.infoSoft,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 130,
      ),
      itemBuilder: (context, index) => _buildStatCard(c, items[index]),
    );
  }

  Widget _buildStatCard(DashColors c, _StatItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.softColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(item.icon, color: item.color, size: 21),
          ),
          const Spacer(),
          // Label
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Valeur
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // RESTOCK HISTORY
  // =====================================================================
  Widget _buildRestockList(DashColors c, List<dynamic> history) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined,
                  color: c.primary, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              "Aucun restockage",
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "L'historique des entrées de stock apparaîtra ici.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 12.5,
                height: 1.4,
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
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                // Icône
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border),
                  ),
                  child: Icon(Icons.inventory_2_rounded,
                      color: c.primary, size: 22),
                ),
                const SizedBox(width: 14),
                // Infos
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
                              borderRadius: BorderRadius.circular(8),
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
                                borderRadius: BorderRadius.circular(8),
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
                // Prix
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