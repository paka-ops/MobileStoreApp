import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';

/// ============================================================================
/// PRIMARY BUTTON — bouton principal du design system.
///
///   • Largeur pleine, hauteur 52 px (`AppSizes.primaryButtonHeight`)
///   • BorderRadius `AppRadius.button` → pilule
///   • Variante `navy` : délègue à [AppButton] (haptique, loader, état
///     désactivé identiques)
///   • Variante `gradient` : dégradé de marque + ombre teintée
///   • Variante `outline` : contour secondaire
///
///   PrimaryButton(
///     label: "Enregistrer la vente",
///     icon: Icons.check_rounded,
///     onPressed: _submit,          // logique existante intacte
///     isLoading: _isSaving,
///   )
///
/// Le rendu (dimensions, couleurs, opacités, échelle au press) est celui de
/// l'implémentation d'origine : aucune constante n'a été ajustée.
/// ============================================================================
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  final double height;
  final double radius;

  /// Couleur de fond (encre par défaut) / du texte.
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

  /// Variante dégradé de marque (actions promotionnelles, CTA).
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

    // ---------------------------------------------------------------- encre
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

    // ------------------------------------------------------------ dégradé
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

    // ------------------------------------------------------------- contour
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

/// Cœur visuel de la variante dégradé (pilule + ombre teintée).
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

    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
