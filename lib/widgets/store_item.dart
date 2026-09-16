import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/store_page.dart' hide AppColors;
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors, PremiumRadii;
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/widgets/premium_kit.dart';
import '../models/Store.dart';
import 'package:mobile_store_app/widgets/boutika_loader.dart';

// =====================================================================
// CARTE BOUTIQUE — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : ouverture du détail, mise à jour, suppression,
// bascule des actions (appui long) — tout est conservé à l'identique.
// Seule la présentation change (bandeau dégradé, hiérarchie, dialogues).
// =====================================================================
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
    final filteredStores = List<Store>.from(widget.otherStores)
      ..removeWhere((item) => item.id == _store.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreDetailScreen(
          store: _store,
          userType: UserService.userType ?? '',
          otherStores: filteredStores,
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // DIALOG — Mise à jour boutique (logique strictement inchangée)
  // -----------------------------------------------------------------------
  void _showUpdateDialog(BuildContext context, DashColors colors) {
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
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colors.border, width: 1),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              title: Row(
                children: [
                  PremiumIconTile(
                    icon: Icons.edit_rounded,
                    color: colors.primary,
                    softColor: colors.primarySoft,
                    size: 46,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Modifier la boutique",
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Nom et adresse visibles par l'équipe",
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: colors.textPrimary,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration(
                          label: "Nom de la boutique",
                          icon: Icons.storefront_rounded,
                          hint: "Ex: Boutique Centre-ville",
                          colors: colors,
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? "Le nom est obligatoire"
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: locationController,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: colors.textPrimary,
                        ),
                        decoration: _fieldDecoration(
                          label: "Emplacement / Adresse",
                          icon: Icons.location_on_rounded,
                          hint: "Ex: Rue 12, Douala",
                          colors: colors,
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? "Veuillez préciser l'emplacement"
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Callbacks strictement inchangés — présentation 52 px.
                PremiumDialogActions(
                  confirmLabel: "Enregistrer",
                  onCancel: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  onConfirm: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isLoading = true);
                          try {
                            final storeMap = {
                              "name": nameController.text.trim(),
                              "location": locationController.text.trim(),
                            };
                            final updatedStore =
                                await StoreService().updateStore(
                                    _store.id, storeMap, context);

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
                                  context);
                            } else {
                              showErrorMessage(
                                  "La mise à jour a échoué.", context);
                            }
                          } catch (e) {
                            if (!mounted) return;
                            setDialogState(() => isLoading = false);
                            showErrorMessage(
                                "Erreur lors de la mise à jour.", context);
                          }
                        },
                  confirmLoading: isLoading
                      ? const BouTikaLoader.compact()
                      : null,
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // On attend que Flutter ait terminé de retirer le dialogue
      WidgetsBinding.instance.addPostFrameCallback((_) {
        nameController.dispose();
        locationController.dispose();
      });
    });
  }

  // -----------------------------------------------------------------------
  // DIALOG — Suppression boutique (logique strictement inchangée)
  // -----------------------------------------------------------------------
  void _showDeleteDialog(BuildContext context, DashColors colors) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colors.border, width: 1),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Médaillon danger feutré (thème courant, plus de fixe).
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: colors.dangerSoft,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.danger.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: colors.danger,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Supprimer la boutique",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Voulez-vous vraiment supprimer '${_store.name}' ?"
                    " Cette action est irréversible.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13.5,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
              actions: [
                // Proportions d'origine conservées — callbacks inchangés.
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(dialogContext).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colors.card,
                            foregroundColor: colors.textPrimary,
                            elevation: 0,
                            side: BorderSide(
                                color: colors.border, width: 1.2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    PremiumRadii.input)),
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
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
                                        context);
                                    widget.isDeleted(true);
                                  } catch (e) {
                                    if (!mounted) return;
                                    setDialogState(
                                        () => isLoading = false);
                                    showErrorMessage(
                                        "Erreur lors de la suppression.",
                                        context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.danger,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    PremiumRadii.input)),
                          ),
                          child: isLoading
                              ? const BouTikaLoader.compact()
                              : const Text(
                                  "Supprimer",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
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

  // =========================================================================
  // BUILD — mêmes gestes (tap / appui long), présentation premium
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        final colors = DashColors(context);

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
            onLongPress: () => setState(() => _showActions = !_showActions),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showActions
                      ? colors.primary.withOpacity(0.55)
                      : colors.border,
                  width: _showActions ? 1.5 : 1,
                ),
                boxShadow: colors.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- BANDEAU HÉRO : dégradé émeraude feutré ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primarySoft,
                          colors.primarySoft.withOpacity(0.35),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(19)),
                    ),
                    child: Row(
                      children: [
                        // Pastille boutique blanche sur voile émeraude.
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(
                                PremiumRadii.sm),
                            border: Border.all(color: colors.border),
                            boxShadow: colors.cardShadow,
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: colors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _store.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _showActions
                                    ? "Actions disponibles"
                                    : "Appuyez pour ouvrir • Appui long pour gérer",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _showActions
                                ? colors.card
                                : colors.primary,
                            borderRadius: BorderRadius.circular(12),
                            border: _showActions
                                ? Border.all(color: colors.border)
                                : null,
                            boxShadow: _showActions
                                ? null
                                : colors.glowShadow,
                          ),
                          child: Icon(
                            _showActions
                                ? Icons.close_rounded
                                : Icons.arrow_forward_rounded,
                            color: _showActions
                                ? colors.textSecondary
                                : Colors.white,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- DÉTAILS ---
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (_store.location != null &&
                                        _store.location!
                                            .trim()
                                            .isNotEmpty)
                                    ? _store.location!
                                    : "Adresse non renseignée",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textSecondary,
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
                              icon:
                                  Icons.store_mall_directory_outlined,
                              label: "Magasin",
                              colors: colors,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              icon: Icons.verified_user_rounded,
                              label: (UserService.userType ?? '') ==
                                      "employer"
                                  ? "Admin"
                                  : "Staff",
                              colors: colors,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- ACTIONS (appui long) : mêmes callbacks ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: _showActions
                        ? Container(
                            key: const ValueKey("actions"),
                            margin: const EdgeInsets.fromLTRB(
                                16, 0, 16, 16),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius:
                                  BorderRadius.circular(16),
                              border:
                                  Border.all(color: colors.border),
                            ),
                            child: Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.edit_rounded,
                                  label: "Modifier",
                                  color: colors.primary,
                                  backgroundColor:
                                      colors.primarySoft,
                                  borderColor: colors.border,
                                  labelColor: colors.primary,
                                  onTap: () {
                                    setState(
                                        () => _showActions = false);
                                    _showUpdateDialog(
                                        context, colors);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon:
                                      Icons.delete_outline_rounded,
                                  label: "Supprimer",
                                  color: colors.danger,
                                  backgroundColor:
                                      colors.dangerSoft,
                                  borderColor: colors.border,
                                  labelColor: colors.danger,
                                  onTap: () {
                                    setState(
                                        () => _showActions = false);
                                    _showDeleteDialog(
                                        context, colors);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.close_rounded,
                                  label: "Fermer",
                                  color: colors.textSecondary,
                                  backgroundColor: colors.card,
                                  borderColor: colors.border,
                                  labelColor: colors.textPrimary,
                                  onTap: () => setState(
                                      () => _showActions = false),
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
      },
    );
  }

  // -----------------------------------------------------------------------
  // WIDGETS HELPERS — présentation uniquement
  // -----------------------------------------------------------------------
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required DashColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
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
    required Color borderColor,
    required Color labelColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: labelColor,
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

  // -----------------------------------------------------------------------
  // DÉCORATION DES CHAMPS TEXTE — même signature, rendu premium
  // -----------------------------------------------------------------------
  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    required String hint,
    required DashColors colors,
  }) {
    return colors.fieldDecoration(label: label, icon: icon, hint: hint);
  }
}
