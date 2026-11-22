import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';

/// ============================================================================
/// ROUND ACTION BUTTON — action secondaire circulaire du design system
/// (favori, partage, dépense, retrait…).
///
///   • Cercle de [size] px (52 par défaut)
///   • Surface carte + ombre douce
///   • Icône 21 px, couleur encre par défaut
///   • `PressableScale` (même retour tactile que le reste du kit)
///
/// Le rendu est strictement celui de l'implémentation d'origine.
/// ============================================================================
class RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? background;
  final Color? iconColor;
  final double size;

  const RoundActionButton({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.background,
    this.iconColor,
    this.size = AppSizes.primaryButtonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    Widget button = PressableScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background ?? c.card,
          shape: BoxShape.circle,
          boxShadow: c.cardShadow,
        ),
        child: Icon(icon, size: 21, color: iconColor ?? c.textPrimary),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
