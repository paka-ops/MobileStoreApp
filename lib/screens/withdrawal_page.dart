import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/models/withdrawal.dart';
import 'package:mobile_store_app/service/withdrawal_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors;
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/widgets/boutika_loader.dart';

/// ============================================================================
/// FORMULAIRE RETRAIT — ajout (page d'accueil) / modification (historique).
///
///   await showWithdrawalFormDialog(context, storeId: storeId);
///   await showWithdrawalFormDialog(context, storeId: storeId,
///                                  withdrawal: retraitAmodifier);
///
/// Retourne `true` si le retrait a bien été enregistré côté serveur.
/// ============================================================================
Future<bool> showWithdrawalFormDialog(
  BuildContext context, {
  required String storeId,
  Withdrawal? withdrawal,
}) async {
  final bool? saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _WithdrawalFormDialog(
      storeId: storeId,
      withdrawal: withdrawal,
    ),
  );
  return saved ?? false;
}

/// ============================================================================
/// HISTORIQUE DES RETRAITS — les requêtes sont faites par date sur le serveur
/// (mêmes filtres que order_story_screen), chaque ligne est modifiable et
/// supprimable. Dates par défaut : aujourd'hui.
/// ============================================================================
class WithdrawalScreen extends StatefulWidget {
  final String storeId;
  const WithdrawalScreen({super.key, required this.storeId});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  bool isLoading = false;

  List<Withdrawal> withdrawals = [];

  /// Période envoyée à l'API (les valeurs par défaut sont la date du jour).
  DateTime startDate = _today();
  DateTime endDate = _today();

  static DateTime _today() => _startOfDay(DateTime.now());

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  @override
  void initState() {
    super.initState();
    _fetchWithdrawals();
  }

