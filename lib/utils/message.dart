import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';

// ============================================================================
// MESSAGES — snackbars premium (API inchangée).
//
// Les fonctions publiques conservent exactement les mêmes signatures :
//   showErrorMessage(message, context)
//   showSuccessMessage(message, context)
//   showExceptionMessage(context)
//   showSubscriptionExpiredMessage(context)
// ============================================================================

/// Couleurs des messages (fixes, indépendantes du thème).
class _MessageColors {
  static const Color error = Color(0xFFDE4A52);
  static const Color success = Color(0xFF2F9E68);
  static const Color warning = Color(0xFFDE911D);
}

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
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                height: 1.35,
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
    color: _MessageColors.error,
    icon: Icons.error_outline,
  );
}

void showSuccessMessage(String message, BuildContext context) {
  showModernSnackBar(
    context: context,
    message: message,
    color: _MessageColors.success,
    icon: Icons.check_circle_outline,
  );
}

void showExceptionMessage(BuildContext context) {
  showModernSnackBar(
    context: context,
    message:
        "Impossible de contacter le serveur. Vérifiez votre connexion Internet ou réessayez plus tard.",
    color: _MessageColors.warning,
    icon: Icons.wifi_off,
  );
}

void showSubscriptionExpiredMessage(BuildContext context) {
  showModernSnackBar(
    context: context,
    message: "Abonnement expiré . Veuillez renouveler votre abonnement pour continuer.",
    color: _MessageColors.error,
    icon: Icons.lock_clock_outlined,
  );
}
