/// ============================================================================
/// APP CONFIG — constantes techniques et métier partagées par l'application.
///
/// Source unique des valeurs qui étaient jusqu'ici dispersées dans les écrans
/// et les services. **Aucune valeur n'a été modifiée** : chaque constante est
/// la copie exacte du littéral d'origine (voir le commentaire de traçabilité).
///
/// Ce fichier ne dépend d'aucun widget : il peut être lu par la couche
/// données comme par la couche présentation.
/// ============================================================================
class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // IDENTITÉ DE L'APPLICATION
  // ---------------------------------------------------------------------------

  /// Titre de la fenêtre / de l'application (`MaterialApp.title`).
  static const String appName = 'BouTiKa';

  /// Signature affichée sous la marque (écrans d'entrée).
  static const String appTagline = 'ma boutique autrement';

  /// Version affichée des documents (rapports, mentions).
  static const String appVersion = '1.0.0';

  // ---------------------------------------------------------------------------
  // RÉSEAU
  // ---------------------------------------------------------------------------

  /// Base des endpoints REST — valeur historique de `UserService.baseUrl`.
  static const String apiBaseUrl = 'http://127.0.0.1:8080/api';

  /// En-tête d'authentification standard de l'API.
  static const String authorizationHeader = 'Authorization';

  /// Préfixe du jeton JWT.
  static const String bearerPrefix = 'Bearer';

  /// Délai des appels courts (boutiques, retraits, dépenses, stock).
  static const Duration timeoutShort = Duration(seconds: 10);

  /// Délai standard (produits, catégories, employés, commandes).
  static const Duration timeoutStandard = Duration(seconds: 15);

  /// Délai des écritures de dépense (`SpendingServcie`).
  static const Duration timeoutSpending = Duration(seconds: 16);

  /// Délai de l'authentification (`UserService.login`).
  static const Duration timeoutLogin = Duration(seconds: 20);

  /// Délai des rapports d'activité (`OrderService.getAllOrderBetweenTwoDate`).
  static const Duration timeoutReport = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // CODES HTTP UTILISÉS PAR L'API
  // ---------------------------------------------------------------------------

  /// Succès d'une lecture.
  static const int statusOk = 200;

  /// Succès d'une création.
  static const int statusCreated = 201;

  /// Succès d'une suppression sans contenu.
  static const int statusNoContent = 204;

  /// Session expirée / non habilitée (traitée comme abonnement expiré).
  static const int statusUnauthorized = 401;

  /// Abonnement expiré (message dédié).
  static const int statusSubscriptionExpired = 402;

  /// Conflit métier (rupture de stock à la vente).
  static const int statusConflict = 409;

  // ---------------------------------------------------------------------------
  // RÈGLES MÉTIER PARTAGÉES
  // ---------------------------------------------------------------------------

  /// Seuil d'alerte de stock : un produit est « en alerte » lorsque
  /// `baseStock - totalSell` est **strictement inférieur** à cette valeur.
  static const double lowStockThreshold = 10;

  /// Symbole monétaire affiché par défaut.
  static const String currencySymbol = 'F';

  /// Symbole utilisé par les rapports généraux.
  static const String currencySymbolCfa = 'CFA';

  /// Tolérance de la vérification de caisse (comparaison en valeur absolue).
  static const double cashVerificationTolerance = 0.01;

  /// Compteur maximal affiché sur une pastille (« 99+ » au-delà).
  static const int maxBadgeCount = 99;

  // ---------------------------------------------------------------------------
  // IDENTIFIANTS DE ROUTES NOMMÉES EXISTANTES
  // ---------------------------------------------------------------------------

  /// Route initiale de l'application (accueil pré-login).
  static const String routeRoot = '/';

  /// Route de l'écran de connexion (`pushNamed` depuis l'accueil et
  /// l'inscription).
  static const String routeLogin = '/login';
}
