import 'package:flutter/material.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors, PremiumRadii;
import 'package:mobile_store_app/widgets/premium_kit.dart';

//
// Ligne d'info abonnement — carte feutrée du thème courant.
// Mêmes paramètres d'entrée, présentation premium.
//
class BuildInfoTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  BuildInfoTitle(
      {required this.icon,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          PremiumIconTile(
            icon: icon,
            color: color,
            softColor: color.withOpacity(0.12),
            size: 46,
            iconSize: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
