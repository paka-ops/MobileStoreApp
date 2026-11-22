import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/shared/models/product.dart';

/// ============================================================================
/// PRODUCT STATS — agrégats statistiques d'un produit.
///
/// `restockHistory` conserve la liste brute renvoyée par le service, comme dans
/// l'écran d'origine (les champs y sont lus à l'affichage).
/// ============================================================================
class ProductStats {
  final double totalSold;
  final double totalEntered;
  final double revenue;
  final double ca;
  final List<dynamic> restockHistory;

  const ProductStats({
    required this.totalSold,
    required this.totalEntered,
    required this.revenue,
    required this.restockHistory,
    required this.ca,
  });
}

/// Mouvement de restockage prêt à l'affichage.
class RestockMovement {
  final String dateLabel;
  final double quantityAdded;
  final double buyingPrice;
  final double sellingPrice;
  final double totalSell;

  const RestockMovement({
    required this.dateLabel,
    required this.quantityAdded,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.totalSell,
  });
}

/// ============================================================================
/// PRODUCT STOCK STATUS — état de stock avec les libellés de cet écran.
///
/// Seuils identiques aux autres écrans (≤ 5, ≤ 15) mais libellés propres :
/// « Stock critique » / « Stock bas » / « Stock sain ».
/// ============================================================================
class ProductStockStatus {
  final double quantity;

  const ProductStockStatus(this.quantity);

  bool get isCritical => quantity <= 5;

  bool get isLow => quantity <= 15;

  String get label {
    if (isCritical) return "Stock critique";
    if (isLow) return "Stock bas";
    return "Stock sain";
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

/// ============================================================================
/// PRODUCT STATS CALCULATOR — calculs purs des statistiques produit.
///
/// Formules **strictement** identiques à l'écran d'origine :
///   • `totalSold    = Σ totalSell`
///   • `totalEntered = Σ (baseStock − previousStock)`
///   • `revenue      = Σ (totalSell × sellingPrice − totalSell × buyingPrice)`
///   • `ca           = Σ (totalSell × sellingPrice)`
///   • `saleRate     = totalEntered > 0 ? totalSold / totalEntered × 100 : 0`
///   • `remaining    = (baseStock − totalSell)` borné à `[0, +∞)`
///
/// Les champs absents ou non numériques valent `0.0` (`?? 0.0` d'origine), et
/// une date illisible reste « Date inconnue ».
/// ============================================================================
class ProductStatsCalculator {
  ProductStatsCalculator._();

  static ProductStats fromRaw(List<dynamic> data) {
    double totalSold = 0.0;
    double totalEntered = 0.0;
    double revenue = 0.0;
    double ca = 0.0;

    for (final dynamic stock in data) {
      final double sold = (stock['totalSell'] as num?)?.toDouble() ?? 0.0;
      final double baseStock =
          (stock['baseStock'] as num?)?.toDouble() ?? 0.0;
      final double previousStock =
          (stock['previousStock'] as num?)?.toDouble() ?? 0.0;
      final double sellingPrice =
          (stock['sellingPrice'] as num?)?.toDouble() ?? 0.0;
      final double buyingPrice =
          (stock['buyingPrice'] as num?)?.toDouble() ?? 0.0;

      totalSold += sold;
      totalEntered += baseStock - previousStock;
      revenue += sold * sellingPrice - sold * buyingPrice;
      ca += sold * sellingPrice;
    }

    return ProductStats(
      totalSold: totalSold,
      totalEntered: totalEntered,
      revenue: revenue,
      restockHistory: data,
      ca: ca,
    );
  }

  /// Stock restant d'un produit (jamais négatif).
  static double remainingStock(Product product) {
    final double baseStock =
        (product.stock?.baseStock ?? 0).toDouble();
    final double totalSell = (product.stock?.totalSell ?? 0).toDouble();
    return (baseStock - totalSell).clamp(0, double.infinity);
  }

  /// Taux de vente en pourcentage.
  static double saleRate(ProductStats stats) => stats.totalEntered > 0
      ? (stats.totalSold / stats.totalEntered) * 100
      : 0;

  /// Montant compact : `1.2M F`, `12K F`, `850 F`.
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M F";
    }
    if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K F";
    }
    return "${amount.toStringAsFixed(0)} F";
  }

  /// Transforme un mouvement brut du service en vue affichable.
  static RestockMovement movementFrom(dynamic item) {
    String date = "Date inconnue";
    if (item['createdAt'] != null) {
      try {
        date = DateFormat('dd MMM yyyy').format(DateTime.parse(item['createdAt']));
      } catch (_) {
        // Date illisible : libellé de repli conservé.
      }
    }

    return RestockMovement(
      dateLabel: date,
      quantityAdded: (item['quantityAdded'] as num?)?.toDouble() ?? 0.0,
      buyingPrice: (item['buyingPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (item['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      totalSell: (item['totalSell'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
