import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/models/person.dart';
import 'package:mobile_store_app/models/withdrawal.dart';
import 'package:mobile_store_app/service/withdrawal_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors, appDarkMode;
import 'package:mobile_store_app/widgets/boutika_loader.dart';

class WithdrawalScreen extends StatefulWidget {
  final String storeId;

  const WithdrawalScreen({super.key, required this.storeId});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final WithdrawalService _withdrawalService = WithdrawalService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isLoading = false;
  List<Withdrawal> withdrawals = [];

  late DateTime startDate;
  late DateTime endDate;

  static const Color _accent = Color(0xFF5B8DEF);
  static const Color _danger = Color(0xFFDE4A52);

  @override
  void initState() {
    super.initState();
    final today = _today();
    startDate = today;
    endDate = today;
    _fetchWithdrawals();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _atStartOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _atEndOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _hasCustomFilter {
    final today = _today();
    return !_isSameDay(startDate, today) || !_isSameDay(endDate, today);
  }

  Future<void> _fetchWithdrawals() async {
    setState(() => isLoading = true);
    try {
      final data = await _withdrawalService.getAllWithdrawals(
        widget.storeId,
        _atStartOfDay(startDate),
        _atEndOfDay(endDate),
        context,
      );

      data.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      if (!mounted) return;
      setState(() => withdrawals = data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des retraits : $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  double get _totalAmount {
    return withdrawals.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final colors = DashColors(context);
    final currentDate = isStart ? startDate : endDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
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

    if (picked == null) return;

    setState(() {
      if (isStart) {
        startDate = picked;
        if (picked.isAfter(endDate)) {
          endDate = picked;
        }
      } else {
        endDate = picked;
        if (picked.isBefore(startDate)) {
          startDate = picked;
        }
      }
    });

    await _fetchWithdrawals();
  }

  Future<void> _resetFilters() async {
    final today = _today();
    setState(() {
      startDate = today;
      endDate = today;
    });
    await _fetchWithdrawals();
  }

  void _prepareForm([Withdrawal? withdrawal]) {
    _amountController.text = withdrawal?.price?.toStringAsFixed(0) ?? '';
    _descriptionController.text = withdrawal?.description ?? '';
  }

  Future<void> _showWithdrawalForm({Withdrawal? withdrawal}) async {
    final colors = DashColors(context);
    final isEdit = withdrawal != null;
    bool isSaving = false;

    _prepareForm(withdrawal);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setPopupState) {
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
                    isEdit ? Icons.edit_rounded : Icons.south_west_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    isEdit ? 'Modifier le retrait' : 'Nouveau retrait',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 17.5,
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
                      keyboardType: TextInputType.number,
                      label: 'Montant (F)',
                      icon: Icons.payments_outlined,
                      hint: 'Ex: 10000',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Indiquez le montant';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount <= 0) {
                          return 'Montant invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      label: 'Description / Motif',
                      icon: Icons.description_outlined,
                      hint: 'Ex: Retrait de caisse',
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Indiquez le motif'
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
                      label: 'Annuler',
                      height: 48,
                      onPressed: isSaving
                          ? null
                          : () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton.primary(
                      label: isEdit ? 'Modifier' : 'Enregistrer',
                      height: 48,
                      background: colors.primary,
                      foreground: Colors.white,
                      isLoading: isSaving,
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              setPopupState(() => isSaving = true);

                              final payload = Withdrawal(
                                price: double.parse(_amountController.text.trim()),
                                description: _descriptionController.text.trim(),
                                storeId: widget.storeId,
                              );

                              final success = isEdit
                                  ? await _withdrawalService.updateWithdrawal(
                                      withdrawal.id!,
                                      payload,
                                      context,
                                    )
                                  : await _withdrawalService.saveWithdrawal(
                                      payload,
                                      context,
                                    );

                              if (!mounted) return;

                              if (success) {
                                Navigator.pop(ctx);
                                await _fetchWithdrawals();
                                return;
                              }

                              setPopupState(() => isSaving = false);
                            },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(Withdrawal withdrawal) async {
    final colors = DashColors(context);
    bool isDeleting = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
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
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: colors.danger,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Supprimer le retrait',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Voulez-vous vraiment supprimer ce retrait ? Cette action est irréversible.',
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
                        label: 'Annuler',
                        height: 48,
                        onPressed: isDeleting
                            ? null
                            : () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton.danger(
                        label: 'Supprimer',
                        height: 48,
                        isLoading: isDeleting,
                        onPressed: isDeleting
                            ? null
                            : () async {
                                setDialogState(() => isDeleting = true);
                                final success = await _withdrawalService
                                    .deleteWithdrawal(withdrawal.id!, context);
                                if (!mounted) return;
                                if (success) {
                                  Navigator.pop(dialogContext);
                                  await _fetchWithdrawals();
                                } else {
                                  setDialogState(() => isDeleting = false);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _actorLabel(Person? person) {
    if (person == null) return '';
    if ((person.username ?? '').trim().isNotEmpty) {
      return person.username!.trim();
    }

    return '${person.firstname} ${person.lastname}'.trim();
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
              'Historique des retraits',
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
                tooltip: 'Actualiser',
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
                    _buildEmptyState()
                  else
                    ...withdrawals
                        .map((withdrawal) => _buildWithdrawalCard(withdrawal, colors)),
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
                  Icons.account_balance_wallet_rounded,
                  color: _accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Résumé des retraits',
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
                  label: 'TOTAL',
                  value: '${_totalAmount.toStringAsFixed(0)} F',
                  valueColor: _danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  colors: colors,
                  label: 'NOMBRE',
                  value: '${withdrawals.length}',
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
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filtrer par période',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
              ),
              if (_hasCustomFilter)
                GestureDetector(
                  onTap: _resetFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.dangerSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, size: 13, color: _danger),
                        const SizedBox(width: 4),
                        Text(
                          'Réinitialiser',
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
                  label: 'Date début',
                  date: startDate,
                  onTap: () => _pickDate(isStart: true),
                  onClear: () async {
                    final today = _today();
                    setState(() {
                      startDate = today;
                      if (startDate.isAfter(endDate)) {
                        endDate = startDate;
                      }
                    });
                    await _fetchWithdrawals();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilterDateChip(
                  label: 'Date fin',
                  date: endDate,
                  onTap: () => _pickDate(isStart: false),
                  onClear: () async {
                    final today = _today();
                    setState(() {
                      endDate = today;
                      if (endDate.isBefore(startDate)) {
                        startDate = endDate;
                      }
                    });
                    await _fetchWithdrawals();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalCard(Withdrawal withdrawal, DashColors colors) {
    final amount = withdrawal.price ?? 0;
    final actor = _actorLabel(withdrawal.person);
    final dateText = withdrawal.createdAt != null
        ? DateFormat('dd MMM yyyy • HH:mm').format(withdrawal.createdAt!)
        : 'Date inconnue';

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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.south_west_rounded,
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
                      withdrawal.description?.trim().isNotEmpty == true
                          ? withdrawal.description!
                          : 'Sans description',
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
                    if (actor.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Par $actor',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                  '- ${amount.toStringAsFixed(0)} F',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _danger,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton.soft(
                  label: 'Modifier',
                  icon: Icons.edit_rounded,
                  color: colors.warning,
                  softColor: colors.warningSoft,
                  height: 44,
                  onPressed: withdrawal.id == null
                      ? null
                      : () => _showWithdrawalForm(withdrawal: withdrawal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.danger(
                  label: 'Supprimer',
                  icon: Icons.delete_outline_rounded,
                  height: 44,
                  onPressed: withdrawal.id == null
                      ? null
                      : () => _confirmDelete(withdrawal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SizedBox(
        height: 420,
        child: EmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Aucun retrait trouvé',
          message: 'Aucun retrait ne correspond à la période sélectionnée.',
          actionLabel: 'Actualiser',
          onAction: _fetchWithdrawals,
        ),
      ),
    );
  }
}
