import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store_app/utils/app_colors.dart';

// =====================================================================
// MODÈLE FICTIF
// =====================================================================
class _StoreDashData {
  final String id;
  final String name;
  final String location;
  final double chiffreAffaires;
  final double benefice;
  final double depenses;
  final int nbCommandes;
  final double panierMoyen;
  final double tauxConversion;
  final List<double> weeklyRevenue;
  final List<double> weeklyExpense;
  final bool isActive;

  const _StoreDashData({
    required this.id,
    required this.name,
    required this.location,
    required this.chiffreAffaires,
    required this.benefice,
    required this.depenses,
    required this.nbCommandes,
    required this.panierMoyen,
    required this.tauxConversion,
    required this.weeklyRevenue,
    required this.weeklyExpense,
    this.isActive = true,
  });
}

// =====================================================================
// DASHBOARD SCREEN
// =====================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedPeriodIndex = 2;


  final List<String> _periods = ["Jour", "Semaine", "Mois", "Année"];
  final List<String> _weekDays = [
    "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"
  ];

  final List<_StoreDashData> _stores = const [
    _StoreDashData(
      id: "1",
      name: "Boutique Centre-Ville",
      location: "Rue 12, Douala",
      chiffreAffaires: 4850000,
      benefice: 1230000,
      depenses: 890000,
      nbCommandes: 342,
      panierMoyen: 14181,
      tauxConversion: 68.5,
      weeklyRevenue: [320000, 480000, 290000, 510000, 680000, 420000, 590000],
      weeklyExpense: [80000, 120000, 65000, 95000, 140000, 70000, 110000],
    ),
    _StoreDashData(
      id: "2",
      name: "Boutique Akwa",
      location: "Boulevard de la Liberté, Douala",
      chiffreAffaires: 3200000,
      benefice: 980000,
      depenses: 620000,
      nbCommandes: 218,
      panierMoyen: 14679,
      tauxConversion: 72.3,
      weeklyRevenue: [250000, 380000, 310000, 420000, 510000, 350000, 480000],
      weeklyExpense: [60000, 90000, 75000, 85000, 110000, 65000, 95000],
    ),
    _StoreDashData(
      id: "3",
      name: "Boutique Bonamoussadi",
      location: "Carrefour Ange Raphaël",
      chiffreAffaires: 1750000,
      benefice: 420000,
      depenses: 380000,
      nbCommandes: 126,
      panierMoyen: 13889,
      tauxConversion: 55.8,
      weeklyRevenue: [180000, 220000, 150000, 280000, 340000, 200000, 310000],
      weeklyExpense: [45000, 65000, 40000, 55000, 80000, 50000, 70000],
    ),
    _StoreDashData(
      id: "4",
      name: "Boutique Yaoundé",
      location: "Mvog-Mbi, Yaoundé",
      chiffreAffaires: 2100000,
      benefice: 650000,
      depenses: 510000,
      nbCommandes: 189,
      panierMoyen: 11111,
      tauxConversion: 61.2,
      weeklyRevenue: [200000, 310000, 260000, 350000, 410000, 280000, 390000],
      weeklyExpense: [55000, 80000, 60000, 70000, 100000, 55000, 85000],
    ),
  ];

  double get _totalCA => _stores.fold(0, (s, e) => s + e.chiffreAffaires);
  double get _totalBenefice => _stores.fold(0, (s, e) => s + e.benefice);
  double get _totalDepenses => _stores.fold(0, (s, e) => s + e.depenses);
  int get _totalCommandes => _stores.fold(0, (s, e) => s + e.nbCommandes);

  @override
  Widget build(BuildContext context) {
    // On wrap dans un Theme pour basculer light/dark
    return Theme(
      data: appDarkMode.value ? _buildDarkTheme() : _buildLightTheme(),
      child: Builder(builder: (context) {
        final c = DashColors(context);

        // Ajuster la status bar
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
          appDarkMode.value ? Brightness.light : Brightness.dark,
        ));

        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(c)),
                SliverToBoxAdapter(child: _buildPeriodSelector(c)),
                SliverToBoxAdapter(child: _buildGlobalKpiSection(c)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child:
                    _buildSectionTitle(c, "Performance globale", "7 jours"),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                    child: _buildGlobalBarChart(c),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: _buildSectionTitle(
                        c, "Classement boutiques", "Par CA"),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                    child: _buildRankingBar(c),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
                    child: _buildSectionTitle(
                        c, "Mes boutiques", "${_stores.length} actives"),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _StoreCard(
                          store: _stores[index],
                          rank: index + 1,
                          maxCA: _stores.first.chiffreAffaires,
                          weekDays: _weekDays,
                          colors: c,
                          onTap: () => _navigateToStore(_stores[index]),
                        ),
                      ),
                      childCount: _stores.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // =====================================================================
  // THEMES
  // =====================================================================
  ThemeData _buildLightTheme() {
    // Preserve the global application theme instead of replacing it locally.
    return Theme.of(context).copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
    );
  }

  ThemeData _buildDarkTheme() {
    // Preserve all global component themes (inputs, dialogs, buttons, etc.).
    return Theme.of(context).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkBorder,
      fontFamily: 'Inter',
    );
  }

  // =====================================================================
  // NAVIGATION
  // =====================================================================
  void _navigateToStore(_StoreDashData store) {
    final c = DashColors(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ouverture de ${store.name}..."),
        backgroundColor: c.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // =====================================================================
  // HEADER
  // =====================================================================
  Widget _buildHeader(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Icon(Icons.dashboard_rounded, color: c.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Vue d'ensemble de vos boutiques",
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // --- TOGGLE DARK MODE ---
          GestureDetector(
            onTap: () {
              appDarkMode.value = !appDarkMode.value;
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: appDarkMode.value ? AppColors.darkCardElevated : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Icon(
                appDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                size: 20,
                color: appDarkMode.value
                    ? AppColors.darkWarning
                    : AppColors.textGrey,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _headerIconButton(c, Icons.notifications_none_rounded, badge: 5),
        ],
      ),
    );
  }

  Widget _headerIconButton(DashColors c, IconData icon, {int badge = 0}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Icon(icon, size: 20, color: c.textPrimary),
        ),
        if (badge > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: c.danger,
                shape: BoxShape.circle,
              ),
              child: Text(
                "$badge",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }

  // =====================================================================
  // PERIOD SELECTOR
  // =====================================================================
  Widget _buildPeriodSelector(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: List.generate(_periods.length, (i) {
            final bool sel = _selectedPeriodIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriodIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? c.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    _periods[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: sel ? Colors.white : c.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // =====================================================================
  // KPI GLOBAUX
  // =====================================================================
  Widget _buildGlobalKpiSection(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: _GlobalKpiCard(
                icon: Icons.shopping_bag_rounded,
                label: "Commandes",
                value: "$_totalCommandes",
                trend: "+12%",
                trendUp: true,
                color: c.info,
                softColor: c.infoSoft,
                c: c,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlobalKpiCard(
                icon: Icons.show_chart_rounded,
                label: "Chiffre d'affaires",
                value: _fmt(_totalCA),
                trend: "+8.2%",
                trendUp: true,
                color: c.primary,
                softColor: c.primarySoft,
                c: c,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _GlobalKpiCard(
                icon: Icons.trending_up_rounded,
                label: "Bénéfice total",
                value: _fmt(_totalBenefice),
                trend: "+5.4%",
                trendUp: true,
                color: c.success,
                softColor: c.successSoft,
                c: c,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlobalKpiCard(
                icon: Icons.receipt_long_rounded,
                label: "Dépenses totales",
                value: _fmt(_totalDepenses),
                trend: "+2.1%",
                trendUp: false,
                color: c.danger,
                softColor: c.dangerSoft,
                c: c,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // =====================================================================
  // GRAPHE GLOBAL
  // =====================================================================
  Widget _buildGlobalBarChart(DashColors c) {
    List<double> totalRev = List.filled(7, 0);
    List<double> totalExp = List.filled(7, 0);
    for (final s in _stores) {
      for (int i = 0; i < 7; i++) {
        totalRev[i] += s.weeklyRevenue[i];
        totalExp[i] += s.weeklyExpense[i];
      }
    }
    final double maxVal = totalRev.reduce(max).clamp(1, double.infinity);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _legendDot(c, c.primary, "Revenus"),
            const SizedBox(width: 16),
            _legendDot(c, c.danger, "Dépenses"),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final rH = (totalRev[i] / maxVal) * 120;
                final eH = (totalExp[i] / maxVal) * 120;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _bar(rH, c.primary, c.primarySoft),
                            const SizedBox(width: 3),
                            _bar(eH, c.danger, c.dangerSoft),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_weekDays[i],
                            style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double height, Color color, Color softColor) {
    return Container(
      width: 12,
      height: height.clamp(4, 120),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 12,
          height: (height * 0.7).clamp(4, 120),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _legendDot(DashColors c, Color color, String l) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(l,
          style: TextStyle(
              color: c.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    ],
  );

  // =====================================================================
  // CLASSEMENT
  // =====================================================================
  Widget _buildRankingBar(DashColors c) {
    final sorted = List<_StoreDashData>.from(_stores)
      ..sort((a, b) => b.chiffreAffaires.compareTo(a.chiffreAffaires));
    final double maxCA = sorted.first.chiffreAffaires;

    final List<Color> rankColors = [
      c.primary,
      c.info,
      c.accent,
      c.success,
      c.warning,
      c.danger,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final ratio = s.chiffreAffaires / maxCA;
          final color = rankColors[i % rankColors.length];

          return Padding(
            padding: EdgeInsets.only(bottom: i < sorted.length - 1 ? 16 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text("#${i + 1}",
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(s.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5)),
                    ),
                    Text(_fmt(s.chiffreAffaires),
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // =====================================================================
  // HELPERS
  // =====================================================================
  Widget _buildSectionTitle(DashColors c, String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(sub,
              style: TextStyle(
                  color: c.primary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  String _fmt(double amount) {
    if (amount >= 1000000) return "${(amount / 1000000).toStringAsFixed(1)}M";
    if (amount >= 1000) return "${(amount / 1000).toStringAsFixed(0)}K";
    return "${amount.toStringAsFixed(0)}";
  }
}

// =====================================================================
// GLOBAL KPI CARD
// =====================================================================
class _GlobalKpiCard extends StatelessWidget {
  final IconData icon;
  final String label, value, trend;
  final bool trendUp;
  final Color color, softColor;
  final DashColors c;

  const _GlobalKpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.color,
    required this.softColor,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: softColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: trendUp ? c.successSoft : c.dangerSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                    trendUp
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 12,
                    color: trendUp ? c.success : c.danger),
                const SizedBox(width: 2),
                Text(trend,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: trendUp ? c.success : c.danger)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          Text(value,
              style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: c.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5)),
        ],
      ),
    );
  }
}

// =====================================================================
// STORE CARD
// =====================================================================
class _StoreCard extends StatelessWidget {
  final _StoreDashData store;
  final int rank;
  final double maxCA;
  final List<String> weekDays;
  final DashColors colors;
  final VoidCallback onTap;

  const _StoreCard({
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
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
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
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2)),
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
                style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600)),
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
                        color: c.primary.withOpacity(0.2 + (h / 40) * 0.8),
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
            style: TextStyle(
                color: c.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600),
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