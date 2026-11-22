import 'package:mobile_store_app/models/order.dart';

/// ============================================================================
/// GENERAL REPORT METRICS — agrégats d'un rapport général.
///
/// Champs typés comme les valeurs calculées d'origine (deux `double` + un
/// `int`) : l'affichage `"$sales CFA"` produit donc exactement les mêmes
/// chaînes qu'avant (« 0.0 CFA », « 2500.0 CFA », …).
/// ============================================================================
class GeneralReportMetrics {
  /// Chiffre d'affaires cumulé (prix de vente × quantités).
  final double sales;

  /// Nombre de commandes.
  final int totalOrder;

  /// Panier moyen (CA / commandes, 0 si aucune commande).
  final double panierMoyen;

  /// Bénéfice cumulé ((vente − achat) × quantités).
  final double revenue;

  const GeneralReportMetrics({
    required this.sales,
    required this.totalOrder,
    required this.panierMoyen,
    required this.revenue,
  });
}

/// ============================================================================
/// GENERAL REPORT CALCULATOR — calculs purs du rapport général.
///
/// Formules **strictement** identiques à l'écran d'origine :
///   • `sales   = Σ (sellingPrice × quantité)`
///   • `revenue = Σ ((sellingPrice − buyingPrice) × quantité)`
///   • `panierMoyen = commandes > 0 ? sales / commandes : 0.0`
///
/// `sellingPrice` et `buyingPrice` sont nullable dans le modèle : `?? 0`
/// conserve la valeur de repli d'origine.
/// ============================================================================
class GeneralReportCalculator {
  GeneralReportCalculator._();

  static GeneralReportMetrics compute(List<Order> orders) {
    double totalSales = 0;
    double totalRevenue = 0;

    for (final Order order in orders) {
      order.products.forEach((product, quantity) {
        final double sellingPrice = product.stock?.sellingPrice ?? 0;
        final double buyingPrice = product.stock?.buyingPrice ?? 0;
        totalSales += sellingPrice * quantity;
        totalRevenue += (sellingPrice - buyingPrice) * quantity;
      });
    }

    final int totalOrders = orders.length;
    final double panierMoyen = totalOrders > 0 ? totalSales / totalOrders : 0.0;

    return GeneralReportMetrics(
      sales: totalSales,
      totalOrder: totalOrders,
      panierMoyen: panierMoyen,
      revenue: totalRevenue,
    );
  }
}
