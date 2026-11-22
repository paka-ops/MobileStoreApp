import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/features/stores/controllers/store_actions_controller.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/utils/message.dart';

/// Ouvre le dialogue de modification d'une boutique.
///
/// `barrierDismissible: false` comme dans l'original : seule l'action
/// « Annuler » referme la boîte.
void showStoreUpdateDialog({
  required BuildContext context,
  required Store store,
  required StoreActionsController actions,
  required ValueChanged<Store> onUpdated,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => StoreUpdateDialog(
      store: store,
      actions: actions,
      onUpdated: onUpdated,
    ),
  );
}

/// ============================================================================
/// STORE UPDATE DIALOG — modification du nom et de l'emplacement.
///
/// Rendu identique :
///   • `AlertDialog` surface carte, rayon 20, bordure 1 px
///   • paddings titre 24 / contenu 24‑20‑24‑0 / actions 24
///   • titre : pastille `fill` 10 + icône crayon 21 + libellé 17.5
///   • deux `AppTextField` (nom obligatoire, emplacement obligatoire), gap 16
///   • « Annuler » (flex 1) + « Enregistrer » (flex 2), gap 12, hauteur 48
///
/// Messages conservés mot pour mot :
///   • succès → « Boutique mise à jour avec succès ! » (affiché par la carte
///     après fermeture, comme auparavant)
///   • `null`  → « La mise à jour a échoué. »
///   • erreur  → « Erreur lors de la mise à jour. »
/// ============================================================================
class StoreUpdateDialog extends StatefulWidget {
  final Store store;
  final StoreActionsController actions;
  final ValueChanged<Store> onUpdated;

  const StoreUpdateDialog({
    super.key,
    required this.store,
    required this.actions,
    required this.onUpdated,
  });

  @override
  State<StoreUpdateDialog> createState() => _StoreUpdateDialogState();
}

class _StoreUpdateDialogState extends State<StoreUpdateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.store.name);
  late final TextEditingController _locationController =
      TextEditingController(text: widget.store.location ?? '');

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final StoreUpdateOutcome outcome = await widget.actions.updateStore(
      storeId: widget.store.id,
      name: _nameController.text,
      location: _locationController.text,
      context: context,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (outcome.status) {
      case StoreUpdateStatus.success:
        Navigator.of(context).pop();
        widget.onUpdated(outcome.store!);
        break;
      case StoreUpdateStatus.failed:
        showErrorMessage("La mise à jour a échoué.", context);
        break;
      case StoreUpdateStatus.error:
        showErrorMessage("Erreur lors de la mise à jour.", context);
        break;
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
              color: colors.fill,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: colors.textPrimary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Modifier la boutique",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading.copyWith(
                fontSize: 17.5,
                color: colors.textPrimary,
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
                controller: _nameController,
                textInputAction: TextInputAction.next,
                label: "Nom de la boutique",
                icon: Icons.storefront_rounded,
                hint: "Ex: Boutique Centre-ville",
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Le nom est obligatoire"
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _locationController,
                label: "Emplacement / Adresse",
                icon: Icons.location_on_rounded,
                hint: "Ex: Rue 12, Douala",
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Veuillez préciser l'emplacement"
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
                onPressed: _isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: "Enregistrer",
                height: 48,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
