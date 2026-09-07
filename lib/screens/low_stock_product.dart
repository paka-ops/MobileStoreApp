import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/screens/product_details_page.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart';
import 'package:mobile_store_app/utils/message.dart';

class LowStockProductDetailsScreen extends StatefulWidget {
  final List<Product> products;
  final String userType;

  const LowStockProductDetailsScreen({
    super.key,
    required this.products,
    required this.userType,
  });

  @override
  State createState() => _LowStockProductDetailsScreenState();
}

class _LowStockProductDetailsScreenState
    extends State<LowStockProductDetailsScreen> {
  late List<Product> _allProducts;
  late List<Product> _filteredProducts;
  bool isRestocking = false;

  @override
  void initState() {
    super.initState();
    _allProducts = List<Product>.from(widget.products);
    _filteredProducts = List<Product>.from(_allProducts);
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List<Product>.from(_allProducts);
      } else {
        _filteredProducts = _allProducts
            .where(
                (p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
    if (qty <= 5) return "Critique";
    if (qty <= 15) return "Bas";
    return "Normal";
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stock critique",
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
                  "Produits nécessitant un restockage",
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Alert icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.dangerSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.danger.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: c.danger,
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
              child: Icon(Icons.search_rounded,
                  color: c.textSecondary, size: 20),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 12),
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // STATS ROW
  // =====================================================================
  Widget _buildStatsRow(DashColors c) {
    final int total = _allProducts.length;
    final int critical =
        _allProducts.where((p) => _getStock(p) <= 5).length;
    final int low = _allProducts
        .where((p) => _getStock(p) > 5 && _getStock(p) <= 10)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              c: c,
              icon: Icons.warning_amber_rounded,
              label: "Total alertes",
              value: "$total",
              color: c.accent,
              softColor: c.accentSoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              c: c,
              icon: Icons.error_outline_rounded,
              label: "Critique",
              value: "$critical",
              color: c.danger,
              softColor: c.dangerSoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              c: c,
              icon: Icons.trending_down_rounded,
              label: "Bas",
              value: "$low",
              color: c.warning,
              softColor: c.warningSoft,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // BODY
  // =====================================================================
  Widget _buildBody(DashColors c) {
    if (_filteredProducts.isEmpty) {
      return _buildEmptyState(c);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LowStockProductCard(
            product: _filteredProducts[index],
            c: c,
            userType: widget.userType,
            onRestock: () =>
                _showRestockDialog(context, _filteredProducts[index]),
            onInfo: () =>
                _showInfoDialog(context, _filteredProducts[index]),
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
                color: c.successSoft,
                shape: BoxShape.circle,
                border: Border.all(color: c.border),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 50,
                color: c.success,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "Tout va bien !",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Aucun produit en stock critique pour le moment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // DIALOG — Restocker
  // =====================================================================
  void _showRestockDialog(BuildContext context, Product product) async {
    final c = DashColors(context);
    final restockController = TextEditingController();
    final restockingKey = GlobalKey<FormState>();

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
                  child: Icon(Icons.add_box_rounded,
                      color: c.success, size: 22),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stock actuel info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.dangerSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: c.danger.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: c.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Stock actuel : ${_getStock(product).toStringAsFixed(2)} unité(s)",
                            style: TextStyle(
                              color: c.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        final index = _allProducts.indexWhere(
                                (prod) => prod.id == product.id);
                        if (index != -1) {
                          _allProducts[index] = p;
                          // Remove if stock is now healthy
                          if (_getStock(p) > 10) {
                            _allProducts.removeAt(index);
                          }
                        }
                        _filterProducts("");
                      });

                      Navigator.pop(dialogContext);
                      showSuccessMessage(
                        "${add.toStringAsFixed(2)} unités ajoutées à ${p.name}",
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
  // DIALOG — Info produit
  // =====================================================================
  void _showInfoDialog(BuildContext context, Product p) {
    final c = DashColors(context);
    final stock = _getStock(p);
    final isLow = stock <= 5;

    showDialog(
      context: context,
      builder: (dialogContext) {
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
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLow ? c.dangerSoft : c.warningSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: isLow ? c.danger : c.warning,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),

                // Name
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
                _infoRow(c, "Prix de vente",
                    "${p.stock!.sellingPrice} F"),
                _infoRow(c, "Stock restant",
                    "${stock.toStringAsFixed(2)} unités"),
                _infoRow(
                  c,
                  "État",
                  isLow ? "Critique" : "Bas",
                  valueColor: isLow ? c.danger : c.warning,
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          foregroundColor: c.textPrimary,
                          side: BorderSide(
                              color: c.border, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pop(dialogContext),
                        child: const Text("Fermer",
                            style: TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          backgroundColor: c.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductStatsScreen(product: p),
                            ),
                          );
                        },
                        child: const Text("Plus d'infos",
                            style: TextStyle(
                                fontWeight: FontWeight.w600)),
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
          Text(
            label,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
              (valueColor ?? c.textPrimary).withOpacity(0.1),
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
    return TextFormField(
      controller: controller,
      keyboardType:
      isNumber ? TextInputType.number : TextInputType.text,
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
          fontSize: 13.5,
        ),
        hintStyle:
        TextStyle(color: c.textSecondary, fontSize: 13.5),
        filled: true,
        fillColor: c.background,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: c.primary, size: 20),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 12),
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
              (v) =>
          (v == null || v.isEmpty) ? "Champ obligatoire" : null,
    );
  }

  // =====================================================================
  // SHARED — Dialog actions
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
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
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

  // =====================================================================
  // HELPER
  // =====================================================================
  double _getStock(Product p) {
    return (p.stock!.baseStock - p.stock!.totalSell)
        .clamp(0, double.infinity);
  }
}

// =====================================================================
// STAT CHIP
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
// LOW STOCK PRODUCT CARD
// =====================================================================
class _LowStockProductCard extends StatelessWidget {
  final Product product;
  final DashColors c;
  final String userType;
  final VoidCallback onRestock;
  final VoidCallback onInfo;

  const _LowStockProductCard({
    required this.product,
    required this.c,
    required this.userType,
    required this.onRestock,
    required this.onInfo,
  });

  double _getStock() {
    return (product.stock!.baseStock - product.stock!.totalSell)
        .clamp(0, double.infinity);
  }

  Color _stockColor(DashColors c) {
    final qty = _getStock();
    if (qty <= 5) return c.danger;
    if (qty <= 15) return c.warning;
    return c.success;
  }

  Color _stockSoftColor(DashColors c) {
    final qty = _getStock();
    if (qty <= 5) return c.dangerSoft;
    if (qty <= 15) return c.warningSoft;
    return c.successSoft;
  }

  String _stockLabel() {
    final qty = _getStock();
    if (qty <= 5) return "Critique";
    if (qty <= 15) return "Bas";
    return "Normal";
  }

  @override
  Widget build(BuildContext context) {
    final stock = _getStock();
    final statusColor = _stockColor(c);
    final statusSoft = _stockSoftColor(c);
    final double maxStock = product.stock!.baseStock.toDouble();
    final double ratio =
    maxStock > 0 ? (stock / maxStock).clamp(0, 1) : 0;

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
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusSoft,
              borderRadius: BorderRadius.circular(12),
              border:
              Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Icon(Icons.warning_amber_rounded,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 11,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${stock.toStringAsFixed(2)} — ${_stockLabel()}",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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

                  // Stock bar
                  Text(
                    "NIVEAU DE STOCK",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: c.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${stock.toStringAsFixed(2)} restant sur ${maxStock.toStringAsFixed(0)}",
                        style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "${(ratio * 100).toStringAsFixed(2)}%",
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
                      backgroundColor:
                      statusColor.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          statusColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Detail chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _detailChip(
                        "Vente",
                        "${product.stock!.sellingPrice} F",
                        c.primary,
                        c.primarySoft,
                      ),
                      _detailChip(
                        "Stock",
                        stock.toStringAsFixed(2),
                        statusColor,
                        statusSoft,
                      ),
                      _detailChip(
                        "État",
                        _stockLabel(),
                        statusColor,
                        statusSoft,
                      ),
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
                        _actionBtn(
                          Icons.add_box_rounded,
                          "Restocker",
                          c.success,
                          c.successSoft,
                          onRestock,
                        ),
                        const SizedBox(width: 10),
                        _actionBtn(
                          Icons.info_outline_rounded,
                          "Détails",
                          c.info,
                          c.infoSoft,
                          onInfo,
                        ),
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

  Widget _detailChip(
      String label, String value, Color color, Color softColor) {
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

  Widget _actionBtn(IconData icon, String label, Color color,
      Color softColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
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