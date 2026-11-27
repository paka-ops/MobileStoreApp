import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';

/// ============================================================================
/// WELCOME HIGHLIGHTS BAR — bandeau « verre dépoli » de l'accueil.
///
///   • Pilule translucide + flou (σ = 12)
///   • Trois avantages séparés par des points 3 × 3
///   • Couleurs des points : marque (violet) / accent (rose) / succès (vert)
///
/// Les paddings (18 × 10), le rayon (pilule), la bordure 1.1, l'ombre douce et
/// les opacités (0.68 clair / 0.55 sombre) sont ceux de l'écran d'origine.
/// ============================================================================
class WelcomeHighlightsBar extends StatelessWidget {
  const WelcomeHighlightsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: colors.card.withValues(alpha: colors.isDark ? 0.55 : 0.68),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: colors.isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.1,
            ),
            boxShadow: colors.softShadow,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              _HighlightItem(
                label: "Stock en temps réel",
                dotColor: colors.primary,
              ),
              _DotSeparator(color: colors.textTertiary),
              _HighlightItem(
                label: "Ventes rapides",
                dotColor: colors.accent,
              ),
              _DotSeparator(color: colors.textTertiary),
              _HighlightItem(
                label: "Analyses claires",
                dotColor: colors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avantage du bandeau : point coloré 6 px + libellé 12 / w600.
class _HighlightItem extends StatelessWidget {
  final String label;
  final Color dotColor;

  const _HighlightItem({required this.label, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Séparateur discret entre deux avantages (point 3 × 3).
class _DotSeparator extends StatelessWidget {
  final Color color;

  const _DotSeparator({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
