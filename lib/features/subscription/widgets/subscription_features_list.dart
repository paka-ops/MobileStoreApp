import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';

/// Avantage affiché dans la liste des inclusions.
class SubscriptionFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color softColor;

  const SubscriptionFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.softColor,
  });
}

/// ============================================================================
/// SUBSCRIPTION FEATURES LIST — « Inclus dans votre offre ».
///
///   • `SectionHeader` (titre + sous-titre) puis 14 px
///   • quatre cartes surface rayon 16, bordure 1 px, margin basse 10,
///     padding 14 : pastille d'icône 9 px, titre 13.5 / w700,
///     description 11.5, coche 18 teintée
///
/// Les couleurs proviennent des jetons du thème (`primary`, `success`, `info`,
/// `accent` et leurs variantes douces) : identiques à l'original.
/// ============================================================================
class SubscriptionFeaturesList extends StatelessWidget {
  const SubscriptionFeaturesList({super.key});

  List<SubscriptionFeature> _features(DashColors c) => [
        SubscriptionFeature(
          icon: Icons.storefront_rounded,
          title: 'Gestion de boutique',
          description: 'Produits, stocks et employés centralisés',
          color: c.primary,
          softColor: c.primarySoft,
        ),
        SubscriptionFeature(
          icon: Icons.point_of_sale_rounded,
          title: 'Ventes illimitées',
          description: 'Enregistrez toutes vos transactions',
          color: c.success,
          softColor: c.successSoft,
        ),
        SubscriptionFeature(
          icon: Icons.insights_rounded,
          title: 'Rapports & analyses',
          description: 'Suivez vos performances en temps réel',
          color: c.info,
          softColor: c.infoSoft,
        ),
        SubscriptionFeature(
          icon: Icons.support_agent_rounded,
          title: 'Support dédié',
          description: 'Une équipe disponible pour vous aider',
          color: c.accent,
          softColor: c.accentSoft,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Inclus dans votre offre",
          subtitle: "Tout ce dont votre boutique a besoin",
        ),
        const SizedBox(height: 14),
        ..._features(c).map(
          (feature) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: feature.softColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    feature.icon,
                    color: feature.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature.description,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle_rounded,
                  color: feature.color,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
