import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// FLOATING PRICE TAG — étiquette de prix flottante du design system.
///
///   • Card blanche flottante, BorderRadius.circular(16), ombre
///   • Positionnée en absolu/Stack sur le côté de l'écran
///
///   Stack(
///     children: [
///       contenu,
///       FloatingPriceTag(
///         label: "Prix unitaire",
///         value: "1 500 F",
///         alignment: Alignment.centerRight,   // côté de l'écran
///         inset: EdgeInsets.only(right: 12),
///       ),
///     ],
///   )
///
/// Variante pastel (`FloatingPriceTag.accent`) pour un prix mis en avant :
/// fond dégradé teal, texte blanc.
/// ============================================================================
class FloatingPriceTag extends StatelessWidget {
  /// Sur-titre (« Prix unitaire », « Total »).
  final String? label;

  /// Valeur affichée (« 1 500 F »).
  final String value;

  final IconData? icon;
  final VoidCallback? onTap;

  /// Position dans le Stack parent.
  final Alignment alignment;
  final EdgeInsetsGeometry inset;

  /// Fond blanc par défaut ; `accent: true` → surface encre + texte blanc.
  final bool accent;

  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const FloatingPriceTag({
    super.key,
    this.label,
    required this.value,
    this.icon,
    this.onTap,
    this.alignment = Alignment.centerRight,
    this.inset = const EdgeInsets.symmetric(horizontal: 12),
    this.accent = false,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
  });

  /// Variante mise en avant : dégradé teal → émeraude, texte blanc.
  const FloatingPriceTag.accent({
    super.key,
    this.label,
    required this.value,
    this.icon,
    this.onTap,
    this.alignment = Alignment.centerRight,
    this.inset = const EdgeInsets.symmetric(horizontal: 12),
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
  }) : accent = true;

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final Color titleColor = accent ? Colors.white : c.textPrimary;
    final Color labelColor = accent
        ? Colors.white.withValues(alpha: 0.72)
        : c.textSecondary;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: inset,
        child: PressableScale(
          onTap: onTap,
          // Anti-overflow : largeur bornée (usage en Stack / Align).
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 230),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: accent ? null : c.card,
                gradient: accent ? c.inkWash : null,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: c.floatingShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accent
                            ? Colors.white.withValues(alpha: 0.14)
                            : c.fill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 15,
                        color: accent ? Colors.white : c.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (label != null)
                          Text(
                            label!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.label.copyWith(
                              color: labelColor,
                              fontSize: 10.5,
                            ),
                          ),
                        const SizedBox(height: 1),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.amount.copyWith(
                            color: titleColor,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 10),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
