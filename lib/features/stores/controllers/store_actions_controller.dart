import 'package:flutter/material.dart';

import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/service/store_service.dart';

/// Issue d'une mise à jour de boutique.
enum StoreUpdateStatus {
  /// Le service a renvoyé la boutique mise à jour.
  success,

  /// Le service a renvoyé `null` (« La mise à jour a échoué. »).
  failed,

  /// Une exception a été levée (« Erreur lors de la mise à jour. »).
  error,
}

/// Résultat d'une mise à jour de boutique.
class StoreUpdateOutcome {
  final StoreUpdateStatus status;
  final Store? store;

  const StoreUpdateOutcome._(this.status, this.store);

  /// Mise à jour appliquée.
  const StoreUpdateOutcome.success(Store store)
      : this._(StoreUpdateStatus.success, store);

  /// Refus serveur (`null`).
  const StoreUpdateOutcome.failed()
      : this._(StoreUpdateStatus.failed, null);

  /// Exception réseau.
  const StoreUpdateOutcome.error()
      : this._(StoreUpdateStatus.error, null);

  bool get isSuccess => status == StoreUpdateStatus.success;
  bool get isFailed => status == StoreUpdateStatus.failed;
  bool get isError => status == StoreUpdateStatus.error;
}

/// ============================================================================
/// STORE ACTIONS CONTROLLER — actions « métier » sur une boutique existante.
///
/// Les deux appels réseau des dialogues (modifier / supprimer) quittent le
/// widget : ce contrôleur ne fait que les exécuter et qualifier leur issue, ce
/// qui permet à l'interface de conserver **exactement** les trois messages
/// distincts de l'original :
///
///   • succès de la mise à jour → « Boutique mise à jour avec succès ! »
///   • `null` renvoyé          → « La mise à jour a échoué. »
///   • exception               → « Erreur lors de la mise à jour. »
///
///   • suppression sans exception → succès (le booléen du service était
///     ignoré dans l'original : comportement conservé)
///   • exception                  → « Erreur lors de la suppression. »
/// ============================================================================
class StoreActionsController {
  StoreActionsController({StoreService? storeService})
      : _storeService = storeService ?? StoreService();

  final StoreService _storeService;

  /// Met à jour le nom et l'emplacement d'une boutique.
  ///
  /// Les deux valeurs sont élaguées, comme dans l'original.
  Future<StoreUpdateOutcome> updateStore({
    required String storeId,
    required String name,
    required String location,
    required BuildContext context,
  }) async {
    try {
      final Store updatedStore = await _storeService.updateStore(
        storeId,
        <String, dynamic>{
          "name": name.trim(),
          "location": location.trim(),
        },
        context,
      );

      return StoreUpdateOutcome.success(updatedStore);
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour: $e");
      return const StoreUpdateOutcome.error();
    }
  }

  /// Supprime une boutique. Retourne `false` uniquement sur exception.
  Future<bool> deleteStore({
    required String storeId,
    required BuildContext context,
  }) async {
    try {
      await _storeService.deleteStore(storeId, context);
      return true;
    } catch (e) {
      debugPrint("Erreur lors de la suppression: $e");
      return false;
    }
  }
}
