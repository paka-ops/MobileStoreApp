import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/screens/EmployerFormPage.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors;

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
                        border: Border.all(color: colors.border),
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
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          "ma boutique autrement",
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 11.5,
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
                  color: colors.primarySoft,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.20),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.14),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 66,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 36),

              Text(
                "Bienvenue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Gérez votre stock, suivez vos ventes et\npilotez votre boutique en toute simplicité.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
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
              AppButton.primary(
                label: "Se connecter",
                icon: Icons.login_rounded,
                height: 54,
                onPressed: () => Navigator.pushNamed(context, "/login"),
              ),
              const SizedBox(height: 12),
              AppButton.secondary(
                label: "Créer un compte",
                icon: Icons.person_add_alt_rounded,
                height: 54,
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
