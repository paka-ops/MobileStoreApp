import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';

/// ============================================================================
/// REPORT CHART PLACEHOLDER — emplacement réservé du graphique de performance.
///
///   • carte 200 px, rayon 20, bordure 1 px
///   • pastille 14 px `primarySoft` + icône bar_chart 30 (opacité 0.7)
///   • « Graphique de performance » + « Bientôt disponible » (11 px, opacité 0.7)
///
/// Ce bloc est le rendu définitif de l'application d'origine (aucune
/// logique) : il est conservé à l'identique.
/// ============================================================================
class ReportChartPlaceholder extends StatelessWidget {
  const ReportChartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 30,
                color: colors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Graphique de performance",
              style: AppTextStyles.label.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Bientôt disponible",
              style: TextStyle(
                color: colors.textSecondary.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
