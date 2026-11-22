import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/config/app_config.dart';
import 'package:mobile_store_app/core/config/saas_module.dart';
import 'package:mobile_store_app/core/config/saas_module_manager.dart';
import 'package:mobile_store_app/features/auth/login_screen.dart';
import 'package:mobile_store_app/features/welcome/welcome_pre_login_screen.dart';

/// ============================================================================
/// APP ROUTER — table de routage nommée de BouTiKa.
///
/// Rôle : centraliser les routes nommées de l'application (auparavant déclarées
/// en ligne dans `main.dart`) et les relier au [SaaSModuleManager], afin qu'un
/// module désactivé à chaud ne soit plus routable.
///
/// Invariance : l'application d'origine ne déclarait que deux routes nommées
/// (`AppConfig.routeRoot` et `AppConfig.routeLogin`). Ce routeur enregistre
/// exactement les mêmes, avec les mêmes builders — aucune route
/// supplémentaire n'est exposée, les autres écrans continuant d'être poussés
/// par `MaterialPageRoute` comme auparavant.
///
/// Les modules dont l'écran exige des arguments (boutique, historique, …) ne
/// sont pas enregistrés ici : ils ne l'étaient pas non plus dans l'original.
/// ============================================================================
class AppRouter {
  const AppRouter._();

  /// Route affichée au démarrage : accueil pré-login.
  static const String initialRoute = AppConfig.routeRoot;

  /// Table de routage complète (tous les modules étant activés par défaut).
  static Map<String, WidgetBuilder> get routes =>
      routesFor(SaaSModuleManager.instance);

  /// Table de routage filtrée par les modules actifs du [modules].
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

  /// Module SaaS associé à une route nommée, ou `null` si la route n'est pas
  /// déclarée par un module (c'était le cas de toutes les routes poussées
  /// directement dans l'application d'origine).
  static SaaSModule? moduleForRoute(String route) {
    for (final SaaSModule module in SaaSModule.values) {
      if (module.route == route) return module;
    }
    return null;
  }
}
