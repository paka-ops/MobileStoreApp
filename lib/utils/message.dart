
import 'dart:ui';

import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
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
    color: const Color(0xFFEF4444), // rouge soft
    icon: Icons.error_outline,
  );
}
void showSuccessMessage(String message, BuildContext context) {
  showModernSnackBar(
    context: context,
    message: message,
    color: const Color(0xFF10B981), // vert fintech
    icon: Icons.check_circle_outline,
  );
}

void showExceptionMessage(BuildContext context) {
  showModernSnackBar(
    context: context,
    message:
    "Impossible de contacter le serveur. Vérifiez votre connexion Internet ou réessayez plus tard.",
    color: const Color(0xFFF59E0B), // orange warning
    icon: Icons.wifi_off,
  );
}
void showSubscriptionExpiredMessage(BuildContext context) {
  showModernSnackBar(
    context: context,
    message: "Abonnement expiré . Veuillez renouveler votre abonnement pour continuer.",
    color: const Color(0xFFEF4444), // Rouge "Destructive" moderne
    icon: Icons.lock_clock_outlined, // Icône de verrouillage temporel
  );
}