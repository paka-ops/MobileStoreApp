import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/dashboard_screens.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show appDarkMode, DashColors;
import '../widgets/store_item.dart';
import '../models/Store.dart';

class WelcomeScreen extends StatefulWidget {
  final List<Store> stores;
  final String userType;
  const WelcomeScreen({super.key, required this.stores, required this.userType});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();
  final _storeFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- EN-TÊTE : Logo et Titre (façon UI 1) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/boutika.png',
                      height: 42,
                      width: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "BouTiKa",
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Mes Boutiques",
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ValueListenableBuilder<bool>(
                    valueListenable: appDarkMode,
                    builder: (context, isDark, _) => IconButton(
                      tooltip: isDark ? 'Activer le thème clair' : 'Activer le thème sombre',
                      onPressed: () => appDarkMode.value = !isDark,
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  _buildHeaderStatChip(colors,
                    icon: Icons.inventory_2_rounded,
                    label: "${widget.stores.length}",
                    sub: widget.stores.length > 1 ? "Boutiques" : "Boutique",
                  ),
                  const SizedBox(width: 10),
                  _buildHeaderStatChip(colors,
                    icon: Icons.verified_user_rounded,
                    label: widget.userType == "employer" ? "Admin" : "Staff",
                    sub: "Statut",
                  ),
                  if (widget.userType == "employer") ...[
                    const SizedBox(width: 10),
                    _buildHeaderStatChip(colors,
                      icon: Icons.query_stats,
                      buttonIcon: Icons.query_stats,
                      label: "Dashboard",
                      sub: "Information rapide",
                    ),
                  ],
                ],
              ),
            ),

            // --- CORPS CENTRAL : Liste ou Empty State ---
            Expanded(
              child: widget.stores.isEmpty
                  ? _buildEmptyState(colors)
                  : _buildResponsiveStoreList(),
            ),
          ],
        ),
      ),
      floatingActionButton: (widget.userType == "employer")
          ? _buildAddStoreFab(context, colors)
          : null,
    );
  }

  Widget _buildHeaderStatChip(DashColors colors,
      {required IconData icon, required String label, required String sub, IconData? buttonIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        children: [
          (buttonIcon != null)? IconButton(onPressed: (){Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(),
            ),
          );}, icon: Icon(buttonIcon, color: colors.primary, size: 16)) : Icon(icon, color: colors.primary, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
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
                if (value) {
                  setState(() {
                    widget.stores.removeAt(index);
                  });
                }
              },
            ),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
            itemCount: widget.stores.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: StoreItem(
                store: widget.stores[index],
                otherStores: widget.stores,
                isDeleted: (value) {
                  if (value) {
                    setState(() {
                      widget.stores.removeAt(index);
                    });
                  }
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildAddStoreFab(BuildContext context, DashColors colors) {
    return SizedBox(
      width: 190,
      height: 54,
      child: FloatingActionButton.extended(
        onPressed: () => _showAddStoreForm(context, colors),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          "Nouvelle boutique",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAddStoreForm(BuildContext context, DashColors colors) {
    bool isLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (stcontext, state) {
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.border, width: 1.2),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Row(
            children: [
              Icon(Icons.add_business_rounded, color: colors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                "Nouvelle Boutique",
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
                        color: colors.textPrimary),
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(colors,
                      label: "Nom de la boutique",
                      icon: Icons.storefront_rounded,
                      hint: "Ex: Boutique Centre-ville",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _storeAddressController,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        color: colors.textPrimary),
                    decoration: _fieldDecoration(colors,
                      label: "Emplacement / Adresse",
                      icon: Icons.location_on_rounded,
                      hint: "Ex: Rue 12, Douala",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez préciser l\'emplacement';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colors.card,
                      foregroundColor: colors.textPrimary,
                      elevation: 0,
                      side: BorderSide(color: colors.border, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isLoading ? null : () {
                      _storeNameController.clear();
                      _storeAddressController.clear();
                      state(() {
                        isLoading = false;
                      });
                      Navigator.pop(context);
                    },
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      if (_storeFormKey.currentState!.validate()) {
                        state(() {
                          isLoading = true;
                        });

                        try {
                          StoreService storeService = StoreService();
                          Map<String, dynamic> storeData = {
                            "name": _storeNameController.text,
                            "location": _storeAddressController.text,
                            "employee": null,
                            "employer": null,
                            "categories": null,
                          };
                          Store? store = await storeService.addStore(storeData, context);

                          if (mounted) {
                            state(() {
                              isLoading = false;
                            });
                          }

                          if (store != null) {
                            setState(() {
                              widget.stores.add(store);
                            });
                            Navigator.pop(context);
                            _storeNameController.clear();
                            _storeAddressController.clear();
                            showSuccessMessage("Boutique créée avec succès !", context);
                          } else {
                            showErrorMessage("La création a échoué.", context);
                          }
                        } catch (e) {
                          if (mounted) {
                            state(() {
                              isLoading = false;
                            });
                            showErrorMessage("Erreur de connexion au serveur.", context);
                          }
                          print("Erreur lors de l'ajout: $e");
                        }
                      }
                    },
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
                      "Créer la boutique",
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
      }),
    );
  }

  Widget _buildEmptyState(DashColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: colors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 70,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Aucune boutique trouvée",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.userType == "employer"
                  ? "Créez votre première boutique pour commencer à piloter votre stock en temps réel."
                  : "Vous n'êtes rattaché à aucune boutique pour le moment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (widget.userType == "employer") ...[
              const SizedBox(height: 30),
              SizedBox(
                width: 250,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _showAddStoreForm(context, colors),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Créer une boutique",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(DashColors colors, {
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
          color: colors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13.5),
      hintStyle: TextStyle(color: colors.textSecondary, fontSize: 13.5),
      filled: true,
      fillColor: colors.background,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(icon, color: colors.primary, size: 20),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.danger, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.danger, width: 1.6),
      ),
    );
  }
}
