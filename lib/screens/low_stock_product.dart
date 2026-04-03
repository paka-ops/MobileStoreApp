import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/screens/product_details_page.dart';
import 'package:mobile_store_app/service/product_service.dart';

class LowStockProductDetailsScreen extends StatefulWidget {
  List<Product> products;
  String userType;
  LowStockProductDetailsScreen({super.key,required this.products,required this.userType});

  @override
  State createState() => _LowStockProductDetailsScreen();
}

class _LowStockProductDetailsScreen extends State<LowStockProductDetailsScreen> {
  bool isLoading = false;
  // Clés et Controllers partagés pour l'ajout et la modification
  final _productFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _salingPriceController = TextEditingController();
  bool isRestocking = false;
  void _filterProducts(String query) {
    setState(() {
      widget.products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Color _getQuantityColor(double qty) {
    if (qty <= 5) return Colors.red;
    if (qty <= 15) return Colors.orange;
    return Colors.green;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produits en Rupture de Stock"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => _filterProducts(value),
              decoration: InputDecoration(
                hintText: "Rechercher un produit...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final p = widget.products[index];
                final Color statusColor = _getQuantityColor((p.stock!.baseStock - p.stock!.totalSell) ?? 0);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(Icons.shopping_bag_outlined, color: statusColor),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Prix: ${p.stock!.sellingPrice} F"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailItem("En Stock", "${(p.stock!.baseStock - p.stock!.totalSell)?.toStringAsFixed(2)??0}", color: statusColor),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ?(widget.userType == "employer")? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: (widget.userType == "employer")?[
                                _buildActionButton(Icons.add_box, "Restocker", Colors.green, () {
                                  _showRestockDialog(context, p);
                                }),
                                _buildActionButton(Icons.info_rounded, "Infos", Colors.deepOrange, () {
                                  _showInfoDialog(context, p);
                                }),
                              ]:[],
                            ):null,
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOGUE POUR AJOUTER UN PRODUIT ---

  // --- DIALOGUE D'INFORMATION ---
  void _showInfoDialog(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Détails : ${p.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID : ${p.id}"),
            const SizedBox(height: 8),
            Text("Prix unitaire : ${p.stock!.sellingPrice} F"),
            const SizedBox(height: 8),
            Text("Stock actuel : ${((p.stock!.baseStock - p.stock!.totalSell)).toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            Text("État du stock : ${(p.stock!.baseStock - p.stock!.totalSell) <= 5 ? 'Critique' : 'Normal'}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductStatsScreen(product: p))), child: const Text("plus d'infos")),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer")),
        ],
      ),
    );
  }

  // --- CONFIRMATION DE SUPPRESSION ---

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _showRestockDialog(BuildContext context, Product product) {
    final restockController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) =>StatefulBuilder(builder: (stContext,setRestockState){
        return  AlertDialog(
          title: Text("Restocker ${product.name}"),
          content: TextField(
            controller: restockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Quantité à ajouter"),
          ),
          actions: [
            TextButton(onPressed: () {setRestockState(()=>isRestocking?isRestocking=false:null);Navigator.pop(context);}, child: const Text("Annuler")),
            ElevatedButton(
              onPressed: isRestocking?null:() async {
                setRestockState(()=>isLoading=true );
                double add = double.tryParse(restockController.text) ?? 0;
                if (add > 0) {

                  Product? p = await ProductService().updateStock(product.id, add,context);
                  if(mounted)setRestockState(()=>isRestocking = false);
                  if(p!=null){
                    setState(() {
                      int index  = widget.products.indexWhere((prod) => prod.id == product.id);
                      widget.products[index] = p;
                    });
                  }

                }
                Navigator.pop(context);
              },
              child:isRestocking?CircularProgressIndicator(): const Text("Ajouter"),
            ),
          ],
        );
      }),
    );
  }
}
