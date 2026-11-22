/// ============================================================================
/// ORDER CARD — carte de commande dépliable de l'historique.
///
/// Reprise à l'identique de la classe privée `_OrderCard` de l'écran
/// d'origine : mêmes champs, mêmes animations, mêmes actions.
/// ============================================================================
import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/enums.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/service/user_service.dart';

// =====================================================================
// ORDER CARD — carte extensible
// =====================================================================
class OrderCard extends StatefulWidget {
  final Order order;
  final DashColors c;
  final String userType;
  final VoidCallback onDelete;
  final double Function(Order) calculateTotal;
  final String Function(OrderStatus) getStatusLabel;
  final Color Function(OrderStatus) statusColor;
  final Color Function(OrderStatus) statusSoftColor;

  const OrderCard({
    super.key,
    required this.order,
    required this.c,
    required this.userType,
    required this.onDelete,
    required this.calculateTotal,
    required this.getStatusLabel,
    required this.statusColor,
    required this.statusSoftColor,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final order = widget.order;
    final Color sColor = widget.statusColor(order.status);
    final Color sSoft = widget.statusSoftColor(order.status);
    final double totalAmount = widget.calculateTotal(order);
    final String? username = UserService.username;
    final bool canAct = username == order.maker['username'] ||
        (widget.userType == 'employer' &&
            order.status == OrderStatus.DELETION_PENDING);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _expanded
              ? sColor.withValues(alpha: 0.35)
              : c.border,
          width: _expanded ? 1.3 : 1,
        ),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        children: [
          // --- Header ---
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
                      color: sSoft,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                          color: sColor.withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.receipt_rounded,
                        color: sColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "N°${order.orderId.substring(0, 8)}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                  letterSpacing: -0.1,
                                  color: c.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: sSoft,
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.getStatusLabel(order.status),
                                style: TextStyle(
                                  color: sColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 12, color: c.textSecondary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                DateFormat('dd MMM yyyy • HH:mm')
                                    .format(order.createdAt),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${totalAmount.toStringAsFixed(2)} F",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: c.primary,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration:
                        const Duration(milliseconds: 220),
                        child: Icon(Icons.expand_more_rounded,
                            size: 18, color: c.textSecondary),
                      ),
                    ],
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

                  OverlineLabel(text: "Détails produits"),
                  const SizedBox(height: 12),

                  if (order.products.isNotEmpty)
                    ...order.products.entries.map((entry) {
                      final product = entry.key;
                      final quantity = entry.value;
                      final double lineTotal =
                          (quantity ?? 0) *
                              (product.stock?.sellingPrice ?? 0);

                      return Padding(
                        padding:
                        const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: c.cardElevated,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border:
                            Border.all(color: c.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: c.primarySoft,
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Icon(
                                    Icons
                                        .shopping_bag_outlined,
                                    color: c.primary,
                                    size: 14),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "${product.name} × ${quantity}",
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                "${lineTotal.toStringAsFixed(2)} F",
                                style: TextStyle(
                                  color: c.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 12),
                  Container(height: 1, color: c.border),
                  const SizedBox(height: 12),

                  // Vendeur
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: c.infoSoft,
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.person_rounded,
                            size: 14, color: c.info),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Vendeur : ",
                        style: AppTextStyles.bodySecondary.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      Flexible(
                        child: Text(
                          order.maker?['username'] ?? 'N/A',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary.copyWith(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: c.primarySoft,
                      borderRadius:
                      BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                          color:
                          c.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total commande",
                          style: TextStyle(
                            color: c.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          "${totalAmount.toStringAsFixed(2)} F",
                          style: TextStyle(
                            color: c.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  if (canAct) ...[
                    const SizedBox(height: 12),
                    Container(height: 1, color: c.border),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton.soft(
                            label: "Modifier",
                            icon: Icons.edit_rounded,
                            color: c.warning,
                            softColor: c.warningSoft,
                            height: 44,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton.danger(
                            label: widget.userType == 'employee'
                                ? "Annuler"
                                : "Supprimer",
                            icon:
                            Icons.delete_outline_rounded,
                            height: 44,
                            onPressed: widget.onDelete,
                          ),
                        ),
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
}

