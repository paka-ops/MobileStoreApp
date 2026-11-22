import 'package:flutter/material.dart';

import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/product_service.dart';

/// ============================================================================
/// CATEGORY PRODUCTS CONTROLLER — produits d'une catégorie.
///
/// Responsabilités (identiques à l'état interne de l'écran d'origine) :
///   • chargement des produits de la catégorie (`getAllProductByCategoryId`)
///   • liste des produits en stock critique (`baseStock - totalSell <= 10`,
///     seuil propre à l'original)
///   • recherche insensible à la casse sur le nom, réinitialisation si vide
///   • compteurs de la rangée de KPI : total, normal, critique
///   • remplacement local d'un produit après un restockage — **sans** recalcul
///     de la liste critique, exactement comme avant (le badge de l'en-tête
///     reste donc inchangé jusqu'au prochain rechargement)
///
/// Les exceptions du service continuent de remonter (aucun `catch` ajouté).
/// ============================================================================
class CategoryProductsController extends ChangeNotifier {
  CategoryProductsController({
    required this.categoryId,
    ProductService? productService,
  }) : _productService = productService ?? ProductService();

  final String categoryId;
  final ProductService _productService;

  List<Product> _allProducts = <Product>[];
  List<Product> _filteredProducts = <Product>[];
  List<Product> _lowStockProducts = <Product>[];
  bool _isLoading = true;
  bool _disposed = false;

  /// Tous les produits de la catégorie.
  List<Product> get allProducts => _allProducts;

  /// Produits après recherche.
  List<Product> get filteredProducts => _filteredProducts;

  /// Produits dont le stock restant est `<= 10`.
  List<Product> get lowStockProducts => _lowStockProducts;

  /// Chargement en cours.
  bool get isLoading => _isLoading;

  /// Nombre total de produits.
  int get totalCount => _allProducts.length;

  /// Nombre de produits en stock critique.
  int get lowStockCount => _lowStockProducts.length;

  /// Nombre de produits au stock sain.
  int get healthyCount => totalCount - lowStockCount;

  /// Charge les produits de la catégorie.
  Future<void> load(BuildContext context) async {
    _isLoading = true;
    _notify();

    final List<Product> products = await _productService
        .getAllProductByCategoryId(categoryId, context);

    _allProducts = products;
    _lowStockProducts = products
        .where((p) => (p.stock!.baseStock - p.stock!.totalSell) <= 10)
        .toList();
    _filteredProducts = products;
    _isLoading = false;
    _notify();
  }

  /// Filtre la liste affichée.
  void filter(String query) {
    if (query.isEmpty) {
      _filteredProducts = List<Product>.from(_allProducts);
    } else {
      _filteredProducts = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    _notify();
  }

  /// Remplace un produit à son index puis réinitialise le filtre.
  void replaceProduct(Product product) {
    final int index = _allProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _allProducts[index] = product;
    }
    filter("");
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
