import 'package:flutter/material.dart';

import 'package:mobile_store_app/features/products/controllers/product_stats_calculator.dart';
import 'package:mobile_store_app/shared/services/product_service.dart';

/// État de chargement des statistiques d'un produit.
enum ProductStatsStatus { loading, error, ready }

/// ============================================================================
/// PRODUCT STATS CONTROLLER — cycle de vie des statistiques d'un produit.
///
/// Remplace le `FutureBuilder` de l'écran d'origine en conservant exactement
/// les mêmes états observables :
///   • [ProductStatsStatus.loading] → squelette + loader « Chargement des
///     statistiques... »
///   • [ProductStatsStatus.error]   → `ErrorState` avec `"$error"` et action
///     « Réessayer »
///   • [ProductStatsStatus.ready]   → contenu (les statistiques sont calculées
///     par [ProductStatsCalculator], jamais dans le rendu)
///
/// `load()` peut être rappelé à volonté (bouton d'actualisation, tirer pour
/// rafraîchir) : le service est sollicité à chaque fois, comme avant.
/// ============================================================================
class ProductStatsController extends ChangeNotifier {
  ProductStatsController({
    required this.productId,
    ProductService? productService,
  }) : _productService = productService ?? ProductService();

  final String productId;
  final ProductService _productService;

  ProductStatsStatus _status = ProductStatsStatus.loading;
  ProductStats? _stats;
  String _errorMessage = '';
  bool _disposed = false;

  ProductStatsStatus get status => _status;

  /// Statistiques prêtes (uniquement en [ProductStatsStatus.ready]).
  ProductStats? get stats => _stats;

  /// Message d'erreur du dernier chargement.
  String get errorMessage => _errorMessage;

  /// Charge (ou recharge) les statistiques du produit.
  Future<void> load(BuildContext context) async {
    _status = ProductStatsStatus.loading;
    _notify();

    try {
      final List<dynamic> data = await _productService.getStatsForProduct(
        productId,
        context,
      );

      if (_disposed) return;

      _stats = ProductStatsCalculator.fromRaw(data);
      _status = ProductStatsStatus.ready;
    } catch (e) {
      if (_disposed) return;
      _errorMessage = "$e";
      _status = ProductStatsStatus.error;
    }

    _notify();
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
