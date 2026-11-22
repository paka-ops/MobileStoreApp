import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_store_app/core/constants/app_durations.dart';
import 'package:mobile_store_app/features/history/history_tabs.dart';

/// ============================================================================
/// HISTORY CONTROLLER — état de navigation de l'écran des historiques.
///
/// Responsabilités (identiques à l'état interne de l'écran d'origine) :
///   • index d'onglet courant, borné sur les quatre historiques
///   • `PageController` partagé entre la barre et le `PageView`
///   • sélection d'un onglet : retour haptique puis animation de page
///     (`AppDurations.normal`, `AppCurves.standard`)
///   • synchronisation lors d'un changement d'`initialIndex` du parent :
///     saut direct de page sans animation, et uniquement si la page est montée
///
/// Le `dispose` libère le `PageController` comme le faisait l'écran.
/// ============================================================================
class HistoryController extends ChangeNotifier {
  HistoryController({required int initialIndex})
      : _currentIndex = HistoryTabs.clampIndex(initialIndex) {
    pageController = PageController(initialPage: _currentIndex);
  }

  late final PageController pageController;

  int _currentIndex;

  /// Onglet actuellement affiché.
  int get currentIndex => _currentIndex;

  /// Métadonnées de l'onglet affiché (sous-titre d'en-tête).
  HistoryTabMeta get currentTab => HistoryTabs.items[_currentIndex];

  /// Sélectionne un onglet depuis la barre de navigation.
  void select(int index) {
    if (index == _currentIndex) return;

    HapticFeedback.selectionClick();
    _currentIndex = index;
    notifyListeners();

    pageController.animateToPage(
      index,
      duration: AppDurations.normal,
      curve: AppCurves.standard,
    );
  }

  /// Synchronise l'index lorsqu'un glissement de page se termine.
  void onPageChanged(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// Applique un nouvel `initialIndex` fourni par le parent.
  void syncInitialIndex(int initialIndex) {
    final int target = HistoryTabs.clampIndex(initialIndex);
    if (target == _currentIndex) return;

    _currentIndex = target;
    if (pageController.hasClients) {
      pageController.jumpToPage(target);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
