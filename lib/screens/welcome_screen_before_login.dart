import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/screens/EmployerFormPage.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors;
import 'package:mobile_store_app/widgets/design_system.dart';

class WelcomePreLoginScreen extends StatefulWidget {
  const WelcomePreLoginScreen({super.key});

  @override
  State<WelcomePreLoginScreen> createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePreLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        final colors = DashColors(context);

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(colors),
                Expanded(
                  child: _buildBody(colors),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // EN-TÊTE — identique à WelcomeScreen (logo + chips horizontaux)
  // -------------------------------------------------------------------------
  Widget _buildHeader(DashColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "BouTiKa",
                      style: AppTextStyles.brand
                          .copyWith(color: colors.textPrimary),
                    ),
                    Text(
                      "ma boutique autrement",
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        color: colors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: appDarkMode,
                builder: (context, isDark, _) => IconButton(
                  tooltip: isDark
                      ? 'Activer le thème clair'
                      : 'Activer le thème sombre',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 40, minHeight: 40),
                  onPressed: () => appDarkMode.value = !isDark,
                  icon: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Chips d'info — ScrollView horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHeaderStatChip(
                  colors,
                  icon: Icons.inventory_2_rounded,
                  label: "Stock",
                  sub: "En temps réel",
                ),
                const SizedBox(width: 8),
                _buildHeaderStatChip(
                  colors,
                  icon: Icons.point_of_sale_rounded,
                  label: "Ventes",
                  sub: "Rapides",
                ),
                const SizedBox(width: 8),
                _buildHeaderStatChip(
                  colors,
                  icon: Icons.insights_rounded,
                  label: "Analyses",
                  sub: "Claires",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CHIP D'EN-TÊTE — style identique à WelcomeScreen
  // -------------------------------------------------------------------------
  Widget _buildHeaderStatChip(
    DashColors colors, {
    required IconData icon,
    required String label,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colors.primary, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1.1,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CORPS PRINCIPAL — même design centré que l'empty state de WelcomeScreen
  // avec les boutons de redirection pré-login conservés
  // -------------------------------------------------------------------------
  Widget _buildBody(DashColors colors) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primarySoft,
                      boxShadow: colors.cardShadow,
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 60,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 34),
                  Text(
                    "Bienvenue",
                    textAlign: TextAlign.center,
                    style:
                        AppTextStyles.h3.copyWith(color: colors.textPrimary),
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
                  const SizedBox(height: 28),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
