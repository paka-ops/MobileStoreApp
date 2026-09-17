import 'package:flutter/material.dart';

import '../../constants/app_durations.dart';
import '../../theme/app_colors.dart';

/// ============================================================================
/// PRIMITIVES — micro-interactions, badges, chips, headers de section.
/// ============================================================================

/// PressableScale — micro-interaction universelle d'appui (scale 0.98).
///
/// Enveloppez n'importe quel widget pour lui donner un feedback tactile
/// cohérent :
///
///   PressableScale(onTap: () { ... }, child: MaCarte())
/// ============================================================================
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Échelle appliquée pendant l'appui.
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.98,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  @override
  Widget build(BuildContext context) {
    final Widget scaled = AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1.0,
      duration: AppDurations.fast,
      curve: AppCurves.press,
      child: widget.child,
    );

    if (!_enabled) return scaled;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: scaled,
    );
  }
}

/// ============================================================================
/// AppBadge — pastille de comptage (notifications, alertes stock).
/// ============================================================================
class AppBadge extends StatelessWidget {
  final int count;
  final Color color;
  final Color textColor;

  const AppBadge({
    super.key,
    required this.count,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// ============================================================================
/// SoftChip — pilule d'information douce (icône + texte colorés, fond teinté).
/// ============================================================================
class SoftChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final Color softColor;
  final TextStyle? textStyle;

  const SoftChip({
    super.key,
    this.icon,
    required this.label,
    required this.color,
    required this.softColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle ??
                  TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// StatusPill — pilule de statut avec point lumineux (Active / Inactive…).
/// ============================================================================
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color softColor;
  final bool withDot;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.softColor,
    this.withDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// SectionHeader — titre de section avec sous-titre et action optionnelle.
/// ============================================================================
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: c.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

/// ============================================================================
/// OverlineLabel — petit label « ÉTAT DU STOCK » en majuscules espacées.
/// ============================================================================
class OverlineLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const OverlineLabel({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color ?? DashColors(context).textSecondary,
      ),
    );
  }
}
