import 'package:collection/collection.dart';

import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/order.dart';

/// Ventes et bénéfice d'une catégorie.
class CategorySalesMetrics {
  /// Chiffre d'affaires de la catégorie.
  final double sales;

  /// Bénéfice net de la catégorie.
  final double revenues;

  const CategorySalesMetrics({required this.sales, required this.revenues});
}

/// ============================================================================
/// CATEGORY SALES CALCULATOR — ventilation des ventes par catégorie.
///
/// Deux étapes, **formules et effets identiques à l'écran d'origine** :
///
///   1. [indexOrdersByCategory] vide `orderContentsByCategory` de chaque
///      catégorie puis le remplit en associant chaque produit d'une commande
///      à la catégorie **portant le même nom** (première correspondance).
///      Cette mutation du modèle est celle de l'application d'origine et reste
///      exposée aux écrans qui s'appuient dessus : elle est simplement sortie
///      du `build()`.
///
///   2. [salesFor] somme, pour une catégorie indexée :
///        `sales    = Σ (sellingPrice × quantité)`
///        `revenues = Σ (sellingPrice × quantité − buyingPrice × quantité)`
///
/// Les `?? 0` d'origine sont conservés pour les prix nullables.
/// ============================================================================
class CategorySalesCalculator {
  CategorySalesCalculator._();

  /// Réindexe les contenus de commandes sur les catégories fournies.
  static void indexOrdersByCategory(
    List<Order> orders,
    List<Category> categories,
  ) {
    for (final Category category in categories) {
      category.orderContentsByCategory.clear();
    }

    final Set<Category> categoriesSet = categories.toSet();
    for (final Order order in orders) {
      order.products.forEach((product, quantity) {
        final Category? category = categoriesSet.firstWhereOrNull(
          (element) => element.name == product.category?.name,
        );

        if (category != null) {
          category.orderContentsByCategory.add({product: quantity});
        }
      });
    }
  }

  /// Ventes et bénéfice d'une catégorie déjà indexée.
  static CategorySalesMetrics salesFor(Category category) {
    double sales = 0;
    double revenues = 0;

    category.orderContentsByCategory.forEach((content) {
      content.forEach((product, quantity) {
        sales += (product.stock!.sellingPrice ?? 0) * quantity;
        revenues += ((product.stock!.sellingPrice ?? 0) * quantity) -
            ((product.stock!.buyingPrice ?? 0) * quantity);
      });
    });

    return CategorySalesMetrics(sales: sales, revenues: revenues);
  }
}
