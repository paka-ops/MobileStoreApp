import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../common/primitives.dart';

/// ============================================================================
/// APP CARD — conteneur premium (surface, bordure fine, ombre douce).
///
///   AppCard(child: ...)                    // statique
///   AppCard(onTap: ..., child: ...)        // cliquable + micro-interaction
///   AppCard.outlined(child: ...)           // variante bordure visible
///   AppCard.filled(child: ...)             // variante fond légèrement teinté
/// ============================================================================
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;

  /// null → ombre standard du thème ; liste vide → pas d'ombre.
  final List<BoxShadow>? shadow;
  final double borderWidth;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppRadius.xl,
    this.color,
    this.borderColor,
    this.shadow,
    this.borderWidth = 1,
  });

  /// Variante « outline » : bordure visible, pas d'ombre.
  const AppCard.outlined({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppRadius.xl,
    this.color,
    this.borderColor,
  })  : shadow = const [],
        borderWidth = 1.3;

  /// Variante « filled » : fond légèrement différent, ni ombre ni bordure.
  const AppCard.filled({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppRadius.xl,
    this.color,
  })  : shadow = const [],
        borderColor = Colors.transparent,
        borderWidth = 0;

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    final List<BoxShadow>? effectiveShadow =
        (shadow != null && shadow!.isEmpty) ? null : (shadow ?? c.cardShadow);

    final Decoration decoration = BoxDecoration(
      color: color ?? c.card,
      borderRadius: BorderRadius.circular(radius),
      border: borderWidth > 0
          ? Border.all(
              color: borderColor ?? c.border,
              width: borderWidth,
            )
          : null,
      boxShadow: effectiveShadow,
    );

    final Widget content = Padding(padding: padding, child: child);

    if (onTap == null && onLongPress == null) {
      return DecoratedBox(decoration: decoration, child: content);
    }

    return PressableScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Ink(
            decoration: decoration,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// STAT CARD — mini KPI (icône, valeur, libellé).
/// ============================================================================
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color softColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
      radius: AppRadius.lg,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: AppDecorations.softIconBox(
              c,
              color: color,
              softColor: softColor,
              radius: AppRadius.sm,
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.amount.copyWith(
              fontSize: 17.5,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// ACTION TILE — carte d'accès à une fonctionnalité (hub stock, menus…).
/// ============================================================================
class ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color softColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int? badge;
  final Widget? trailing;

  const ActionTile({
    super.key,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      radius: AppRadius.lg,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: AppDecorations.softIconBox(
                  c,
                  color: color,
                  softColor: softColor,
                  radius: AppRadius.md,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (badge != null && badge! > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: AppBadge(count: badge!, color: color),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 14.5,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: c.textSecondary,
                size: 22,
              ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// INFO TILE — ligne « icône + label + valeur ».
/// ============================================================================
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color softColor;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: AppDecorations.softIconBox(
              c,
              color: color,
              softColor: softColor,
              radius: AppRadius.sm,
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
