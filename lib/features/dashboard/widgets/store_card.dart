/// ============================================================================
/// STORE CARD — carte de boutique du tableau de bord (classement par CA).
///
/// Reprise à l'identique de la classe privée `_StoreCard` : rang, jauge de CA,
/// mini-graphe hebdomadaire et indicateurs.
/// ============================================================================
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/features/dashboard/models/store_dash_data.dart';

class StoreCard extends StatelessWidget {
  final StoreDashData store;
  final int rank;
  final double maxCA;
  final List<String> weekDays;
  final DashColors colors;
  final VoidCallback onTap;

  const StoreCard({
    super.key,
    required this.store,
    required this.rank,
    required this.maxCA,
    required this.weekDays,
    required this.colors,
    required this.onTap,
  });

  String _fmt(double a) {
    if (a >= 1000000) return "${(a / 1000000).toStringAsFixed(1)}M";
    if (a >= 1000) return "${(a / 1000).toStringAsFixed(0)}K";
    return "${a.toStringAsFixed(0)}";
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final double maxRev =
    store.weeklyRevenue.reduce(max).clamp(1, double.infinity);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: c.border, width: 1),
            boxShadow: c.cardShadow,
          ),
          child: Column(
            children: [
              _buildHeader(c),
              _buildKpiGrid(c),
              _buildMiniChartHeader(c),
              _buildMiniChart(c, maxRev),
              _buildFooter(c),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DashColors c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: c.border),
            ),
            child: Center(
              child: Text(
                "#$rank",
                style: TextStyle(
                  color: rank <= 3 ? c.primary : c.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 12, color: c.textSecondary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        store.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(color: c.textSecondary, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: store.isActive ? c.successSoft : c.dangerSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: store.isActive ? c.success : c.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  store.isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    color: store.isActive ? c.success : c.danger,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
      child: Column(
        children: [
          Row(children: [
            Expanded(
                child: _miniKpi(c, Icons.shopping_bag_outlined, "Commandes",
                    "${store.nbCommandes}", c.info, c.infoSoft)),
            const SizedBox(width: 8),
            Expanded(
                child: _miniKpi(c, Icons.show_chart_rounded, "Chiffre d'aff.",
                    _fmt(store.chiffreAffaires), c.primary, c.primarySoft)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _miniKpi(c, Icons.trending_up_rounded, "Bénéfice",
                    _fmt(store.benefice), c.success, c.successSoft)),
            const SizedBox(width: 8),
            Expanded(
                child: _miniKpi(c, Icons.receipt_long_rounded, "Dépenses",
                    _fmt(store.depenses), c.danger, c.dangerSoft)),
          ]),
        ],
      ),
    );
  }

  Widget _miniKpi(DashColors c, IconData icon, String label, String value,
      Color color, Color soft) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
                const SizedBox(height: 1),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChartHeader(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text("Revenus 7 derniers jours",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(color: c.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.accentSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 11, color: c.accent),
                const SizedBox(width: 4),
                Text("Panier: ${_fmt(store.panierMoyen)}",
                    style: TextStyle(
                        color: c.accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart(DashColors c, double maxRev) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: SizedBox(
        height: 58,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final h = (store.weeklyRevenue[i] / maxRev) * 40;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      height: h.clamp(4, 40),
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.2 + (h / 40) * 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(weekDays[i],
                        style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFooter(DashColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.cardElevated,
        borderRadius:
        const BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Row(
        children: [
          Icon(Icons.pie_chart_outline_rounded,
              size: 13, color: c.textSecondary),
          const SizedBox(width: 5),
          Text(
            "Conversion: ${store.tauxConversion.toStringAsFixed(1)}%",
            style: AppTextStyles.label.copyWith(color: c.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text("Voir détails",
              style: TextStyle(
                  color: c.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, size: 14, color: c.primary),
        ],
      ),
    );
  }
}
