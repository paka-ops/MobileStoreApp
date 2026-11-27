import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';

/// ============================================================================
/// REPORT KPI CARD — tuile d'indicateur d'un rapport.
///
///   • carte surface, rayon 20, bordure 1 px, ombre douce, padding 16
///   • pastille d'icône 9 px teintée à 10 %
///   • valeur 17 / w700 sur une ligne (ellipsis), libellé 13.5 / w600
///
/// Constantes identiques à l'écran d'origine (padding, gaps 14 et 4).
/// ============================================================================
class ReportKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ReportKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading.copyWith(
              fontSize: 17,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
