import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
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
  // EN-TÊTE — épuré (logo BouTiKa + sélecteur thème)
  // -------------------------------------------------------------------------
  Widget _buildHeader(DashColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "BouTiKa",
                  style:
                      AppTextStyles.brand.copyWith(color: colors.textPrimary),
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
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: () => appDarkMode.value = !isDark,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CORPS PRINCIPAL — héro centré, bandeau verre dépoli sans icônes,
  // boutons d'action premium (dégradé marque + pilule translucide)
  // -------------------------------------------------------------------------
  Widget _buildBody(DashColors colors) {
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
                  _buildPremiumHighlightsBar(colors),

                  const Spacer(),
                  const SizedBox(height: 24),

                  // Bouton principal dégradé violet → rose
                  PrimaryButton.gradient(
                    label: "Se connecter",
                    icon: Icons.login_rounded,
                    onPressed: () => Navigator.pushNamed(context, "/login"),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmployerFormPage()),
                      );
                    },
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

  Widget _buildPremiumHighlightsBar(DashColors colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: colors.card.withValues(alpha: colors.isDark ? 0.55 : 0.68),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: colors.isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.1,
            ),
            boxShadow: colors.softShadow,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              _highlightItem(colors, "Stock en temps réel", colors.primary),
              _dotSeparator(colors),
              _highlightItem(colors, "Ventes rapides", colors.accent),
              _dotSeparator(colors),
              _highlightItem(colors, "Analyses claires", colors.success),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlightItem(DashColors colors, String label, Color dotColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _dotSeparator(DashColors colors) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: colors.textTertiary,
        shape: BoxShape.circle,
      ),
    );
  }
}
