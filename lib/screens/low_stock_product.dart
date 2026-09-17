import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
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

  double _getStock(Product p) =>
      (p.stock!.baseStock - p.stock!.totalSell);

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
    return AppScreenHeader(
      title: "Stock critique",
      subtitle: "Produits nécessitant un restockage",
      actions: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _allProducts.isEmpty ? c.successSoft : c.dangerSoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: (_allProducts.isEmpty ? c.success : c.danger)
                  .withValues(alpha: 0.25),
            ),
          ),
          child: Icon(
            _allProducts.isEmpty
                ? Icons.check_circle_outline_rounded
                : Icons.warning_amber_rounded,
            size: 20,
            color: _allProducts.isEmpty ? c.success : c.danger,
          ),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.warning_amber_rounded,
              label: "Total alertes",
              value: "$total",
              color: c.accent,
              softColor: c.accentSoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              icon: Icons.error_outline_rounded,
              label: "Critique",
              value: "$critical",
              color: c.danger,
              softColor: c.dangerSoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
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
      return EmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: "Tout va bien !",
        message: "Aucun produit en stock critique pour le moment.",
        iconColor: c.success,
        iconSoftColor: c.successSoft,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
            onInfo: () => _showInfoDialog(context, _filteredProducts[index]),
          ),
        );
      },
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
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: c.border),
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
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
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
                  InfoCallout(
                    icon: Icons.warning_amber_rounded,
                    text:
                    "Stock actuel : ${_getStock(product).toStringAsFixed(2)} unité(s)",
                    color: c.danger,
                    softColor: c.dangerSoft,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: restockController,
                    label: "Quantité à ajouter",
                    hint: "Ex: 25",
                    icon: Icons.add_circle_outline_rounded,
                    keyboardType: TextInputType.number,
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
            side: BorderSide(color: c.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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

                Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        label: "Fermer",
                        height: 48,
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.primary(
                        label: "Plus d'infos",
                        height: 48,
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
  // Actions de dialog (Annuler / Confirmer)
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
// LOW STOCK PRODUCT CARD — carte extensible
// =====================================================================
class _LowStockProductCard extends StatefulWidget {
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

  @override
  State<_LowStockProductCard> createState() => _LowStockProductCardState();
}

class _LowStockProductCardState extends State<_LowStockProductCard> {
  bool _expanded = false;

  double _getStock() =>
      (widget.product.stock!.baseStock - widget.product.stock!.totalSell)
          .toDouble();

  Color _stockColor(DashColors c) {
    final stock = _getStock();
    if (stock <= 5) return c.danger;
    if (stock <= 15) return c.warning;
    return c.success;
  }

  Color _stockSoftColor(DashColors c) {
    final stock = _getStock();
    if (stock <= 5) return c.dangerSoft;
    if (stock <= 15) return c.warningSoft;
    return c.successSoft;
  }

  String _stockLabel() {
    final stock = _getStock();
    if (stock <= 5) return "Critique";
    if (stock <= 15) return "Bas";
    return "Normal";
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final stock = _getStock();
    final statusColor = _stockColor(c);
    final statusSoft = _stockSoftColor(c);
    final double maxStock = widget.product.stock!.baseStock.toDouble();
    final double progress =
    maxStock > 0 ? (stock / maxStock).clamp(0, 1) : 0;

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
                          widget.product.name,
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
                            Flexible(
                              child: Text(
                                "${widget.product.stock!.sellingPrice} F",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
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
                                "${stock.toStringAsFixed(2)} — ${_stockLabel()}",
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
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "${stock.toStringAsFixed(2)} restant sur ${maxStock.toStringAsFixed(0)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
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
                      value: progress,
                      minHeight: 8,
                      backgroundColor:
                      statusColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          statusColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SoftChip(
                        icon: Icons.sell_outlined,
                        label:
                        "Vente: ${widget.product.stock!.sellingPrice} F",
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
                      SoftChip(
                        icon: Icons.flag_rounded,
                        label: _stockLabel(),
                        color: statusColor,
                        softColor: statusSoft,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.soft(
                          label: "Restocker",
                          icon: Icons.add_box_rounded,
                          color: c.success,
                          softColor: c.successSoft,
                          height: 44,
                          expand: false,
                          onPressed: widget.onRestock,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppButton.soft(
                          label: "Infos",
                          icon: Icons.info_outline_rounded,
                          color: c.info,
                          softColor: c.infoSoft,
                          height: 44,
                          expand: false,
                          onPressed: widget.onInfo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
