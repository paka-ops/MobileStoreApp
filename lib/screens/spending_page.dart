import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/service/spending_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, AppColors, DashColors;
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/widgets/boutika_loader.dart';

class ExpensesScreen extends StatefulWidget {
  final String storeId;
  const ExpensesScreen({super.key, required this.storeId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool isLoading = false;

  /// Liste telle que renvoyée par le serveur pour la période filtrée.
  List<Spending> expenses = [];

  /// Période envoyée à l'API — par défaut : la date d'aujourd'hui.
  DateTime startDate = _today();
  DateTime endDate = _today();

  static const Color _accent = AppColors.accentPink;
  static const Color _danger = AppColors.badgeRed;

  static DateTime _today() => _startOfDay(DateTime.now());

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  /// Le filtrage est fait par le serveur : les dates choisies sont envoyées
  /// dans l'API (`startDate` / `endDate`), aucune recherche côté application.
  Future<void> _fetchExpenses() async {
    setState(() => isLoading = true);
    try {
      final spendingServcie = SpendingServcie();
      final List<Spending> spendings = await spendingServcie.getAllSpending(
        widget.storeId,
        _startOfDay(startDate),
        _endOfDay(endDate),
        context,
      );

      spendings.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() => expenses = spendings);
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération : $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _applyFilters() => _fetchExpenses();

  void _resetToToday() {
    setState(() {
      startDate = _today();
      endDate = _today();
    });
    _applyFilters();
  }

  bool get _isTodayFilter =>
      _startOfDay(startDate) == _today() && _startOfDay(endDate) == _today();

  double get _totalAmount {
    return expenses.fold<double>(
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
          appBar: AppBar(
            title: Text(
              "Historique des Dépenses",
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
                  else if (expenses.isEmpty)
                    _buildEmptyState(colors)
                  else
                    ...expenses.map((e) => _buildExpenseCard(e, colors)),
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
                  borderRadius: AppRadius.sm,
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
                  value: "${_totalAmount.toStringAsFixed(0)} F",
                  valueColor: _danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  colors: colors,
                  label: "NOMBRE",
                  value: "${expenses.length}",
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
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(DashColors colors) {
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
                    AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 14.5, color: colors.textPrimary),
                  ),
                ),
              ),
              if (!_isTodayFilter)
                GestureDetector(
                  onTap: _resetToToday,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: AppRadius.xl,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.today_rounded,
                            size: 13, color: colors.primary),
                        const SizedBox(width: 4),
                        Text(
                          "Aujourd'hui",
                          style: TextStyle(
                            color: colors.primary,
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
                    setState(() => startDate = _today());
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
                    setState(() => endDate = _today());
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
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
          if (endDate.isBefore(picked)) endDate = picked;
        } else {
          endDate = picked;
          if (startDate.isAfter(picked)) startDate = picked;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: AppRadius.lg,
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
                        AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 14.5, color: colors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dateText,
                      style: TextStyle(
                        AppTextStyles.label.copyWith(color: colors.textSecondary, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: _danger.withValues(alpha: 0.10),
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  "- ${amount.toStringAsFixed(0)} F",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _danger,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: colors.hairline),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton.soft(
                  label: "Modifier",
                  icon: Icons.edit_rounded,
                  color: colors.warning,
                  softColor: colors.warningSoft,
                  height: 44,
                  fontSize: 13,
                  onPressed: () async {
                    final bool saved =
                        await _showEditExpenseDialog(spending);
                    if (saved && mounted) _fetchExpenses();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.danger(
                  label: "Supprimer",
                  icon: Icons.delete_outline_rounded,
                  height: 44,
                  fontSize: 13,
                  onPressed: () => _confirmDelete(spending),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Modification d'une dépense existante
  // -------------------------------------------------------------------------
  Future<bool> _showEditExpenseDialog(Spending spending) async {
    final bool? saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ExpenseEditDialog(
        spending: spending,
        storeId: widget.storeId,
      ),
    );
    return saved ?? false;
  }

  // -------------------------------------------------------------------------
  // Suppression d'une dépense existante
  // -------------------------------------------------------------------------
  Future<void> _confirmDelete(Spending spending) async {
    final String? id = spending.id;
    if (id == null || id.isEmpty) {
      showErrorMessage("Dépense introuvable", context);
      return;
    }

    final colors = DashColors(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xl,
          side: BorderSide(color: colors.border),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _danger.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded,
                  color: _danger, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              "Supprimer la dépense",
              style: TextStyle(
                AppTextStyles.heading.copyWith(fontSize: 17, color: colors.textPrimary),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Voulez-vous vraiment supprimer cette dépense de "
              "${(spending.price ?? 0).toStringAsFixed(0)} F ? Cette action est irréversible.",
              textAlign: TextAlign.center,
              style: TextStyle(
                AppTextStyles.bodySecondary.copyWith(AppTextStyles.bodySecondary.copyWith(color: colors.textSecondary).5, height: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: "Annuler",
                  height: 48,
                  onPressed: () => Navigator.pop(dialogContext, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton.danger(
                  label: "Supprimer",
                  height: 48,
                  fontSize: 13,
                  onPressed: () => Navigator.pop(dialogContext, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final bool deleted =
        await SpendingServcie().deleteSpending(id, context);

    if (!mounted) return;
    if (deleted) {
      setState(() => expenses.removeWhere((e) => e.id == id));
      showSuccessMessage("Dépense supprimée avec succès", context);
    }
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
          onAction: _fetchExpenses,
        ),
      ),
    );
  }
}

/// ============================================================================
/// DIALOG — modification d'une dépense existante (même formulaire que l'ajout,
/// pré-rempli avec les valeurs enregistrées).
/// ============================================================================
class _ExpenseEditDialog extends StatefulWidget {
  final Spending spending;
  final String storeId;

  const _ExpenseEditDialog({
    required this.spending,
    required this.storeId,
  });

  @override
  State<_ExpenseEditDialog> createState() => _ExpenseEditDialogState();
}

class _ExpenseEditDialogState extends State<_ExpenseEditDialog> {
  static const Color _accent = AppColors.accentPink;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final double? price = widget.spending.price;
    _amountController = TextEditingController(
      text: price == null
          ? ""
          : (price == price.roundToDouble()
              ? price.toStringAsFixed(0)
              : price.toString()),
    );
    _descriptionController =
        TextEditingController(text: widget.spending.description ?? "");
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final double? amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (amount == null || amount <= 0) return;

    final Spending updated = Spending(
      id: widget.spending.id,
      description: _descriptionController.text.trim(),
      price: amount,
      storeId: widget.spending.storeId ?? widget.storeId,
    );

    setState(() => isSaving = true);
    try {
      final bool ok = await SpendingServcie().updateSpending(updated, context);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.xl,
        side: BorderSide(color: colors.border),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(Icons.edit_rounded, color: _accent, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              "Modifier la dépense",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                label: "Montant (F)",
                icon: Icons.payments_outlined,
                hint: "Ex: 2500",
                validator: (v) {
                  final double? value = double.tryParse(
                    (v ?? "").trim().replaceAll(',', '.'),
                  );
                  if (value == null || value <= 0) {
                    return "Indiquez un montant valide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _descriptionController,
                maxLines: 2,
                label: "Description / Motif",
                icon: Icons.description_outlined,
                hint: "Ex: Transport marchandises",
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Indiquez le motif"
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: "Annuler",
                height: 48,
                onPressed: isSaving ? null : () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: "Enregistrer",
                height: 48,
                isLoading: isSaving,
                onPressed: isSaving ? null : _save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
