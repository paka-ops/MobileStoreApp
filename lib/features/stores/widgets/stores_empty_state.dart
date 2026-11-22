import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/shared/widgets/buttons/primary_button.dart';

/// ============================================================================
/// STORES EMPTY STATE — aucune boutique rattachée.
///
///   • pastille 148 px `primarySoft` + icône storefront 60
///   • « Aucune boutique trouvée » (18 / w700) à 34 px
///   • texte contextuel (employeur / employé) à 10 px, interligne 1.55
///   • CTA « Créer une boutique » (largeur naturelle) pour l'employeur, à 28 px
///
/// Mise en page : `Center` + padding horizontal 24, colonne centrée
/// verticalement — comme l'original.
/// ============================================================================
class StoresEmptyState extends StatelessWidget {
  /// Type d'utilisateur connecté (`employer` ou autre).
  final String userType;

  /// Ouvre le dialogue de création (bouton et conditions employeur).
  final VoidCallback onCreateStore;

  const StoresEmptyState({
    super.key,
    required this.userType,
    required this.onCreateStore,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              "Aucune boutique trouvée",
              style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              userType == "employer"
                  ? "Créez votre première boutique pour commencer"
                      " à piloter votre stock en temps réel."
                  : "Vous n'êtes rattaché à aucune boutique pour le moment.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: colors.textSecondary,
                height: 1.55,
              ),
            ),
            if (userType == "employer") ...[
              const SizedBox(height: 28),
              PrimaryButton(
                label: "Créer une boutique",
                icon: Icons.add_rounded,
                expand: false,
                onPressed: onCreateStore,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
