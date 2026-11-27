import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/features/categories/controllers/category_products_controller.dart';
import 'package:mobile_store_app/features/categories/widgets/category_dialog_parts.dart';
import 'package:mobile_store_app/shared/models/product.dart';
import 'package:mobile_store_app/shared/services/product_service.dart';

/// Résultat d'un restockage réussi.
class CategoryRestockResult {
  final Product product;
  final double added;

  const CategoryRestockResult({required this.product, required this.added});
}

/// Ouvre le dialogue de restockage d'un produit de la catégorie.
///
/// Met à jour la liste locale en cas de succès (remplacement à l'index) et
/// renvoie le produit renseigné par l'API, ou `null` si le dialogue a été
/// annulé.
Future<CategoryRestockResult?> showCategoryRestockDialog(
  BuildContext context, {
  required Product product,
  required CategoryProductsController controller,
}) {
  return showDialog<CategoryRestockResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _CategoryRestockDialog(
      product: product,
      controller: controller,
    ),
  );
}

class _CategoryRestockDialog extends StatefulWidget {
  final Product product;
  final CategoryProductsController controller;

  const _CategoryRestockDialog({
    required this.product,
    required this.controller,
  });

  @override
  State<_CategoryRestockDialog> createState() => _CategoryRestockDialogState();
}

class _CategoryRestockDialogState extends State<_CategoryRestockDialog> {
  final _restockController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void dispose() {
    _restockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final double add = double.tryParse(_restockController.text) ?? 0;

    final Product? p =
        await ProductService().updateStock(widget.product.id, add, context);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (p != null) {
      widget.controller.replaceProduct(p);
      Navigator.pop(context, CategoryRestockResult(product: p, added: add));
    }
  }

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final double stock =
        widget.product.stock!.baseStock - widget.product.stock!.totalSell;

    return AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: c.border),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      title: CategoryDialogTitle(
        icon: Icons.add_box_rounded,
        title: "Restocker ${widget.product.name}",
        iconColor: c.success,
        iconSoftColor: c.successSoft,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoCallout(
              icon: Icons.warning_amber_rounded,
              text: "Stock actuel : ${stock.toStringAsFixed(2)} unité(s)",
              color: c.danger,
              softColor: c.dangerSoft,
            ),
            const SizedBox(height: 16),
            CategoryFormField(
              controller: _restockController,
              label: "Quantité à ajouter",
              icon: Icons.add_circle_outline_rounded,
              hint: "Ex: 25",
              isNumber: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Entrez une valeur";
                }
                final parsed = double.tryParse(value);
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
        CategoryDialogActions(
          isLoading: _isSaving,
          confirmLabel: "Ajouter",
          confirmColor: c.success,
          onCancel: () {
            setState(() => _isSaving = false);
            Navigator.pop(context);
          },
          onConfirm: _submit,
        ),
      ],
    );
  }
}
