import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/config/app_config.dart';
import 'package:mobile_store_app/core/config/saas_module.dart';
import 'package:mobile_store_app/core/config/saas_module_manager.dart';
import 'package:mobile_store_app/core/router/route_arguments.dart';
import 'package:mobile_store_app/features/auth/login_screen.dart';
import 'package:mobile_store_app/features/auth/signup_screen.dart';
import 'package:mobile_store_app/features/dashboard/dashboard_screen.dart';
import 'package:mobile_store_app/features/history/history_screen.dart';
import 'package:mobile_store_app/features/order_story/order_story_screen.dart';
import 'package:mobile_store_app/features/reports/general_report_screen.dart';
import 'package:mobile_store_app/features/spending/spending_screen.dart';
import 'package:mobile_store_app/features/stock/stock_history_screen.dart';
import 'package:mobile_store_app/features/store_detail/store_detail_screen.dart';
import 'package:mobile_store_app/features/stores/stores_screen.dart';
import 'package:mobile_store_app/features/subscription/subscription_screen.dart';
import 'package:mobile_store_app/features/welcome/welcome_pre_login_screen.dart';
import 'package:mobile_store_app/features/withdrawals/withdrawal_screen.dart';

/// ============================================================================
/// APP ROUTER — table de routage nommée de BouTiKa.
///
/// Deux niveaux, dans l'ordre de résolution de Flutter :
///
///  1. [routes] (routes statiques, sans argument) : accueil et connexion.
///     L'application d'origine ne déclarait que ces deux routes nommées ; elles
///     sont enregistrées avec exactement les mêmes builders.
///  2. [onGenerateRoute] : routes des modules SaaS dont l'écran exige des
///     arguments ([RouteArguments] typés). Elles n'étaient pas déclarées dans
///     l'original (les écrans étaient poussés par `MaterialPageRoute`) ; elles
///     sont désormais adressables par nom, sans changer ces push directs.
///
/// Les deux niveaux respectent [SaaSModuleManager] : un module désactivé à
/// chaud n'est plus routable et retombe sur le comportement « route inconnue »
/// de Flutter.
///
/// Cas particulier : `SaaSModule.catalog` (grille de catégories de la
/// boutique) n'a pas d'écran autonome — elle vit dans l'onglet inventaire de
/// `StoreDetailScreen`, qui n'expose pas de paramètre d'onglet. Cette route
/// reste donc non routable et documentée comme telle.
/// ============================================================================
class AppRouter {
  const AppRouter._();

  /// Route affichée au démarrage : accueil pré-login.
  static const String initialRoute = AppConfig.routeRoot;

  /// Table de routage complète (tous les modules étant activés par défaut).
  static Map<String, WidgetBuilder> get routes =>
      routesFor(SaaSModuleManager.instance);

  /// Table de routage filtrée par les modules actifs de [modules].
  ///
  /// Un module désactivé n'apparaît pas dans la table : `Navigator` lève alors
  /// l'erreur standard de route inconnue, exactement comme pour une route
  /// jamais déclarée.
  static Map<String, WidgetBuilder> routesFor(SaaSModuleManager modules) {
    return <String, WidgetBuilder>{
      if (modules.isEnabled(SaaSModule.welcome))
        AppConfig.routeRoot: (context) => WelcomePreLoginScreen(),
      if (modules.isEnabled(SaaSModule.auth))
        AppConfig.routeLogin: (context) => LoginScreen(),
    };
  }

  /// Résolution des routes nommées des modules (écrans à arguments).
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      onGenerateRouteFor(settings);

  /// Variante testable : permet d'injecter un [SaaSModuleManager] donné.
  static Route<dynamic>? onGenerateRouteFor(
    RouteSettings settings, {
    SaaSModuleManager? modules,
  }) {
    final String? name = settings.name;
    if (name == null) return null;

    final SaaSModuleManager manager = modules ?? SaaSModuleManager.instance;
    final SaaSModule? module = moduleForRoute(name);
    if (module != null && !manager.isEnabled(module)) return null;

    final Widget? page = _buildPage(name, settings.arguments);
    if (page == null) return null;

    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }

  /// Module SaaS associé à une route nommée, ou `null` si la route n'est pas
  /// déclarée par un module (c'était le cas de toutes les routes poussées
  /// directement dans l'application d'origine).
  static SaaSModule? moduleForRoute(String route) {
    for (final SaaSModule module in SaaSModule.values) {
      if (module.route == route) return module;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // CONSTRUCTION DES ÉCRANS
  // ---------------------------------------------------------------------------

  /// Construit l'écran d'une route de module, ou `null` si la route n'est pas
  /// gérée ou si les arguments attendus sont absents / mal typés.
  static Widget? _buildPage(String name, Object? arguments) {
    if (name == SaaSModule.signup.route) {
      return const EmployerFormPage();
    }
    if (name == SaaSModule.dashboard.route) {
      return const DashboardScreen();
    }

    if (name == SaaSModule.stores.route) {
      if (arguments is! StoresRouteArguments) return null;
      return WelcomeScreen(
        stores: arguments.stores,
        userType: arguments.userType,
      );
    }

    if (name == SaaSModule.storeDetail.route) {
      if (arguments is! StoreRouteArguments) return null;
      return StoreDetailScreen(
        store: arguments.store,
        userType: arguments.userType,
        otherStores: arguments.otherStores,
      );
    }

    if (name == SaaSModule.history.route) {
      if (arguments is! HistoryRouteArguments) return null;
      return HistoryScreen(
        storeId: arguments.storeId,
        userType: arguments.userType,
        categories: arguments.categories,
        products: arguments.products,
        initialIndex: arguments.initialIndex,
        embedded: arguments.embedded,
      );
    }

    if (name == SaaSModule.orders.route) {
      if (arguments is! OrdersRouteArguments) return null;
      return OrderStoryScreen(
        storeId: arguments.storeId,
        userType: arguments.userType,
        categories: arguments.categories,
        embedded: arguments.embedded,
      );
    }

    if (name == SaaSModule.stock.route) {
      if (arguments is! StockRouteArguments) return null;
      return RestockHistoryScreen(
        products: arguments.products,
        embedded: arguments.embedded,
      );
    }

    if (name == SaaSModule.expenses.route) {
      if (arguments is! StoreScopedRouteArguments) return null;
      return ExpensesScreen(
        storeId: arguments.storeId,
        embedded: arguments.embedded,
      );
    }

    if (name == SaaSModule.withdrawals.route) {
      if (arguments is! StoreScopedRouteArguments) return null;
      return WithdrawalScreen(
        storeId: arguments.storeId,
        embedded: arguments.embedded,
      );
    }

    if (name == SaaSModule.reports.route) {
      if (arguments is! ReportsRouteArguments) return null;
      return GeneralReportScreen(
        storeId: arguments.storeId,
        userType: arguments.userType,
        orders: arguments.orders,
      );
    }

    if (name == SaaSModule.subscription.route) {
      if (arguments is! SubscriptionRouteArguments) return null;
      return SubscriptionScreenPage(subscription: arguments.subscription);
    }

    // `SaaSModule.catalog` : pas d'écran autonome (cf. en-tête de classe).
    return null;
  }
}
