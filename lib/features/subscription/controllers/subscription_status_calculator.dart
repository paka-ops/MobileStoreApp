import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/shared/models/subscription.dart';

/// ============================================================================
/// SUBSCRIPTION STATUS — état dérivé d'un abonnement.
///
///   • [isExpired]     : date d'expiration antérieure à maintenant
///   • [daysLeft]      : différence en jours (peut être négative)
///   • [label]         : « Expiré » / « Actif »
///   • [hasTimeLeft]   : `daysLeft > 0` (choix d'icône et de libellé)
///
/// Les couleurs sont exposées sous forme de méthodes car elles dépendent du
/// thème courant : `danger`/`dangerSoft` si expiré, `success`/`successSoft`
/// sinon — exactement les mêmes jetons que l'original.
/// ============================================================================
class SubscriptionStatus {
  final bool isExpired;
  final int daysLeft;

  const SubscriptionStatus({required this.isExpired, required this.daysLeft});

  /// Libellé de la pastille d'état.
  String get label => isExpired ? "Expiré" : "Actif";

  /// `true` s'il reste au moins un jour.
  bool get hasTimeLeft => daysLeft > 0;

  /// Couleur pleine de l'état.
  Color color(DashColors colors) => isExpired ? colors.danger : colors.success;

  /// Couleur de fond de l'état.
  Color softColor(DashColors colors) =>
      isExpired ? colors.dangerSoft : colors.successSoft;
}

/// ============================================================================
/// SUBSCRIPTION STATUS CALCULATOR — dérivation pure de l'état d'abonnement.
///
/// `expirationDate` est non nulle dans les abonnements affichés (l'écran
/// d'origine utilisait `expirationDate!` sans garde) : le même accès est
/// conservé.
/// ============================================================================
class SubscriptionStatusCalculator {
  SubscriptionStatusCalculator._();

  static SubscriptionStatus of(Subscription subscription) {
    final DateTime now = DateTime.now();

    return SubscriptionStatus(
      isExpired: subscription.expirationDate!.isBefore(now),
      daysLeft: subscription.expirationDate!.difference(now).inDays,
    );
  }
}
