import 'package:flutter/material.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors;

class SubscriptionHeader extends StatelessWidget {
  const SubscriptionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.verified_rounded,
                  color: c.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Abonnement",
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Consultez l'état de votre abonnement et contactez le support pour le renouveler.",
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
