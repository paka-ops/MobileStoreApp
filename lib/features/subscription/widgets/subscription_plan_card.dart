import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/features/subscription/controllers/subscription_status_calculator.dart';
import 'package:mobile_store_app/shared/models/subscription.dart';

/// ============================================================================
/// SUBSCRIPTION PLAN CARD — carte détaillée de l'abonnement.
///
///   • bandeau dégradé violet → rose (10 % / 6 %), rayon supérieur 19
///   • pastille 12 px `primarySoft` bordée + icône premium 26
///   • « Formule actuelle » + « Plan … » (17 / w800) + pastille d'état
///   • quatre lignes d'information (début, expiration, durée, temps restant)
///     avec pastille d'icône 8 px et valeur 13.5 / w800
///
/// L'état (expiré / jours restants / libellé / couleurs / icône) est dérivé par
/// [SubscriptionStatusCalculator] : plus aucun calcul de date dans le widget.
/// ============================================================================
class SubscriptionPlanCard extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionPlanCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final SubscriptionStatus status =
        SubscriptionStatusCalculator.of(subscription);
    final Color statusColor = status.color(c);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: c.border),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        children: [
          // Bandeau plan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.primary.withValues(alpha: 0.10),
                  c.accent.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl - 1),
                topRight: Radius.circular(AppRadius.xl - 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: c.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: c.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OverlineLabel(text: "Formule actuelle"),
                      const SizedBox(height: 3),
                      Text(
                        "Plan ${subscription.plan}",
                        style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(
                  label: status.label,
                  color: statusColor,
                  softColor: status.softColor(c),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _SubscriptionInfoRow(
                  icon: Icons.calendar_month_rounded,
                  color: c.info,
                  softColor: c.infoSoft,
                  label: "Date de début",
                  value:
                      DateFormat('dd/MM/yyyy').format(subscription.startDate!),
                ),
                _SubscriptionInfoRow(
                  icon: Icons.event_busy_rounded,
                  color: c.warning,
                  softColor: c.warningSoft,
                  label: "Date d'expiration",
                  value: DateFormat('dd/MM/yyyy')
                      .format(subscription.expirationDate!),
                ),
                _SubscriptionInfoRow(
                  icon: Icons.timelapse_rounded,
                  color: c.primary,
                  softColor: c.primarySoft,
                  label: "Durée",
                  value: "${subscription.duration} jours",
                ),
                _SubscriptionInfoRow(
                  icon: status.hasTimeLeft
                      ? Icons.hourglass_bottom_rounded
                      : Icons.block_rounded,
                  color: statusColor,
                  softColor: status.softColor(c),
                  label: status.hasTimeLeft ? "Temps restant" : "Statut",
                  value: status.hasTimeLeft
                      ? "${status.daysLeft} jours"
                      : "À renouveler",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne d'information de la carte (icône 16 dans une pastille 8 px).
class _SubscriptionInfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color softColor;
  final String label;
  final String value;

  const _SubscriptionInfoRow({
    required this.icon,
    required this.color,
    required this.softColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(
              color: c.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
