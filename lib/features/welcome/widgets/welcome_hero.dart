import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/features/welcome/widgets/welcome_highlights_bar.dart';
import 'package:mobile_store_app/shared/widgets/buttons/primary_button.dart';

/// ============================================================================
/// WELCOME HERO — corps de l'accueil pré-login.
///
///   • Médaillon héro 148 px (halo dégradé violet → rose, trois cercles)
///   • « Bienvenue » + promesse en deux lignes
///   • Bandeau verre dépoli des avantages
///   • CTA dégradé « Se connecter » + CTA translucide « Créer un compte »
///
/// Anti-overflow : `LayoutBuilder` + `SingleChildScrollView` +
/// `ConstrainedBox(minHeight)` + `IntrinsicHeight` — structure et constantes
/// identiques à l'écran d'origine (Spacer 2×, gaps 32 / 10 / 24 / 24 / 12 / 12).
///
/// ⚠️ Présentation pure : les deux actions sont fournies par l'écran.
/// ============================================================================
class WelcomeHero extends StatelessWidget {
  /// Ouvre l'écran de connexion.
  final VoidCallback onLoginPressed;

  /// Ouvre le parcours de création de compte.
  final VoidCallback onSignupPressed;

  const WelcomeHero({
    super.key,
    required this.onLoginPressed,
    required this.onSignupPressed,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const Spacer(),

                  // Médaillon héro avec halo dégradé subtil
                  Container(
                    width: 148,
                    height: 148,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colors.primary.withValues(alpha: 0.25),
                          colors.accent.withValues(alpha: 0.18),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: colors.floatingShadow,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.card,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primarySoft,
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 56,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    "Bienvenue",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Gérez votre stock, suivez vos ventes et\npilotez votre boutique en toute simplicité.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bandeau valeur ajoutée épuré (verre dépoli, sans icônes)
                  const WelcomeHighlightsBar(),

                  const Spacer(),
                  const SizedBox(height: 24),

                  // Bouton principal dégradé violet → rose
                  PrimaryButton.gradient(
                    label: "Se connecter",
                    icon: Icons.login_rounded,
                    onPressed: onLoginPressed,
                  ),
                  const SizedBox(height: 12),

                  // Bouton secondaire translucide assorti au design lavande
                  AppButton.secondary(
                    label: "Créer un compte",
                    icon: Icons.person_add_alt_rounded,
                    height: AppSizes.primaryButtonHeight,
                    background: colors.card
                        .withValues(alpha: colors.isDark ? 0.65 : 0.85),
                    foreground: colors.primary,
                    borderColor: colors.primary.withValues(alpha: 0.28),
                    onPressed: onSignupPressed,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
