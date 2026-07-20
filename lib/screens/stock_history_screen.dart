import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/models/stock.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/service/user_service.dart';

// Note: Assure-toi d'avoir un modèle Dart correspondant à ton entité Java Stock


class RestockHistoryScreen extends StatefulWidget {
  final List<Product> products; // Correction du nom "produtIds"
  const RestockHistoryScreen({super.key, required this.products});
  @override
  State<RestockHistoryScreen> createState() => _RestockHistoryScreenState();
}

class _RestockHistoryScreenState extends State<RestockHistoryScreen> {
  DateTime? startDate = DateTime.now().add(Duration(days: -30));
  DateTime? endDate = DateTime.now().add(Duration(days:1));
  bool isLoading = false;
  List<String> productIds = [];
  void _getProductIds(List<Product> products){
      products.forEach((e){
        productIds.add(e.id);
      });
      setState(() {
        productIds;
      });
  }
  void _applyFilter(){

  }
  // Cette liste sera remplie par ton appel API (List<Stock> du backend)

  List<Stock> stocks = [];
  Map<String,Product> productsIdMap = {};
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
    // TODO: implement initState
    _getProductIds(widget.products);
    _getAllStocksByProductIds(productIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Mouvements de Stock",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () { _getAllStocksByProductIds(productIds);},
          ),
        ],
      ),
      body: SafeArea(child: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                :stocks.isEmpty?_buildEmptyState(): _buildRestockList(),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () { /* Formulaire pour créer un nouveau Stock */ },
        label: const Text("Nouvel Arrivage"),
        icon: const Icon(Icons.add_business_outlined),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          const Text("Période d'analyse",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _filterChipDate("Début", startDate, true)),
              const SizedBox(width: 8),
              Expanded(child: _filterChipDate("Fin", endDate, false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChipDate(String label, DateTime? date, bool isStart) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            if (isStart) startDate = picked; else endDate = picked;
          });
          _getAllStocksByProductIds(productIds);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(
              date == null ? label : DateFormat('dd/MM/yy').format(date),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Pas de restockage trouvée",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRestockList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        Stock stock = stocks[index];

        final addedQty = stock.baseStock - stock.previousStock!;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              // 🔵 ICON MODERNE
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: Color(0xFF0284C7), size: 20),
              ),

              // 🏷️ TITRE
              title: Text(
                productsIdMap[stock.productId]!.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              // 📅 DATE
              subtitle: Text(
                "Ajouté le ${stock.date!}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),

              // 🟢 BADGE QUANTITÉ
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "+${addedQty.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

              // 📊 DETAILS
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: [
                      _modernDetailRow("Prix de vente", "${stock.sellingPrice}"),
                      ?(UserService.userType =='employee')?null:_modernDetailRow("Prix d'achat", "${stock.buyingPrice}"),
                      _modernDetailRow("Total vendu", stock.totalSell.toStringAsFixed(2)),
                      _modernDetailRow(
                        "Ancien stock",
                        stock.previousStock?.toStringAsFixed(2) ?? "0",
                      ),
                      _modernDetailRow(
                        "Nouveau stock",
                        stock.baseStock.toStringAsFixed(2),
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
  Widget _modernDetailRow(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isHighlight ? const Color(0xFF2563EB) : Colors.black87,
            ),
          ),
        ],
      ),
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