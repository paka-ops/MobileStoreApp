import 'package:flutter/foundation.dart';

import 'saas_module.dart';

/// ============================================================================
/// SAAS MODULE MANAGER — moteur d'activation des modules fonctionnels.
///
/// Principe : l'application entière est décrite comme un ensemble de modules
/// ([SaaSModule]). Ce manager maintient l'ensemble des modules **désactivés**
/// (l'état par défaut est donc « tout activé », comme l'application d'origine)
/// et notifie ses auditeurs à chaque changement, ce qui permet au routeur
/// (`lib/core/router/`) de réagir immédiatement, sans redémarrage.
///
///   // État par défaut : tout est activé.
///   final manager = SaaSModuleManager.instance;
///   manager.isEnabled(SaaSModule.reports);          // true
///   manager.setEnabled(SaaSModule.reports, false);  // désactivation à chaud
///   manager.enableAll();                            // restauration
///
///   // Écoute réactive (un seul abonnement pour toute l'application) :
///   ListenableBuilder(
///     listenable: manager,
///     builder: (context, _) => MonContenu(manager),
///   )
///
/// Le moteur est volontairement sans dépendance d'UI ni de stockage : la
/// persistance (par exemple un abonnement par boutique) est branchée plus tard
/// en fournissant l'ensemble initial de modules désactivés, sans modifier ce
/// contrat public.
/// ============================================================================
class SaaSModuleManager extends ChangeNotifier {
  /// Crée un manager dont tous les modules sont activés, sauf ceux fournis
  /// dans [initiallyDisabled].
  ///
  /// Utile pour les tests ou pour restaurer un état d'abonnement connu :
  ///   SaaSModuleManager(initiallyDisabled: {SaaSModule.reports})
  SaaSModuleManager({Iterable<SaaSModule> initiallyDisabled = const []})
      : _disabled = <SaaSModule>{...initiallyDisabled};

  /// Instance partagée par l'application (injectée par `main.dart`).
  static final SaaSModuleManager instance = SaaSModuleManager();

  final Set<SaaSModule> _disabled;

  // ---------------------------------------------------------------------------
  // LECTURE
  // ---------------------------------------------------------------------------

  /// Modules désactivés, dans l'ordre de déclaration de [SaaSModule].
  List<SaaSModule> get disabledModules => SaaSModule.values
      .where((SaaSModule module) => _disabled.contains(module))
      .toList(growable: false);

  /// Modules activés, dans l'ordre de déclaration de [SaaSModule].
  List<SaaSModule> get enabledModules => SaaSModule.values
      .where((SaaSModule module) => !_disabled.contains(module))
      .toList(growable: false);

  /// `true` si le module est disponible pour l'utilisateur.
  bool isEnabled(SaaSModule module) => !_disabled.contains(module);

  /// `true` si au moins un module est désactivé (permet d'afficher un bandeau
  /// d'information dans un futur écran d'administration).
  bool get hasDisabledModules => _disabled.isNotEmpty;

  /// `true` si la route nommée correspond à un module **désactivé**.
  /// Les routes non pilotées par un module restent toujours accessibles.
  bool isRouteDisabled(String? route) {
    final SaaSModule? module = SaaSModule.fromRoute(route);
    return module != null && !isEnabled(module);
  }

  // ---------------------------------------------------------------------------
  // ÉCRITURE (notifie uniquement en cas de changement réel)
  // ---------------------------------------------------------------------------

  /// Active ou désactive un module. Retourne `true` si l'état a changé.
  bool setEnabled(SaaSModule module, bool enabled) {
    final bool changed = enabled ? _disabled.remove(module) : _disabled.add(module);
    if (changed) notifyListeners();
    return changed;
  }

  /// Active un module. Retourne `true` si l'état a changé.
  bool enable(SaaSModule module) => setEnabled(module, true);

  /// Désactive un module. Retourne `true` si l'état a changé.
  bool disable(SaaSModule module) => setEnabled(module, false);

  /// Active tous les modules. Retourne `true` si l'état a changé.
  bool enableAll() {
    if (_disabled.isEmpty) return false;
    _disabled.clear();
    notifyListeners();
    return true;
  }

  /// Désactive tous les modules. Retourne `true` si l'état a changé.
  bool disableAll() {
    if (_disabled.length == SaaSModule.values.length) return false;
    _disabled
      ..clear()
      ..addAll(SaaSModule.values);
    notifyListeners();
    return true;
  }

  /// Applique un ensemble complet de modules activés (les autres sont
  /// désactivés). Retourne `true` si l'état a changé.
  bool applyEnabledSet(Iterable<SaaSModule> enabled) {
    final Set<SaaSModule> next = <SaaSModule>{
      for (final SaaSModule module in SaaSModule.values)
        if (!enabled.contains(module)) module,
    };
    if (setEquals(next, _disabled)) return false;
    _disabled
      ..clear()
      ..addAll(next);
    notifyListeners();
    return true;
  }

  /// Réinitialise le moteur sur l'état par défaut (tout activé).
  void reset() {
    enableAll();
  }
}
