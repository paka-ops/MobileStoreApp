import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/features/stores/controllers/store_actions_controller.dart';
import 'package:mobile_store_app/shared/models/Store.dart';
import 'package:mobile_store_app/utils/message.dart';

/// Ouvre le dialogue de suppression d'une boutique.
///
/// Fermable par appui extérieur, comme dans l'original (comportement par
/// défaut de `showDialog`).
void showStoreDeleteDialog({
  required BuildContext context,
  required Store store,
  required StoreActionsController actions,
  required VoidCallback onDeleted,
}) {
  showDialog(
    context: context,
    builder: (_) => StoreDeleteDialog(
      store: store,
      actions: actions,
      onDeleted: onDeleted,
    ),
  );
}

/// ============================================================================
/// STORE DELETE DIALOG — confirmation de suppression.
///
/// Rendu identique :
///   • cercle 16 px de padding sur `AppColors.dangerSoft` + icône 30
///     `AppColors.badgeRed` (teintes fixes, non dépendantes du thème : c'est
///     exactement ce que faisait le widget d'origine)
///   • titre 17, question 13.5 centrée (interligne 1.5) avec le nom réel
///   • « Annuler » (flex 1) + « Supprimer » (flex 1, style danger), gap 12
///
/// Messages conservés mot pour mot :
///   • succès  → « Boutique {nom} supprimée » (affiché par la carte, après
///     fermeture, puis notification `isDeleted(true)`)
///   • erreur  → « Erreur lors de la suppression. »
/// ============================================================================
class StoreDeleteDialog extends StatefulWidget {
  final Store store;
  final StoreActionsController actions;
  final VoidCallback onDeleted;

  const StoreDeleteDialog({
    super.key,
    required this.store,
    required this.actions,
    required this.onDeleted,
  });

  @override
  State<StoreDeleteDialog> createState() => _StoreDeleteDialogState();
}

class _StoreDeleteDialogState extends State<StoreDeleteDialog> {
  bool _isLoading = false;

  Future<void> _delete() async {
    setState(() => _isLoading = true);

    final bool isDeleted = await widget.actions.deleteStore(
      storeId: widget.store.id,
      context: context,
    );

    if (!mounted) return;

    if (!isDeleted) {
      setState(() => _isLoading = false);
      showErrorMessage("Erreur lors de la suppression.", context);
      return;
    }

    Navigator.of(context).pop();
    widget.onDeleted();
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
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.dangerSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_forever_rounded,
              color: AppColors.badgeRed,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Supprimer la boutique",
            style: AppTextStyles.heading.copyWith(
              fontSize: 17,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Voulez-vous vraiment supprimer '${widget.store.name}' ?"
            " Cette action est irréversible.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary.copyWith(
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
                onPressed: _isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton.danger(
                label: "Supprimer",
                height: 48,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _delete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
