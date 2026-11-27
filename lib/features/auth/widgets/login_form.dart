import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/features/auth/controllers/login_controller.dart';
import 'package:mobile_store_app/features/stores/stores_screen.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/shared/widgets/buttons/primary_button.dart';

/// ============================================================================
/// LOGIN FORM — formulaire de connexion (identifiant + mot de passe).
///
/// Composition et géométrie identiques à l'écran d'origine :
///   AppTextField (identifiant) · gap 14 · AppTextField (mot de passe, œil)
///   · gap 28 · PrimaryButton « Se connecter » (hauteur pilule 52)
///
/// Comportements conservés :
///   • champs et bouton désactivés pendant l'appel (`isLoading`)
///   • bascule d'affichage du mot de passe
///   • succès → `Navigator.pushReplacement` vers la liste des boutiques
///     (`WelcomeScreen(stores, userType)`)
///   • refus → message « Identifiants incorrects »
/// ============================================================================
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final LoginController _controller = LoginController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final LoginResult? result = await _controller.submit(context);

    // Écran démonté pendant l'appel.
    if (!mounted) return;

    // Tentative ignorée (une connexion était déjà en cours).
    if (result == null) return;

    if (result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(
            stores: result.stores,
            userType: result.userType,
          ),
        ),
      );
    } else {
      showErrorMessage("Identifiants incorrects", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final DashColors colors = DashColors(context);

        return Form(
          key: _controller.formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _controller.usernameController,
                enabled: !_controller.isLoading,
                label: "Nom d'utilisateur",
                hint: "Ex: jean.dupont",
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _controller.passwordController,
                enabled: !_controller.isLoading,
                obscure: _controller.isObscured,
                label: "Mot de passe",
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _controller.isObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                  onPressed: _controller.toggleObscured,
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: "Se connecter",
                icon: Icons.login_rounded,
                isLoading: _controller.isLoading,
                onPressed: _handleLogin,
              ),
            ],
          ),
        );
      },
    );
  }
}
