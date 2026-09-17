import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_store_app/widgets/boutika_loader.dart';

import '../../constants/app_durations.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// ============================================================================
/// APP BUTTON — bouton premium : 5 variantes, état de chargement et
/// micro-interaction d'appui (scale 0.98 + haptic feedback).
///
///   AppButton.primary(label: 'Enregistrer', onPressed: save, isLoading: busy)
///   AppButton.secondary(label: 'Annuler', onPressed: close)
///   AppButton.danger(label: 'Supprimer', onPressed: delete)
///   AppButton.soft(label: 'Restocker', icon: Icons.add, onPressed: restock,
///                  color: c.success, softColor: c.successSoft)
///   AppButton.ghost(label: 'Plus tard', onPressed: later, expand: false)
/// ============================================================================
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  /// Icône optionnelle à gauche du libellé.
  final IconData? icon;

  /// Affiche un loader à la place du contenu.
  final bool isLoading;

  /// Étire le bouton sur toute la largeur disponible.
  final bool expand;

  /// Couleurs surchargées (sinon déduites de la variante + du thème).
  final Color? background;
  final Color? foreground;
  final Color? borderColor;

  final _AppButtonVariant variant;
  final double height;
  final double radius;
  final double? fontSize;

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.background,
    this.foreground,
    this.height = AppSizes.buttonHeight,
    this.radius = AppRadius.md,
    this.fontSize,
  })  : variant = _AppButtonVariant.primary,
        borderColor = null;

  /// Bouton secondaire : bordure 1.4 px, fond transparent.
  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.background,
    this.foreground,
    this.borderColor,
    this.height = AppSizes.buttonHeight,
    this.radius = AppRadius.md,
    this.fontSize,
  }) : variant = _AppButtonVariant.secondary;

  /// Bouton « doux » : fond teinté + texte coloré (actions contextuelles).
  const AppButton.soft({
    super.key,
    required this.label,
    required this.onPressed,
    required Color softColor,
    required Color color,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.height = AppSizes.buttonHeight,
    this.radius = AppRadius.md,
    this.fontSize,
  })  : variant = _AppButtonVariant.soft,
        background = softColor,
        foreground = color,
        borderColor = null;

  /// Bouton destructeur.
  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.background,
    this.foreground,
    this.height = AppSizes.buttonHeight,
    this.radius = AppRadius.md,
    this.fontSize,
  })  : variant = _AppButtonVariant.danger,
        borderColor = null;

  /// Bouton texte (action tertiaire).
  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.foreground,
    this.height = 44,
    this.radius = AppRadius.md,
    this.fontSize,
  })  : variant = _AppButtonVariant.ghost,
        background = null,
        borderColor = null;

  @override
  State<AppButton> createState() => _AppButtonState();
}

enum _AppButtonVariant { primary, secondary, soft, danger, ghost }

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final bool enabled = widget.onPressed != null && !widget.isLoading;

    late final Color bg;
    late final Color fg;
    Border? border;

    switch (widget.variant) {
      case _AppButtonVariant.primary:
        bg = widget.background ?? c.primary;
        fg = widget.foreground ?? c.onPrimary;
        break;
      case _AppButtonVariant.secondary:
        bg = widget.background ?? Colors.transparent;
        fg = widget.foreground ?? c.textPrimary;
        border = Border.all(
          color: widget.borderColor ?? c.border,
          width: 1.4,
        );
        break;
      case _AppButtonVariant.soft:
        bg = widget.background ?? c.primarySoft;
        fg = widget.foreground ?? c.primary;
        break;
      case _AppButtonVariant.danger:
        bg = widget.background ?? c.danger;
        fg = widget.foreground ?? Colors.white;
        break;
      case _AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = widget.foreground ?? c.primary;
        break;
    }

    final bool transparentVariant =
        widget.variant == _AppButtonVariant.ghost ||
            widget.variant == _AppButtonVariant.secondary;

    final Color disabledBg =
        transparentVariant ? Colors.transparent : bg.withValues(alpha: 0.45);
    final Color disabledFg = transparentVariant
        ? fg.withValues(alpha: 0.45)
        : c.onPrimary.withValues(alpha: 0.8);

    final TextStyle textStyle = AppTextStyles.button.copyWith(
      color: enabled ? fg : disabledFg,
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w600,
    );

    final Widget content = widget.isLoading
        ? const BouTikaLoader.compact()
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 19, color: textStyle.color),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
            ],
          );

    final Widget button = AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: enabled ? 1.0 : 0.6,
      child: AnimatedScale(
        scale: _pressed && enabled ? 0.98 : 1.0,
        duration: AppDurations.fast,
        curve: AppCurves.press,
        child: Material(
          color: enabled ? bg : disabledBg,
          borderRadius: BorderRadius.circular(widget.radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.radius),
            onTap: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onPressed!();
                  }
                : null,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Container(
              height: widget.height,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                border: border,
              ),
              alignment: Alignment.center,
              child: content,
            ),
          ),
        ),
      ),
    );

    if (!widget.expand) return button;

    return SizedBox(width: double.infinity, child: button);
  }
}

/// ============================================================================
/// APP ICON BUTTON — bouton icône carré arrondi utilisé dans les headers.
/// ============================================================================
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badge;
  final Color? badgeColor;
  final Color? iconColor;
  final Color? background;
  final String? tooltip;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = 0,
    this.badgeColor,
    this.iconColor,
    this.background,
    this.tooltip,
    this.size = AppSizes.iconButtonSize,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    final Widget button = PressableScale(
      onTap: onTap,
      pressedScale: 0.94,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background ?? c.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.border),
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? c.textPrimary,
        ),
      ),
    );

    final Widget withBadge = badge > 0
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              button,
              Positioned(
                top: -5,
                right: -5,
                child: AppBadge(
                  count: badge,
                  color: badgeColor ?? c.danger,
                ),
              ),
            ],
          )
        : button;

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: withBadge);
    }
    return withBadge;
  }
}

/// ============================================================================
/// APP BACK BUTTON — bouton retour standard de tous les écrans.
/// ============================================================================
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return PressableScale(
      onTap: onPressed ?? () => Navigator.of(context).maybePop(),
      pressedScale: 0.92,
      child: Container(
        width: AppSizes.iconButtonSize,
        height: AppSizes.iconButtonSize,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.border),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 17,
          color: c.textPrimary,
        ),
      ),
    );
  }
}
