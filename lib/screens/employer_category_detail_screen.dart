import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/screens/product_details_page.dart';
import 'package:mobile_store_app/service/product_service.dart';

class EmployerCategoryDetailScreen extends StatefulWidget {
  final Category category;
  EmployerCategoryDetailScreen({super.key, required this.category});

  @override
  State createState() => _EmployerCategoryDetailsState();
}

class _EmployerCategoryDetailsState extends State<EmployerCategoryDetailScreen> {
  List<Product> allProducts = []; // Liste complète
  List<Product> filteredProducts = []; // Liste affichée (filtrée)
  bool isLoading = true;

  // Clés et Controllers partagés pour l'ajout et la modification
  final _productFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    setState(() => isLoading = true);
    ProductService proService = ProductService();
    List<Product> pros = await proService.getAllProductByCategoryId(widget.category.id);
    setState(() {
      allProducts = pros;
      filteredProducts = pros;
      isLoading = false;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Color _getQuantityColor(int qty) {
    if (qty <= 5) return Colors.red;
    if (qty <= 15) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion ${widget.category.name}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts, // Bouton pour rafraîchir la liste
          )
        ],
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
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final p = filteredProducts[index];
                final Color statusColor = _getQuantityColor(p.quantity ?? 0);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(Icons.shopping_bag_outlined, color: statusColor),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Prix: ${p.price} F"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailItem("Réf", "PRD-${p.id.substring(0, 5).toUpperCase()}"),
                                _buildDetailItem("En Stock", "${p.quantity}", color: statusColor),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(Icons.edit, "Modifier", Colors.blue, () {
                                  _showEditProductDialog(context, p);
                                }),
                                _buildActionButton(Icons.add_box, "Restocker", Colors.green, () {
                                  _showRestockDialog(context, p);
                                }),
                                _buildActionButton(Icons.delete_outline, "Supprimer", Colors.red, () {
                                  _confirmDelete(context, p);
                                }),
                                _buildActionButton(Icons.info_rounded, "Infos", Colors.deepOrange, () {
                                  _showInfoDialog(context, p);
                                }),
                              ],
                            ),
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
      // --- AJOUT DU FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- DIALOGUE POUR AJOUTER UN PRODUIT ---
  void _showAddProductDialog(BuildContext context) {
    // Vider les champs avant d'afficher
    _nameController.clear();
    _qtyController.clear();
    _priceController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Nouveau Produit"),
        content: Form(
          key: _productFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nom du produit"),
                  validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                ),
                TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantité initiale"),
                  validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Prix (F)"),
                  validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (_productFormKey.currentState!.validate()) {
                Map<String, dynamic> productData = {
                  "name": _nameController.text,
                  "quantity": int.parse(_qtyController.text),
                  "price": double.parse(_priceController.text),
                };

                ProductService ps = ProductService();
                Product? newProd = await ps.add(productData, widget.category.id);

                if (newProd != null) {
                  _fetchProducts(); // Rafraîchir la liste pour inclure le nouveau produit
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produit ajouté avec succès !")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de l'ajout.")));
                }
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

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
            Text("Prix unitaire : ${p.price} F"),
            const SizedBox(height: 8),
            Text("Stock actuel : ${p.quantity}"),
            const SizedBox(height: 8),
            Text("État du stock : ${p.quantity! <= 5 ? 'Critique' : 'Normal'}"),
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
  void _confirmDelete(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: Text("Voulez-vous vraiment supprimer ${p.name} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              await ProductService().delete(p.id);
              _fetchProducts();
              Navigator.pop(context);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    _nameController.text = product.name;
    _qtyController.text = product.quantity.toString();
    _priceController.text = product.price.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Modifier ${product.name}"),
        content: Form(
          key: _productFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nom du produit"),
                  validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                ),
                TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantité"),
                  validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Prix (F)"),
                  validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (_productFormKey.currentState!.validate()) {
                Map<String, dynamic> updatedData = {
                  "name": _nameController.text,
                  "quantity": int.parse(_qtyController.text),
                  "price": double.parse(_priceController.text),
                };

                ProductService ps = ProductService();
                Product? result = await ps.update(product.id, updatedData);

                if (result != null) {
                  _fetchProducts();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produit mis à jour !")));
                }
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

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
      builder: (context) => AlertDialog(
        title: Text("Restocker ${product.name}"),
        content: TextField(
          controller: restockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Quantité à ajouter"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              int add = int.tryParse(restockController.text) ?? 0;
              if (add > 0) {
                Map<String, dynamic> data = {"quantity": (product.quantity ?? 0) + add};
                await ProductService().update(product.id, data);
                _fetchProducts();
              }
              Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }
}
