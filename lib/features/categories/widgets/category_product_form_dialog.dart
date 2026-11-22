import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/features/categories/widgets/category_dialog_parts.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/product_service.dart';
import 'package:mobile_store_app/utils/message.dart';

/// Ouvre le dialogue de création ou de modification d'un produit.
///
/// `product == null` → « Nouveau Produit » (création) ; sinon
/// « Modifier {nom} » (mise à jour). `onSaved` est appelé avant la fermeture,
/// pour que l'écran recharge ses données comme auparavant.
Future<void> showCategoryProductFormDialog(
  BuildContext context, {
  required String categoryId,
  required VoidCallback onSaved,
  Product? product,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => CategoryProductFormDialog(
      categoryId: categoryId,
      onSaved: onSaved,
      product: product,
    ),
  );
}

/// Formulaire produit (création et modification) de la catégorie.
class CategoryProductFormDialog extends StatefulWidget {
  final String categoryId;
  final VoidCallback onSaved;
  final Product? product;

  const CategoryProductFormDialog({
    super.key,
    required this.categoryId,
    required this.onSaved,
    this.product,
  });

  @override
  State<CategoryProductFormDialog> createState() =>
      _CategoryProductFormDialogState();
}

class _CategoryProductFormDialogState extends State<CategoryProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _salingPriceController = TextEditingController();
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final Product? product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _qtyController.text =
          (product.stock!.baseStock - product.stock!.totalSell).toString();
      _salingPriceController.text =
          product.stock?.sellingPrice.toString() ?? '';
      _buyingPriceController.text =
          product.stock?.buyingPrice.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _buyingPriceController.dispose();
    _salingPriceController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    return {
      "name": _nameController.text,
      "quantity": double.parse(_qtyController.text),
      "sellingPrice": double.parse(_salingPriceController.text),
      "buyingPrice": double.parse(_buyingPriceController.text),
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final ProductService ps = ProductService();

    if (_isEditing) {
      final Product? result =
          await ps.update(widget.product!.id, _buildPayload(), context);
      if (mounted) setState(() => _isSaving = false);
      if (result != null) {
        widget.onSaved();
        Navigator.pop(context);
        showSuccessMessage("Produit mis à jour !", context);
      }
      return;
    }

    final Product? newProd =
        await ps.add(_buildPayload(), widget.categoryId, context);
    if (mounted) setState(() => _isSaving = false);
    if (newProd != null) {
      widget.onSaved();
      Navigator.pop(context);
      showSuccessMessage("Produit ajouté avec succès !", context);
    } else {
      showErrorMessage("Erreur lors de l'ajout.", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final Product? product = widget.product;

    return AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: c.border),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      title: _isEditing
          ? CategoryDialogTitle(
              icon: Icons.edit_rounded,
              title: "Modifier ${product!.name}",
            )
          : const CategoryDialogTitle(
              icon: Icons.add_box_rounded,
              title: "Nouveau Produit",
            ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CategoryFormField(
                controller: _nameController,
                label: "Nom du produit",
                icon: Icons.label_rounded,
                hint: _isEditing ? "" : "Ex: Sac en cuir",
              ),
              const SizedBox(height: 14),
              CategoryFormField(
                controller: _qtyController,
                label: _isEditing ? "Quantité" : "Quantité initiale",
                icon: Icons.inventory_rounded,
                hint: _isEditing ? "" : "Ex: 50",
                isNumber: true,
              ),
              const SizedBox(height: 14),
              CategoryFormField(
                controller: _buyingPriceController,
                label: "Prix d'achat (F)",
                icon: Icons.money_rounded,
                hint: _isEditing ? "" : "Ex: 5000",
                isNumber: true,
              ),
              const SizedBox(height: 14),
              CategoryFormField(
                controller: _salingPriceController,
                label: "Prix de vente (F)",
                icon: Icons.sell_rounded,
                hint: _isEditing ? "" : "Ex: 8000",
                isNumber: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        CategoryDialogActions(
          isLoading: _isSaving,
          confirmLabel: _isEditing ? "Enregistrer" : "Ajouter",
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
