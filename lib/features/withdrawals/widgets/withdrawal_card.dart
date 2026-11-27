import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/shared/models/withdrawal.dart';

/// ============================================================================
/// WITHDRAWAL CARD — carte d'un retrait.
///
///   • pastille 11 px `primarySoft` + icône épargne 22
///   • motif (3 lignes maximum) ou « Sans motif », date `dd MMM yyyy • HH:mm`
///   • montant « − X F » sur `dangerSoft` / `danger` du thème
///   • filet `hairline`
///   • trois actions (hauteur 44, texte 13) : « Modifier » (soft warning),
///     « Modifier » (danger, action historique de mise à jour), « Supprimer »
///
/// Les trois boutons — y compris le doublon « Modifier » — sont conservés tels
/// quels : c'est le rendu et le comportement de l'application d'origine.
/// ============================================================================
class WithdrawalCard extends StatelessWidget {
  final Withdrawal withdrawal;
  final VoidCallback onEdit;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const WithdrawalCard({
    super.key,
    required this.withdrawal,
    required this.onEdit,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);
    final String dateText =
        DateFormat('dd MMM yyyy • HH:mm').format(withdrawal.date!);

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
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  Icons.savings_outlined,
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      withdrawal.message.trim().isNotEmpty
                          ? withdrawal.message
                          : "Sans motif",
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
                  color: colors.dangerSoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  "- ${withdrawal.amount.toStringAsFixed(0)} F",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.danger,
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
                  label: "Modifier",
                  icon: Icons.update,
                  height: 44,
                  fontSize: 13,
                  onPressed: onUpdate,
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
