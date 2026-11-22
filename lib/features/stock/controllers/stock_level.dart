import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/models/product.dart';

/// ============================================================================
/// STOCK LEVEL — niveau de stock d'un produit et ses libellés associés.
///
/// Quantité affichée : `stock.baseStock − stock.totalSell` (formule d'origine).
/// Seuils d'état (identiques) :
///   • `≤ 5`  → « Critique », `danger` / `dangerSoft`
///   • `≤ 15` → « Bas », `warning` / `warningSoft`
///   • sinon  → « Normal », `success` / `successSoft`
/// ============================================================================
class StockLevel {
  final double quantity;

  const StockLevel(this.quantity);

  /// Niveau de stock d'un produit (accès non nul comme dans l'original).
  factory StockLevel.of(Product product) => StockLevel(
        (product.stock!.baseStock - product.stock!.totalSell).toDouble(),
      );

  bool get isCritical => quantity <= 5;

  bool get isLow => quantity <= 15;

  /// Libellé d'état.
  String get label {
    if (isCritical) return "Critique";
    if (isLow) return "Bas";
    return "Normal";
  }

  Color color(DashColors colors) {
    if (isCritical) return colors.danger;
    if (isLow) return colors.warning;
    return colors.success;
  }

  Color softColor(DashColors colors) {
    if (isCritical) return colors.dangerSoft;
    if (isLow) return colors.warningSoft;
    return colors.successSoft;
  }
}
