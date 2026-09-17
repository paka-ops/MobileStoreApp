import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// SERVICE LIST TILE — ligne d'action / de service du design system.
///
///   • Icône dans un cercle pastel à gauche
///   • Titre (bold) + sous-titre (gris) au centre
///   • Chevron « > » à droite
///   • Padding vertical 12 px, aucune bordure visible
///
///   ServiceListTile(
///     icon: Icons.inventory_2_outlined,
///     title: "Produits",
///     subtitle: "128 articles en stock",
///     pastelIndex: 2,                       // pastel cyclique
///     onTap: () => openProducts(),          // logique inchangée
///   )
///
/// ⚠️ Présentation pure : le tap est entièrement géré par l'écran parent.
/// ============================================================================
class ServiceListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  /// Pastel imposé ou déduit de [pastelIndex] (cyclique).
  final Color? pastel;
  final int pastelIndex;
  final Color? iconColor;

  /// Callback de sélection.
  final VoidCallback? onTap;

  /// Élément de droite personnalisé (remplace le chevron si fourni).
  final Widget? trailing;

  /// Affiche le chevron « > » (masqué si [trailing] est fourni).
  final bool showChevron;

  /// Pastille de comptage (ex. nombre d'articles).
  final int badgeCount;

  /// Séparateur fin sous la ligne (désactivé par défaut : aucune bordure).
  final bool showDivider;

  final EdgeInsetsGeometry padding;
  final double iconBoxSize;

  const ServiceListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.pastel,
    this.pastelIndex = 0,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.showChevron = true,
    this.badgeCount = 0,
    this.showDivider = false,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.iconBoxSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final Color soft = pastel ?? c.pastelAt(pastelIndex);

    return PressableScale(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: padding,
            child: Row(
              children: [
                // ------------------------------------- Cercle pastel + icône
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: soft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 21,
                    color: iconColor ?? _deepTint(soft),
                  ),
                ),
                const SizedBox(width: 14),

                // ------------------------------------------ Titre + sous-titre
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardTitle.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (badgeCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: c.primarySoft,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                badgeCount > 99 ? "99+" : "$badgeCount",
                                style: AppTextStyles.label.copyWith(
                                  color: c.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.tileSubtitle
                              .copyWith(color: c.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // ------------------------------------------------ Chevron « > »
                if (trailing != null)
                  trailing!
                else if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: c.textSecondary,
                  ),
              ],
            ),
          ),
          if (showDivider) Container(height: 1, color: c.hairline),
        ],
      ),
    );
  }

  /// Assombrit un pastel pour une teinte d'icône contrastée.
  static Color _deepTint(Color pastel) {
    final HSLColor hsl = HSLColor.fromColor(pastel);
    return hsl
        .withLightness((hsl.lightness - 0.30).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.12).clamp(0.0, 1.0))
        .toColor();
  }
}
