import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';

/// Ouvre le dialogue « Contacter le support ».
///
/// Le contenu est statique (numéro de téléphone) : aucun appel réseau, aucune
/// logique métier. Le rendu reprend exactement les constantes de l'original
/// (Dialog rayon 20 bordé, padding 24, pastille 14, gaps 16/8/16/20).
void showSubscriptionContactDialog(BuildContext context) {
  final DashColors c = DashColors(context);

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: c.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Contacter le support",
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Appelez-nous au numéro ci-dessous pour renouveler ou gérer votre abonnement.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                color: c.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            InfoCallout(
              icon: Icons.phone_rounded,
              text: '+228 99691176',
              color: c.primary,
              softColor: c.primarySoft,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                label: "J'ai compris",
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// ============================================================================
/// SUBSCRIPTION CONTACT BUTTON — CTA « Contacter le support ».
///
/// Bouton primaire pleine largeur (hauteur par défaut du design system,
/// icône casque) qui ouvre le dialogue de contact.
/// ============================================================================
class SubscriptionContactButton extends StatelessWidget {
  const SubscriptionContactButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: "Contacter le support",
      icon: Icons.support_agent_rounded,
      onPressed: () => showSubscriptionContactDialog(context),
    );
  }
}
