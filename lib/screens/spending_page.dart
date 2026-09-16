import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/core/constants/app_radius.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/service/spending_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors;
import 'package:mobile_store_app/widgets/boutika_loader.dart';

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

  static const Color _accent = Color(0xFFC08552);
  static const Color _danger = Color(0xFFDE4A52);

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
            title: Text(
              "Historique des Dépenses",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                letterSpacing: -0.2,
                color: colors.textPrimary,
              ),
            ),
            backgroundColor: colors.background,
            foregroundColor: colors.textPrimary,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: "Actualiser",
                onPressed: () =>
                    _fetchExpenses(startDate: startDate, endDate: endDate),
                icon: Icon(Icons.refresh_rounded, color: colors.primary),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () =>
                  _fetchExpenses(startDate: startDate, endDate: endDate),
              color: colors.primary,
              backgroundColor: colors.card,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  _buildSummaryCard(colors),
                  const SizedBox(height: 16),
                  _buildFilterSection(colors),
                  const SizedBox(height: 16),
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Center(
                        child: const BouTikaLoader(),
                      ),
                    )
                  else if (filteredExpenses.isEmpty)
                    _buildEmptyState(colors)
                  else
                    ...filteredExpenses.map((e) => _buildExpenseCard(e, colors)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(DashColors colors) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: _accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Résumé des dépenses",
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  colors: colors,
                  label: "TOTAL",
                  value: "${_totalFilteredAmount.toStringAsFixed(0)} F",
                  valueColor: _danger,
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
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(DashColors colors) {
    final hasFilter = startDate != null || endDate != null;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_outlined,
                  color: colors.primary, size: 18),
              const SizedBox(width: 8),
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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                    });
                    _applyFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.dangerSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded,
                            size: 13, color: _danger),
                        const SizedBox(width: 4),
                        Text(
                          "Réinitialiser",
                          style: TextStyle(
                            color: _danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilterDateChip(
                  label: "Date début",
                  date: startDate,
                  onTap: () => _pickDate(isStart: true),
                  onClear: () {
                    setState(() {
                      startDate = null;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilterDateChip(
                  label: "Date fin",
                  date: endDate,
                  onTap: () => _pickDate(isStart: false),
                  onClear: () {
                    setState(() {
                      endDate = null;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final colors = DashColors(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
  }

  Widget _buildExpenseCard(Spending spending, DashColors colors) {
    final amount = spending.price ?? 0;
    final dateText = spending.createdAt != null
        ? DateFormat('dd MMM yyyy • HH:mm').format(spending.createdAt!)
        : "Date inconnue";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.money_off_rounded,
              color: _accent,
              size: 22,
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _danger.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "- ${amount.toStringAsFixed(0)} F",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _danger,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DashColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SizedBox(
        height: 420,
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: "Aucune dépense trouvée",
          message:
          "Aucune dépense ne correspond à la période sélectionnée.",
          actionLabel: "Actualiser",
          onAction: () =>
              _fetchExpenses(startDate: startDate, endDate: endDate),
        ),
      ),
    );
  }
}
