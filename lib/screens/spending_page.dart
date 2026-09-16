import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/service/spending_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors, PremiumRadii;
import 'package:mobile_store_app/widgets/boutika_loader.dart';
import 'package:mobile_store_app/widgets/premium_kit.dart';

// =====================================================================
// HISTORIQUE DES DÉPENSES — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : chargement, tri, filtres par période, mapping des
// cartes — tout est conservé. Seule la présentation change (résumé,
// filtres, cartes terracotta feutrées, état vide premium).
// =====================================================================
class ExpensesScreen extends StatefulWidget {
  final String storeId;
  const ExpensesScreen({super.key, required this.storeId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool isLoading = false;

  List<Spending> allExpenses = [];
  List<Spending> filteredExpenses = [];

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses({DateTime? startDate, DateTime? endDate}) async {
    setState(() => isLoading = true);
    try {
      final spendingServcie = SpendingServcie();
      final List<Spending> spendings = await spendingServcie.getAllSpending(
        widget.storeId,
        startDate ?? DateTime.now().subtract(const Duration(days: 1)),
        endDate ?? DateTime.now().add(const Duration(days: 1)),
        context,
      );

      final expenses = spendings.cast<Spending>();

      expenses.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          allExpenses = expenses;
          _runFilterLogic();
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération : $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _runFilterLogic() {
    filteredExpenses = List<Spending>.from(allExpenses);
  }

  void _applyFilters() =>
      _fetchExpenses(startDate: startDate, endDate: endDate);

  double get _totalFilteredAmount {
    return filteredExpenses.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        final colors = DashColors(context);

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: const Text("Historique des Dépenses"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(PremiumRadii.sm),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: IconButton(
                    tooltip: "Actualiser",
                    onPressed: () => _fetchExpenses(
                        startDate: startDate, endDate: endDate),
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () =>
                  _fetchExpenses(startDate: startDate, endDate: endDate),
              color: colors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildSummaryCard(colors),
                  const SizedBox(height: 16),
                  _buildFilterSection(colors),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(
                        child: BouTikaLoader(),
                      ),
                    )
                  else if (filteredExpenses.isEmpty)
                    _buildEmptyState(colors)
                  else
                    ...filteredExpenses
                        .map((e) => _buildExpenseCard(e, colors)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Carte résumé — bandeau terracotta feutré + stats Bold.
  Widget _buildSummaryCard(DashColors colors) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.accentSoft,
                  colors.accentSoft.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(PremiumRadii.sm),
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: colors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Résumé des dépenses",
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Période sélectionnée",
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    colors: colors,
                    label: "TOTAL",
                    value: "${_totalFilteredAmount.toStringAsFixed(0)} F",
                    valueColor: colors.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    colors: colors,
                    label: "NOMBRE",
                    value: "${filteredExpenses.length}",
                    valueColor: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required DashColors colors,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumMicroLabel(label),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Filtres — callbacks de réinitialisation inchangés.
  Widget _buildFilterSection(DashColors colors) {
    final hasFilter = startDate != null || endDate != null;

    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PremiumIconTile(
                icon: Icons.filter_alt_outlined,
                color: colors.primary,
                softColor: colors.primarySoft,
                size: 40,
                iconSize: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Filtrer par période",
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
              ),
              if (hasFilter)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                    });
                    _applyFilters();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: colors.danger,
                  ),
                  label: Text(
                    "Réinitialiser",
                    style: TextStyle(
                      color: colors.danger,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDatePickerChip(
                  colors: colors,
                  label: "Date début",
                  date: startDate,
                  isStart: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePickerChip(
                  colors: colors,
                  label: "Date fin",
                  date: endDate,
                  isStart: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sélecteur de date — logique showDatePicker inchangée.
  Widget _buildDatePickerChip({
    required DashColors colors,
    required String label,
    required DateTime? date,
    required bool isStart,
  }) {
    final hasDate = date != null;

    return InkWell(
      borderRadius: BorderRadius.circular(PremiumRadii.input),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: colors.primary,
                onPrimary: Colors.white,
                surface: colors.card,
                onSurface: colors.textPrimary,
              ),
            ),
            child: child!,
          ),
        );

        if (picked != null) {
          setState(() {
            if (isStart) {
              startDate = picked;
            } else {
              endDate = picked;
            }
          });
          _applyFilters();
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: hasDate ? colors.primarySoft : colors.fieldFill,
          borderRadius: BorderRadius.circular(PremiumRadii.input),
          border: Border.all(
            color: hasDate
                ? colors.primary.withOpacity(0.4)
                : colors.border,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: hasDate ? colors.primary : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasDate ? DateFormat('dd/MM/yy').format(date!) : label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: hasDate ? colors.primary : colors.textSecondary,
                ),
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isStart) {
                      startDate = null;
                    } else {
                      endDate = null;
                    }
                  });
                  _applyFilters();
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: colors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Carte dépense — terracotta feutré, montant Bold en pastille.
  Widget _buildExpenseCard(Spending spending, DashColors colors) {
    final amount = spending.price ?? 0;
    final dateText = spending.createdAt != null
        ? DateFormat('dd MMM yyyy • HH:mm').format(spending.createdAt!)
        : "Date inconnue";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        radius: PremiumRadii.md,
        child: Row(
          children: [
            PremiumIconTile(
              icon: Icons.money_off_rounded,
              color: colors.accent,
              softColor: colors.accentSoft,
              size: 48,
              iconSize: 23,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spending.description?.trim().isNotEmpty == true
                        ? spending.description!
                        : "Sans description",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dateText,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: colors.dangerSoft,
                borderRadius: BorderRadius.circular(PremiumRadii.sm),
              ),
              child: Text(
                "- ${amount.toStringAsFixed(0)} F",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colors.danger,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(DashColors colors) {
    return const Padding(
      padding: EdgeInsets.only(top: 48),
      child: PremiumEmptyState(
        icon: Icons.receipt_long_outlined,
        title: "Aucune dépense trouvée",
        message: "Aucune dépense ne correspond à la période sélectionnée.",
      ),
    );
  }
}
