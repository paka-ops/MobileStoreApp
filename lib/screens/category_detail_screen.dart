import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/screens/low_stock_product.dart';
import 'package:mobile_store_app/screens/product_details_page.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/utils/message.dart';

class EmployerCategoryDetailScreen extends StatefulWidget {
  final Category category;
  final String userType;
  EmployerCategoryDetailScreen({super.key, required this.category, required this.userType});

  @override
  State createState() => _EmployerCategoryDetailsState();
}

class _EmployerCategoryDetailsState extends State<EmployerCategoryDetailScreen> {
  List<Product> allProducts = []; // Liste complète
  List<Product> filteredProducts = []; // Liste affichée (filtrée)
  List<Product> lowStockProducts = []; // Produits en stock critique
  bool isLoading = true;
  bool isEditing = false;
  bool isAdding = false;
  bool isRestocking = false;
  bool isRemoving = false;

  // Clés et Controllers partagés pour l'ajout et la modification
  final _productFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _salingPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    setState(() => isLoading = true);
    ProductService proService = ProductService();
    List<Product> pros = await proService.getAllProductByCategoryId(widget.category.id,context);
    List<Product> lowStock = pros.where((p) => (p.stock!.baseStock - p.stock!.totalSell) <= 10).toList();
    setState(() {
      allProducts = pros;
      lowStockProducts = lowStock;
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

  Color _getQuantityColor(double qty) {
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
            onPressed: (){
              print("Low stock products: ${lowStockProducts.map((p) => p.name).toList()}");
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LowStockProductDetailsScreen(products: lowStockProducts, userType: widget.userType)));},
            icon: Icon(Icons.warning_amber_rounded, color: (lowStockProducts.isNotEmpty)?Colors.redAccent:Colors.grey),
          ),
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
                final Color statusColor = _getQuantityColor((p.stock!.baseStock - p.stock!.totalSell)?? 0);

