
import 'package:flutter/material.dart';
import 'package:mobile_store_app/service/product_service.dart';

import '../models/category.dart';
import '../models/product.dart';

class CategoryDetailScreen extends StatefulWidget {
  Category category;

  CategoryDetailScreen({super.key, required this.category});
  @override
  State<StatefulWidget> createState() => _CategoryDetailsState();

}
class _CategoryDetailsState extends State<CategoryDetailScreen> {
  final _productFormKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productQtyController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.products.length, // Simulation de 10 produits
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            title: Text("${widget.category.name} - ${widget.category.products[index].name}"),
            subtitle:  Text("Ref: PRD-00X45"),
            trailing: Text("${widget.category.products[index].price} F", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            onTap: () {
              // Action lors du clic sur un produit
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.orange,
      child: const Icon(Icons.add, color: Colors.white),
      onPressed: () => _showProductForm(context),
    ),
    );
  }
  void _showProductForm(BuildContext context, {Product? product}) {
    // Si product n'est pas null, on remplit les champs pour la modification
    if (product != null) {
      _productNameController.text = product.name;
      _productQtyController.text = product.quantity.toString();
      _productPriceController.text = product.price.toString();
    } else {
      _productNameController.clear();
      _productQtyController.clear();
      _productPriceController.clear();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(product == null ? Icons.add_box : Icons.edit, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text(product == null ? "Nouveau Produit" : "Modifier Produit"),
          ],
        ),
        content: Form(
          key: _productFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CHAMP NOM
                TextFormField(
                  controller: _productNameController,
                  decoration: const InputDecoration(labelText: "Nom du produit", prefixIcon: Icon(Icons.shopping_bag)),
                  validator: (value) => (value == null || value.isEmpty) ? 'Nom obligatoire' : null,
                ),
                const SizedBox(height: 10),
                // CHAMP QUANTITÉ
                TextFormField(
                  controller: _productQtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantité en stock", prefixIcon: Icon(Icons.inventory_2)),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Entrez une quantité';
                    if (int.tryParse(value) == null) return 'Nombre entier valide requis';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // CHAMP PRIX
                TextFormField(
                  controller: _productPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Prix unitaire", prefixIcon: Icon(Icons.payments), suffixText: "F"),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Entrez un prix';
                    if (double.tryParse(value) == null) return 'Prix valide requis';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              if (_productFormKey.currentState!.validate()) {
                ProductService ps = ProductService();

                Map<String, dynamic> productData = {
                  "name": _productNameController.text,
                  "quantity": _productQtyController.text,
                  "price": _productPriceController.text,
                };

                try {
                  if (product == null) {
                    // LOGIQUE AJOUT
                    Product? newProd = await ps.add(productData,widget.category.id);
                    if (newProd != null) {
                      setState(() {
                        widget.category.products.add(newProd);
                      });
                      print("vocie les produits ${widget.category.products}");
                    }
                  } else {
                    // LOGIQUE MISE À JOUR
                    Product? updatedProd = await ps.update(product.id, productData);
                    if (updatedProd != null) {
                      setState(() {
                        int index = widget.category.products.indexWhere((p) => p.id == product.id);
                        widget.category.products[index] = updatedProd;
                      });
                      print("vocie les produits ${widget.category.products}");
                    }
                  }
                  Navigator.pop(context);
                  print("vocie les produits ${widget.category.products}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(product == null ? "Produit ajouté !" : "Produit mis à jour !")),
                  );
                } catch (e) {
                  print("Erreur API: $e");
                }
              }
            },
            child: Text(product == null ? "Ajouter" : "Enregistrer", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}