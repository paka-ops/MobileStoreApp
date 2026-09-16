import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/constants/app_radius.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors;

class SubscriptionFeaturesList extends StatelessWidget {
  const SubscriptionFeaturesList({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.storefront_rounded,
        'title': 'Gestion de boutique',
        'desc': 'Produits, stocks et employés centralisés',
        'color': c.primary,
        'soft': c.primarySoft,
      },
      {
        'icon': Icons.point_of_sale_rounded,
        'title': 'Ventes illimitées',
        'desc': 'Enregistrez toutes vos transactions',
        'color': c.success,
        'soft': c.successSoft,
      },
      {
        'icon': Icons.insights_rounded,
        'title': 'Rapports & analyses',
        'desc': 'Suivez vos performances en temps réel',
        'color': c.info,
        'soft': c.infoSoft,
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': 'Support dédié',
        'desc': 'Une équipe disponible pour vous aider',
        'color': c.accent,
        'soft': c.accentSoft,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Inclus dans votre offre",
          subtitle: "Tout ce dont votre boutique a besoin",
        ),
        const SizedBox(height: 14),
        ...features.map((f) => Container(
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
                      color: f['soft'],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(f['icon'],
                        color: f['color'], size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['title'],
                          style: TextStyle(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          f['desc'],
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle_rounded,
                      color: f['color'], size: 18),
                ],
              ),
            )),
      ],
    );
  }
}
