import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/service/spending_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show appDarkMode, DashColors;

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

  DateTime? startDate = DateTime.now().subtract(Duration(days: 1));
  DateTime? endDate = DateTime.now();

  static const Color _accent = Color(0xFFC08552);
  static const Color _danger = Color(0xFFC96B6B);

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() => isLoading = true);
    try {
      final spendingServcie = SpendingServcie();
      final List<Spending> spendings =
      await spendingServcie.getAllSpending(widget.storeId,startDate,endDate,context);

      final expenses = spendings.cast<Spending>();

      expenses.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          allExpenses = expenses;
          _applyLocalFilter();
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération : $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _applyLocalFilter() {
    filteredExpenses = allExpenses.where((expense) {
      final createdAt = expense.createdAt;
      if (createdAt == null) return false;

      final isAfterStart =
      startDate == null ? true : !createdAt.isBefore(_startOfDay(startDate!));

      final isBeforeEnd =
      endDate == null ? true : createdAt.isBefore(_startOfDay(endDate!).add(const Duration(days: 1)));

      return isAfterStart && isBeforeEnd;
    }).toList();
  }

  DateTime _startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

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
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
                onPressed: _fetchExpenses,
                icon: Icon(Icons.refresh_rounded, color: colors.primary),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchExpenses,
              color: colors.primary,
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
                        child: CircularProgressIndicator(color: colors.primary),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.10),
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
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
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
        borderRadius: BorderRadius.circular(16),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(DashColors colors) {
    final hasFilter = startDate != null || endDate != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "Filtrer par période",
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              const Spacer(),
              if (hasFilter)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                      _applyLocalFilter();
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 16, color: _danger),
                  label: const Text(
                    "Réinitialiser",
                    style: TextStyle(
                      color: _danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildDatePickerChip(
                  colors: colors,
                  label: "Du",
                  date: startDate,
                  onPicked: (date) {
                    setState(() {
                      startDate = date;
                      _applyLocalFilter();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePickerChip(
                  colors: colors,
                  label: "Au",
                  date: endDate,
                  onPicked: (date) {
                    setState(() {
                      endDate = date;
                      _applyLocalFilter();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerChip({
    required DashColors colors,
    required String label,
    required DateTime? date,
    required Function(DateTime) onPicked,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
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
              ),
            ),
            child: child!,
          ),
        );

        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date == null ? label : DateFormat('dd/MM/yyyy').format(date),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: date == null ? colors.textSecondary : colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.10),
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
              color: _danger.withOpacity(0.10),
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
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: colors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 52,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Aucune dépense trouvée",
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Aucune dépense ne correspond à la période sélectionnée.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}