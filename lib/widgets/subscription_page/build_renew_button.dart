import 'package:flutter/material.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors, PremiumRadii;

//
// Bouton de renouvellement — CTA émeraude 60 px avec halo.
// Callback d'origine conservé (action à brancher côté métier).
//
class BuildRenewButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PremiumRadii.md),
          boxShadow: colors.glowShadow,
        ),
        child: ElevatedButton(
          onPressed: () {
            // Action de renouvellement
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumRadii.md)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.autorenew_rounded, size: 22),
              SizedBox(width: 10),
              Text("Renouveler l'abonnement",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
