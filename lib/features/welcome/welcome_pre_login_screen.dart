import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/features/auth/signup_screen.dart';
import 'package:mobile_store_app/features/welcome/widgets/welcome_hero.dart';
import 'package:mobile_store_app/shared/widgets/layout/app_brand_header.dart';

/// ============================================================================
/// WELCOME PRE LOGIN SCREEN — accueil avant connexion (route « / »).
///
/// Structure identique à l'écran d'origine :
///   Scaffold transparent → SafeArea → Column[en-tête de marque, hero étendu]
///
/// Le fond dégradé lavande provient de `AppBackground` (branché sur
/// `MaterialApp.builder` dans `main.dart`), comme auparavant.
///
/// Comportements conservés :
///   • bascule thème clair / sombre depuis l'en-tête
///   • « Se connecter » → `Navigator.pushNamed(context, "/login")`
///   • « Créer un compte » → `EmployerFormPage` en `MaterialPageRoute`
/// ============================================================================
class WelcomePreLoginScreen extends StatelessWidget {
  const WelcomePreLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const AppBrandHeader(subtitle: "ma boutique autrement"),
                Expanded(
                  child: WelcomeHero(
                    onLoginPressed: () =>
                        Navigator.pushNamed(context, "/login"),
                    onSignupPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployerFormPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
