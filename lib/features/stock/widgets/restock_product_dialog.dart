import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/features/stock/controllers/low_stock_controller.dart';
import 'package:mobile_store_app/features/stock/controllers/stock_level.dart';
import 'package:mobile_store_app/models/product.dart';

/// Résultat d'un restockage : produit mis à jour et quantité ajoutée.
class RestockResult {
  final Product product;
  final double addedQuantity;

  const RestockResult({required this.product, required this.addedQuantity});
}

/// Ouvre le dialogue de restockage d'un produit.
///
/// Retourne le résultat (produit à jour + quantité ajoutée) ou `null` si
/// l'utilisateur annule, afin que l'écran affiche le message de succès.
Future<RestockResult?> showRestockProductDialog({
  required BuildContext context,
  required Product product,
  required LowStockController controller,
}) {
  return showDialog<RestockResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => RestockProductDialog(
      product: product,
      controller: controller,
    ),
  );
}

/// ============================================================================
/// RESTOCK PRODUCT DIALOG — saisie de la quantité à ajouter.
///
///   • `AlertDialog` surface carte, rayon 20, bordure 1 px, paddings 24
///   • titre : pastille `successSoft` 10 px + icône 22 + « Restocker {nom} »
///   • rappel du stock courant (`InfoCallout` danger) puis champ numérique
///     « Quantité à ajouter » validé (vide → « Entrez une valeur »,
///     non numérique ou ≤ 0 → « Valeur invalide »)
///   • « Annuler » (flex 1) + « Ajouter » (flex 2, fond succès, texte blanc)
///     avec loader pendant l'appel
///
/// Le contrôleur de saisie et l'état de chargement appartiennent au dialogue,
/// qui les libère à sa fermeture (aucune fuite, aucun `dispose` différé).
/// ============================================================================
class RestockProductDialog extends StatefulWidget {
  final Product product;
  final LowStockController controller;

  const RestockProductDialog({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  State<RestockProductDialog> createState() => _RestockProductDialogState();
}

class _RestockProductDialogState extends State<RestockProductDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final double add = double.tryParse(_quantityController.text) ?? 0;

    final Product? updated = await widget.controller.restock(
      product: widget.product,
      add: add,
      context: context,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (updated != null) {
      Navigator.pop(
        context,
        RestockResult(product: updated, addedQuantity: add),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final StockLevel level = StockLevel.of(widget.product);

    return AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: c.border),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.successSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.add_box_rounded, color: c.success, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Restocker ${widget.product.name}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading.copyWith(
                fontSize: 17.5,
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoCallout(
              icon: Icons.warning_amber_rounded,
              text:
                  "Stock actuel : ${level.quantity.toStringAsFixed(2)} unité(s)",
              color: c.danger,
              softColor: c.dangerSoft,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _quantityController,
              label: "Quantité à ajouter",
              hint: "Ex: 25",
              icon: Icons.add_circle_outline_rounded,
              keyboardType: TextInputType.number,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Entrez une valeur";
                }
                final double? parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return "Valeur invalide";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: "Annuler",
                height: 48,
                onPressed: _isLoading ? null : () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: "Ajouter",
                height: 48,
                background: c.success,
                foreground: Colors.white,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _confirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
