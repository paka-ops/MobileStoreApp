import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/core/constants/app_radius.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/models/stock.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart';
import 'package:mobile_store_app/widgets/boutika_loader.dart';

class RestockHistoryScreen extends StatefulWidget {
  final List<Product> products;
  const RestockHistoryScreen({super.key, required this.products});
  @override
  State<RestockHistoryScreen> createState() => _RestockHistoryScreenState();
}

class _RestockHistoryScreenState extends State<RestockHistoryScreen> {
  DateTime? startDate = DateTime.now().add(const Duration(days: -30));
  DateTime? endDate = DateTime.now().add(const Duration(days: 1));
  bool isLoading = false;
  List<String> productIds = [];

  void _getProductIds(List<Product> products) {
    products.forEach((e) {
      productIds.add(e.id);
    });
    setState(() {
      productIds;
    });
  }

  void _applyFilter() {
    // Réservé à un futur filtre local.
  }

  List<Stock> stocks = [];
  Map<String, Product> productsIdMap = {};

  void _getAllStocksByProductIds(List<String> productIds) async {
    // 1. On lance l'animation de chargement
    setState(() => isLoading = true);

    // 2. Appel au service (qui gère déjà ses propres erreurs)
    List<Stock>? results = await ProductService().getAllProductStocks(
        startDate!, endDate!, productIds, context);

    // 3. Mise à jour des données et arrêt du chargement
    setState(() {
      stocks = results ?? [];

      // On remplit la map pour l'affichage des noms de produits
      for (var e in widget.products) {
        productsIdMap[e.id] = e;
      }

      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getProductIds(widget.products);
    _getAllStocksByProductIds(productIds);
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: "Mouvements de Stock",
              subtitle: "Historique des arrivages",
              actions: [
                AppIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: "Actualiser",
                  onTap: () {
                    _getAllStocksByProductIds(productIds);
                  },
                ),
              ],
            ),
            _buildFilterBar(c),
            Expanded(
              child: isLoading
                  ? Center(child: const BouTikaLoader())
                  : stocks.isEmpty
                  ? EmptyState(
                icon: Icons.inventory_2_outlined,
                title: "Pas de restockage trouvé",
                message:
                "Aucun mouvement de stock sur la période sélectionnée.",
                actionLabel: "Actualiser",
                onAction: () =>
                    _getAllStocksByProductIds(productIds),
              )
                  : _buildRestockList(c),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () { /* Formulaire pour créer un nouveau Stock */ },
        label: const Text("Nouvel Arrivage"),
        icon: const Icon(Icons.add_business_outlined),
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildFilterBar(DashColors c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: c.border),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.date_range_rounded,
                  size: 16, color: c.primary),
              const SizedBox(width: 6),
              Text(
                "Période d'analyse",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: c.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilterDateChip(
                  label: "Début",
                  date: startDate,
                  onTap: () => _pickDate(true),
                  onClear: () {
                    setState(() => startDate = null);
                    _getAllStocksByProductIds(productIds);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterDateChip(
                  label: "Fin",
                  date: endDate,
                  onTap: () => _pickDate(false),
                  onClear: () {
                    setState(() => endDate = null);
                    _getAllStocksByProductIds(productIds);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final c = DashColors(context);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: c.primary,
            onPrimary: Colors.white,
            surface: c.card,
            onSurface: c.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      _getAllStocksByProductIds(productIds);
    }
  }

  Widget _buildRestockList(DashColors c) {
    return RefreshIndicator(
      color: c.primary,
      backgroundColor: c.card,
      onRefresh: () async =>
          _getAllStocksByProductIds(productIds),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          Stock stock = stocks[index];

          final double addedQty =
              stock.baseStock - (stock.previousStock ?? 0);

          final String productName =
              productsIdMap[stock.productId]?.name ?? "Produit";

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RestockCard(
              stock: stock,
              productName: productName,
              addedQty: addedQty,
              c: c,
            ),
          );
        },
      ),
    );
  }
}

// =====================================================================
// CARTE MOUVEMENT
// =====================================================================
class _RestockCard extends StatefulWidget {
  final Stock stock;
  final String productName;
  final double addedQty;
  final DashColors c;

  const _RestockCard({
    required this.stock,
    required this.productName,
    required this.addedQty,
    required this.c,
  });

  @override
  State<_RestockCard> createState() => _RestockCardState();
}

class _RestockCardState extends State<_RestockCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final stock = widget.stock;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _expanded
              ? c.primary.withValues(alpha: 0.35)
              : c.border,
          width: _expanded ? 1.3 : 1,
        ),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: c.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.inventory_2_outlined,
                        color: c.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            letterSpacing: -0.1,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ajouté le ${DateFormat('dd/MM/yyyy').format(stock.date!)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.successSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "+${widget.addedQty.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: c.success,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOut,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Container(height: 1, color: c.border),
                  const SizedBox(height: 8),
                  _modernDetailRow(c, "Prix de vente",
                      "${stock.sellingPrice}"),
                  if (UserService.userType != 'employee')
                    _modernDetailRow(c, "Prix d'achat",
                        "${stock.buyingPrice}"),
                  _modernDetailRow(c, "Total vendu",
                      stock.totalSell.toStringAsFixed(2)),
                  _modernDetailRow(
                    c,
                    "Ancien stock",
                    stock.previousStock?.toStringAsFixed(2) ?? "0",
                  ),
                  _modernDetailRow(
                    c,
                    "Nouveau stock",
                    stock.baseStock.toStringAsFixed(2),
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernDetailRow(DashColors c, String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isHighlight ? c.primary : c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
