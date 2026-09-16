import 'package:flutter/material.dart';

// =====================================================================
// NOTIFICATIONS — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// SIGNATURES INCHANGÉES : `showErrorMessage`, `showSuccessMessage`,
// `showExceptionMessage`, `showSubscriptionExpiredMessage` gardent les
// mêmes paramètres et comportements. Seule la présentation change
// (coins 14, pastille d'icône, teintes feutrées anti-fatigue).
// =====================================================================
void showModernSnackBar({
  required BuildContext context,
  required String message,
  required Color color,
  required IconData icon,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void showErrorMessage(String message, BuildContext context) {
  showModernSnackBar(
    context: context,
    message: message,
    color: const Color(0xFFD95C5C), // rouge doux
    icon: Icons.error_outline_rounded,
  );
}

void showSuccessMessage(String message, BuildContext context) {
  showModernSnackBar(
    context: context,
    message: message,
    color: const Color(0xFF0E9F6E), // émeraude marque
    icon: Icons.check_circle_outline_rounded,
  );
}

void showExceptionMessage(BuildContext context) {
  showModernSnackBar(
    context: context,
    message:
        "Impossible de contacter le serveur. Vérifiez votre connexion Internet ou réessayez plus tard.",
    color: const Color(0xFFC2703D), // terracotta warning
    icon: Icons.wifi_off_rounded,
  );
}

void showSubscriptionExpiredMessage(BuildContext context) {
  showModernSnackBar(
    context: context,
    message:
        "Abonnement expiré . Veuillez renouveler votre abonnement pour continuer.",
    color: const Color(0xFFD95C5C), // rouge doux « Destructive »
    icon: Icons.lock_clock_outlined, // Icône de verrouillage temporel
  );
}
