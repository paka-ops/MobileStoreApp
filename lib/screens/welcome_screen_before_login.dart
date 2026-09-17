import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/screens/EmployerFormPage.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors;
import 'package:mobile_store_app/widgets/design_system.dart';

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
              // --- EN-TÊTE : Logo et bouton thème ---
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colors.card,
                        shape: BoxShape.circle,
                        boxShadow: colors.cardShadow,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/boutika.png',
                          height: 38,
                          width: 38,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "BouTiKa",
                          style: AppTextStyles.greeting.copyWith(
                            color: colors.primary,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          "ma boutique autrement",
                          style: AppTextStyles.label.copyWith(
                            color: colors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ValueListenableBuilder<bool>(
                      valueListenable: appDarkMode,
                      builder: (context, isDark, _) => AppIconButton(
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        iconColor: colors.primary,
                        tooltip: isDark
                            ? 'Activer le thème clair'
                            : 'Activer le thème sombre',
                        onTap: () => appDarkMode.value = !isDark,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- ZONE CENTRALE : illustration + promesse ---
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: colors.accentGradient,
                  boxShadow: [
                    BoxShadow(
                      color: colors.gradientColors.first
                          .withValues(alpha: 0.30),
                      blurRadius: 34,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 66,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 36),

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

              // --- Points clés ---
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  SoftChip(
                    icon: Icons.inventory_2_rounded,
                    label: "Stock en temps réel",
                    color: colors.primary,
                    softColor: colors.primarySoft,
                  ),
                  SoftChip(
                    icon: Icons.point_of_sale_rounded,
                    label: "Ventes rapides",
                    color: colors.success,
                    softColor: colors.successSoft,
                  ),
                  SoftChip(
                    icon: Icons.insights_rounded,
                    label: "Analyses claires",
                    color: colors.accent,
                    softColor: colors.accentSoft,
                  ),
                ],
              ),

              const Spacer(),

              // --- ZONE D'ACTION : boutons en bas pour l'ergonomie ---
              PrimaryButton(
                label: "Se connecter",
                icon: Icons.login_rounded,
                onPressed: () => Navigator.pushNamed(context, "/login"),
              ),
              const SizedBox(height: 12),
              PrimaryButton.outline(
                label: "Créer un compte",
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
