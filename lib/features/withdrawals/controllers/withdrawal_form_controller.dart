import 'package:flutter/material.dart';

import 'package:mobile_store_app/models/withdrawal.dart';
import 'package:mobile_store_app/service/withdrawal_service.dart';

/// ============================================================================
/// WITHDRAWAL FORM CONTROLLER — persistance d'un retrait saisi.
///
///   • création → `WithdrawalService.create`
///   • édition  → `WithdrawalService.update`
///
/// Le service reçoit un [Withdrawal] portant : identifiant d'origine (édition),
/// montant saisi, motif élagué et **date d'origine conservée** (la date n'est
/// jamais modifiable) — exactement comme dans le formulaire d'origine.
/// ============================================================================
class WithdrawalFormController {
  WithdrawalFormController({WithdrawalService? withdrawalService})
      : _withdrawalService = withdrawalService ?? WithdrawalService();

  final WithdrawalService _withdrawalService;

  /// Enregistre le retrait. Retourne le retrait enregistré, ou `null`.
  Future<Withdrawal?> save({
    required bool isEditing,
    required String storeId,
    required Withdrawal draft,
    required BuildContext context,
  }) {
    return isEditing
        ? _withdrawalService.update(
            storeId: storeId,
            withdrawal: draft,
            context: context,
          )
        : _withdrawalService.create(
            storeId: storeId,
            withdrawal: draft,
            context: context,
          );
  }
}
