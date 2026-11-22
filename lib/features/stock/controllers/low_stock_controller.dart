import 'package:flutter/material.dart';

import 'package:mobile_store_app/features/stock/controllers/stock_level.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/product_service.dart';

/// ============================================================================
/// LOW STOCK CONTROLLER — produits en stock critique.
///
/// Responsabilités (identiques à l'état interne de l'écran d'origine) :
///   • copie de travail de la liste reçue (`_allProducts`) et liste filtrée
///   • recherche insensible à la casse sur le nom, réinitialisation si vide
///   • compteurs de l'en-tête : total des alertes, critiques (`≤ 5`),
///     « bas » (`> 5` et `≤ 10` — seuil propre à l'original)
///   • restockage via `ProductService.updateStock` puis mise à jour locale :
///       – remplacement du produit à son index
///       – **retrait** de la liste si le stock obtenu dépasse 10
///       – réinitialisation du filtre (le champ de recherche n'est pas vidé,
///         exactement comme avant)
///
/// Les exceptions du service continuent de remonter (aucun `catch` ajouté).
/// ============================================================================
class LowStockController extends ChangeNotifier {
  LowStockController({
    required List<Product> products,
    ProductService? productService,
  })  : _allProducts = List<Product>.from(products),
        _filteredProducts = List<Product>.from(products),
        _productService = productService ?? ProductService();

  final ProductService _productService;

  List<Product> _allProducts;
  List<Product> _filteredProducts;
  bool _disposed = false;

  /// Produits après recherche.
  List<Product> get filteredProducts => _filteredProducts;

  /// Nombre total d'alertes.
  int get totalAlerts => _allProducts.length;

  /// Nombre de produits critiques (`≤ 5`).
  int get criticalAlerts =>
      _allProducts.where((p) => StockLevel.of(p).quantity <= 5).length;

  /// Nombre de produits « bas » (`> 5` et `≤ 10`).
  int get lowAlerts => _allProducts.where((p) {
        final double quantity = StockLevel.of(p).quantity;
        return quantity > 5 && quantity <= 10;
      }).length;

  /// Filtre la liste affichée.
  void filter(String query) {
    if (query.isEmpty) {
      _filteredProducts = List<Product>.from(_allProducts);
    } else {
      _filteredProducts = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Restocke un produit puis met à jour la liste locale.
  Future<Product?> restock({
    required Product product,
    required double add,
    required BuildContext context,
  }) async {
    final Product? updated = await _productService.updateStock(
      product.id,
      add,
      context,
    );

    if (_disposed) return updated;
    if (updated != null) _applyRestockResult(updated);

    return updated;
  }

  void _applyRestockResult(Product updated) {
    final int index =
        _allProducts.indexWhere((prod) => prod.id == updated.id);

    if (index != -1) {
      _allProducts[index] = updated;
      // Le produit sort de la liste dès que son stock redevient sain.
      if (StockLevel.of(updated).quantity > 10) {
        _allProducts.removeAt(index);
      }
    }

    _filteredProducts = List<Product>.from(_allProducts);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
