import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/models/product.dart';

// =====================================================================
// PRODUCT CARD — carte produit extensible
// =====================================================================
/// Carte produit extensible d'une catégorie.
///
/// En-tête toujours visible (nom, prix, stock), contenu dépliable animé
/// (jauge de stock, chips d'informations, actions employeur). La géométrie et
/// les seuils de couleur sont ceux de l'écran d'origine.
class CategoryProductCard extends StatefulWidget {
  final Product product;
  final DashColors c;
  final String userType;
  final VoidCallback onEdit;
  final VoidCallback onRestock;
  final VoidCallback onDelete;
  final VoidCallback onInfo;

  const CategoryProductCard({
    super.key,
    required this.product,
    required this.c,
    required this.userType,
    required this.onEdit,
    required this.onRestock,
    required this.onDelete,
    required this.onInfo,
  });

  @override
  State<CategoryProductCard> createState() => _CategoryProductCardState();
}

class _CategoryProductCardState extends State<CategoryProductCard> {
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
                      borderRadius: BorderRadius.circular(AppRadius.sm),
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
                          style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "${product.stock!.sellingPrice} F",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySecondary.copyWith(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
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
            Flexible(
              child: Text(
                "${stock.toStringAsFixed(2)} restant",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySecondary.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
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
