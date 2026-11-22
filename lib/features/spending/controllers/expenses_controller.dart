import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/core/utils/date_utils.dart';
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/service/spending_service.dart';

/// ============================================================================
/// EXPENSES CONTROLLER — dépenses d'une boutique sur une période.
///
/// Reprend **à l'identique** la logique de l'écran d'origine :
///   • période par défaut : aujourd'hui (début et fin)
///   • envoi à l'API de `startOfDay(start)` et `endOfDay(end)`
///   • **filtrage local** des résultats : `createdAt.toLocal()` doit être
///     compris entre ces deux bornes (une dépense sans date est écartée)
///   • tri décroissant sur `createdAt` (date absente = `DateTime(2000)`)
///   • jeton `requestId` : une réponse ancienne n'écrase jamais un filtre plus
///     récent
///   • total = Σ `price ?? 0`
///   • suppression locale après succès du service (aucun rechargement)
///
/// Les erreurs de chargement sont seulement journalisées, comme avant.
/// ============================================================================
class ExpensesController extends ChangeNotifier {
  ExpensesController({
    required this.storeId,
    SpendingServcie? spendingService,
  }) : _spendingService = spendingService ?? SpendingServcie() {
    final DateTime today = AppDateUtils.today();
    _startDate = today;
    _endDate = today;
  }

  final String storeId;
  final SpendingServcie _spendingService;

  List<Spending> _expenses = <Spending>[];
  late DateTime _startDate;
  late DateTime _endDate;

  bool _isLoading = false;
  int _fetchRequestId = 0;
  bool _disposed = false;

  /// Dépenses affichées.
  List<Spending> get expenses => _expenses;

  /// `true` pendant le chargement.
  bool get isLoading => _isLoading;

  /// Borne basse de la période sélectionnée.
  DateTime get startDate => _startDate;

  /// Borne haute de la période sélectionnée.
  DateTime get endDate => _endDate;

  /// Libellé compact de la période : `dd/MM/yyyy` sur un même jour,
  /// sinon `dd/MM - dd/MM/yyyy`.
  String get periodLabel {
    final DateFormat fullFmt = DateFormat('dd/MM/yyyy');
    final DateFormat shortFmt = DateFormat('dd/MM');

    if (AppDateUtils.isSameDay(_startDate, _endDate)) {
      return fullFmt.format(_startDate);
    }
    return "${shortFmt.format(_startDate)} - ${fullFmt.format(_endDate)}";
  }

  /// Total des dépenses affichées.
  double get totalAmount => _expenses.fold<double>(
        0,
        (sum, item) => sum + (item.price ?? 0),
      );

  /// Charge les dépenses de la période courante.
  Future<void> load(BuildContext context) async {
    if (_disposed) return;

    final int requestId = ++_fetchRequestId;
    final DateTime periodStart = AppDateUtils.startOfDay(_startDate);
    final DateTime periodEnd = AppDateUtils.endOfDay(_endDate);

    _isLoading = true;
    _notify();

    try {
      final List<Spending> spendings = await _spendingService.getAllSpending(
        storeId,
        periodStart,
        periodEnd,
        context,
      );

      // Une réponse ancienne ne doit pas écraser le dernier filtre choisi.
      if (_disposed || requestId != _fetchRequestId) return;

      final List<Spending> filteredSpendings = spendings.where((spending) {
        final DateTime? date = spending.createdAt?.toLocal();
        return date != null &&
            !date.isBefore(periodStart) &&
            !date.isAfter(periodEnd);
      }).toList();

      filteredSpendings.sort((a, b) {
        final DateTime aDate = a.createdAt ?? DateTime(2000);
        final DateTime bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      _expenses = filteredSpendings;
    } catch (e) {
      debugPrint("Erreur lors de la récupération : $e");
    } finally {
      if (!_disposed && requestId == _fetchRequestId) {
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

  /// Met à jour une dépense via le service.
  Future<bool> updateExpense({
    required Spending original,
    required double amount,
    required String description,
    required String fallbackStoreId,
    required BuildContext context,
  }) {
    final Spending updated = Spending(
      id: original.id,
      description: description.trim(),
      price: amount,
      storeId: original.storeId ?? fallbackStoreId,
    );

    return _spendingService.updateSpending(updated, context);
  }

  /// Supprime une dépense puis la retire de la liste locale.
  Future<bool> deleteExpense(Spending spending, BuildContext context) async {
    final String? id = spending.id;
    if (id == null || id.isEmpty) return false;

    final bool deleted = await _spendingService.deleteSpending(id, context);

    if (_disposed) return deleted;

    if (deleted) {
      _expenses.removeWhere((e) => e.id == id);
      _notify();
    }
    return deleted;
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
