import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store_app/core/constants/app_radius.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/screens/low_stock_product.dart';
import 'package:mobile_store_app/screens/product_details_page.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/widgets/boutika_loader.dart';

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
    return AppScreenHeader(
      title: widget.category.name,
      subtitle: "Gestion des produits",
      actions: [
        AppIconButton(
          icon: Icons.warning_amber_rounded,
          badge: lowStockProducts.length,
          badgeColor: c.danger,
          iconColor: lowStockProducts.isEmpty ? c.textSecondary : c.danger,
          tooltip: "Stock critique",
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
        AppIconButton(
          icon: Icons.refresh_rounded,
          tooltip: "Actualiser",
          onTap: _fetchProducts,
        ),
      ],
    );
  }

  // =====================================================================
  // SEARCH BAR
  // =====================================================================
  Widget _buildSearchBar(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: AppSearchField(
        hint: "Rechercher un produit…",
        onChanged: _filterProducts,
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.inventory_2_rounded,
              label: "Total",
              value: "$total",
              color: c.primary,
              softColor: c.primarySoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              icon: Icons.check_circle_outline_rounded,
              label: "Normal",
              value: "$healthy",
              color: c.success,
              softColor: c.successSoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
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
            const BouTikaLoader(),
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
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: "Aucun produit trouvé",
        message: widget.userType == "employer"
            ? "Ajoutez votre premier produit dans cette catégorie."
            : "Cette catégorie ne contient aucun produit.",
        actionLabel: widget.userType == "employer"
            ? "Ajouter un produit"
            : null,
        onAction: widget.userType == "employer"
            ? () => _showAddProductDialog(context)
            : null,
      );
    }

    return RefreshIndicator(
      color: c.primary,
      backgroundColor: c.card,
      onRefresh: () async => _fetchProducts(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
      ),
    );
  }

  // =====================================================================
  // FAB
  // =====================================================================
  Widget _buildFab(DashColors c) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddProductDialog(context),
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Icon(Icons.add_rounded, size: 20, color: c.onPrimary),
      label: Text(
        "Nouveau produit",
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: c.onPrimary),
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
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: c.border),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            title: _dialogTitle(c, Icons.add_box_rounded, "Nouveau Produit"),
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
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: c.border),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            title: _dialogTitle(
                c, Icons.edit_rounded, "Modifier ${product.name}"),
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
          final stock = product.stock!.baseStock - product.stock!.totalSell;
          return AlertDialog(
            backgroundColor: c.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: c.border),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            title: _dialogTitle(
                c, Icons.add_box_rounded, "Restocker ${product.name}",
                iconColor: c.success, iconSoftColor: c.successSoft),
            content: Form(
              key: restockingKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InfoCallout(
                    icon: Icons.warning_amber_rounded,
                    text:
                    "Stock actuel : ${stock.toStringAsFixed(2)} unité(s)",
                    color: c.danger,
                    softColor: c.dangerSoft,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    c,
                    restockController,
                    "Quantité à ajouter",
                    Icons.add_circle_outline_rounded,
                    "Ex: 25",
                    isNumber: true,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Entrez une valeur";
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed <= 0) {
                        return "Valeur invalide";
                      }
                      return null;
                    },
                  ),
                ],
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

    restockController.dispose();
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
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: c.border),
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
                      color: c.danger, size: 30),
                ),
                const SizedBox(height: 18),
                Text(
                  "Supprimer le produit",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
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
                    height: 1.5,
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
            side: BorderSide(color: c.border),
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
                    letterSpacing: -0.2,
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
                      child: AppButton.secondary(
                        label: "Fermer",
                        height: 48,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.primary(
                        label: "Plus d'infos",
                        height: 48,
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
              color: (valueColor ?? c.textPrimary).withValues(alpha: 0.1),
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
  // SHARED — Titre de dialog
  // =====================================================================
  Widget _dialogTitle(DashColors c, IconData icon, String title,
      {Color? iconColor, Color? iconSoftColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconSoftColor ?? c.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              color: iconColor ?? c.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // SHARED — Champ de texte
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
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint.isEmpty ? null : hint,
      icon: icon,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
          child: AppButton.secondary(
            label: "Annuler",
            height: 48,
            onPressed: isLoading ? null : onCancel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: AppButton.primary(
            label: confirmLabel,
            height: 48,
            background: btnColor,
            foreground: Colors.white,
            isLoading: isLoading,
            onPressed: isLoading ? null : onConfirm,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// PRODUCT CARD — carte produit extensible
// =====================================================================
class _ProductCard extends StatefulWidget {
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

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _expanded = false;

  Color _statusColor(DashColors c, double qty) {
    if (qty <= 5) return c.danger;
    if (qty <= 15) return c.warning;
    return c.success;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final product = widget.product;
    final stock = product.stock!.baseStock - product.stock!.totalSell;
    final Color statusColor = _statusColor(c, stock);
    final Color statusSoft = statusColor.withValues(alpha: 0.12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _expanded
              ? statusColor.withValues(alpha: 0.35)
              : c.border,
          width: _expanded ? 1.3 : 1,
        ),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        children: [
          // --- Header toujours visible ---
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
                      color: statusSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.shopping_bag_outlined,
                        color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.1,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              "${product.stock!.sellingPrice} F",
                              style: TextStyle(
                                color: c.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusSoft,
                                borderRadius:
                                BorderRadius.circular(8),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Contenu extensible ---
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: c.border),
                  const SizedBox(height: 16),

                  OverlineLabel(text: "État du stock"),
                  const SizedBox(height: 12),

                  _buildStockBar(c, stock, statusColor),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.userType == "employer")
                        SoftChip(
                          icon: Icons.shopping_cart_outlined,
                          label:
                          "Achat: ${product.stock!.buyingPrice} F",
                          color: c.accent,
                          softColor: c.accentSoft,
                        ),
                      SoftChip(
                        icon: Icons.sell_outlined,
                        label:
                        "Vente: ${product.stock!.sellingPrice} F",
                        color: c.primary,
                        softColor: c.primarySoft,
                      ),
                      SoftChip(
                        icon: Icons.inventory_rounded,
                        label:
                        "Stock: ${stock.toStringAsFixed(2)}",
                        color: statusColor,
                        softColor: statusSoft,
                      ),
                    ],
                  ),

                  if (widget.userType == "employer") ...[
                    const SizedBox(height: 16),
                    Container(height: 1, color: c.border),
                    const SizedBox(height: 16),
                    OverlineLabel(text: "Actions"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _actionBtn(c, Icons.edit_rounded, "Modifier",
                            c.primary, c.primarySoft, widget.onEdit),
                        const SizedBox(width: 8),
                        _actionBtn(c, Icons.add_box_rounded, "Restocker",
                            c.success, c.successSoft, widget.onRestock),
                        const SizedBox(width: 8),
                        _actionBtn(c, Icons.delete_outline_rounded,
                            "Supprimer", c.danger, c.dangerSoft,
                            widget.onDelete),
                        const SizedBox(width: 8),
                        _actionBtn(c, Icons.info_outline_rounded, "Infos",
                            c.info, c.infoSoft, widget.onInfo),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBar(DashColors c, double stock, Color statusColor) {
    final double maxStock = widget.product.stock!.baseStock;
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
            backgroundColor: statusColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(DashColors c, IconData icon, String label, Color color,
      Color softColor, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: softColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withValues(alpha: 0.15)),
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
      ),
    );
  }
}
