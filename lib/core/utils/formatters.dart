import 'package:intl/intl.dart';

/// ============================================================================
/// APP FORMATTERS — fonctions de formatage partagées.
///
/// Chaque fonction reproduit **exactement** une implémentation qui existait
/// (souvent en double) dans les écrans. Les arrondis, les séparateurs et les
/// symboles sont identiques au caractère près : la migration vers ces helpers
/// ne peut pas modifier l'affichage.
///
/// Les variantes qui diffèrent volontairement (par exemple `25 000 F` vs
/// `25 000,00 F`) coexistent ici sous des noms explicites, afin qu'aucun écran
/// ne se retrouve avec un format « emprunté » à un autre.
/// ============================================================================
class AppFormatters {
  AppFormatters._();

  // ---------------------------------------------------------------------------
  // MONTANTS
  // ---------------------------------------------------------------------------

  /// Montant compact sans symbole : `1.2M`, `485K`, `980`.
  /// (Dashboard : `_fmt`.)
  static String compactAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }

  /// Montant compact suivi du symbole : `1.2M F`, `485K F`, `980 F`.
  /// (Statistiques produit : `_fmtCurrency`.)
  static String compactAmountWithSymbol(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M F';
    }
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K F';
    return '${amount.toStringAsFixed(0)} F';
  }

  /// Montant à deux décimales : `50000.00 F`.
  /// (Vérification de caisse : `formatOrderMontant`.)
  static String amountWithSymbol(double amount) =>
      '${amount.toStringAsFixed(2)} F';

  /// Montant arrondi à l'unité : `48500 F`.
  /// (Rapports par catégorie : `_buildStatItem`.)
  static String roundedAmountWithSymbol(num amount) =>
      '${amount.toStringAsFixed(0)} F';

  /// Montant suivi de « CFA » sans formatage (valeur brute Dart).
  /// (Rapport général : interpolation directe de `num`.)
  static String cfaAmount(num amount) => '$amount CFA';

  /// Montant « nu » : entier si la valeur est ronde, sinon représentation Dart
  /// par défaut (`5000`, `12.5`). Aucun séparateur de milliers.
  /// (Formulaire de retrait : `_formatAmount`.)
  static String plainAmount(double amount) => amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toString();

  // ---------------------------------------------------------------------------
  // COMPTEURS
  // ---------------------------------------------------------------------------

  /// Pastille de compteur : `99+` au-delà de 99, sinon la valeur.
  static String badgeCount(int value) => value > 99 ? '99+' : '$value';

  // ---------------------------------------------------------------------------
  // SAISIE UTILISATEUR
  // ---------------------------------------------------------------------------

  /// Analyse d'un montant saisi, tolérante aux espaces et à la virgule
  /// décimale : `" 50 000,50 "` → `50000.5`.
  /// (Vérification de caisse : `parseOrderMontant`.)
  static double? parseAmount(String? value) {
    if (value == null) return null;
    return double.tryParse(
      value.trim().replaceAll(RegExp(r'\s'), '').replaceAll(',', '.'),
    );
  }

  /// Analyse d'un montant saisi sans retrait des espaces internes :
  /// `"12,5"` → `12.5`. (Formulaire de retrait.)
  static double? parsePlainAmount(String? value) {
    if (value == null) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  // ---------------------------------------------------------------------------
  // DATES
  // ---------------------------------------------------------------------------

  /// `true` si les deux dates tombent le même jour civil.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Libellé d'une période :
  ///   • même jour (ou pas de fin) → `12/05/2024`
  ///   • sinon                     → `12/05 - 30/06/2024`
  ///
  /// (Filtres des historiques : ventes, stock, dépenses, retraits.)
  static String dateRangeLabel(DateTime start, DateTime? end) {
    final DateFormat fullFmt = DateFormat('dd/MM/yyyy');
    final DateFormat shortFmt = DateFormat('dd/MM');
    if (end == null || isSameDay(start, end)) return fullFmt.format(start);
    return '${shortFmt.format(start)} - ${fullFmt.format(end)}';
  }

  /// Date complète `jj/MM/aaaa`.
  static String fullDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
}
