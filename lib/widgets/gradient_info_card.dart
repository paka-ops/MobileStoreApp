import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// GRADIENT INFO CARD — carte d'information à dégradé teal → émeraude.
///
///   • BorderRadius.circular(20)
///   • Gradient diagonal (topLeft → bottomRight) #0D9488 → #10B981
///   • Texte blanc, padding 16 px
///
/// Deux usages :
///
///   1. Chiffre clé :
///      GradientInfoCard(
///        icon: Icons.payments_outlined,
///        label: "Recettes du jour",
///        value: "42 500 F",
///        caption: "12 ventes",
///      )
///
///   2. Séparateur de date (spec « carte date ») :
///      GradientInfoCard.date(label: "Today", value: "12 Mai 2026")
///
/// ⚠️ Widget purement visuel : aucune donnée n'est calculée ici.
/// ============================================================================
class GradientInfoCard extends StatelessWidget {
  final IconData? icon;
  final String? label; // surtitre (« Recettes du jour », « Aujourd'hui »)
  final String? value; // valeur principale (« 42 500 F », « 12 Mai »)
  final String? caption; // précision sous la valeur
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;

  /// Contenu additionnel optionnel (ex. petite puce de tendance).
  final Widget? footer;

  final double radius;
  final EdgeInsetsGeometry padding;

  /// Dégradé personnalisé (sinon dégradé teal du design system).
  final Gradient? gradient;

  /// Variante de dégradé prête à l'emploi : navy → teal.
  final bool navyVariant;

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
    this.radius = AppRadius.xl,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.navyVariant = false,
  });

  /// Constructeur pratique : carte de date (spec « GradientInfoCard »).
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
        padding = const EdgeInsets.all(16),
        gradient = null,
        navyVariant = false;

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final Gradient g = gradient ??
        (navyVariant
            ? LinearGradient(
                colors: [
                  c.navy,
                  Color.lerp(c.navy, c.primary, 0.6) ?? c.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : c.accentGradient);

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: g,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: c.gradientColors.first.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child ??
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
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
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12.5,
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
                          style: AppTextStyles.name.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      if (caption != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          caption!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
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
                  const SizedBox(width: 10),
                  trailing!,
                ],
              ],
            ),
      ),
    );
  }
}

/// Puces translucides posées sur une [GradientInfoCard] (icône + texte).
class GradientCardChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const GradientCardChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
