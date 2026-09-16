import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/models/stock.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors, PremiumRadii;
import 'package:mobile_store_app/widgets/boutika_loader.dart';
import 'package:mobile_store_app/widgets/premium_kit.dart';

// =====================================================================
// MOUVEMENTS DE STOCK — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : identifiants produits, chargement des stocks,
// filtres de période, calcul des quantités ajoutées et masquage du prix
// d'achat pour les employés — tout est conservé. La présentation passe
// au thème (clair/sombre), cartes feutrées et badges émeraude.
// =====================================================================
class RestockHistoryScreen extends StatefulWidget {
  final List<Product> products;
  const RestockHistoryScreen({super.key, required this.products});
  @override
  State<RestockHistoryScreen> createState() => _RestockHistoryScreenState();
}

class _RestockHistoryScreenState extends State<RestockHistoryScreen> {
  DateTime? startDate = DateTime.now().add(Duration(days: -30));
  DateTime? endDate = DateTime.now().add(Duration(days: 1));
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

  void _applyFilter() {}

  // Cette liste sera remplie par ton appel API (List<Stock> du backend)
  List<Stock> stocks = [];
  Map<String, Product> productsIdMap = {};
  void _getAllStocksByProductIds(List<String> productIds) async {
    // 1. On lance l'animation de chargement
    setState(() => isLoading = true);

    // 2. Appel au service (qui gère déjà ses propres erreurs)
    List<Stock>? results = await ProductService()
        .getAllProductStocks(startDate!, endDate!, productIds, context);

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
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        final colors = DashColors(context);

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: const Text("Mouvements de Stock"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(PremiumRadii.sm),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: IconButton(
                    tooltip: "Actualiser",
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                    onPressed: () {
                      _getAllStocksByProductIds(productIds);
                    },
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
              child: Column(
            children: [
              _buildFilterBar(colors),
              Expanded(
                child: isLoading
                    ? const Center(child: BouTikaLoader())
                    : stocks.isEmpty
                        ? _buildEmptyState(colors)
                        : _buildRestockList(colors),
              ),
            ],
          )),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PremiumRadii.input),
              boxShadow: colors.glowShadow,
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                /* Formulaire pour créer un nouveau Stock */
              },
              label: const Text(
                "Nouvel Arrivage",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              icon: const Icon(Icons.add_business_outlined, size: 20),
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        );
      },
    );
  }

  // Barre de période — carte feutrée (plus de blanc pur / ombre dure).
  Widget _buildFilterBar(DashColors colors) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          PremiumMicroLabel("Période d'analyse", color: colors.textSecondary),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _filterChipDate("Début", startDate, true, colors)),
              const SizedBox(width: 12),
              Expanded(child: _filterChipDate("Fin", endDate, false, colors)),
            ],
          ),
        ],
      ),
    );
  }

  // Sélecteur de date — logique showDatePicker inchangée.
  Widget _filterChipDate(
      String label, DateTime? date, bool isStart, DashColors colors) {
    final hasDate = date != null;
    return InkWell(
      borderRadius: BorderRadius.circular(PremiumRadii.input),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: colors.primary,
                onPrimary: Colors.white,
                surface: colors.card,
                onSurface: colors.textPrimary,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            if (isStart)
              startDate = picked;
            else
              endDate = picked;
          });
          _getAllStocksByProductIds(productIds);
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: hasDate ? colors.primarySoft : colors.fieldFill,
          borderRadius: BorderRadius.circular(PremiumRadii.input),
          border: Border.all(
            color: hasDate
                ? colors.primary.withOpacity(0.4)
                : colors.border,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: hasDate ? colors.primary : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                date == null ? label : DateFormat('dd/MM/yy').format(date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasDate ? colors.primary : colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(DashColors colors) {
    return const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: PremiumEmptyState(
          icon: Icons.inventory_2_outlined,
          title: "Pas de restockage trouvée",
          message:
              "Aucun mouvement de stock sur cette période. Les nouveaux arrivages apparaîtront ici.",
        ),
      ),
    );
  }

  // Liste des mouvements — mêmes données, cartes extensibles premium.
  Widget _buildRestockList(DashColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        Stock stock = stocks[index];

        final addedQty = stock.baseStock - stock.previousStock!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(PremiumRadii.lg),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: colors.cardShadow,
          ),
          child: Theme(
            data: Theme.of(context)
                .copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumRadii.lg),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumRadii.lg),
              ),

              // Pastille produit — voile info doux.
              leading: PremiumIconTile(
                icon: Icons.inventory_2_outlined,
                color: colors.info,
                softColor: colors.infoSoft,
                size: 46,
                iconSize: 22,
              ),

              // Nom du produit.
              title: Text(
                productsIdMap[stock.productId]!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: colors.textPrimary,
                ),
              ),

              // Date d'ajout.
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  "Ajouté le ${stock.date!}",
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Badge quantité — émeraude feutré.
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: colors.successSoft,
                  borderRadius: BorderRadius.circular(PremiumRadii.pill),
                ),
                child: Text(
                  "+${addedQty.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: colors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),

              // Détails chiffrés.
              children: [
                Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colors.border),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: [
                      _modernDetailRow(
                          "Prix de vente", "${stock.sellingPrice}", colors),
                      // Prix d'achat masqué aux employés (logique d'origine).
                      if (UserService.userType != 'employee')
                        _modernDetailRow(
                            "Prix d'achat", "${stock.buyingPrice}", colors),
                      _modernDetailRow("Total vendu",
                          stock.totalSell.toStringAsFixed(2), colors),
                      _modernDetailRow(
                        "Ancien stock",
                        stock.previousStock?.toStringAsFixed(2) ?? "0",
                        colors,
                      ),
                      _modernDetailRow(
                        "Nouveau stock",
                        stock.baseStock.toStringAsFixed(2),
                        colors,
                        isHighlight: true,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modernDetailRow(String label, String value, DashColors colors,
      {bool isHighlight = false}) {
    return PremiumInfoRow(
      label: label,
      value: value,
      highlight: isHighlight,
      valueColor: isHighlight ? colors.primary : null,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
