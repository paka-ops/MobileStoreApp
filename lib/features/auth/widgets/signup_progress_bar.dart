import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';

/// ============================================================================
/// SIGNUP PROGRESS BAR — progression du parcours d'inscription.
///
/// Trois segments de 4 px de haut, rayon 2, marge horizontale 4, dont la
/// couleur passe du violet (étapes atteintes) à la bordure (étapes à venir).
/// Padding extérieur 40 × 20 : valeurs identiques à l'origine.
/// ============================================================================
class SignupProgressBar extends StatelessWidget {
  /// Étape courante (0 → 2).
  final int currentStep;

  /// Nombre total d'étapes.
  final int stepCount;

  const SignupProgressBar({
    super.key,
    required this.currentStep,
    this.stepCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: List.generate(stepCount, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= currentStep ? colors.primary : colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
