import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';

/// ============================================================================
/// LOW STOCK STATS ROW — trois compteurs d'alerte.
///
///   « Total alertes » (accent) · « Critique » (danger) · « Bas » (warning)
///
/// Trois `StatCard` de largeur égale, espacées de 10 px, dans une bande
/// 20·8·20·8 : géométrie identique à l'écran d'origine.
/// ============================================================================
class LowStockStatsRow extends StatelessWidget {
  final int total;
  final int critical;
  final int low;

  const LowStockStatsRow({
    super.key,
    required this.total,
    required this.critical,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

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
}
