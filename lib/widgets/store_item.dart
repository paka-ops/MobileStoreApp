import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/store_page.dart' hide AppColors;
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart';
import 'package:mobile_store_app/utils/message.dart';
import '../models/Store.dart';

class StoreItem extends StatefulWidget {
  final Store store;
  final List<Store> otherStores;
  final VoidCallback? onRefresh;
  final void Function(bool value) isDeleted;

  const StoreItem({
    super.key,
    required this.isDeleted,
    required this.store,
    required this.otherStores,
    this.onRefresh,
  });

  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
  bool _showActions = false;
  late Store _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store;
  }

  @override
  void didUpdateWidget(covariant StoreItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _store = widget.store;
  }

  void _openStoreDetails() {
    final List<Store> filteredStores = List<Store>.from(widget.otherStores)
      ..removeWhere((item) => item.id == _store.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDetailScreen(
          store: _store,
          userType: UserService.userType ?? '',
          otherStores: filteredStores,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // DIALOG - Mise à jour boutique (Style UI 1)
  // ---------------------------------------------------------------------
  void _showUpdateDialog(BuildContext context) {
    final nameController = TextEditingController(text: _store.name);
    final locationController =
    TextEditingController(text: _store.location ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppColors.border, width: 1.2),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Modifier la boutique",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: AppColors.textDark,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration(
                          label: "Nom de la boutique",
                          icon: Icons.storefront_rounded,
                          hint: "Ex: Boutique Centre-ville",
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Le nom est obligatoire";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: locationController,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: AppColors.textDark,
                        ),
                        decoration: _fieldDecoration(
                          label: "Emplacement / Adresse",
                          icon: Icons.location_on_rounded,
                          hint: "Ex: Rue 12, Douala",
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Veuillez préciser l'emplacement";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.card,
                          foregroundColor: AppColors.textDark,
                          elevation: 0,
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isLoading = true);

                          try {
                            final Map<String, dynamic> storeMap = {
                              "name": nameController.text.trim(),
                              "location": locationController.text.trim(),
                            };

                            final Store? updatedStore =
                            await StoreService().updateStore(
                              _store.id,
                              storeMap,
                              context,
                            );

                            if (!mounted) return;

                            setDialogState(() => isLoading = false);

                            if (updatedStore != null) {
                              setState(() {
                                _store = updatedStore;
                                _showActions = false;
                              });

                              Navigator.of(dialogContext).pop();
                              widget.onRefresh?.call();
                              showSuccessMessage(
                                "Boutique mise à jour avec succès !",
                                context,
                              );
                            } else {
                              showErrorMessage(
                                "La mise à jour a échoué.",
                                context,
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            setDialogState(() => isLoading = false);
                            showErrorMessage(
                              "Erreur lors de la mise à jour.",
                              context,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "Enregistrer",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      locationController.dispose();
    });
  }

  // ---------------------------------------------------------------------
  // DIALOG - Suppression boutique (Style UI 1)
  // ---------------------------------------------------------------------
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppColors.border, width: 1.2),
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
                      color: AppColors.danger,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Supprimer la boutique",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Voulez-vous vraiment supprimer '${_store.name}' ? Cette action est irréversible.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.card,
                          foregroundColor: AppColors.textDark,
                          elevation: 0,
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                          setDialogState(() => isLoading = true);

                          try {
                            await StoreService()
                                .deleteStore(_store.id, context);

                            if (!mounted) return;

                            Navigator.of(dialogContext).pop();
                            showSuccessMessage(
                              "Boutique ${_store.name} supprimée",
                              context,
                            );
                            widget.isDeleted(true);
                          } catch (e) {
                            if (!mounted) return;
                            setDialogState(() => isLoading = false);
                            showErrorMessage(
                              "Erreur lors de la suppression.",
                              context,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "Supprimer",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (_showActions) {
            setState(() => _showActions = false);
            return;
          }
          _openStoreDetails();
        },
        onLongPress: () {
          setState(() {
            _showActions = !_showActions;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _showActions ? AppColors.primary : AppColors.border,
              width: _showActions ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER DOUX ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _store.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _showActions
                                ? "Actions disponibles"
                                : "Appuyez pour ouvrir • Appui long pour gérer",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        _showActions
                            ? Icons.close_rounded
                            : Icons.chevron_right_rounded,
                        color: _showActions
                            ? AppColors.textGrey
                            : AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // --- DETAILS ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (_store.location != null &&
                                _store.location!.trim().isNotEmpty)
                                ? _store.location!
                                : "Adresse non renseignée",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13.5,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.store_mall_directory_outlined,
                          label: "Magasin",
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.verified_user_rounded,
                          label: (UserService.userType ?? '') == "employer"
                              ? "Admin"
                              : "Staff",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- ACTIONS ---
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _showActions
                    ? Container(
                  key: const ValueKey("actions"),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.edit_rounded,
                        label: "Modifier",
                        color: AppColors.primary,
                        backgroundColor: AppColors.primarySoft,
                        onTap: () {
                          setState(() => _showActions = false);
                          _showUpdateDialog(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: "Supprimer",
                        color: AppColors.danger,
                        backgroundColor: AppColors.dangerSoft,
                        onTap: () {
                          setState(() => _showActions = false);
                          _showDeleteDialog(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.close_rounded,
                        label: "Fermer",
                        color: AppColors.textGrey,
                        backgroundColor: AppColors.card,
                        onTap: () {
                          setState(() => _showActions = false);
                        },
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color == AppColors.textGrey
                      ? AppColors.textDark
                      : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Décoration des champs text - même style que WelcomeScreen
  // ---------------------------------------------------------------------
  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: AppColors.textGrey,
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 13.5,
      ),
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.danger, width: 1.6),
      ),
    );
  }
}