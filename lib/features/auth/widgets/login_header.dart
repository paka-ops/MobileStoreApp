import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';

/// ============================================================================
/// LOGIN HEADER — bloc de marque de l'écran de connexion.
///
///   • Pastille 64 px (fond violet très pâle, ombre douce) + icône storefront 28
///   • `AppBrandMark` (logo BouTiKa)
///   • « Connexion » (22 / w700)
///   • Consigne en une ligne (13 / regular, hauteur interligne 1.5)
///
/// Gaps identiques à l'origine : 18 px puis 34 px puis 8 px.
/// ============================================================================
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Marque
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.primarySoft,
            shape: BoxShape.circle,
            boxShadow: colors.cardShadow,
          ),
          child: Icon(
            Icons.storefront_rounded,
            color: colors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 18),
        const AppBrandMark(),
        const SizedBox(height: 34),

        // Titres
        Text(
          "Connexion",
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          "Entrez vos identifiants pour accéder à votre boutique",
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