  Future<void> _fetchWithdrawals() async {
    setState(() => isLoading = true);
    try {
      final List<Withdrawal>? result =
          await WithdrawalService().getWithdrawals(
        storeId: widget.storeId,
        startDate: _startOfDay(startDate),
        endDate: _endOfDay(endDate),
        context: context,
      );

      final List<Withdrawal> list = result ?? <Withdrawal>[];
      list.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() => withdrawals = list);
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération des retraits : $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _applyFilters() => _fetchWithdrawals();

  void _resetToToday() {
    setState(() {
      startDate = _today();
      endDate = _today();
    });
    _applyFilters();
  }

  bool get _isTodayFilter =>
      _startOfDay(startDate) == _today() && _startOfDay(endDate) == _today();

  double get _totalAmount =>
      withdrawals.fold<double>(0, (sum, item) => sum + item.amount);

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
              "Historique des retraits",
              style: TextStyle(
                fontWeight: FontWeight.w700,
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
                onPressed: _fetchWithdrawals,
                icon: Icon(Icons.refresh_rounded, color: colors.primary),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchWithdrawals,
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
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: BouTikaLoader()),
                    )
                  else if (withdrawals.isEmpty)
                    _buildEmptyState(colors)
                  else
                    ...withdrawals
                        .map((w) => _buildWithdrawalCard(w, colors)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Résumé
  // -------------------------------------------------------------------------
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
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.savings_outlined,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Résumé des retraits",
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
                  label: "TOTAL RETIRÉ",
                  value: "${_totalAmount.toStringAsFixed(0)} F",
                  valueColor: colors.danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  colors: colors,
                  label: "NOMBRE",
                  value: "${withdrawals.length}",
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

  // -------------------------------------------------------------------------
  // Filtres — les dates choisies sont envoyées à l'API (recherche en base)
  // -------------------------------------------------------------------------
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
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
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
                      borderRadius: BorderRadius.circular(20),
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

  // -------------------------------------------------------------------------
  // Carte d'un retrait — modification + suppression
  // -------------------------------------------------------------------------
  Widget _buildWithdrawalCard(Withdrawal withdrawal, DashColors colors) {
    final String dateText =
        DateFormat('dd MMM yyyy • HH:mm').format(withdrawal.date);

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
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.savings_outlined,
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      withdrawal.message.trim().isNotEmpty
                          ? withdrawal.message
                          : "Sans motif",
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: colors.dangerSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "- ${withdrawal.amount.toStringAsFixed(0)} F",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.danger,
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
                    final bool saved = await showWithdrawalFormDialog(
                      context,
                      storeId: widget.storeId,
                      withdrawal: withdrawal,
                    );
                    if (saved && mounted) _fetchWithdrawals();
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
                  onPressed: () => _confirmDelete(withdrawal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Withdrawal withdrawal) async {
    final String? id = withdrawal.id;
    if (id == null || id.isEmpty) {
      showErrorMessage("Retrait introuvable", context);
      return;
    }

    final colors = DashColors(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
                color: colors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_forever_rounded,
                  color: colors.danger, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              "Supprimer le retrait",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Voulez-vous vraiment supprimer le retrait de "
              "${withdrawal.amount.toStringAsFixed(0)} F ? Cette action est irréversible.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13.5,
                height: 1.5,
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

    final bool deleted = await WithdrawalService().delete(
      withdrawalId: id,
      context: context,
    );

    if (!mounted) return;
    if (deleted) {
      setState(() => withdrawals.removeWhere((w) => w.id == id));
      showSuccessMessage("Retrait supprimé avec succès", context);
    }
  }

  Widget _buildEmptyState(DashColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SizedBox(
        height: 420,
        child: EmptyState(
          icon: Icons.savings_outlined,
          title: "Aucun retrait trouvé",
          message:
              "Aucun retrait ne correspond à la période sélectionnée.",
          actionLabel: "Actualiser",
          onAction: _fetchWithdrawals,
        ),
      ),
    );
  }
}

/// ============================================================================
/// DIALOG — formulaire d'ajout / de modification d'un retrait.
/// ============================================================================
class _WithdrawalFormDialog extends StatefulWidget {
  final String storeId;
  final Withdrawal? withdrawal;

  const _WithdrawalFormDialog({
    required this.storeId,
    this.withdrawal,
  });

  @override
  State<_WithdrawalFormDialog> createState() => _WithdrawalFormDialogState();
}

class _WithdrawalFormDialogState extends State<_WithdrawalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _messageController;
  late DateTime _date;
  bool isSaving = false;

  bool get isEditing => widget.withdrawal != null;

  @override
  void initState() {
    super.initState();
    final Withdrawal? existing = widget.withdrawal;
    _amountController = TextEditingController(
      text: existing == null ? "" : _formatAmount(existing.amount),
    );
    _messageController =
        TextEditingController(text: existing?.message ?? "");
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  static String _formatAmount(double amount) => amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toString();

  Future<void> _pickDate() async {
    final colors = DashColors(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
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
        final DateTime previous = _date;
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          previous.hour,
          previous.minute,
          previous.second,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final double? amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (amount == null || amount <= 0) return;

    if (isEditing && (widget.withdrawal?.id == null ||
        widget.withdrawal!.id!.isEmpty)) {
      showErrorMessage("Retrait introuvable", context);
      return;
    }

    final Withdrawal withdrawal = Withdrawal(
      id: widget.withdrawal?.id,
      amount: amount,
      message: _messageController.text.trim(),
      date: _date,
    );

    setState(() => isSaving = true);
    try {
      final Withdrawal? saved = isEditing
          ? await WithdrawalService().update(
              storeId: widget.storeId,
              withdrawal: withdrawal,
              context: context,
            )
          : await WithdrawalService().create(
              storeId: widget.storeId,
              withdrawal: withdrawal,
              context: context,
            );

      if (!mounted) return;

      if (saved != null) {
        showSuccessMessage(
          isEditing
              ? "Retrait modifié avec succès"
              : "Retrait enregistré avec succès",
          context,
        );
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
        borderRadius: BorderRadius.circular(20),
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
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.savings_outlined,
              color: colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              isEditing ? "Modifier le retrait" : "Nouveau retrait",
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                controller: _messageController,
                maxLines: 2,
                label: "Motif du retrait",
                icon: Icons.description_outlined,
                hint: "Ex: Retrait pour achat personnel",
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Indiquez le motif"
                    : null,
              ),
              const SizedBox(height: 14),
              Text(
                "DATE DU RETRAIT",
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              _DateField(
                date: _date,
                onTap: _pickDate,
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
                onPressed:
                    isSaving ? null : () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: isEditing ? "Enregistrer" : "Ajouter",
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

/// ============================================================================
/// CHAMP DATE — présentation uniquement (le datePicker vit dans le formulaire).
/// ============================================================================
class _DateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
        decoration: BoxDecoration(
          color: colors.fill,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 19,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy').format(date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 20,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
