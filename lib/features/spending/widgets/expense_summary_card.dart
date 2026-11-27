import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';

/// ============================================================================
/// EXPENSE SUMMARY CARD — résumé de la période.
///
///   • `AppCard` padding 18
///   • pastille rose (`AppColors.accentPink` à 10 %) + icône portefeuille 20
///   • deux boîtes : « TOTAL » (rouge fixe) et « NOMBRE » (violet du thème)
///
/// Le rose et le rouge sont les teintes **fixes** de la palette, comme dans
/// l'écran d'origine (indépendantes du thème clair / sombre).
/// ============================================================================
class ExpenseSummaryCard extends StatelessWidget {
  final double totalAmount;
  final int expenseCount;

  const ExpenseSummaryCard({
    super.key,
    required this.totalAmount,
    required this.expenseCount,
  });

  static const Color _accent = AppColors.accentPink;
  static const Color _danger = AppColors.badgeRed;

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: _accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Résumé des dépenses",
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ExpenseStatBox(
                  label: "TOTAL",
                  value: "${totalAmount.toStringAsFixed(0)} F",
                  valueColor: _danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExpenseStatBox(
                  label: "NOMBRE",
                  value: "$expenseCount",
                  valueColor: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Boîte de statistique du résumé (libellé 10.5 espacé + valeur 17).
class _ExpenseStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _ExpenseStatBox({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
