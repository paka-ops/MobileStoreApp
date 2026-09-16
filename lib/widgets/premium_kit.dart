import 'package:flutter/material.dart';
import 'package:mobile_store_app/utils/app_colors.dart';

// =====================================================================
// PREMIUM KIT — composants de présentation « BouTika Premium »
// ---------------------------------------------------------------------
// 100 % visuel : ces widgets ne contiennent AUCUNE logique métier.
// Ils reçoivent leurs données et callbacks en paramètres et se contentent
// de les habiller (anti-fatigue, tactile ≥ 48 px, coins doux 12-16).
// =====================================================================

// ---------------------------------------------------------------------
// CARTE PREMIUM — fond feutré, bordure fine, ombre diffuse
// ---------------------------------------------------------------------
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final bool withShadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = PremiumGap.card,
    this.radius = PremiumRadii.lg,
    this.onTap,
    this.color,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: withShadow ? colors.cardShadow : null,
      ),
      child: child,
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: body,
      ),
    );
  }
}

// ---------------------------------------------------------------------
// TUILE D'ICÔNE — pastille colorée douce (fonds `Soft` uniquement)
// ---------------------------------------------------------------------
class PremiumIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color softColor;
  final double size;
  final double iconSize;
  final double radius;

  const PremiumIconTile({
    super.key,
    required this.icon,
    required this.color,
    required this.softColor,
    this.size = 46,
    this.iconSize = 22,
    this.radius = PremiumRadii.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

// ---------------------------------------------------------------------
// EN-TÊTE DE SECTION — titre Medium + sous-titre + icône/action
// ---------------------------------------------------------------------
class PremiumSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  const PremiumSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return Row(
      children: [
        if (icon != null) ...[
          PremiumIconTile(
            icon: icon!,
            color: colors.primary,
            softColor: colors.primarySoft,
            size: 42,
            iconSize: 20,
            radius: PremiumRadii.sm,
          ),
          PremiumGap.mdW,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.5,
                  letterSpacing: -0.2,
                  color: colors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ---------------------------------------------------------------------
// BOUTON PRIMAIRE — CTA émeraude, 54 px, halo diffus
// ---------------------------------------------------------------------
class PremiumPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? loadingWidget;
  final bool expanded;
  final double height;

  const PremiumPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loadingWidget,
    this.expanded = true,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PremiumRadii.input),
          boxShadow: onPressed == null ? null : colors.glowShadow,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PremiumRadii.input),
            ),
          ),
          child: loadingWidget ??
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// BOUTON SECONDAIRE — contour fin, fond carte, 54 px
// ---------------------------------------------------------------------
class PremiumSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final double height;

  const PremiumSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.card,
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PremiumRadii.input),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: colors.textSecondary),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// BOUTON DANGER — rouge doux, 54 px
// ---------------------------------------------------------------------
class PremiumDangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? loadingWidget;
  final bool expanded;

  const PremiumDangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loadingWidget,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return SizedBox(
      height: 54,
      width: expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.danger,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PremiumRadii.input),
          ),
        ),
        child: loadingWidget ??
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// BADGE / CHIP — pastille douce + label Medium
// ---------------------------------------------------------------------
class PremiumBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color softColor;

  const PremiumBadge({
    super.key,
    required this.label,
    required this.color,
    required this.softColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// ÉTAT VIDE — illustration douce, titre, message, action optionnelle
// ---------------------------------------------------------------------
class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Médaillon décoratif : halo + pastille + icône.
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: colors.primarySoft.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Icon(icon, size: 44, color: colors.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13.5,
                height: 1.55,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 240,
                child: PremiumPrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// LIGNE D'INFO — label discret + valeur Bold (détails, reçus)
// ---------------------------------------------------------------------
class PremiumInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool highlight;

  const PremiumInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: highlight ? 15 : 13.5,
                color: valueColor ??
                    (highlight ? colors.primary : colors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// POIGNÉE DE BOTTOM SHEET — barre de préhension standard
// ---------------------------------------------------------------------
class PremiumSheetHandle extends StatelessWidget {
  const PremiumSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// AVATAR PREMIUM — initiales sur voile de marque, anneau fin
// ---------------------------------------------------------------------
class PremiumAvatar extends StatelessWidget {
  final String label;
  final double radius;
  final VoidCallback? onTap;

  const PremiumAvatar({
    super.key,
    required this.label,
    this.radius = 23,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    final initials = label.trim().isEmpty
        ? '?'
        : label
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
            .join();
    final avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primarySoft,
        border: Border.all(
          color: colors.primary.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.62,
        ),
      ),
    );
    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }
}

// ---------------------------------------------------------------------
// MICRO-LABEL — capitales espacées pour sections / KPI
// ---------------------------------------------------------------------
class PremiumMicroLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const PremiumMicroLabel(this.label, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color ?? colors.textSecondary,
      ),
    );
  }
}

// ---------------------------------------------------------------------
// BOUTON D'ACTION DIALOGUE — « Annuler / Valider » côte à côte, 52 px
// ---------------------------------------------------------------------
class PremiumDialogActions extends StatelessWidget {
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final Widget? confirmLoading;
  final Color? confirmColor;

  const PremiumDialogActions({
    super.key,
    this.cancelLabel = 'Annuler',
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.confirmLoading,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                backgroundColor: colors.card,
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.border, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.input),
                ),
              ),
              child: Text(
                cancelLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? colors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.input),
                ),
              ),
              child: confirmLoading ??
                  Text(
                    confirmLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
