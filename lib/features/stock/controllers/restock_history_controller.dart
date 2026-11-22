import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/shared/models/product.dart';
import 'package:mobile_store_app/shared/models/stock.dart';
import 'package:mobile_store_app/shared/services/product_service.dart';
import 'package:mobile_store_app/shared/services/user_service.dart';

/// Période sélectionnée dans le dialogue de dates.
class RestockPeriod {
  final DateTime? start;
  final DateTime? end;

  const RestockPeriod({required this.start, required this.end});
}

/// ============================================================================
/// RESTOCK HISTORY CONTROLLER — mouvements de stock d'une boutique.
///
/// Responsabilités (identiques à l'état interne de l'écran d'origine) :
///   • période par défaut : aujourd'hui − 30 jours → aujourd'hui + 1 jour
///   • chargement `ProductService.getAllProductStocks(start, end, ids, ctx)`
///     avec état de chargement, repli `[]` si le service renvoie `null`
///   • index `productId → Product` pour l'affichage des noms, repli
///     « Produit » si le produit n'est pas connu
///   • quantité ajoutée d'un mouvement : `baseStock − previousStock (?? 0)`
///   • libellé de période :
///       – même jour (ou date de fin absente) → `dd/MM/yyyy`
///       – sinon                             → `dd/MM - dd/MM/yyyy`
///   • `isEmployee` : le prix d'achat est masqué pour ce rôle
/// ============================================================================
class RestockHistoryController extends ChangeNotifier {
  RestockHistoryController({
    required List<Product> products,
    ProductService? productService,
  })  : _products = products,
        _productService = productService ?? ProductService() {
    _productIds = products.map((e) => e.id).toList();
  }

  final ProductService _productService;

  List<Product> _products;
  late List<String> _productIds;

  List<Stock> _stocks = <Stock>[];
  final Map<String, Product> _productsIdMap = <String, Product>{};

  DateTime? _startDate = DateTime.now().add(const Duration(days: -30));
  DateTime? _endDate = DateTime.now().add(const Duration(days: 1));

  bool _isLoading = false;
  bool _disposed = false;

  /// Mouvements affichés.
  List<Stock> get stocks => _stocks;

  /// `true` pendant l'appel réseau.
  bool get isLoading => _isLoading;

  /// Date de début sélectionnée.
  DateTime? get startDate => _startDate;

  /// Date de fin sélectionnée.
  DateTime? get endDate => _endDate;

  /// `true` lorsque l'utilisateur connecté est un employé (prix d'achat masqué).
  bool get isEmployee => UserService.userType == 'employee';

  /// Libellé compact de la période affichée.
  String get periodLabel {
    final DateFormat fullFmt = DateFormat('dd/MM/yyyy');
    final DateFormat shortFmt = DateFormat('dd/MM');
    final DateTime s =
        _startDate ?? DateTime.now().add(const Duration(days: -30));
    final DateTime? e = _endDate;

    if (e == null ||
        (s.year == e.year && s.month == e.month && s.day == e.day)) {
      return fullFmt.format(s);
    }
    return "${shortFmt.format(s)} - ${fullFmt.format(e)}";
  }

  /// Nom lisible d'un produit, repli « Produit ».
  String productNameFor(String productId) =>
      _productsIdMap[productId]?.name ?? "Produit";

  /// Quantité ajoutée par un mouvement de stock.
  double addedQuantityFor(Stock stock) =>
      stock.baseStock - (stock.previousStock ?? 0);

  /// Charge les mouvements sur la période courante.
  Future<void> load(BuildContext context) async {
    _setLoading(true);

    final DateTime effectiveStart =
        _startDate ?? DateTime.now().add(const Duration(days: -30));
    final DateTime effectiveEnd =
        _endDate ?? DateTime.now().add(const Duration(days: 1));

    final List<Stock>? results = await _productService.getAllProductStocks(
      effectiveStart,
      effectiveEnd,
      _productIds,
      context,
    );

    if (_disposed) return;

    _stocks = results ?? <Stock>[];
    for (final Product product in _products) {
      _productsIdMap[product.id] = product;
    }
    _setLoading(false);
  }

  /// Applique une nouvelle période puis recharge.
  Future<void> applyPeriod(BuildContext context, RestockPeriod period) async {
    _startDate = period.start;
    _endDate = period.end;
    await load(context);
  }

  /// Remplace la liste de produits (changement fourni par le parent).
  void updateProducts(List<Product> products) {
    _products = products;
    _productIds = products.map((e) => e.id).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
