import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';

/// ============================================================================
/// STORES ADD FAB — bouton flottant « Nouvelle boutique » (employeur).
///
/// Largeur fixe 190 px, hauteur 54 px, élévation 4, rayon pilule, libellé
/// 15 / w700 et icône 22 : constantes identiques à l'original.
/// ============================================================================
class StoresAddFab extends StatelessWidget {
  final VoidCallback onPressed;

  const StoresAddFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return SizedBox(
      width: 190,
      height: 54,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: colors.buttonPrimary,
        foregroundColor: colors.buttonOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          "Nouvelle boutique",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
