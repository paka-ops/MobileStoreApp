import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/dashboard_screens.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors, PremiumRadii;
import 'package:mobile_store_app/widgets/premium_kit.dart';
import '../widgets/store_item.dart';
import '../models/Store.dart';
import 'package:mobile_store_app/widgets/boutika_loader.dart';

// =====================================================================
// MES BOUTIQUES — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : contrôleurs, formulaires, callbacks de création,
// navigation dashboard et suppression — tout est conservé. Seule la
// présentation change (en-tête, chips, carte vide, dialogue premium).
// =====================================================================
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
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storeFormKey = GlobalKey<FormState>();

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
          backgroundColor: colors.background,
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
  // EN-TÊTE — médaillon dégradé + chips d'info défilantes
  // -------------------------------------------------------------------------
  Widget _buildHeader(DashColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LIGNE 1 : Logo + Nom app + bouton thème
          Row(
            children: [
              // Médaillon de marque avec halo émeraude.
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: colors.primaryGradient,
                  borderRadius: BorderRadius.circular(PremiumRadii.sm),
                  boxShadow: colors.glowShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(PremiumRadii.sm),
                  child: Image.asset(
                    'assets/images/boutika.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Textes — Expanded pour absorber l'espace libre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "BouTiKa",
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      "Mes Boutiques",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton bascule de thème — carte feutrée 44 px.
              ValueListenableBuilder<bool>(
                valueListenable: appDarkMode,
                builder: (context, isDark, _) => Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(PremiumRadii.sm),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: IconButton(
                    tooltip: isDark
                        ? 'Activer le thème clair'
                        : 'Activer le thème sombre',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 44, minHeight: 44),
                    onPressed: () => appDarkMode.value = !isDark,
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // LIGNE 2 : Chips d'info — défilement horizontal anti-overflow.
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
  // CHIP D'EN-TÊTE — pastille feutrée, icône douce
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
        left: buttonIcon != null ? 6 : 12,
        right: 14,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône normale ou bouton selon le cas (callback inchangé).
          if (buttonIcon != null)
            SizedBox(
              width: 34,
              height: 34,
              child: Material(
                color: colors.primarySoft,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardScreen()),
                  ),
                  child: Icon(buttonIcon, color: colors.primary, size: 17),
                ),
              ),
            )
          else
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colors.primary, size: 17),
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
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
  // LISTE RESPONSIVE — logique inchangée
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
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
  // FAB — pastille émeraude avec halo (callback inchangé)
  // -------------------------------------------------------------------------
  Widget _buildAddStoreFab(BuildContext context, DashColors colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        boxShadow: colors.glowShadow,
      ),
      child: SizedBox(
        width: 196,
        height: 54,
        child: FloatingActionButton.extended(
          onPressed: () => _showAddStoreForm(context, colors),
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PremiumRadii.input)),
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            "Nouvelle boutique",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // DIALOG — Ajouter une boutique (logique strictement inchangée)
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
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colors.border, width: 1),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          title: Row(
            children: [
              PremiumIconTile(
                icon: Icons.add_business_rounded,
                color: colors.primary,
                softColor: colors.primarySoft,
                size: 44,
                iconSize: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nouvelle boutique",
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Elle apparaîtra dans votre liste",
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
              key: _storeFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _storeNameController,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: colors.textPrimary,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(
                      colors,
                      label: "Nom de la boutique",
                      icon: Icons.storefront_rounded,
                      hint: "Ex: Boutique Centre-ville",
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Le nom est obligatoire'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _storeAddressController,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: colors.textPrimary,
                    ),
                    decoration: _fieldDecoration(
                      colors,
                      label: "Emplacement / Adresse",
                      icon: Icons.location_on_rounded,
                      hint: "Ex: Rue 12, Douala",
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? "Veuillez préciser l'emplacement"
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Boutons 52 px — callbacks strictement inchangés.
            PremiumDialogActions(
              confirmLabel: "Créer la boutique",
              onCancel: isLoading
                  ? null
                  : () {
                      _storeNameController.clear();
                      _storeAddressController.clear();
                      state(() => isLoading = false);
                      Navigator.pop(ctx);
                    },
              onConfirm: isLoading
                  ? null
                  : () async {
                      if (!_storeFormKey.currentState!.validate()) return;

                      state(() => isLoading = true);
                      try {
                        final storeData = {
                          "name": _storeNameController.text,
                          "location": _storeAddressController.text,
                          "employee": null,
                          "employer": null,
                          "categories": null,
                        };
                        final store = await StoreService()
                            .addStore(storeData, context);

                        if (mounted) state(() => isLoading = false);

                        if (store != null) {
                          setState(() => widget.stores.add(store));
                          Navigator.pop(ctx);
                          _storeNameController.clear();
                          _storeAddressController.clear();
                          showSuccessMessage(
                              "Boutique créée avec succès !", context);
                        } else {
                          showErrorMessage(
                              "La création a échoué.", context);
                        }
                      } catch (e) {
                        if (mounted) state(() => isLoading = false);
                        showErrorMessage(
                            "Erreur de connexion au serveur.", context);
                        print("Erreur lors de l'ajout: $e");
                      }
                    },
              confirmLoading: isLoading
                  ? const BouTikaLoader.compact()
                  : null,
            ),
          ],
        );
      }),
    );
  }

  // -------------------------------------------------------------------------
  // ÉTAT VIDE — médaillon premium (callback inchangé)
  // -------------------------------------------------------------------------
  Widget _buildEmptyState(DashColors colors) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
        child: PremiumEmptyState(
          icon: Icons.storefront_rounded,
          title: "Aucune boutique trouvée",
          message: widget.userType == "employer"
              ? "Créez votre première boutique pour commencer"
                  " à piloter votre stock en temps réel."
              : "Vous n'êtes rattaché à aucune boutique pour le moment.",
          actionLabel:
              widget.userType == "employer" ? "Créer une boutique" : null,
          onAction: widget.userType == "employer"
              ? () {
                  final colors = DashColors(context);
                  _showAddStoreForm(context, colors);
                }
              : null,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // DÉCORATION CHAMPS TEXTE — même signature, rendu premium
  // -------------------------------------------------------------------------
  InputDecoration _fieldDecoration(
    DashColors colors, {
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return colors.fieldDecoration(label: label, icon: icon, hint: hint);
  }
}
