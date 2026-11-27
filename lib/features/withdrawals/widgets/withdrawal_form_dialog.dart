import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/features/withdrawals/controllers/withdrawal_form_controller.dart';
import 'package:mobile_store_app/shared/models/withdrawal.dart';
import 'package:mobile_store_app/utils/message.dart';

/// Ouvre le formulaire de retrait (ajout sans [withdrawal], édition avec).
///
/// Retourne `true` si le retrait a bien été enregistré côté serveur.
Future<bool> showWithdrawalFormDialog(
  BuildContext context, {
  required String storeId,
  Withdrawal? withdrawal,
  WithdrawalFormController? formController,
}) async {
  final bool? saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => WithdrawalFormDialog(
      storeId: storeId,
      withdrawal: withdrawal,
      formController: formController ?? WithdrawalFormController(),
    ),
  );
  return saved ?? false;
}

/// ============================================================================
/// WITHDRAWAL FORM DIALOG — ajout / modification d'un retrait.
///
///   • titre : pastille `primarySoft` + icône épargne 20
///   • phrase d'introduction, puis rappel **non modifiable** de la date en
///     édition (`dd/MM/yyyy HH:mm` en heure locale)
///   • montant (décimales autorisées, « , » acceptée) et motif (2 lignes)
///   • « Annuler » (flex 1) + « Enregistrer »/« Ajouter » (flex 2), hauteur 48
///
/// Messages conservés : « Retrait introuvable » (édition sans identifiant),
/// « Retrait modifié avec succès » / « Retrait enregistré avec succès ».
///
/// La persistance (création ou mise à jour) est déléguée à
/// [WithdrawalFormController] ; le montant pré-rempli suit la même règle que
/// l'original (entier sans décimale si le montant est rond).
/// ============================================================================
class WithdrawalFormDialog extends StatefulWidget {
  final String storeId;
  final Withdrawal? withdrawal;
  final WithdrawalFormController formController;

  const WithdrawalFormDialog({
    super.key,
    required this.storeId,
    required this.formController,
    this.withdrawal,
  });

  @override
  State<WithdrawalFormDialog> createState() => _WithdrawalFormDialogState();
}

class _WithdrawalFormDialogState extends State<WithdrawalFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _messageController;
  bool _isSaving = false;

  bool get _isEditing => widget.withdrawal != null;

  @override
  void initState() {
    super.initState();

    final Withdrawal? existing = widget.withdrawal;
    _amountController = TextEditingController(
      text: existing == null ? "" : _formatAmount(existing.amount),
    );
    _messageController =
        TextEditingController(text: existing?.message ?? "");
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  static String _formatAmount(double amount) =>
      amount == amount.roundToDouble()
          ? amount.toStringAsFixed(0)
          : amount.toString();

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final double? amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (amount == null || !amount.isFinite || amount <= 0) return;

    if (_isEditing &&
        (widget.withdrawal?.id == null || widget.withdrawal!.id!.isEmpty)) {
      showErrorMessage("Retrait introuvable", context);
      return;
    }

    final Withdrawal withdrawal = Withdrawal(
      id: widget.withdrawal?.id,
      amount: amount,
      message: _messageController.text.trim(),
      date: widget.withdrawal?.date,
    );

    setState(() => _isSaving = true);
    try {
      final Withdrawal? saved = await widget.formController.save(
        isEditing: _isEditing,
        storeId: widget.storeId,
        draft: withdrawal,
        context: context,
      );

      if (!mounted) return;

      if (saved != null) {
        showSuccessMessage(
          _isEditing
              ? "Retrait modifié avec succès"
              : "Retrait enregistré avec succès",
          context,
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
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
              borderRadius: BorderRadius.circular(AppRadius.sm),
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
              _isEditing ? "Modifier le retrait" : "Nouveau retrait",
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
              Text(
                _isEditing
                    ? "Modifiez le montant et le motif de ce retrait."
                    : "Renseignez le montant et le motif du retrait.",
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              if (_isEditing && widget.withdrawal!.date != null) ...[
                const SizedBox(height: 8),
                Text(
                  "Date du retrait (non modifiable) : ${DateFormat('dd/MM/yyyy HH:mm').format(widget.withdrawal!.date!.toLocal())}",
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
              const SizedBox(height: 18),
              AppTextField(
                controller: _amountController,
                enabled: !_isSaving,
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
                  if (value == null || !value.isFinite || value <= 0) {
                    return "Indiquez un montant valide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _messageController,
                enabled: !_isSaving,
                maxLines: 2,
                label: "Motif du retrait",
                icon: Icons.description_outlined,
                hint: "Ex: Retrait pour achat personnel",
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
                onPressed:
                    _isSaving ? null : () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: _isEditing ? "Enregistrer" : "Ajouter",
                height: 48,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
