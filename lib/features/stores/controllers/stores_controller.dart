import 'package:flutter/material.dart';

import 'package:mobile_store_app/shared/models/Store.dart';
import 'package:mobile_store_app/shared/services/store_service.dart';

/// Issue d'une création de boutique.
enum StoreCreationStatus {
  /// Le service a renvoyé une boutique.
  success,

  /// Le service a renvoyé `null` (refus serveur).
  failed,

  /// Une exception a été levée pendant l'appel.
  error,
}

/// Résultat d'une création de boutique.
class StoreCreationOutcome {
  final StoreCreationStatus status;
  final Store? store;

  const StoreCreationOutcome._(this.status, this.store);

  /// Boutique créée.
  const StoreCreationOutcome.success(Store store)
      : this._(StoreCreationStatus.success, store);

  /// Refus serveur (`null`).
  const StoreCreationOutcome.failed()
      : this._(StoreCreationStatus.failed, null);

  /// Exception réseau.
  const StoreCreationOutcome.error()
      : this._(StoreCreationStatus.error, null);

  bool get isSuccess => status == StoreCreationStatus.success;
}

/// ============================================================================
/// STORES CONTROLLER — état et cycle de vie de la liste des boutiques.
///
/// Responsabilités (identiques à l'écran d'origine) :
///   • tenir la liste affichée (la même instance que celle transmise par la
///     connexion, comme auparavant : la mutation est donc partagée)
///   • créer une boutique via `StoreService.addStore` et l'ajouter à la liste
///     en cas de succès uniquement
///   • supprimer un élément à l'index affiché
///
/// Le `notifyListeners()` remplace le `setState` d'origine : l'écran se
/// reconstruit à l'identique (en-tête, compteur de boutiques et liste).
///
/// Le payload de création conserve **exactement** les clés et les valeurs
/// d'origine, y compris `employee`, `employer` et `categories` à `null`, et les
/// textes non élagués (le service reçoit la saisie brute).
/// ============================================================================
class StoresController extends ChangeNotifier {
  StoresController({
    required List<Store> stores,
    StoreService? storeService,
  })  : _stores = stores,
        _storeService = storeService ?? StoreService();

  final List<Store> _stores;
  final StoreService _storeService;

  /// Boutiques affichées (liste vivante, mise à jour comme avant).
  List<Store> get stores => _stores;

  /// Nombre de boutiques (libellé singulier / pluriel de l'en-tête).
  int get count => _stores.length;

  /// Crée une boutique puis l'ajoute à la liste si le serveur l'accepte.
  Future<StoreCreationOutcome> createStore({
    required String name,
    required String location,
    required BuildContext context,
  }) async {
    try {
      final Map<String, dynamic> storeData = <String, dynamic>{
        "name": name,
        "location": location,
        "employee": null,
        "employer": null,
        "categories": null,
      };

      final Store? store = await _storeService.addStore(storeData, context);

      if (store == null) return const StoreCreationOutcome.failed();

      _stores.add(store);
      notifyListeners();
      return StoreCreationOutcome.success(store);
    } catch (e) {
      debugPrint("Erreur lors de l'ajout: $e");
      return const StoreCreationOutcome.error();
    }
  }

  /// Retire la boutique affichée à [index].
  ///
  /// L'index provient de l'élément de liste, exactement comme le `setState`
  /// d'origine ; un index hors bornes est simplement ignoré.
  void removeAt(int index) {
    if (index < 0 || index >= _stores.length) return;
    _stores.removeAt(index);
    notifyListeners();
  }
}
