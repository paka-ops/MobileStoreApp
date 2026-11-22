import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/features/stores/controllers/stores_controller.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/utils/message.dart';

/// Ouvre le dialogue de création d'une boutique.
///
/// `barrierDismissible: false` comme dans l'original.
void showAddStoreDialog({
  required BuildContext context,
  required StoresController controller,
  required ValueChanged<Store> onCreated,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AddStoreDialog(
      controller: controller,
      onCreated: onCreated,
    ),
  );
}

/// ============================================================================
/// ADD STORE DIALOG — création d'une boutique.
///
/// Rendu identique :
///   • `AlertDialog` surface carte, rayon 20, bordure 1 px
///   • titre : pastille `primarySoft` 10 + icône bâtiment 22 + « Nouvelle
///     Boutique » 17.5
///   • deux `AppTextField` (nom, emplacement), gap 16, validation « champ vide »
///   • « Annuler » (flex 1) + « Créer la boutique » (flex 2), gap 12
///
/// Les contrôleurs et la clé de formulaire appartiennent désormais au dialogue :
/// chaque ouverture repart donc vierge, exactement comme lorsque l'écran les
/// vidait à la fermeture.
///
/// Messages conservés mot pour mot :
///   • succès  → « Boutique créée avec succès ! » (affiché par l'écran après
///     fermeture)
///   • `null`  → « La création a échoué. »
///   • erreur  → « Erreur de connexion au serveur. »
/// ============================================================================
class AddStoreDialog extends StatefulWidget {
  final StoresController controller;
  final ValueChanged<Store> onCreated;

  const AddStoreDialog({
    super.key,
    required this.controller,
    required this.onCreated,
  });

  @override
  State<AddStoreDialog> createState() => _AddStoreDialogState();
}

class _AddStoreDialogState extends State<AddStoreDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final StoreCreationOutcome outcome = await widget.controller.createStore(
      name: _nameController.text,
      location: _addressController.text,
      context: context,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (outcome.status) {
      case StoreCreationStatus.success:
        Navigator.pop(context);
        widget.onCreated(outcome.store!);
        break;
      case StoreCreationStatus.failed:
        showErrorMessage("La création a échoué.", context);
        break;
      case StoreCreationStatus.error:
        showErrorMessage("Erreur de connexion au serveur.", context);
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
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.add_business_rounded,
              color: colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Nouvelle Boutique",
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
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Le nom est obligatoire' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _addressController,
                label: "Emplacement / Adresse",
                icon: Icons.location_on_rounded,
                hint: "Ex: Rue 12, Douala",
                validator: (v) => (v == null || v.isEmpty)
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
                onPressed:
                    _isLoading ? null : () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: "Créer la boutique",
                height: 48,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _create,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