                return _buildProductCard(p, statusColor);
              },
            ),
          ),
        ],
      ),
      // --- AJOUT DU FLOATING ACTION BUTTON ---
      floatingActionButton:(widget.userType == "employer")? FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ):null,
    );
  }

  // --- DIALOGUE POUR AJOUTER UN PRODUIT ---
  void _showAddProductDialog(BuildContext context) {
    // Vider les champs avant d'afficher
    _nameController.clear();
    _qtyController.clear();
    _salingPriceController.clear();
    _buyingPriceController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (stContext,setAddingState){
        return AlertDialog(
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
                    controller: _buyingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Prix d' achat (F)"),
                    validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                  ),
                  TextFormField(
                    controller: _salingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Prix de vente (F)"),
                    validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: (){isAdding? setAddingState(()=>isAdding=false):null;Navigator.pop(context);}, child: const Text("Annuler")),
            ElevatedButton(
              onPressed: isAdding?null:() async {
                setAddingState(()=>isAdding = true);
                if (_productFormKey.currentState!.validate()) {
                  Map<String, dynamic> productData = {
                    "name": _nameController.text,
                    "quantity": double.parse(_qtyController.text),
                    "sellingPrice": double.parse(_salingPriceController.text),
                    "buyingPrice": double.parse(_buyingPriceController.text),
                  };
                  ProductService ps = ProductService();
                  Product? newProd = await ps.add(productData, widget.category.id,context);
                  if(mounted) setAddingState(()=>isAdding = false);
                  if (newProd != null) {
                    _fetchProducts(); // Rafraîchir la liste pour inclure le nouveau produit
                    Navigator.pop(context);
                    showSuccessMessage("Produit ajouté avec succès !", context);
                  } else {
                    showErrorMessage("Erreur lors de l'ajout.", context);
                    }
                }
              },
              child:isAdding?CircularProgressIndicator(): const Text("Ajouter"),
            ),
          ],
        );
      }),
    );
  }

  // --- DIALOGUE D'INFORMATION ---
  void _showInfoDialog(BuildContext context, Product p) {
    final stock = (p.stock!.baseStock - p.stock!.totalSell);
    final isLow = stock <= 5;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔵 ICON HEADER
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF3B82F6),
                    size: 28,
                  ),
                ),

                const SizedBox(height: 15),

                // 🏷️ TITLE
                Text(
                  p.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // 📊 INFOS
                _modernRow("Prix", "${p.stock!.sellingPrice} F"),
                _modernRow("Stock", "$stock"),

                _modernRow(
                  "État",
                  isLow ? "Critique" : "Normal",
                  valueColor:
                  isLow ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                ),

                const SizedBox(height: 25),

                // 🔘 ACTIONS
                Row(
                  children: [
                    // bouton secondaire
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Fermer"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // bouton principal
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductStatsScreen(product: p),
                            ),
                          );
                        },
                        child: const Text("Plus d'infos"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _modernRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // --- CONFIRMATION DE SUPPRESSION ---
  void _confirmDelete(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (stContext,setDeleteState){
        return AlertDialog(
          title: const Text("Supprimer ?"),
          content: Text("Voulez-vous vraiment supprimer ${p.name} ?"),
          actions: [
            TextButton(onPressed: (){ setDeleteState(()=>isRemoving?isRemoving=false:null);Navigator.pop(context);}, child: const Text("Annuler")),
            TextButton(
              onPressed:isRemoving?null: () async {
                setDeleteState(()=>isRemoving = true);
                await ProductService().delete(p.id,context);
                if(mounted)setDeleteState(()=>isRemoving = false);
                _fetchProducts();
                Navigator.pop(context);
              },
              child:isRemoving?CircularProgressIndicator(): const Text("Supprimer", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      })
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    _nameController.text = product.name;
    _qtyController.text = (product.stock!.baseStock - product.stock!.totalSell).toString();
    _salingPriceController.text = product.stock?.sellingPrice.toString() ?? '';
    _buyingPriceController.text = product.stock?.buyingPrice.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (stcontxt,setEditStat){
        return AlertDialog(
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
                    controller: _buyingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Prix d' achat (F)"),
                    validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                  ),
                  TextFormField(
                    controller: _salingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Prix de vente (F)"),
                    validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: (){ setEditStat(()=>isEditing?isEditing=false:null );Navigator.pop(context);}, child: const Text("Annuler")),
            ElevatedButton(
              onPressed: isEditing?null:() async {
                if (_productFormKey.currentState!.validate()) {
                  setEditStat(()=>isEditing = true);
                  Map<String, dynamic> updatedData = {
                    "name": _nameController.text,
                    "quantity": double.parse(_qtyController.text),
                    "sellingPrice": double.parse(_salingPriceController.text),
                    "buyingPrice": double.parse(_buyingPriceController.text),
                  };

                  ProductService ps = ProductService();
                  Product? result = await ps.update(product.id, updatedData,context);
                  if(mounted) setEditStat(()=>isEditing= false);
                  if (result != null) {
                    _fetchProducts();
                    Navigator.pop(context);
                    showSuccessMessage("Produit mis à jour !", context);
                    }
                }
              },
              child:isEditing?CircularProgressIndicator(): const Text("Enregistrer"),
            ),
          ],
        );
      }),
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
    final GlobalKey<FormState> restockingKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (stContext,setRestockStat){
        return AlertDialog(
          title: Text("Restocker ${product.name}"),
          content: Form(
            key: restockingKey,
            child:  TextFormField(
              controller: restockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantité à ajouter"),
              validator: (String? value){
                if(value == null||value.isEmpty) return "entrer une valeur";
                if(double.parse(value)<=0)return "valeur ne peux pas etre inférieur a zero";
                return null;
              },
            ),
          ),
          actions: [
            TextButton(onPressed: (){ setRestockStat(()=>isRestocking?isRestocking=false:null);Navigator.pop(context);}, child: const Text("Annuler")),
            ElevatedButton(
              onPressed:isRestocking?null: () async {

                double add = double.tryParse(restockController.text) ?? 0;
                if (restockingKey.currentState!.validate()){setRestockStat(()=>isRestocking=true);
                  Product? p = await ProductService().updateStock(product.id, add,context);
                  if(mounted) setRestockStat(()=>isRestocking=false);
                  if(p!=null){
                    setState(() {
                      int index  = allProducts.indexWhere((prod) => prod.id == product.id);
                      allProducts[index] = p;
                      _filterProducts(""); // Rafraîchir la liste affichée

                    });
                    showSuccessMessage("$add unitées ajouté au produit ${p.name}", context);
                    Navigator.pop(context);
                  }

                }


              },
              child:isRestocking?CircularProgressIndicator():const Text("Ajouter"),
            ),
          ],
        );
      }),
    );
  }
  Widget _buildProductCard(Product p, Color statusColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // Style d'icône identique au Drawer/Category
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: statusColor, size: 24),
          ),
          title: Text(
            p.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            "Prix de vente: ${p.stock!.sellingPrice} F",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de section stylisé
                  const Text(
                    "ÉTAT DU STOCK",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.userType == "employer")
                        _buildDetailItem("Prix d'achat", "${p.stock!.buyingPrice} F"),
                      _buildDetailItem(
                          "Disponible",
                          "${((p.stock!.baseStock) - (p.stock!.totalSell)).toStringAsFixed(2)} unités",
                          color: statusColor
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Section Actions stylisée
                  if (widget.userType == "employer") ...[
                    const Text(
                      "ACTIONS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Utilisation d'un Wrap pour que les boutons ne débordent pas
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildModernActionButton(Icons.edit, "Modifier", Colors.blue, () {
                          _showEditProductDialog(context, p);
                        }),
                        _buildModernActionButton(Icons.add_box, "Restocker", Colors.green, () {
                          _showRestockDialog(context, p);
                        }),
                        _buildModernActionButton(Icons.delete_outline, "Supprimer", Colors.red, () {
                          _confirmDelete(context, p);
                        }),
                        _buildModernActionButton(Icons.info_rounded, "Infos", Colors.deepOrange, () {
                          _showInfoDialog(context, p);
                        }),
                      ],
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

// Fonction utilitaire pour des boutons d'action conformes au nouveau style
  Widget _buildModernActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
