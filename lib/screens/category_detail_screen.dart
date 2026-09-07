import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/screens/low_stock_product.dart';
import 'package:mobile_store_app/screens/product_details_page.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart';
import 'package:mobile_store_app/utils/message.dart';

class EmployerCategoryDetailScreen extends StatefulWidget {
  final Category category;
  final String userType;

  const EmployerCategoryDetailScreen({
    super.key,
    required this.category,
    required this.userType,
  });

  @override
  State createState() => _EmployerCategoryDetailsState();
}

class _EmployerCategoryDetailsState
    extends State<EmployerCategoryDetailScreen> {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  List<Product> lowStockProducts = [];
  bool isLoading = true;
  bool isEditing = false;
  bool isAdding = false;
  bool isRestocking = false;
  bool isRemoving = false;

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

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _buyingPriceController.dispose();
    _salingPriceController.dispose();
    super.dispose();
  }

  void _fetchProducts() async {
    setState(() => isLoading = true);
    ProductService proService = ProductService();
    List<Product> pros =
    await proService.getAllProductByCategoryId(widget.category.id, context);
    List<Product> lowStock = pros
        .where((p) => (p.stock!.baseStock - p.stock!.totalSell) <= 10)
        .toList();
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

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

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
            _buildSearchBar(c),
            _buildStatsRow(c),
            Expanded(child: _buildBody(c)),
          ],
        ),
      ),
      floatingActionButton: (widget.userType == "employer")
          ? _buildFab(c)
          : null,
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
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: c.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.name,
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
                  "Gestion des produits",
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Low stock alert
          _buildHeaderAction(
            c,
            icon: Icons.warning_amber_rounded,
            badge: lowStockProducts.length,
            badgeColor: c.danger,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LowStockProductDetailsScreen(
                    products: lowStockProducts,
                    userType: widget.userType,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          // Refresh
          _buildHeaderAction(
            c,
            icon: Icons.refresh_rounded,
            onTap: _fetchProducts,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(
      DashColors c, {
        required IconData icon,
        int badge = 0,
        Color? badgeColor,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Icon(icon, size: 20, color: c.textPrimary),
          ),
          if (badge > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeColor ?? c.danger,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$badge",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =====================================================================
  // SEARCH BAR
  // =====================================================================
  Widget _buildSearchBar(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: TextField(
          onChanged: _filterProducts,
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: "Rechercher un produit...",
            hintStyle: TextStyle(
              color: c.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.search_rounded, color: c.textSecondary, size: 20),
            ),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // STATS ROW (mini KPIs)
  // =====================================================================
  Widget _buildStatsRow(DashColors c) {
    final int total = allProducts.length;
    final int lowStock = lowStockProducts.length;
    final int healthy = total - lowStock;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              c: c,
              icon: Icons.inventory_2_rounded,
              label: "Total",
              value: "$total",
              color: c.primary,
              softColor: c.primarySoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              c: c,
              icon: Icons.check_circle_outline_rounded,
              label: "Normal",
              value: "$healthy",
              color: c.success,
              softColor: c.successSoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              c: c,
              icon: Icons.warning_amber_rounded,
              label: "Critique",
              value: "$lowStock",
              color: c.danger,
              softColor: c.dangerSoft,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // BODY — Loading / Empty / List
  // =====================================================================
  Widget _buildBody(DashColors c) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.5,
              color: c.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "Chargement des produits...",
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

    if (filteredProducts.isEmpty) {
      return _buildEmptyState(c);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ProductCard(
            product: filteredProducts[index],
            c: c,
            userType: widget.userType,
            onEdit: () =>
                _showEditProductDialog(context, filteredProducts[index]),
            onRestock: () =>
                _showRestockDialog(context, filteredProducts[index]),
            onDelete: () => _confirmDelete(context, filteredProducts[index]),
            onInfo: () => _showInfoDialog(context, filteredProducts[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(DashColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: c.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: c.border),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 50,
                color: c.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "Aucun produit trouvé",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.userType == "employer"
                  ? "Ajoutez votre premier produit dans cette catégorie."
                  : "Cette catégorie ne contient aucun produit.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (widget.userType == "employer") ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddProductDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(
                    "Ajouter un produit",
                    style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // FAB
  // =====================================================================
  Widget _buildFab(DashColors c) {
    return SizedBox(
      width: 170,
      height: 52,
      child: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: c.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          "Nouveau produit",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // =====================================================================
  // DIALOG — Ajouter un produit
  // =====================================================================
  void _showAddProductDialog(BuildContext context) {
    final c = DashColors(context);
    _nameController.clear();
    _qtyController.clear();
    _salingPriceController.clear();
    _buyingPriceController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (stContext, setAddingState) {
          return AlertDialog(
            backgroundColor: c.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: c.border, width: 1.2),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                  Icon(Icons.add_box_rounded, color: c.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Nouveau Produit",
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _productFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildField(c, _nameController, "Nom du produit",
                        Icons.label_rounded, "Ex: Sac en cuir"),
                    const SizedBox(height: 14),
                    _buildField(c, _qtyController, "Quantité initiale",
                        Icons.inventory_rounded, "Ex: 50",
                        isNumber: true),
                    const SizedBox(height: 14),
                    _buildField(c, _buyingPriceController, "Prix d'achat (F)",
                        Icons.money_rounded, "Ex: 5000",
                        isNumber: true),
                    const SizedBox(height: 14),
                    _buildField(c, _salingPriceController, "Prix de vente (F)",
                        Icons.sell_rounded, "Ex: 8000",
                        isNumber: true),
                  ],
                ),
              ),
            ),
            actions: [
              _buildDialogActions(
                c,
                isLoading: isAdding,
                confirmLabel: "Ajouter",
                onCancel: () {
                  setAddingState(() => isAdding = false);
                  Navigator.pop(context);
                },
                onConfirm: () async {
                  if (_productFormKey.currentState!.validate()) {
                    setAddingState(() => isAdding = true);
                    Map<String, dynamic> productData = {
                      "name": _nameController.text,
                      "quantity": double.parse(_qtyController.text),
                      "sellingPrice":
                      double.parse(_salingPriceController.text),
                      "buyingPrice":
                      double.parse(_buyingPriceController.text),
                    };
                    ProductService ps = ProductService();
                    Product? newProd =
                    await ps.add(productData, widget.category.id, context);
                    if (mounted) setAddingState(() => isAdding = false);
                    if (newProd != null) {
                      _fetchProducts();
                      Navigator.pop(context);
                      showSuccessMessage(
                          "Produit ajouté avec succès !", context);
                    } else {
                      showErrorMessage("Erreur lors de l'ajout.", context);
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================================================
  // DIALOG — Modifier un produit
  // =====================================================================
  void _showEditProductDialog(BuildContext context, Product product) {
    final c = DashColors(context);
    _nameController.text = product.name;
    _qtyController.text =
        (product.stock!.baseStock - product.stock!.totalSell).toString();
    _salingPriceController.text =
        product.stock?.sellingPrice.toString() ?? '';
    _buyingPriceController.text =
        product.stock?.buyingPrice.toString() ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (stContext, setEditStat) {
          return AlertDialog(
            backgroundColor: c.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: c.border, width: 1.2),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.edit_rounded, color: c.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Modifier ${product.name}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _productFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildField(c, _nameController, "Nom du produit",
                        Icons.label_rounded, ""),
                    const SizedBox(height: 14),
                    _buildField(c, _qtyController, "Quantité",
                        Icons.inventory_rounded, "",
                        isNumber: true),
                    const SizedBox(height: 14),
                    _buildField(c, _buyingPriceController, "Prix d'achat (F)",
                        Icons.money_rounded, "",
                        isNumber: true),
                    const SizedBox(height: 14),
                    _buildField(c, _salingPriceController, "Prix de vente (F)",
                        Icons.sell_rounded, "",
                        isNumber: true),
                  ],
                ),
              ),
            ),
            actions: [
              _buildDialogActions(
                c,
                isLoading: isEditing,
                confirmLabel: "Enregistrer",
                onCancel: () {
                  setEditStat(() => isEditing = false);
                  Navigator.pop(context);
                },
                onConfirm: () async {
                  if (_productFormKey.currentState!.validate()) {
                    setEditStat(() => isEditing = true);
                    Map<String, dynamic> updatedData = {
                      "name": _nameController.text,
                      "quantity": double.parse(_qtyController.text),
                      "sellingPrice":
                      double.parse(_salingPriceController.text),
                      "buyingPrice":
                      double.parse(_buyingPriceController.text),
                    };
                    ProductService ps = ProductService();
                    Product? result =
                    await ps.update(product.id, updatedData, context);
                    if (mounted) setEditStat(() => isEditing = false);
                    if (result != null) {
                      _fetchProducts();
                      Navigator.pop(context);
                      showSuccessMessage("Produit mis à jour !", context);
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================================================
  // DIALOG — Restocker
  // =====================================================================
  void _showRestockDialog(BuildContext context, Product product) async {
    final c = DashColors(context);
    final restockController = TextEditingController();
    final GlobalKey<FormState> restockingKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stContext, setRestockStat) {
          return AlertDialog(
            backgroundColor: c.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: c.border, width: 1.2),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.successSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_box_rounded, color: c.success, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Restocker ${product.name}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: Form(
              key: restockingKey,
              child: _buildField(
                c,
                restockController,
                "Quantité à ajouter",
                Icons.add_circle_outline_rounded,
                "Ex: 25",
                isNumber: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) return "Entrez une valeur";
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return "Valeur invalide";
                  }
                  return null;
                },
              ),
            ),
            actions: [
              _buildDialogActions(
                c,
                isLoading: isRestocking,
                confirmLabel: "Ajouter",
                confirmColor: c.success,
                onCancel: () {
                  setRestockStat(() => isRestocking = false);
                  Navigator.pop(dialogContext);
                },
                onConfirm: () async {
                  if (restockingKey.currentState!.validate()) {
                    setRestockStat(() => isRestocking = true);

                    final double add =
                        double.tryParse(restockController.text) ?? 0;

                    Product? p = await ProductService()
                        .updateStock(product.id, add, context);

                    if (!mounted) return;

                    setRestockStat(() => isRestocking = false);

                    if (p != null) {
                      setState(() {
                        final index = allProducts.indexWhere(
                              (prod) => prod.id == product.id,
                        );
                        if (index != -1) {
                          allProducts[index] = p;
                        }
                        _filterProducts("");
                      });

                      Navigator.pop(dialogContext);
                      showSuccessMessage(
                        "$add unités ajoutées à ${p.name}",
                        context,
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================================================
  // DIALOG — Supprimer
  // =====================================================================
  void _confirmDelete(BuildContext context, Product p) {
    final c = DashColors(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (stContext, setDeleteState) {
          return AlertDialog(
            backgroundColor: c.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: c.border, width: 1.2),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.dangerSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_forever_rounded,
                      color: c.danger, size: 32),
                ),
                const SizedBox(height: 18),
                Text(
                  "Supprimer le produit",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Voulez-vous vraiment supprimer '${p.name}' ? Cette action est irréversible.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
            actions: [
              _buildDialogActions(
                c,
                isLoading: isRemoving,
                confirmLabel: "Supprimer",
                confirmColor: c.danger,
                onCancel: () {
                  setDeleteState(() => isRemoving = false);
                  Navigator.pop(context);
                },
                onConfirm: () async {
                  setDeleteState(() => isRemoving = true);
                  await ProductService().delete(p.id, context);
                  if (mounted) setDeleteState(() => isRemoving = false);
                  _fetchProducts();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================================================
  // DIALOG — Info produit
  // =====================================================================
  void _showInfoDialog(BuildContext context, Product p) {
    final c = DashColors(context);
    final stock = (p.stock!.baseStock - p.stock!.totalSell);
    final isLow = stock <= 5;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: c.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: c.border, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.infoSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.inventory_2_outlined,
                      color: c.info, size: 28),
                ),
                const SizedBox(height: 18),
                Text(
                  p.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Info rows
                _infoRow(c, "Prix de vente", "${p.stock!.sellingPrice} F"),
                _infoRow(c, "Stock restant", "${stock.toStringAsFixed(2)}"),
                _infoRow(
                  c,
                  "État",
                  isLow ? "Critique" : "Normal",
                  valueColor: isLow ? c.danger : c.success,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: c.textPrimary,
                          side: BorderSide(color: c.border, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Fermer",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: c.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
                        child: const Text("Plus d'infos",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(DashColors c, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (valueColor ?? c.textPrimary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: valueColor ?? c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // SHARED — Champ de texte stylisé
  // =====================================================================
  Widget _buildField(
      DashColors c,
      TextEditingController controller,
      String label,
      IconData icon,
      String hint, {
        bool isNumber = false,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.5,
        color: c.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
            color: c.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13.5),
        hintStyle: TextStyle(color: c.textSecondary, fontSize: 13.5),
        filled: true,
        fillColor: c.background,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: c.primary, size: 20),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.danger, width: 1.3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.danger, width: 1.6),
        ),
      ),
      validator: validator ??
              (v) => (v == null || v.isEmpty) ? "Champ obligatoire" : null,
    );
  }

  // =====================================================================
  // SHARED — Actions de dialog (Annuler / Confirmer)
  // =====================================================================
  Widget _buildDialogActions(
      DashColors c, {
        required bool isLoading,
        required String confirmLabel,
        Color? confirmColor,
        required VoidCallback onCancel,
        required VoidCallback onConfirm,
      }) {
    final Color btnColor = confirmColor ?? c.primary;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: c.card,
              foregroundColor: c.textPrimary,
              elevation: 0,
              side: BorderSide(color: c.border, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isLoading ? null : onCancel,
            child: const Text("Annuler",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isLoading ? null : onConfirm,
            child: isLoading
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2.2, color: Colors.white),
            )
                : Text(confirmLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// STAT CHIP (header KPI)
// =====================================================================
class _StatChip extends StatelessWidget {
  final DashColors c;
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color softColor;

  const _StatChip({
    required this.c,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: softColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// PRODUCT CARD — avec ExpansionTile stylisé
// =====================================================================
class _ProductCard extends StatelessWidget {
  final Product product;
  final DashColors c;
  final String userType;
  final VoidCallback onEdit;
  final VoidCallback onRestock;
  final VoidCallback onDelete;
  final VoidCallback onInfo;

  const _ProductCard({
    required this.product,
    required this.c,
    required this.userType,
    required this.onEdit,
    required this.onRestock,
    required this.onDelete,
    required this.onInfo,
  });

  Color _statusColor(DashColors c, double qty) {
    if (qty <= 5) return c.danger;
    if (qty <= 15) return c.warning;
    return c.success;
  }

  @override
  Widget build(BuildContext context) {
    final stock = product.stock!.baseStock - product.stock!.totalSell;
    final Color statusColor = _statusColor(c, stock);

    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Icon(Icons.shopping_bag_outlined,
                color: statusColor, size: 22),
          ),
          title: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: c.textPrimary,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                "${product.stock!.sellingPrice} F",
                style: TextStyle(
                  color: c.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${stock.toStringAsFixed(2)} en stock",
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.expand_more_rounded,
            color: c.textSecondary,
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: c.border, height: 1),
                  const SizedBox(height: 16),

                  // Stock details
                  Text(
                    "ÉTAT DU STOCK",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: c.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress bar
                  _buildStockBar(c, stock, statusColor),
                  const SizedBox(height: 16),

                  // Detail chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (userType == "employer")
                        _detailChip(c, "Achat",
                            "${product.stock!.buyingPrice} F", c.accent,
                            c.accentSoft),
                      _detailChip(c, "Vente",
                          "${product.stock!.sellingPrice} F", c.primary,
                          c.primarySoft),
                      _detailChip(c, "Stock",
                          stock.toStringAsFixed(2), statusColor,
                          statusColor.withOpacity(0.12)),
                    ],
                  ),

                  // Actions
                  if (userType == "employer") ...[
                    const SizedBox(height: 16),
                    Divider(color: c.border, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      "ACTIONS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: c.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _actionBtn(c, Icons.edit_rounded, "Modifier",
                            c.primary, c.primarySoft, onEdit),
                        const SizedBox(width: 8),
                        _actionBtn(c, Icons.add_box_rounded, "Restocker",
                            c.success, c.successSoft, onRestock),
                        const SizedBox(width: 8),
                        _actionBtn(c, Icons.delete_outline_rounded,
                            "Supprimer", c.danger, c.dangerSoft, onDelete),
                        const SizedBox(width: 8),
                        _actionBtn(c, Icons.info_outline_rounded, "Infos",
                            c.info, c.infoSoft, onInfo),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBar(DashColors c, double stock, Color statusColor) {
    final double maxStock = product.stock!.baseStock;
    final double ratio = maxStock > 0 ? (stock / maxStock).clamp(0, 1) : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${stock.toStringAsFixed(2)} restant",
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              "${(ratio * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: statusColor.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }

  Widget _detailChip(
      DashColors c, String label, String value, Color color, Color softColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _actionBtn(DashColors c, IconData icon, String label, Color color,
      Color softColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}