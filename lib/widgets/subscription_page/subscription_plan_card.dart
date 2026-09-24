import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/models/subscription.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors;

class SubscriptionPlanCard extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionPlanCard({super.key, required this.subscription});

  Color _statusColor(DashColors c) {
    final bool isExpired =
        subscription.expirationDate!.isBefore(DateTime.now());
    return isExpired ? c.danger : c.success;
  }

  Color _statusSoftColor(DashColors c) {
    final bool isExpired =
        subscription.expirationDate!.isBefore(DateTime.now());
    return isExpired ? c.dangerSoft : c.successSoft;
  }

  String _statusLabel() {
    final bool isExpired =
        subscription.expirationDate!.isBefore(DateTime.now());
    return isExpired ? "Expiré" : "Actif";
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final int daysLeft = subscription.expirationDate!
        .difference(DateTime.now())
        .inDays;
    final Color statusColor = _statusColor(c);

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
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: c.primary.withValues(alpha: 0.2)),
                  ),
                  child: Icon(Icons.workspace_premium_rounded,
                      color: c.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OverlineLabel(text: "Formule actuelle"),
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
                  label: _statusLabel(),
                  color: statusColor,
                  softColor: _statusSoftColor(c),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildRow(
                  c,
                  icon: Icons.calendar_month_rounded,
                  color: c.info,
                  softColor: c.infoSoft,
                  label: "Date de début",
                  value: DateFormat('dd/MM/yyyy')
                      .format(subscription.startDate!),
                ),
                _buildRow(
                  c,
                  icon: Icons.event_busy_rounded,
                  color: c.warning,
                  softColor: c.warningSoft,
                  label: "Date d'expiration",
                  value: DateFormat('dd/MM/yyyy')
                      .format(subscription.expirationDate!),
                ),
                _buildRow(
                  c,
                  icon: Icons.timelapse_rounded,
                  color: c.primary,
                  softColor: c.primarySoft,
                  label: "Durée",
                  value: "${subscription.duration} jours",
                ),
                _buildRow(
                  c,
                  icon: daysLeft > 0
                      ? Icons.hourglass_bottom_rounded
                      : Icons.block_rounded,
                  color: statusColor,
                  softColor: _statusSoftColor(c),
                  label: daysLeft > 0
                      ? "Temps restant"
                      : "Statut",
                  value: daysLeft > 0
                      ? "$daysLeft jours"
                      : "À renouveler",
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    DashColors c, {
    required IconData icon,
    required Color color,
    required Color softColor,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
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
