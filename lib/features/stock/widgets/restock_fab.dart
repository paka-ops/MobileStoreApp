import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';

/// ============================================================================
/// RESTOCK FAB — bouton flottant « Nouvel Arrivage ».
///
/// `heroTag` fixe `restock_history_add_fab`, forme arrondie 16, couleurs
/// `primary`/`onPrimary` : identiques à l'original.
///
/// L'action reste volontairement sans effet, comme dans l'application
/// d'origine où le bouton n'était pas encore relié à un formulaire.
/// ============================================================================
class RestockFab extends StatelessWidget {
  const RestockFab({super.key});

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return FloatingActionButton.extended(
      heroTag: "restock_history_add_fab",
      onPressed: () {},
      label: const Text("Nouvel Arrivage"),
      icon: const Icon(Icons.add_business_outlined),
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}
