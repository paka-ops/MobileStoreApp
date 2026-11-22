import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/utils/color_utils.dart';
import 'package:mobile_store_app/features/stores/controllers/store_actions_controller.dart';
import 'package:mobile_store_app/features/stores/widgets/store_delete_dialog.dart';
import 'package:mobile_store_app/features/stores/widgets/store_update_dialog.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/features/store_detail/store_detail_screen.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';

/// ============================================================================
/// STORE ITEM — carte d'une boutique dans la liste d'accueil.
///
/// Rendu identique à l'original :
///   • carte arrondie (rayon 20) qui passe de `cardShadow` à `floatingShadow`
///     en 220 ms `easeOut` quand les actions sont dépliées
///   • en-tête : pastille 48 px (pastel déterministe du nom) + nom 16 / w800
///     + sous-titre contextuel + chevron dans une boîte bordée (200 ms)
///   • détails : emplacement (ou « Adresse non renseignée ») + deux chips
///     (« Magasin », « Admin »/« Staff »)
///   • actions repliées/dépliées par `AnimatedSwitcher` 220 ms : Modifier,
///     Supprimer, Fermer
///
/// Interactions conservées :
///   • appui simple → ouvre le détail, ou referme les actions si dépliées
///   • appui long → bascule les actions
///
/// Toute la logique réseau des dialogues a quitté ce widget : elle vit dans
/// [StoreActionsController] et dans les deux boîtes de dialogue dédiées.
/// ============================================================================
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
  final StoreActionsController _actions = StoreActionsController();

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

  /// Ouvre la fiche boutique en excluant la boutique courante de la liste des
  /// « autres boutiques » (même filtrage que l'original).
  void _openStoreDetails() {
    final List<Store> filteredStores = List<Store>.from(widget.otherStores)
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

  /// Ouvre le dialogue de modification (non fermable au clic extérieur).
  void _openUpdateDialog() {
    showStoreUpdateDialog(
      context: context,
      store: _store,
      actions: _actions,
      onUpdated: (Store updatedStore) {
        if (!mounted) return;
        setState(() {
          _store = updatedStore;
          _showActions = false;
        });
        widget.onRefresh?.call();
        showSuccessMessage("Boutique mise à jour avec succès !", context);
      },
    );
  }

  /// Ouvre le dialogue de suppression.
  void _openDeleteDialog() {
    showStoreDeleteDialog(
      context: context,
      store: _store,
      actions: _actions,
      onDeleted: () {
        if (!mounted) return;
        showSuccessMessage("Boutique ${_store.name} supprimée", context);
        widget.isDeleted(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        final DashColors colors = DashColors(context);

        final Color pastel = AppColorUtils.pastelForName(_store.name, colors);
        final Color pastelIcon = AppColorUtils.iconTint(pastel);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            onTap: () {
              if (_showActions) {
                setState(() => _showActions = false);
                return;
              }
              _openStoreDetails();
            },
            onLongPress: () => setState(() => _showActions = !_showActions),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow:
                    _showActions ? colors.floatingShadow : colors.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- HEADER ---
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: AppSizes.categoryIcon,
                          height: AppSizes.categoryIcon,
                          decoration: BoxDecoration(
                            color: pastel,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: pastelIcon,
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
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 16,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: colors.border),
                          ),
                          child: Icon(
                            _showActions
                                ? Icons.close_rounded
                                : Icons.chevron_right_rounded,
                            color: _showActions
                                ? colors.textSecondary
                                : colors.primary,
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
                            Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: colors.textSecondary,
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
                                style: AppTextStyles.bodySecondary.copyWith(
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
                            _StoreInfoChip(
                              icon: Icons.store_mall_directory_outlined,
                              label: "Magasin",
                              colors: colors,
                            ),
                            const SizedBox(width: 8),
                            _StoreInfoChip(
                              icon: Icons.verified_user_rounded,
                              label: (UserService.userType ?? "") == "employer"
                                  ? "Admin"
                                  : "Staff",
                              colors: colors,
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
                              color: colors.background,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: StoreActionButton(
                                    icon: Icons.edit_rounded,
                                    label: "Modifier",
                                    color: colors.fill,
                                    backgroundColor: colors.fill,
                                    labelColor: colors.textPrimary,
                                    onTap: () {
                                      setState(() => _showActions = false);
                                      _openUpdateDialog();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: StoreActionButton(
                                    icon: Icons.delete_outline_rounded,
                                    label: "Supprimer",
                                    color: AppColors.badgeRed,
                                    backgroundColor: AppColors.dangerSoft,
                                    labelColor: AppColors.badgeRed,
                                    onTap: () {
                                      setState(() => _showActions = false);
                                      _openDeleteDialog();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: StoreActionButton(
                                    icon: Icons.close_rounded,
                                    label: "Fermer",
                                    color: colors.textSecondary,
                                    backgroundColor: colors.card,
                                    labelColor: colors.textPrimary,
                                    onTap: () =>
                                        setState(() => _showActions = false),
                                  ),
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
}

/// Chip d'information du pied de carte (icône 14 + libellé 11.5 / w600).
class _StoreInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final DashColors colors;

  const _StoreInfoChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: colors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton d'action de la barre dépliée (icône 18 + libellé 10.5 / w700).
class StoreActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final Color labelColor;
  final VoidCallback onTap;

  const StoreActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
