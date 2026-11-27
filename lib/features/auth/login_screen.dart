import 'package:flutter/material.dart';

import 'package:mobile_store_app/features/auth/widgets/login_form.dart';
import 'package:mobile_store_app/features/auth/widgets/login_header.dart';

/// ============================================================================
/// LOGIN SCREEN — écran de connexion (route « /login »).
///
/// Structure identique à l'origine :
///   Scaffold → SafeArea → Center → SingleChildScrollView (padding 28 × 40)
///   → Column[en-tête de marque, gap 28, formulaire]
///
/// La logique vit dans [LoginController] (via `LoginForm`), la navigation et
/// les messages dans `LoginForm` : cet écran ne fait que composer.
/// ============================================================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                LoginHeader(),
                SizedBox(height: 28),

                // Formulaire
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
