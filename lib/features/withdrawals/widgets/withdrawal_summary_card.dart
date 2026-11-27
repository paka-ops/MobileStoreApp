import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';

/// Résumé des retraits : « TOTAL RETIRÉ » (danger du thème) et « NOMBRE ».
///
/// Mêmes constantes que l'écran d'origine (AppCard 18, pastille 10, gaps 10/18).
class WithdrawalSummaryCard extends StatelessWidget {
  final double totalAmount;
  final int withdrawalCount;

  const WithdrawalSummaryCard({
    super.key,
    required this.totalAmount,
    required this.withdrawalCount,
  });

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
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.savings_outlined,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Résumé des retraits",
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
                child: _WithdrawalStatBox(
                  label: "TOTAL RETIRÉ",
                  value: "${totalAmount.toStringAsFixed(0)} F",
                  valueColor: colors.danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WithdrawalStatBox(
                  label: "NOMBRE",
                  value: "$withdrawalCount",
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

/// Boîte de statistique du résumé.
class _WithdrawalStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _WithdrawalStatBox({
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
