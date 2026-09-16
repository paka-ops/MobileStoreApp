import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/EmployerFormPage.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors, PremiumGap, PremiumRadii;
import 'package:mobile_store_app/widgets/premium_kit.dart';

// =====================================================================
// ACCUEIL PRÉ-CONNEXION — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : bascule de thème et navigations ("/login",
// `EmployerFormPage`) strictement identiques. Seule la présentation
// change (halo apaisant, carte de proposition de valeur, CTA 54 px).
// =====================================================================
class WelcomePreLoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePreLoginScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // --- EN-TÊTE : Logo et slogan (+ bascule de thème) ---
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: colors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(PremiumRadii.sm),
                        boxShadow: colors.glowShadow,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(PremiumRadii.sm),
                        child: Image.asset(
                          'assets/images/boutika.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BouTiKa',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'ma boutique autrement',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ValueListenableBuilder<bool>(
                      valueListenable: appDarkMode,
                      builder: (context, isDark, _) => Container(
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(
                            PremiumRadii.sm,
                          ),
                          border: Border.all(
                            color: colors.border,
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          tooltip: isDark
                              ? 'Activer le thème clair'
                              : 'Activer le thème sombre',
                          onPressed: () => appDarkMode.value = !isDark,
                          icon: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            color: colors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- ZONE CENTRALE : médaillon + proposition de valeur ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 208,
                    height: 208,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.primary.withOpacity(0.14),
                          colors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      color: colors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border, width: 1),
                      boxShadow: colors.cardShadow,
                    ),
                    child: Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: colors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 46,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'Bienvenue',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Gérez votre stock, suivez vos ventes et\npilotez votre boutique en toute simplicité.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // Puces de réassurance (présentation uniquement).
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PremiumBadge(
                    label: 'Stock',
                    icon: Icons.inventory_2_outlined,
                    color: colors.primary,
                    softColor: colors.primarySoft,
                  ),
                  PremiumGap.smW,
                  PremiumBadge(
                    label: 'Ventes',
                    icon: Icons.receipt_long_outlined,
                    color: colors.info,
                    softColor: colors.infoSoft,
                  ),
                  PremiumGap.smW,
                  PremiumBadge(
                    label: 'Équipe',
                    icon: Icons.groups_outlined,
                    color: colors.accent,
                    softColor: colors.accentSoft,
                  ),
                ],
              ),

              const Spacer(),

              // --- ZONE D'ACTION : boutons 54 px en bas (ergonomie) ---
              PremiumPrimaryButton(
                label: 'Se connecter',
                icon: Icons.login_rounded,
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
              const SizedBox(height: 12),
              PremiumSecondaryButton(
                label: 'Créer un compte',
                icon: Icons.person_add_alt_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmployerFormPage()),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
