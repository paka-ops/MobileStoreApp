import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// CHAT FAB — bouton d'action flottant circulaire du design system.
///
///   • Cercle à dégradé teal, icône blanche
///   • Position en bas à droite, effet flottant (ombre prononcée)
///
///   ChatFab(
///     onTap: _openAssistant,        // logique inchangée
///     icon: Icons.chat_bubble_outline_rounded,
///     tooltip: "Assistant",
///   )
///
/// Variante `ChatFab.labeled` : pilule dégradée avec icône + texte (CTA
/// principal type « Nouvelle vente »), toujours ancrée en bas à droite.
/// ============================================================================
class ChatFab extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String? tooltip;
  final double size;

  /// Tag héro (transition vers l'écran de conversation).
  final Object? heroTag;

  /// Étiquette optionnelle → transforme le cercle en pilule.
  final String? label;

  /// Icône de gauche de la variante pilule (par défaut [icon]).
  final IconData? leadingIcon;

  /// Affiche une pastille d'alerte.
  final int badgeCount;

  /// Position dans le Stack / le Scaffold parent.
  final Alignment alignment;
  final EdgeInsetsGeometry margin;

  /// Dégradé personnalisé (teal par défaut).
  final Gradient? gradient;

  const ChatFab({
    super.key,
    this.onTap,
    this.icon = Icons.chat_bubble_outline_rounded,
    this.tooltip,
    this.size = 58,
    this.heroTag,
    this.badgeCount = 0,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.fromLTRB(0, 0, 20, 20),
  })  : label = null,
        leadingIcon = null,
        gradient = null;

  /// Variante pilule : icône + libellé (CTA flottant).
  const ChatFab.labeled({
    super.key,
    this.onTap,
    required this.label,
    this.icon = Icons.add_rounded,
    this.leadingIcon,
    this.tooltip,
    this.heroTag,
    this.badgeCount = 0,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.fromLTRB(0, 0, 20, 20),
    this.gradient,
  }) : size = 56;

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    // Pastille encre par défaut (comme les boutons pillules des apps premium).
    final Gradient g = gradient ?? c.inkWash;
    final bool isPill = label != null;

    Widget content;
    if (isPill) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Container(
        height: size,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: g,
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: c.floatingShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(leadingIcon ?? icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontSize: 14.5,
                ),
              ),
            ),
          ],
        ),
      ),
      );
    } else {
      content = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: g,
          shape: BoxShape.circle,
          boxShadow: c.floatingShadow,
        ),
        child: Icon(icon, size: 25, color: Colors.white),
      );
    }

    Widget button = PressableScale(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
                decoration: BoxDecoration(
                  color: c.badgeRed,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: Colors.white, width: 1.6),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount > 99 ? "99+" : "$badgeCount",
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (heroTag != null) {
      button = Hero(tag: heroTag!, child: button);
    }

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return Align(
      alignment: alignment,
      child: Padding(padding: margin, child: button),
    );
  }
}
