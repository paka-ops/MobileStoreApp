import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/models/spending.dart';

/// ============================================================================
/// EXPENSE CARD — carte d'une dépense.
///
///   • pastille rose 11 px + icône billet barré 22
///   • description (cardTitle / w700 / 14.5, 3 lignes maximum) ou
///     « Sans description », date `dd MMM yyyy • HH:mm` en heure locale
///   • montant « − X F » sur rouge fixe à 10 %
///   • filet `hairline`, puis « Modifier » (soft warning) et « Supprimer »
///     (danger), hauteur 44, texte 13
///
/// Le formatage de date et le montant sont calculés ici même, comme avant.
/// ============================================================================
class ExpenseCard extends StatelessWidget {
  final Spending spending;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseCard({
    super.key,
    required this.spending,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _accent = AppColors.accentPink;
  static const Color _danger = AppColors.badgeRed;

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    final double amount = spending.price ?? 0;
    final String dateText = spending.createdAt != null
        ? DateFormat('dd MMM yyyy • HH:mm')
            .format(spending.createdAt!.toLocal())
        : "Date inconnue";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.money_off_rounded,
                  color: _accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spending.description?.trim().isNotEmpty == true
                          ? spending.description!
                          : "Sans description",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dateText,
                      style: AppTextStyles.label.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: _danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  "- ${amount.toStringAsFixed(0)} F",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _danger,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: colors.hairline),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton.soft(
                  label: "Modifier",
                  icon: Icons.edit_rounded,
                  color: colors.warning,
                  softColor: colors.warningSoft,
                  height: 44,
                  fontSize: 13,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.danger(
                  label: "Supprimer",
                  icon: Icons.delete_outline_rounded,
                  height: 44,
                  fontSize: 13,
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
