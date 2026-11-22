import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';

/// Métadonnées d'un onglet d'historique.
class HistoryTabMeta {
  final String label;
  final String subtitle;
  final IconData icon;
  final IconData activeIcon;

  const HistoryTabMeta({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.activeIcon,
  });
}

/// ============================================================================
/// HISTORY TABS — définition des quatre historiques de la boutique.
///
/// Ordre, libellés, sous-titres et paires d'icônes strictement identiques à
/// l'écran d'origine (Ventes, Stock, Dépenses, Retraits).
///
/// [accentFor] conserve la table de couleurs par onglet :
/// ventes → `primary`, stock → `info`, dépenses → `accent`, retraits →
/// `success`, repli `primary`.
/// ============================================================================
class HistoryTabs {
  HistoryTabs._();

  static const List<HistoryTabMeta> items = <HistoryTabMeta>[
    HistoryTabMeta(
      label: "Ventes",
      subtitle: "Historique des commandes",
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    HistoryTabMeta(
      label: "Stock",
      subtitle: "Mouvements et arrivages",
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
    ),
    HistoryTabMeta(
      label: "Dépenses",
      subtitle: "Historique des dépenses",
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
    ),
    HistoryTabMeta(
      label: "Retraits",
      subtitle: "Historique des retraits",
      icon: Icons.savings_outlined,
      activeIcon: Icons.savings_rounded,
    ),
  ];

  /// Index borné sur la liste des onglets.
  static int clampIndex(int index) => index.clamp(0, items.length - 1);

  /// Couleur d'accent d'un onglet.
  static Color accentFor(int index, DashColors colors) {
    switch (index) {
      case 0:
        return colors.primary;
      case 1:
        return colors.info;
      case 2:
        return colors.accent;
      case 3:
        return colors.success;
      default:
        return colors.primary;
    }
  }
}
