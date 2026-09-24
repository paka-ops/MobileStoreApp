import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/widgets/design_system.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/screens/dashboard_screens.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors;
import '../widgets/store_item.dart';
import '../models/Store.dart';

class WelcomeScreen extends StatefulWidget {
  final List<Store> stores;
  final String userType;
  const WelcomeScreen({
    super.key,
    required this.stores,
    required this.userType,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _storeNameController    = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storeFormKey           = GlobalKey<FormState>();

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        final colors = DashColors(context);

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(colors),
                Expanded(
                  child: widget.stores.isEmpty
                      ? _buildEmptyState(colors)
                      : _buildResponsiveStoreList(),
                ),
              ],
            ),
          ),
          floatingActionButton: widget.userType == "employer"
              ? _buildAddStoreFab(context, colors)
              : null,
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // EN-TÊTE — logo + stats (ligne horizontale scrollable, anti-overflow)
  // -------------------------------------------------------------------------
  Widget _buildHeader(DashColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colors.card,
                  shape: BoxShape.circle,
                  boxShadow: colors.cardShadow,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/boutika.png',
                    height: 38,
                    width: 38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "BouTiKa",
                      style: AppTextStyles.brand
                          .copyWith(color: colors.textPrimary),
                    ),
                    Text(
                      "Mes Boutiques",
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        color: colors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: appDarkMode,
                builder: (context, isDark, _) => IconButton(
                  tooltip: isDark
                      ? 'Activer le thème clair'
                      : 'Activer le thème sombre',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 40, minHeight: 40),
                  onPressed: () => appDarkMode.value = !isDark,
                  icon: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Chips d'info — ScrollView horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHeaderStatChip(
                  colors,
                  icon: Icons.inventory_2_rounded,
                  label: "${widget.stores.length}",
                  sub: widget.stores.length > 1 ? "Boutiques" : "Boutique",
                ),
                const SizedBox(width: 8),
                _buildHeaderStatChip(
                  colors,
                  icon: Icons.verified_user_rounded,
                  label: widget.userType == "employer" ? "Admin" : "Staff",
                  sub: "Statut",
                ),
                if (widget.userType == "employer") ...[
                  const SizedBox(width: 8),
                  _buildHeaderStatChip(
                    colors,
                    icon: Icons.query_stats,
                    buttonIcon: Icons.query_stats,
                    label: "Dashboard",
                    sub: "Info rapide",
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CHIP D'EN-TÊTE
  // -------------------------------------------------------------------------
  Widget _buildHeaderStatChip(
      DashColors colors, {
        required IconData icon,
        required String label,
        required String sub,
        IconData? buttonIcon,
      }) {
    return Container(
      padding: EdgeInsets.only(
        left: buttonIcon != null ? 4 : 12,
        right: 12,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (buttonIcon != null)
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                ),
                icon: Icon(buttonIcon, color: colors.primary, size: 16),
              ),
            )
          else
            Icon(icon, color: colors.primary, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1.1,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // LISTE RESPONSIVE
  // -------------------------------------------------------------------------
  Widget _buildResponsiveStoreList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        if (isWide) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: widget.stores.length,
            itemBuilder: (context, index) => StoreItem(
              store: widget.stores[index],
              otherStores: widget.stores,
              isDeleted: (value) {
                if (value) setState(() => widget.stores.removeAt(index));
              },
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
          itemCount: widget.stores.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: StoreItem(
              store: widget.stores[index],
              otherStores: widget.stores,
              isDeleted: (value) {
                if (value) setState(() => widget.stores.removeAt(index));
              },
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // FAB
  // -------------------------------------------------------------------------
  Widget _buildAddStoreFab(BuildContext context, DashColors colors) {
    return SizedBox(
      width: 190,
      height: 54,
      child: FloatingActionButton.extended(
        onPressed: () => _showAddStoreForm(context, colors),
        backgroundColor: colors.buttonPrimary,
        foregroundColor: colors.buttonOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          "Nouvelle boutique",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // DIALOG — Ajouter une boutique (logique inchangée)
  // -------------------------------------------------------------------------
  void _showAddStoreForm(BuildContext context, DashColors colors) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (ctx, state) {
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: colors.border),
          ),
          titlePadding:   const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                child: Icon(Icons.add_business_rounded,
                    color: colors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Nouvelle Boutique",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading.copyWith(fontSize: 17.5, color: colors.textPrimary),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _storeFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: _storeNameController,
                    textInputAction: TextInputAction.next,
                    label: "Nom de la boutique",
                    icon: Icons.storefront_rounded,
                    hint: "Ex: Boutique Centre-ville",
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Le nom est obligatoire'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _storeAddressController,
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
                    onPressed: isLoading
                        ? null
                        : () {
                      _storeNameController.clear();
                      _storeAddressController.clear();
                      state(() => isLoading = false);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    label: "Créer la boutique",
                    height: 48,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () async {
                      if (!_storeFormKey.currentState!
                          .validate()) return;

                      state(() => isLoading = true);
                      try {
                        final storeData = {
                          "name":
                          _storeNameController.text,
                          "location":
                          _storeAddressController.text,
                          "employee":   null,
                          "employer":   null,
                          "categories": null,
                        };
                        final store = await StoreService()
                            .addStore(storeData, context);

                        if (mounted)
                          state(() => isLoading = false);

                        if (store != null) {
                          setState(() =>
                              widget.stores.add(store));
                          Navigator.pop(ctx);
                          _storeNameController.clear();
                          _storeAddressController.clear();
                          showSuccessMessage(
                              "Boutique créée avec succès !",
                              context);
                        } else {
                          showErrorMessage(
                              "La création a échoué.",
                              context);
                        }
                      } catch (e) {
                        if (mounted)
                          state(() => isLoading = false);
                        showErrorMessage(
                            "Erreur de connexion au serveur.",
                            context);
                        print("Erreur lors de l'ajout: $e");
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  // -------------------------------------------------------------------------
  // EMPTY STATE
  // -------------------------------------------------------------------------
  Widget _buildEmptyState(DashColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primarySoft,
                boxShadow: colors.cardShadow,
              ),
              child: Icon(Icons.storefront_rounded,
                  size: 60, color: colors.primary),
            ),
            const SizedBox(height: 34),
            Text(
              "Aucune boutique trouvée",
              style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              widget.userType == "employer"
                  ? "Créez votre première boutique pour commencer"
                  " à piloter votre stock en temps réel."
                  : "Vous n'êtes rattaché à aucune boutique pour le moment.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: colors.textSecondary,
                height: 1.55,
              ),
            ),
            if (widget.userType == "employer") ...[
              const SizedBox(height: 28),
              PrimaryButton(
                label: "Créer une boutique",
                icon: Icons.add_rounded,
                expand: false,
                onPressed: () {
                  final colors = DashColors(context);
                  _showAddStoreForm(context, colors);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
