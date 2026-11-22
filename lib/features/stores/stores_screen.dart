import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/features/stores/controllers/stores_controller.dart';
import 'package:mobile_store_app/features/stores/widgets/add_store_dialog.dart';
import 'package:mobile_store_app/features/stores/widgets/stores_add_fab.dart';
import 'package:mobile_store_app/features/stores/widgets/stores_empty_state.dart';
import 'package:mobile_store_app/features/stores/widgets/stores_header.dart';
import 'package:mobile_store_app/features/stores/widgets/stores_list_view.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/features/dashboard/dashboard_screen.dart';
import 'package:mobile_store_app/utils/message.dart';

/// ============================================================================
/// WELCOME SCREEN — liste des boutiques de l'utilisateur connecté.
///
/// Structure identique à l'écran d'origine :
///   Scaffold → SafeArea → Column[en-tête + chips, liste ou état vide]
///   + FAB « Nouvelle boutique » pour un employeur
///
/// L'état (liste, création, suppression) vit dans [StoresController] ; chaque
/// écran de liste passe la **même instance** de liste que celle reçue de la
/// connexion, comme auparavant.
///
/// Comportements conservés :
///   • compteur de boutiques et libellé singulier / pluriel dans l'en-tête
///   • chip « Dashboard » (employeur) → `DashboardScreen`
///   • création via dialogue, rafraîchissement immédiat, message de succès
///   • suppression depuis une carte, retrait à l'index affiché
///   • réaction à la bascule clair / sombre
/// ============================================================================
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
  late final StoresController _controller =
      StoresController(stores: widget.stores);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Ouvre le dialogue de création puis affiche le message de succès.
  void _openAddStoreForm() {
    showAddStoreDialog(
      context: context,
      controller: _controller,
      onCreated: (_) {
        if (!mounted) return;
        showSuccessMessage("Boutique créée avec succès !", context);
      },
    );
  }

  void _openDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final DashColors colors = DashColors(context);
            final List<Store> stores = _controller.stores;

            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    StoresHeader(
                      userType: widget.userType,
                      storeCount: _controller.count,
                      onOpenDashboard: _openDashboard,
                    ),
                    Expanded(
                      child: stores.isEmpty
                          ? StoresEmptyState(
                              userType: widget.userType,
                              onCreateStore: _openAddStoreForm,
                            )
                          : StoresListView(
                              stores: stores,
                              onDeleteAt: _controller.removeAt,
                            ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: widget.userType == "employer"
                  ? StoresAddFab(onPressed: _openAddStoreForm)
                  : null,
            );
          },
        );
      },
    );
  }
}
