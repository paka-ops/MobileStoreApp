import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// APPOINTMENT CARD — carte de rendez-vous du design system.
///
/// Structure exacte de la spec :
///   • Card blanche, BorderRadius.circular(20), ombre douce
///   • Row : Avatar + Nom / Spécialité + icône menu (3 points)
///   • Badge « Confirmé » avec check icon
///   • Divider fin
///   • Row : Date (icône calendrier) | Heure (icône horloge)
///
/// Dans BouTiKa elle sert de carte d'employé / vente / mouvement planifié :
///   AppointmentCard(
///     title: employee.name,
///     subtitle: employee.role,
///     initials: "AK",
///     statusLabel: "Confirmé",
///     dateLabel: "12 Mai 2026",
///     timeLabel: "09:30",
///     onTap: () => openProfile(employee),
///     onMenuTap: () => _showEmployeeOptions(employee),
///   )
///
/// ⚠️ Aucune logique : tous les callbacks sont fournis par l'écran parent.
/// ============================================================================
class AppointmentCard extends StatelessWidget {
  /// Nom affiché (titre).
  final String title;

  /// Spécialité / rôle / sous-titre.
  final String? subtitle;

  /// Avatar : enfant > initiales > icône.
  final Widget? avatar;
  final String? initials;
  final IconData avatarIcon;

  /// Badge de statut (« Confirmé » par défaut).
  final String? statusLabel;
  final Color? statusColor;
  final Color? statusSoftColor;
  final IconData statusIcon;
  final bool showStatus;

  /// Méta : date.
  final String? dateLabel;
  final IconData dateIcon;

  /// Méta : heure.
  final String? timeLabel;
  final IconData timeIcon;

  /// Méta additionnelles (chips optionnelles affichées sur la ligne date/heure).
  final List<Widget> extraMeta;

  /// Actions.
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;
  final bool showMenu;

  /// Contenu additionnel inséré entre le divider et les méta.
  final Widget? content;

  /// Badge de droite (compteur, montant…).
  final Widget? trailing;

  /// Tag de transition héro de l'avatar (liste → détail).
  final Object? heroTag;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? background;

  const AppointmentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.avatar,
    this.initials,
    this.avatarIcon = Icons.person_rounded,
    this.statusLabel = "Confirmé",
    this.statusColor,
    this.statusSoftColor,
    this.statusIcon = Icons.check_rounded,
    this.showStatus = true,
    this.dateLabel,
    this.dateIcon = Icons.calendar_today_outlined,
    this.timeLabel,
    this.timeIcon = Icons.access_time_rounded,
    this.extraMeta = const <Widget>[],
    this.onTap,
    this.onMenuTap,
    this.showMenu = true,
    this.content,
    this.trailing,
    this.heroTag,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    final Color sColor = statusColor ?? c.success;
    final Color sSoft = statusSoftColor ?? c.successSoft;
    final bool hasMeta = dateLabel != null || timeLabel != null;

    return Padding(
      padding: margin,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: background ?? c.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: c.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------- Row identité
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardAvatar(
                    avatar: avatar,
                    initials: initials,
                    icon: avatarIcon,
                    heroTag: heroTag,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle
                              .copyWith(color: c.textPrimary, fontSize: 15.5),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.tileSubtitle
                                .copyWith(color: c.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                  if (showMenu)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onMenuTap,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 20,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),

              // ------------------------------------------------- Badge statut
              if (showStatus && statusLabel != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sSoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: sColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          statusIcon,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel!,
                        style: AppTextStyles.chip.copyWith(
                          color: sColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (content != null) ...[
                const SizedBox(height: 14),
                content!,
              ],

              // ------------------------------------------------- Divider fin
              if (hasMeta) ...[
                const SizedBox(height: 14),
                Container(height: 1, color: c.hairline),
                const SizedBox(height: 12),

                // --------------------------------------------- Date | Heure
                Row(
                  children: [
                    if (dateLabel != null)
                      _MetaItem(
                        icon: dateIcon,
                        label: "Date",
                        value: dateLabel!,
                        color: c.textPrimary,
                        secondary: c.textSecondary,
                      ),
                    if (dateLabel != null && timeLabel != null)
                      Container(
                        width: 1,
                        height: 26,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: c.hairline,
                      ),
                    if (timeLabel != null)
                      _MetaItem(
                        icon: timeIcon,
                        label: "Heure",
                        value: timeLabel!,
                        color: c.textPrimary,
                        secondary: c.textSecondary,
                      ),
                    if (extraMeta.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      ...extraMeta,
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bloc « label + valeur » avec icône (Date / Heure).
class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color secondary;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 15, color: c.primary),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.label.copyWith(color: secondary)),
            const SizedBox(height: 1),
            Text(
              value,
              style: AppTextStyles.amountSmall.copyWith(
                color: color,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Avatar de carte (image / initiales / icône) + support Hero.
class _CardAvatar extends StatelessWidget {
  final Widget? avatar;
  final String? initials;
  final IconData icon;
  final Object? heroTag;

  const _CardAvatar({
    this.avatar,
    this.initials,
    required this.icon,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final bool hasInitials = initials != null && initials!.trim().isNotEmpty;

    Widget child;
    if (avatar != null) {
      child = ClipOval(child: avatar);
    } else {
      child = Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasInitials ? c.accentGradient : null,
          color: hasInitials ? null : c.primarySoft,
        ),
        child: hasInitials
            ? Text(
                initials!.trim().substring(0, 1).toUpperCase(),
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                ),
              )
            : Icon(icon, size: 22, color: c.primary),
      );
    }

    if (avatar != null) {
      child = SizedBox(width: 46, height: 46, child: child);
    }

    if (heroTag != null) {
      child = Hero(tag: heroTag!, child: child);
    }

    return child;
  }
}
