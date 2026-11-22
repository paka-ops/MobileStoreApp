import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/features/spending/controllers/expenses_controller.dart';

/// Ouvre le dialogue de modification d'une dépense.
///
/// Retourne `true` si la modification a été enregistrée.
Future<bool?> showExpenseEditDialog({
  required BuildContext context,
  required Spending spending,
  required String storeId,
  required ExpensesController controller,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ExpenseEditDialog(
      spending: spending,
      storeId: storeId,
      controller: controller,
    ),
  );
}

/// ============================================================================
/// EXPENSE EDIT DIALOG — modification d'une dépense existante.
///
/// Formulaire pré-rempli :
///   • montant : entier sans décimale si le prix est rond, sinon `toString()`
///     (comportement d'origine), saisi en `numberWithOptions(decimal: true)`
///   • description (2 lignes)
///   • « Annuler » (flex 1) + « Enregistrer » (flex 2), hauteur 48, loader
///
/// Validation identique : montant parsé après remplacement de « , » par « . »,
/// refusé s'il est nul, négatif ou illisible ; description non vide.
/// ============================================================================
class ExpenseEditDialog extends StatefulWidget {
  final Spending spending;
  final String storeId;
  final ExpensesController controller;

  const ExpenseEditDialog({
    super.key,
    required this.spending,
    required this.storeId,
    required this.controller,
  });

  @override
  State<ExpenseEditDialog> createState() => _ExpenseEditDialogState();
}

class _ExpenseEditDialogState extends State<ExpenseEditDialog> {
  static const Color _accent = AppColors.accentPink;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  bool _isSaving = false;

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

    setState(() => _isSaving = true);
    try {
      final bool saved = await widget.controller.updateExpense(
        original: widget.spending,
        amount: amount,
        description: _descriptionController.text,
        fallbackStoreId: widget.storeId,
        context: context,
      );

      if (!mounted) return;
      if (saved) {
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
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.sm),
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
                onPressed:
                    _isSaving ? null : () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: "Enregistrer",
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
