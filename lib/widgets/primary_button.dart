import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/buttons/app_button.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// PRIMARY BUTTON — bouton principal du design system (« Book Appointment »).
///
///   • Largeur pleine, hauteur 56 px
///   • BorderRadius.circular(28) → pilule
///   • Fond navy (#0F172A), texte blanc bold
///   • Ombre légère
///
///   PrimaryButton(
///     label: "Enregistrer la vente",
///     icon: Icons.check_rounded,
///     onPressed: _submit,          // logique existante intacte
///     isLoading: _isSaving,
///   )
///
/// Variantes : `.gradient` (teal → émeraude) et `.outline`.
/// La variante navy délègue à [AppButton] : haptique, loader et état
/// désactivé restent strictement identiques à l'existant.
/// ============================================================================
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  final double height;
  final double radius;

  /// Couleur de fond (navy par défaut) / du texte.
  final Color? background;
  final Color? foreground;

  /// Variante d'affichage.
  final _PrimaryButtonVariant variant;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.height = AppSizes.primaryButtonHeight,
    this.radius = AppRadius.button,
    this.background,
    this.foreground,
  }) : variant = _PrimaryButtonVariant.navy;

  /// Variante dégradé teal → émeraude (actions promotionnelles, CTA).
  const PrimaryButton.gradient({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.height = AppSizes.primaryButtonHeight,
    this.radius = AppRadius.button,
    this.foreground = Colors.white,
  })  : variant = _PrimaryButtonVariant.gradient,
        background = null;

  /// Variante contour (action secondaire forte).
  const PrimaryButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.height = AppSizes.primaryButtonHeight,
    this.radius = AppRadius.button,
    this.foreground,
    this.background,
  }) : variant = _PrimaryButtonVariant.outline;

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    // ---------------------------------------------------------------- navy
    if (variant == _PrimaryButtonVariant.navy) {
      return AppButton.primary(
        label: label,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        expand: expand,
        height: height,
        radius: radius,
        background: background ?? c.buttonPrimary,
        foreground: foreground ?? c.buttonOnPrimary,
      );
    }

    // ------------------------------------------------------------ gradient
    if (variant == _PrimaryButtonVariant.gradient) {
      return _GradientButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        expand: expand,
        height: height,
        radius: radius,
        foreground: foreground ?? Colors.white,
      );
    }

    // ------------------------------------------------------------- outline
    return AppButton.secondary(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      expand: expand,
      height: height,
      radius: radius,
    );
  }
}

enum _PrimaryButtonVariant { navy, gradient, outline }

/// Cœur visuel de la variante dégradé (pilule 56 px + ombre teintée).
class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final double height;
  final double radius;
  final Color foreground;

  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    required this.height,
    required this.radius,
    required this.foreground,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final bool enabled = widget.onPressed != null && !widget.isLoading;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.foreground),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 19, color: widget.foreground),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.button
                  .copyWith(color: widget.foreground, fontSize: 15.5),
            ),
          ),
        ],
      ],
    );

    final Widget button = GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: enabled ? 1 : 0.6,
          child: Container(
            height: widget.height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: c.accentGradient,
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: [
                BoxShadow(
                  color: c.gradientColors.first.withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ),
    );

    return widget.expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// ============================================================================
/// SECONDARY ACTIONS — petits boutons ronds posés à côté d'un [PrimaryButton]
/// (favori, partage…) au style du design system.
/// ============================================================================
class RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? background;
  final Color? iconColor;
  final double size;

  const RoundActionButton({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.background,
    this.iconColor,
    this.size = AppSizes.primaryButtonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    Widget button = PressableScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background ?? c.card,
          shape: BoxShape.circle,
          boxShadow: c.cardShadow,
        ),
        child: Icon(icon, size: 21, color: iconColor ?? c.textPrimary),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
