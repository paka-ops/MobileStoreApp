import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/features/auth/controllers/signup_controller.dart';
import 'package:mobile_store_app/features/auth/widgets/signup_header.dart';
import 'package:mobile_store_app/features/auth/widgets/signup_progress_bar.dart';
import 'package:mobile_store_app/features/auth/widgets/signup_step_controls.dart';
import 'package:mobile_store_app/features/auth/widgets/signup_steps.dart';
import 'package:mobile_store_app/utils/message.dart';

/// ============================================================================
/// EMPLOYER FORM PAGE — création de compte employeur (parcours en 3 étapes).
///
/// Structure identique à l'écran d'origine :
///   Scaffold → AppBar (retour) → SafeArea → Form
///   → Column[badge & titres, barre de progression, Stepper horizontal]
///
/// Le `Theme` local ne modifie que la `primaryColor` du `colorScheme`, pour que
/// le `Stepper` adopte le violet de la marque (identique à l'origine).
///
/// Comportements conservés :
///   • « Suivant » valide l'étape, avance, ou envoie l'inscription
///   • étape incomplète → « Veuillez remplir tous les champs de cette étape »
///   • « Retour » revient d'une étape
///   • succès → « Compte creer avec success » puis retour à « /login » après 3 s
///   • état de chargement relâché après 7 s par le contrôleur (héritage)
/// ============================================================================
class EmployerFormPage extends StatefulWidget {
  const EmployerFormPage({super.key});

  @override
  State<EmployerFormPage> createState() => _EmployerFormPageState();
}

class _EmployerFormPageState extends State<EmployerFormPage> {
  final SignupController _controller = SignupController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final DashColors colors = DashColors(context);

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: colors.textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _controller.formKey,
              child: Column(
                children: [
                  const SignupHeader(),
                  SignupProgressBar(currentStep: _controller.currentStep),

                  // Stepper avec contrôles personnalisés
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: colors.primary,
                            ),
                      ),
                      child: Stepper(
                        type: StepperType.horizontal,
                        elevation: 0,
                        currentStep: _controller.currentStep,
                        onStepContinue: _handleNext,
                        onStepCancel: _controller.back,
                        controlsBuilder: (context, details) =>
                            SignupStepControls(
                          currentStep: _controller.currentStep,
                          isLoading: _controller.isLoading,
                          onContinue: details.onStepContinue,
                          onCancel: details.onStepCancel,
                        ),
                        steps: buildSignupSteps(
                          controller: _controller,
                          colors: colors,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Valide l'étape courante puis avance, envoie ou signale l'incomplet.
  void _handleNext() {
    final SignupStepAction action = _controller.next();

    switch (action) {
      case SignupStepAction.blocked:
        final DashColors colors = DashColors(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text("Veuillez remplir tous les champs de cette étape"),
            backgroundColor: colors.danger,
          ),
        );
        break;
      case SignupStepAction.submit:
        // Appel non attendu, comme auparavant.
        unawaited(_submit());
        break;
      case SignupStepAction.advance:
      case SignupStepAction.none:
        break;
    }
  }

  /// Envoie l'inscription et gère le retour utilisateur.
  Future<void> _submit() async {
    final bool isCreated = await _controller.submit(context);

    if (!mounted) return;

    if (isCreated) {
      showSuccessMessage("Compte creer avec success", context);
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        Navigator.pushNamed(context, "/login");
      });
    }
  }
}
