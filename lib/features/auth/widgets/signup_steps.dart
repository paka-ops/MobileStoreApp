import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/features/auth/controllers/signup_controller.dart';

/// ============================================================================
/// SIGNUP STEPS — les trois étapes du parcours d'inscription employeur.
///
///   1. Identité  : nom (obligatoire) + prénom (obligatoire)
///   2. Contact   : nom d'utilisateur (obligatoire) + téléphone (obligatoire)
///   3. Sécurité  : mot de passe (≥ 4 caractères) + confirmation identique
///
/// Chaque champ reprend exactement la décoration d'origine (`_inputStyle`) :
/// fond carte, libellé 14, icône préfixe 20 violette, padding 16 × 20,
/// bordure au repos 1 px, bordure focus 1.5 px violette, rayon 12.
///
/// Les états d'étape reproduisent la logique d'origine :
///   • étapes 0 et 1 → `complete` après validation, sinon `indexed`
///   • étape 2       → ni `complete` ni `indexed` (indicateur neutre)
/// ============================================================================
List<Step> buildSignupSteps({
  required SignupController controller,
  required DashColors colors,
}) {
  return [
    // =========================================================================
    // ÉTAPE 1 — Nom et prénom
    // =========================================================================
    Step(
      title: Text(
        "Identité",
        style: TextStyle(
          fontSize: 12,
          color: controller.currentStep == 0
              ? colors.primary
              : colors.textSecondary,
        ),
      ),
      content: Column(
        children: [
          TextFormField(
            controller: controller.lastnameController,
            decoration: _inputStyle("Nom", Icons.person_outline, colors),
            validator: (value) =>
                value!.isEmpty ? "Champ requis" : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: controller.firstnameController,
            decoration: _inputStyle("Prénom", Icons.person_outline, colors),
            validator: (value) =>
                value!.isEmpty ? "Champ requis" : null,
          ),
        ],
      ),
      isActive: controller.currentStep >= 0,
      state: controller.currentStep > 0
          ? StepState.complete
          : StepState.indexed,
    ),

    // =========================================================================
    // ÉTAPE 2 — Nom d'utilisateur et téléphone
    // =========================================================================
    Step(
      title: Text(
        "Contact",
        style: TextStyle(
          fontSize: 12,
          color: controller.currentStep == 1
              ? colors.primary
              : colors.textSecondary,
        ),
      ),
      content: Column(
        children: [
          TextFormField(
            controller: controller.usernameController,
            decoration:
                _inputStyle("Nom d'utilisateur", Icons.alternate_email, colors),
            validator: (value) =>
                value!.isEmpty ? "Champ requis" : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputStyle("Téléphone", Icons.phone_outlined, colors),
            validator: (value) =>
                value!.isEmpty ? "Champ requis" : null,
          ),
        ],
      ),
      isActive: controller.currentStep >= 1,
      state: controller.currentStep > 1
          ? StepState.complete
          : StepState.indexed,
    ),

    // =========================================================================
    // ÉTAPE 3 — Mot de passe et confirmation
    // =========================================================================
    Step(
      title: Text(
        "Sécurité",
        style: TextStyle(
          fontSize: 12,
          color: controller.currentStep == 2
              ? colors.primary
              : colors.textSecondary,
        ),
      ),
      content: Column(
        children: [
          TextFormField(
            controller: controller.passwordController,
            obscureText: controller.isObscured,
            decoration:
                _inputStyle("Mot de passe", Icons.lock_outline, colors).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isObscured
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: colors.textSecondary,
                ),
                onPressed: controller.toggleObscured,
              ),
            ),
            validator: (value) =>
                value!.length < 4 ? "4 caractères minimum" : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: controller.isConfirmObscured,
            decoration: _inputStyle("Confirmer mot de passe", Icons.lock_reset, colors)
                .copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isConfirmObscured
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: colors.textSecondary,
                ),
                onPressed: controller.toggleConfirmObscured,
              ),
            ),
            validator: (value) => value != controller.passwordController.text
                ? "Les mots de passe diffèrent"
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            "Assurez-vous que les mots de passe correspondent",
            style: TextStyle(
              fontSize: 11,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      isActive: controller.currentStep >= 2,
    ),
  ];
}

/// Décoration commune des champs du parcours (strictement celle d'origine).
InputDecoration _inputStyle(String label, IconData icon, DashColors colors) {
  return InputDecoration(
    labelText: label,
    labelStyle: AppTextStyles.bodySecondary.copyWith(
      color: colors.textSecondary,
      fontSize: 14,
    ),
    prefixIcon: Icon(icon, color: colors.primary, size: 20),
    filled: true,
    fillColor: colors.card,
    contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: colors.border, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: colors.primary, width: 1.5),
    ),
  );
}
