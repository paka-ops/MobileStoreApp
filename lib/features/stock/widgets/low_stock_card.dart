import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/features/stock/controllers/stock_level.dart';
import 'package:mobile_store_app/models/product.dart';

/// ============================================================================
/// LOW STOCK CARD — carte dépliable d'un produit en stock critique.
///
///   • `AnimatedContainer` 220 ms : bordure à 1.3 px teintée par l'état quand
///     la carte est ouverte
///   • en-tête : pastille d'icône teintée et bordée, nom (cardTitle / w700),
///     prix 13 / w700 et badge « quantité — état » 10.5 / w700
///   • `AnimatedCrossFade` 220 ms : filet, ratio « restant sur base » + %,
///     jauge 8 px, trois `SoftChip` (vente, stock, état), puis boutons
///     « Restocker » (soft succès) et « Infos » (soft info), hauteur 44
///
/// Toutes les constantes sont celles de l'original ; seuls le dépliage local
/// et les dérivations de [StockLevel] subsistent.
/// ============================================================================
class LowStockCard extends StatefulWidget {
  final Product product;
  final VoidCallback onRestock;
  final VoidCallback onInfo;

  const LowStockCard({
    super.key,
    required this.product,
    required this.onRestock,
    required this.onInfo,
  });

  @override
  State<LowStockCard> createState() => _LowStockCardState();
}

class _LowStockCardState extends State<LowStockCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    final StockLevel level = StockLevel.of(widget.product);
    final double stock = level.quantity;
    final Color statusColor = level.color(c);
    final Color statusSoft = level.softColor(c);
    final double maxStock = widget.product.stock!.baseStock.toDouble();
    final double progress = maxStock > 0 ? (stock / maxStock).clamp(0, 1) : 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _expanded ? statusColor.withValues(alpha: 0.35) : c.border,
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
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: statusColor,
                      size: 22,
                    ),
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
                          style: AppTextStyles.cardTitle.copyWith(
                            fontWeight: FontWeight.w700,
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
                                style: AppTextStyles.bodySecondary.copyWith(
                                  color: c.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${stock.toStringAsFixed(2)} — ${level.label}",
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "${stock.toStringAsFixed(2)} restant sur ${maxStock.toStringAsFixed(0)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
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
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
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
                        label: "Stock: ${stock.toStringAsFixed(2)}",
                        color: statusColor,
                        softColor: statusSoft,
                      ),
                      SoftChip(
                        icon: Icons.flag_rounded,
                        label: level.label,
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
