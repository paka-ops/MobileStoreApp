import 'package:flutter/material.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show PremiumRadii;

/**
 * Pastille d'icône — voile coloré doux, coins 12.
 * Mêmes paramètres d'entrée (icon, color).
 */
class IconBox extends StatelessWidget {
  final IconData icon;

  final Color color;

  IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(PremiumRadii.sm),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
