import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/features/categories/widgets/category_dialog_parts.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/product_service.dart';

/// Ouvre la confirmation de suppression d'un produit de la catégorie.
///
/// Renvoie `true` lorsque la suppression a été confirmée et exécutée, `false`
/// si le dialogue a été fermé sans supprimer.
Future<bool> showCategoryProductDeleteDialog(
  BuildContext context, {
  required Product product,
}) async {
  final bool? deleted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => _CategoryProductDeleteDialog(product: product),
  );
  return deleted ?? false;
}

class _CategoryProductDeleteDialog extends StatefulWidget {
  final Product product;

  const _CategoryProductDeleteDialog({required this.product});

  @override
  State<_CategoryProductDeleteDialog> createState() =>
      _CategoryProductDeleteDialogState();
}

class _CategoryProductDeleteDialogState
    extends State<_CategoryProductDeleteDialog> {
  bool _isRemoving = false;

  Future<void> _remove() async {
    setState(() => _isRemoving = true);
    await ProductService().delete(widget.product.id, context);
    if (mounted) setState(() => _isRemoving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: c.border),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.dangerSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_forever_rounded,
                color: c.danger, size: 30),
          ),
          const SizedBox(height: 18),
          Text(
            "Supprimer le produit",
            style: AppTextStyles.heading.copyWith(
              fontSize: 17,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Voulez-vous vraiment supprimer '${widget.product.name}' ? Cette action est irréversible.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary.copyWith(
              color: c.textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        CategoryDialogActions(
          isLoading: _isRemoving,
          confirmLabel: "Supprimer",
          confirmColor: c.danger,
          onCancel: () {
            setState(() => _isRemoving = false);
            Navigator.pop(context);
          },
          onConfirm: _remove,
        ),
      ],
    );
  }
}
