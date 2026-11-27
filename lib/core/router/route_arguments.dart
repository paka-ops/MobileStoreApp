import 'package:mobile_store_app/shared/models/Store.dart';
import 'package:mobile_store_app/shared/models/category.dart';
import 'package:mobile_store_app/shared/models/order.dart';
import 'package:mobile_store_app/shared/models/product.dart';
import 'package:mobile_store_app/shared/models/subscription.dart';

/// ============================================================================
/// ROUTE ARGUMENTS — arguments typés des routes nommées SaaS.
///
/// Les écrans de modules exigent des données (boutique, produits, commandes…).
/// Ces petites classes portent ces données via `RouteSettings.arguments`, ce
/// qui remplace les `Map<String, dynamic>` non typées.
///
/// Aucune logique : uniquement des porteurs immuables.
/// ============================================================================

/// `/stores` — liste des boutiques de l'utilisateur connecté.
class StoresRouteArguments {
  final List<Store> stores;
  final String userType;

  const StoresRouteArguments({required this.stores, required this.userType});
}

/// `/store` — espace de travail d'une boutique.
class StoreRouteArguments {
  final Store store;
  final String userType;
  final List<Store> otherStores;

  const StoreRouteArguments({
    required this.store,
    required this.userType,
    required this.otherStores,
  });
}

/// `/history` — historiques unifiés (ventes, stock, dépenses, retraits).
class HistoryRouteArguments {
  final String storeId;
  final String userType;
  final List<Category> categories;
  final List<Product> products;
  final int initialIndex;
  final bool embedded;

  const HistoryRouteArguments({
    required this.storeId,
    required this.userType,
    required this.categories,
    required this.products,
    this.initialIndex = 0,
    this.embedded = false,
  });
}

/// `/orders` — historique des commandes d'une boutique.
class OrdersRouteArguments {
  final String storeId;
  final String userType;
  final List<Category> categories;
  final bool embedded;

  const OrdersRouteArguments({
    required this.storeId,
    required this.userType,
    required this.categories,
    this.embedded = false,
  });
}

/// `/expenses` et `/withdrawals` — écran rattaché à une boutique.
class StoreScopedRouteArguments {
  final String storeId;
  final bool embedded;

  const StoreScopedRouteArguments({
    required this.storeId,
    this.embedded = false,
  });
}

/// `/stock` — historique des arrivages d'une sélection de produits.
class StockRouteArguments {
  final List<Product> products;
  final bool embedded;

  const StockRouteArguments({required this.products, this.embedded = false});
}

/// `/reports` — rapport général d'une boutique.
class ReportsRouteArguments {
  final String storeId;
  final String userType;
  final List<Order> orders;

  const ReportsRouteArguments({
    required this.storeId,
    required this.userType,
    required this.orders,
  });
}

/// `/subscription` — détail de l'abonnement courant.
class SubscriptionRouteArguments {
  final Subscription subscription;

  const SubscriptionRouteArguments({required this.subscription});
}
