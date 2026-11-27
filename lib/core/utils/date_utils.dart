/// ============================================================================
/// APP DATE UTILS — bornes de journée et comparaisons de dates.
///
/// Ces helpers remplacent les implémentations dupliquées (`_today`,
/// `_startOfDay`, `_endOfDay`) des écrans Dépenses, Retraits et Stock.
/// La sémantique est identique, y compris la borne de fin de journée calculée
/// en microsecondes (elle exclut la microseconde du lendemain, donc la journée
/// entière est couverte, heure d'été comprise).
/// ============================================================================
class AppDateUtils {
  AppDateUtils._();

  /// Début du jour civil de [date] (00:00:00.000000).
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Fin du jour civil de [date] (23:59:59.999999).
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day + 1)
          .subtract(const Duration(microseconds: 1));

  /// Début du jour courant.
  static DateTime today() => startOfDay(DateTime.now());

  /// `true` si les deux dates appartiennent au même jour civil.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
