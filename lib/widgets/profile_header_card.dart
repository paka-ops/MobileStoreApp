import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// ============================================================================
/// PROFILE HEADER CARD — en-tête de fiche détail du design system.
///
///   • Avatar circulaire large (100 px) centré
///   • Nom + badge « Top » (étoile dorée dans une pilule)
///   • Row de stats (Ventes | Expérience | Note) séparés par des
///     dividers verticaux fins
///
///   ProfileHeaderCard(
///     name: employee.name,
///     subtitle: employee.role,
///     initials: "AK",
///     heroTag: "employee-${employee.id}",   // transition liste → détail
///     stats: [
///       ProfileStat(label: "Ventes", value: "182"),
///       ProfileStat(label: "Expérience", value: "3 ans"),
///       ProfileStat(label: "Note", value: "4.8", icon: Icons.star_rounded),
///     ],
///   )
///
/// ⚠️ Présentation pure : les valeurs statistiques sont fournies par l'écran.
/// ============================================================================
class ProfileStat {
  final String label;
  final String value;

  /// Icône optionnelle devant la valeur (ex. étoile de note).
  final IconData? icon;
  final Color? iconColor;

  const ProfileStat({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });
}

class ProfileHeaderCard extends StatelessWidget {
  final String name;

  /// Sous-titre (rôle, boutique, spécialité).
  final String? subtitle;

  /// Avatar : enfant > initiales > icône.
  final Widget? avatar;
  final String? initials;
  final IconData avatarIcon;

  /// Badge « Top » (étoile dorée dans une pilule pastel).
  final bool showTopBadge;
  final String topBadgeLabel;
  final IconData topBadgeIcon;

  /// Statistiques séparées par des dividers verticaux fins.
  final List<ProfileStat> stats;

  /// Tag de transition héro de l'avatar (liste → détail).
  final Object? heroTag;

  /// Actions rapides affichées sous les stats.
  final Widget? footer;
  final Widget? trailing;

  final VoidCallback? onTapAvatar;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double avatarSize;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    this.subtitle,
    this.avatar,
    this.initials,
    this.avatarIcon = Icons.person_rounded,
    this.showTopBadge = true,
    this.topBadgeLabel = "Top",
    this.topBadgeIcon = Icons.star_rounded,
    this.stats = const <ProfileStat>[],
    this.heroTag,
    this.footer,
    this.trailing,
    this.onTapAvatar,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.avatarSize = AppSizes.profileAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Padding(
      padding: margin,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: c.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing!),

            // ------------------------------------------------- Avatar 100 px
            GestureDetector(
              onTap: onTapAvatar,
              child: _LargeAvatar(
                size: avatarSize,
                avatar: avatar,
                initials: initials,
                icon: avatarIcon,
                heroTag: heroTag,
              ),
            ),
            const SizedBox(height: 14),

            // ------------------------------------------------ Nom + badge Top
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.name.copyWith(color: c.textPrimary),
                ),
                if (showTopBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: c.ratingSoft,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(topBadgeIcon, size: 12.5, color: c.rating),
                        const SizedBox(width: 4),
                        Text(
                          topBadgeLabel,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: c.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 5),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(
                  AppTextStyles.bodySecondary.copyWith(color: c.textSecondary).5,
                ),
              ),
            ],

            // ------------------------------------------------------ Stats row
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(height: 1, color: c.hairline),
              const SizedBox(height: 16),
              Row(
                children: List.generate(stats.length, (index) {
                  final ProfileStat s = stats[index];
                  return Expanded(
                    child: Row(
                      children: [
                        if (index > 0)
                          Container(
                            width: 1,
                            height: 30,
                            color: c.hairline,
                          ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (s.icon != null) ...[
                                    Icon(
                                      s.icon,
                                      size: 15,
                                      color: s.iconColor ?? c.rating,
                                    ),
                                    const SizedBox(width: 3),
                                  ],
                                  Flexible(
                                    child: Text(
                                      s.value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.statValue
                                          .copyWith(color: c.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.label
                                    .copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],

            if (footer != null) ...[
              const SizedBox(height: 18),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Avatar circulaire large avec anneau dégradé + support Hero.
class _LargeAvatar extends StatelessWidget {
  final double size;
  final Widget? avatar;
  final String? initials;
  final IconData icon;
  final Object? heroTag;

  const _LargeAvatar({
    required this.size,
    this.avatar,
    this.initials,
    required this.icon,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final bool hasInitials = initials != null && initials!.trim().isNotEmpty;

    Widget inner;
    if (avatar != null) {
      inner = ClipOval(child: avatar);
    } else {
      inner = Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.primarySoft,
        ),
        child: hasInitials
            ? Text(
                initials!.trim().substring(0, 1).toUpperCase(),
                style: AppTextStyles.h1.copyWith(
                  color: c.primary,
                  fontSize: size * 0.36,
                ),
              )
            : Icon(icon, size: size * 0.38, color: c.primary),
      );
    }

    Widget ring = Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.card,
        boxShadow: c.cardShadow,
      ),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.fill),
        padding: const EdgeInsets.all(2),
        child: ClipOval(child: inner),
      ),
    );

    if (heroTag != null) {
      ring = Hero(tag: heroTag!, child: ring);
    }
    return ring;
  }
}
