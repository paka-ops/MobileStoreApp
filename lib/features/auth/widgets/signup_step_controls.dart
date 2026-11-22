import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';

/// ============================================================================
/// SIGNUP STEP CONTROLS — boutons du parcours d'inscription.
///
///   • « Retour » (secondaire, 48 px) à partir de la deuxième étape
///   • « Suivant » / « Terminer l'inscription » (primaire, 48 px, flex 2)
///   • Espacement 15 px entre les deux, 30 px au-dessus du bloc
///
/// Pendant l'envoi, le bouton primaire affiche son loader et est désactivé :
/// c'est exactement le comportement d'origine.
/// ============================================================================
class SignupStepControls extends StatelessWidget {
  /// Étape courante (0 → 2).
  final int currentStep;

  /// `true` pendant l'envoi : le bouton primaire est chargé et désactivé.
  final bool isLoading;

  /// Callback « Suivant » fourni par le `Stepper`.
  final VoidCallback? onContinue;

  /// Callback « Retour » fourni par le `Stepper`.
  final VoidCallback? onCancel;

  const SignupStepControls({
    super.key,
    required this.currentStep,
    required this.isLoading,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = currentStep == 2;

    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: AppButton.secondary(
                label: "Retour",
                height: 48,
                onPressed: onCancel,
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: AppButton.primary(
              label: isLastStep ? "Terminer l'inscription" : "Suivant",
              height: 48,
              isLoading: isLoading,
              onPressed: isLoading ? null : onContinue,
            ),
          ),
        ],
      ),
    );
  }
}
