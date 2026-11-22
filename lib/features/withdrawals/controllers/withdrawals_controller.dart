import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/models/withdrawal.dart';
import 'package:mobile_store_app/service/withdrawal_service.dart';

/// ============================================================================
/// WITHDRAWALS CONTROLLER — historique des retraits d'une boutique.
///
/// Logique **strictement** reprise de l'écran d'origine :
///   • période par défaut : début = aujourd'hui, fin = aujourd'hui + 1 jour
///   • l'API reçoit `startOfDay(début)` et une fin de journée à la milliseconde
///     près (`23:59:59.999`), sémantique propre à cet écran (les dépenses
///     utilisent la microseconde)
///   • repli `[]` si le service renvoie `null`
///   • tri décroissant sur `date!`
///   • total = Σ `amount`
///   • suppression locale après succès du service
///
/// Les erreurs de chargement restent journalisées, jamais propagées.
/// ============================================================================
class WithdrawalsController extends ChangeNotifier {
  WithdrawalsController({
    required this.storeId,
    WithdrawalService? withdrawalService,
  })  : _withdrawalService = withdrawalService ?? WithdrawalService(),
        _startDate = _today(),
        _endDate = _today().add(const Duration(days: 1));

  final String storeId;
  final WithdrawalService _withdrawalService;

  List<Withdrawal> _withdrawals = <Withdrawal>[];
  DateTime _startDate;
  DateTime _endDate;
  bool _isLoading = false;
  bool _disposed = false;

  /// Retraits affichés.
  List<Withdrawal> get withdrawals => _withdrawals;

  /// `true` pendant le chargement.
  bool get isLoading => _isLoading;

  /// Borne basse de la période.
  DateTime get startDate => _startDate;

  /// Borne haute de la période.
  DateTime get endDate => _endDate;

  /// Total des retraits affichés.
  double get totalAmount => _withdrawals.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );

  /// Libellé compact de période (`dd/MM/yyyy` sur un même jour).
  String get periodLabel {
    final DateFormat fullFmt = DateFormat('dd/MM/yyyy');
    final DateFormat shortFmt = DateFormat('dd/MM');

    if (_startOfDay(_startDate) == _startOfDay(_endDate)) {
      return fullFmt.format(_startDate);
    }
    return "${shortFmt.format(_startDate)} - ${fullFmt.format(_endDate)}";
  }

  /// Charge les retraits de la période courante.
  Future<void> load(BuildContext context) async {
    if (_disposed) return;

    _isLoading = true;
    _notify();

    try {
      final List<Withdrawal>? result = await _withdrawalService.getWithdrawals(
        storeId: storeId,
        startDate: _startOfDay(_startDate),
        endDate: _endOfDay(_endDate),
        context: context,
      );

      final List<Withdrawal> list = result ?? <Withdrawal>[];
      list.sort((a, b) => b.date!.compareTo(a.date!));

      if (_disposed) return;
      _withdrawals = list;
    } catch (e) {
      debugPrint("Erreur lors de la récupération des retraits : $e");
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _notify();
      }
    }
  }

  /// Applique une nouvelle période puis recharge.
  Future<void> applyPeriod(
    BuildContext context,
    DateTime start,
    DateTime end,
  ) async {
    _startDate = start;
    _endDate = end;
    await load(context);
  }

  /// Met à jour un retrait (dialogue « Mettre a jours »).
  Future<Withdrawal?> updateWithdrawal(
    Withdrawal withdrawal,
    BuildContext context,
  ) {
    return _withdrawalService.update(
      storeId: storeId,
      withdrawal: withdrawal,
      context: context,
    );
  }

  /// Supprime un retrait puis le retire de la liste locale.
  Future<bool> deleteWithdrawal(
    Withdrawal withdrawal,
    BuildContext context,
  ) async {
    final String? id = withdrawal.id;
    if (id == null || id.isEmpty) return false;

    final bool deleted = await _withdrawalService.delete(
      withdrawalId: id,
      context: context,
    );

    if (_disposed) return deleted;

    if (deleted) {
      _withdrawals.removeWhere((w) => w.id == id);
      _notify();
    }
    return deleted;
  }

  static DateTime _today() => _startOfDay(DateTime.now());

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
