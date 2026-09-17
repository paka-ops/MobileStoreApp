import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors;

class SubscriptionContactButton extends StatelessWidget {
  const SubscriptionContactButton({super.key});

  void _showContactDialog(BuildContext context) {
    final c = DashColors(context);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
                child: Icon(Icons.support_agent_rounded,
                    color: c.primary, size: 28),
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
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: "Contacter le support",
      icon: Icons.support_agent_rounded,
      onPressed: () => _showContactDialog(context),
    );
  }
}
