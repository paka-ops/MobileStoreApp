import 'package:flutter/material.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors, PremiumRadii;
import 'package:mobile_store_app/widgets/premium_kit.dart';

/**
 * Élément de menu latéral — carte feutrée 56 px, pastille douce.
 * Mêmes paramètres d'entrée (icon, color, title, onTap).
 */
class DrawerItem extends StatelessWidget {
  final IconData icon;

  final String title;

  final Color color;

  final VoidCallback onTap;

  DrawerItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(PremiumRadii.sm),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(PremiumRadii.sm),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Row(
              children: [
                PremiumIconTile(
                  icon: icon,
                  color: color,
                  softColor: color.withOpacity(0.12),
                  size: 40,
                  iconSize: 19,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textSecondary,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
