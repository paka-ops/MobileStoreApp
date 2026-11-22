import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';

/// ============================================================================
/// SIGNUP HEADER — badge de marque et titres du parcours d'inscription.
///
///   • Pastille « BouTiKa » 120 px de large (fond violet très pâle)
///   • « Créer votre compte » (22 / w700)
///   • « Complétez les étapes pour commencer » (13 / regular)
///
/// Constantes identiques à l'origine (padding 8 × 12, gap 15).
/// ============================================================================
class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Column(
      children: [
        Container(
          width: 120,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: colors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Center(
            child: Text(
              "BouTiKa",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "Créer votre compte",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        Text(
          "Complétez les étapes pour commencer",
          style:
              AppTextStyles.bodySecondary.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
