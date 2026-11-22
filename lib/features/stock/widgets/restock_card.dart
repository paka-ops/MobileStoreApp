import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/models/stock.dart';

/// ============================================================================
/// RESTOCK CARD — carte dépliable d'un mouvement de stock.
///
///   • `AnimatedContainer` 220 ms `easeOut` : bordure qui passe à 1.3 px et
///     prend la teinte primaire (35 %) quand la carte est ouverte
///   • en-tête : pastille 10 px, nom 14.5 / w700, date `dd/MM/yyyy`
///   • badge « +quantité » sur `successSoft` (2 décimales), chevron rotatif 0.5
///   • `AnimatedCrossFade` 220 ms `easeOut` : filet + cinq lignes de détail
///     (prix de vente, prix d'achat [masqué pour un employé], total vendu,
///     ancien stock, nouveau stock mis en avant)
///
/// Le seul état local est le dépliage de la carte, comme dans l'original.
/// ============================================================================
class RestockCard extends StatefulWidget {
  final Stock stock;
  final String productName;
  final double addedQty;
  final bool showBuyingPrice;

  const RestockCard({
    super.key,
    required this.stock,
    required this.productName,
    required this.addedQty,
    required this.showBuyingPrice,
  });

  @override
  State<RestockCard> createState() => _RestockCardState();
}

class _RestockCardState extends State<RestockCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final Stock stock = widget.stock;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _expanded ? c.primary.withValues(alpha: 0.35) : c.border,
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
                      color: c.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: c.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            letterSpacing: -0.1,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ajouté le ${DateFormat('dd/MM/yyyy').format(stock.date!)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: c.successSoft,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text(
                      "+${widget.addedQty.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: c.success,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 18,
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
                children: [
                  Container(height: 1, color: c.border),
                  const SizedBox(height: 8),
                  _RestockDetailRow(
                    label: "Prix de vente",
                    value: "${stock.sellingPrice}",
                  ),
                  if (widget.showBuyingPrice)
                    _RestockDetailRow(
                      label: "Prix d'achat",
                      value: "${stock.buyingPrice}",
                    ),
                  _RestockDetailRow(
                    label: "Total vendu",
                    value: stock.totalSell.toStringAsFixed(2),
                  ),
                  _RestockDetailRow(
                    label: "Ancien stock",
                    value: stock.previousStock?.toStringAsFixed(2) ?? "0",
                  ),
                  _RestockDetailRow(
                    label: "Nouveau stock",
                    value: stock.baseStock.toStringAsFixed(2),
                    isHighlight: true,
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

/// Ligne de détail d'un mouvement (libellé 13 / valeur 14 / w700).
class _RestockDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _RestockDetailRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(color: c.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isHighlight ? c.primary : c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
