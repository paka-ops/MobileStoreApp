import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/features/reports/controllers/general_report_calculator.dart';
import 'package:mobile_store_app/features/reports/widgets/report_chart_placeholder.dart';
import 'package:mobile_store_app/features/reports/widgets/report_kpi_card.dart';
import 'package:mobile_store_app/features/reports/widgets/report_section_title.dart';
import 'package:mobile_store_app/models/order.dart';

/// ============================================================================
/// GENERAL REPORT SCREEN — rapport général (CA, commandes, panier, bénéfices).
///
/// Structure identique à l'écran d'origine :
///   AppBar transparente centrée → SafeArea → SingleChildScrollView (padding 20)
///   → [Vue d'ensemble : 2 × 2 tuiles KPI] → [Performance hebdomadaire]
///
/// Les calculs vivent dans [GeneralReportCalculator] : aucune agrégation n'est
/// effectuée dans `build()`. La tuile « Bénéfices » reste réservée à
/// l'employeur (`userType == "employer"`), comme avant.
/// ============================================================================
class GeneralReportScreen extends StatelessWidget {
  final String storeId;
  final List<Order> orders;
  final String userType;

  const GeneralReportScreen({
    super.key,
    required this.storeId,
    required this.userType,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);
    final GeneralReportMetrics metrics =
        GeneralReportCalculator.compute(orders);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rapport Général",
          style: AppTextStyles.heading.copyWith(
            fontSize: 17,
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionTitle("Vue d'ensemble"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ReportKpiCard(
                      label: "Ventes Totales",
                      value: "${metrics.sales} CFA",
                      icon: Icons.payments_rounded,
                      color: colors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportKpiCard(
                      label: "Ordres Totaux",
                      value: "${metrics.totalOrder}",
                      icon: Icons.shopping_bag_rounded,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportKpiCard(
                      label: "Panier Moyen",
                      value: "${metrics.panierMoyen.toStringAsFixed(2)} F",
                      icon: Icons.trending_up_rounded,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (userType == "employer")
                    Expanded(
                      child: ReportKpiCard(
                        label: "Bénéfices",
                        value: "${metrics.revenue} CFA",
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.accentPurple,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const ReportSectionTitle("Performance Hebdomadaire"),
              const SizedBox(height: 16),
              const ReportChartPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}
