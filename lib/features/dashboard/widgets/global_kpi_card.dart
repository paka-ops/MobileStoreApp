/// ============================================================================
/// GLOBAL KPI CARD — indicateur global du tableau de bord.
///
/// Reprise à l'identique de la classe privée `_GlobalKpiCard` : pastille
/// d'icône, badge de tendance, valeur et libellé.
/// ============================================================================
import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';

class GlobalKpiCard extends StatelessWidget {
  final IconData icon;
  final String label, value, trend;
  final bool trendUp;
  final Color color, softColor;
  final DashColors c;

  const GlobalKpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.color,
    required this.softColor,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: softColor, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: trendUp ? c.successSoft : c.dangerSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                    trendUp
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 12,
                    color: trendUp ? c.success : c.danger),
                const SizedBox(width: 2),
                Text(trend,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: trendUp ? c.success : c.danger)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          Text(value,
              style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: c.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5)),
        ],
      ),
    );
  }
}
