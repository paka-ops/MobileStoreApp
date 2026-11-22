import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';

/// En-tête des statistiques produit : nom du produit, sous-titre et bouton
/// d'actualisation (mêmes constantes que l'écran d'origine).
class ProductStatsHeader extends StatelessWidget {
  final String productName;
  final VoidCallback onRefresh;

  const ProductStatsHeader({
    super.key,
    required this.productName,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AppScreenHeader(
      title: productName,
      subtitle: "Statistiques du produit",
      actions: [
        AppIconButton(
          icon: Icons.refresh_rounded,
          tooltip: "Actualiser",
          onTap: onRefresh,
        ),
      ],
    );
  }
}
