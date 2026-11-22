import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';

/// ============================================================================
/// CATEGORY ANALYSIS CARD — carte d'analyse d'une catégorie.
///
///   • carte surface rayon 20, bordure 1 px, ombre douce, marge basse 16
///   • bandeau d'en-tête teinté à 6 % (rayon supérieur 19 = 20 − 1)
///   • pastille d'icône teintée à 12 %, nom 15.5 / w800
///   • deux statistiques « VENTES (CA) » / « BÉNÉFICE NET » (employeur),
///     séparées par un filet vertical de 40 px
///   • barre de rentabilité 6 px (bénéfice / ventes borné à [0,1]) affichée
///     seulement si `sales > 0` **et** employeur
///
/// Toutes les constantes sont celles de l'écran d'origine.
/// ============================================================================
class CategoryAnalysisCard extends StatelessWidget {
  final String name;
  final num sales;
  final num revenue;
  final Color color;
  final String userType;

  const CategoryAnalysisCard({
    super.key,
    required this.name,
    required this.sales,
    required this.revenue,
    required this.color,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          // En-tête de la carte
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl - 1),
                topRight: Radius.circular(AppRadius.xl - 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.category_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                      letterSpacing: -0.2,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Statistiques ventes / bénéfice
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _CategoryStatItem(
                  label: "VENTES (CA)",
                  value: sales,
                  color: colors.primary,
                ),
                if (userType == "employer") ...[
                  Container(width: 1, height: 40, color: colors.border),
                  _CategoryStatItem(
                    label: "BÉNÉFICE NET",
                    value: revenue,
                    color: colors.success,
                  ),
                ],
              ],
            ),
          ),

          // Barre visuelle de rentabilité (bénéfice / vente)
          if (sales > 0 && userType == "employer")
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (revenue / sales).clamp(0, 1).toDouble(),
                  backgroundColor: colors.fill,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Statistique de la carte (libellé 10 / w700 espacé + valeur 16 / w800).
class _CategoryStatItem extends StatelessWidget {
  final String label;
  final num value;
  final Color color;

  const _CategoryStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${value.toStringAsFixed(0)} F",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
