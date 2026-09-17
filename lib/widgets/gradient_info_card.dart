import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// GRADIENT INFO CARD — carte d'information à dégradé TRÈS pâle (« wash »).
///
/// Recette premium : la couleur n'est qu'une trace. On part d'une teinte
/// pastel (~5 %) et on fond vers le blanc, avec du texte encre — l'inverse
/// d'un aplat saturé avec du texte blanc, qui fatigue l'œil.
///
/// Deux usages :
///
///   1. Chiffre clé (style « Spending » des apps premium) :
///      GradientInfoCard(
///        icon: Icons.inventory_2_outlined,
///        label: "Produits",
///        value: "128",
///        tint: c.accentSoft,          // pastel : peach, blue, mint…
///        showChevron: true,
///      )
///
///   2. Carte forte (rare) : `inkVariant: true` → surface encre, texte blanc,
///      à réserver à un seul élément mis en avant par écran.
///
///   const GradientInfoCard.date(label: "Aujourd'hui", value: "12 Mai")
///
/// Anti-overflow : valeur et libellé sont ellipsés, la carte n'a pas de
/// hauteur fixe et l'icône se réduit si la largeur est faible.
/// ============================================================================
class GradientInfoCard extends StatelessWidget {
  final IconData? icon;
  final String? label; // surtitre (« Recettes du jour »)
  final String? value; // valeur principale (« 42 500 F »)
  final String? caption; // précision sous la valeur
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;
  final Widget? footer;

  /// Teinte du wash (pastel). Ignorée si [inkVariant] est vrai.
  final Color? tint;

  /// Carte encre (surface sombre, texte blanc) — usage rare et volontaire.
  final bool inkVariant;

  /// Affiche un chevron « > » à droite (style carte cliquable).
  final bool showChevron;

  /// Icône affichée dans une pastille blanche (au lieu du bloc 44 px).
  final bool iconInPill;

  final double radius;
  final EdgeInsetsGeometry padding;

  /// Dégradé personnalisé (prioritaire sur [tint]).
  final Gradient? gradient;

  const GradientInfoCard({
    super.key,
    this.icon,
    this.label,
    this.value,
    this.caption,
    this.trailing,
    this.child,
    this.onTap,
    this.footer,
    this.tint,
    this.inkVariant = false,
    this.showChevron = false,
    this.iconInPill = true,
    this.radius = AppRadius.xl,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
  });

  /// Constructeur pratique : carte de date.
  const GradientInfoCard.date({
    super.key,
    required String label,
    required String value,
    this.icon = Icons.calendar_month_outlined,
    this.onTap,
    this.trailing,
    this.radius = AppRadius.xl,
  })  : label = label,
        value = value,
        caption = null,
        child = null,
        footer = null,
        tint = null,
        inkVariant = false,
        showChevron = false,
        iconInPill = true,
        padding = const EdgeInsets.all(16),
        gradient = null;

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    // ------------------------------------------------------------ couleurs
    final Color titleColor =
        inkVariant ? Colors.white : c.textPrimary;
    final Color labelColor = inkVariant
        ? Colors.white.withValues(alpha: 0.72)
        : c.textSecondary;
    final Color iconFg = inkVariant ? Colors.white : c.textPrimary;
    final Color iconBg = inkVariant
        ? Colors.white.withValues(alpha: 0.12)
        : c.card;

    final Gradient g = gradient ??
        (inkVariant ? c.inkWash : c.wash(tint: tint ?? c.pastelAt(0)));

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: g,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: inkVariant ? c.floatingShadow : c.cardShadow,
        ),
        child: child ??
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  LayoutBuilder(
                    builder: (context, box) {
                      // Icône compacte si la carte est étroite (petits écrans).
                      final double s =
                          box.maxWidth.isFinite && box.maxWidth < 60 ? 34 : 40;
                      return Container(
                        width: s,
                        height: s,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(
                            iconInPill ? 14 : 12,
                          ),
                        ),
                        child: Icon(icon, color: iconFg, size: s * 0.5),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
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
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (label != null && value != null)
                        const SizedBox(height: 2),
                      if (value != null)
                        Text(
                          value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.metric.copyWith(
                            color: titleColor,
                            fontSize: 24,
                          ),
                        ),
                      if (caption != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          caption!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label.copyWith(
                            color: labelColor,
                          ),
                        ),
                      ],
                      if (footer != null) ...[
                        const SizedBox(height: 10),
                        footer!,
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
                if (showChevron)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: inkVariant
                          ? Colors.white.withValues(alpha: 0.75)
                          : c.textTertiary,
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}

/// Petites puces posées sur une carte (icône + texte), thémables.
class GradientCardChip extends StatelessWidget {
  final IconData icon;
  final String label;

  /// true → texte blanc (carte encre) ; false → texte encre (carte wash).
  final bool onInk;
  final Color? color;

  const GradientCardChip({
    super.key,
    required this.icon,
    required this.label,
    this.onInk = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final Color fg = color ?? (onInk ? Colors.white : c.textSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: onInk
            ? Colors.white.withValues(alpha: 0.14)
            : c.fill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
