import 'package:mobile_store_app/models/product.dart';

/// Produits dont le stock restant est strictement inférieur à 10.
///
/// Reprise à l'identique du helper `lib/widgets/store_page/functions/
/// get_low_stock_product.dart` (même seuil strict, même ordre de parcours).
List<Product> getLowStockProduct(List<Product> products) {
  List<Product> lowStock = [];
  products.forEach((e) {
    double restOfStock = e.stock!.baseStock - e.stock!.totalSell;
    if (restOfStock < 10) {
      lowStock.add(e);
    }
  });
  return lowStock;
}
