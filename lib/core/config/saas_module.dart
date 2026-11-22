/// ============================================================================
/// SAAS MODULE — description déclarative des modules fonctionnels de BouTiKa.
///
/// Chaque module correspond à un périmètre fonctionnel réel de l'application
/// (un écran ou un groupe d'écrans). Le [SaaSModuleManager] active ou désactive
/// ces modules à chaud, sans recompilation : c'est le socle du modèle SaaS
/// (offre d'entrée, offre complète, modules optionnels par boutique).
///
/// **Tous les modules sont activés par défaut** : l'expérience utilisateur
/// au démarrage est strictement identique à l'application d'origine.
///
/// Ce fichier est du Dart pur (aucun import Flutter) : il est testable et
/// utilisable hors du widget tree.
/// ============================================================================
enum SaaSModule {
  /// Accueil pré-login (« Bienvenue », CTA connexion / inscription).
  welcome(
    label: 'Accueil',
    description: 'Écran d\'accueil avant connexion',
    route: '/',
  ),

  /// Connexion (identifiants + sélection des boutiques).
  auth(
    label: 'Connexion',
    description: 'Authentification et ouverture de session',
    route: '/login',
  ),

  /// Création de compte employeur (parcours en 3 étapes).
  signup(
    label: 'Inscription',
    description: 'Création d\'un compte propriétaire',
    route: '/signup',
  ),

  /// Sélection des boutiques de l'utilisateur.
  stores(
    label: 'Boutiques',
    description: 'Liste, création et suppression des boutiques',
    route: '/stores',
  ),

  /// Tableau de bord comparatif multi-boutiques.
  dashboard(
    label: 'Dashboard',
    description: 'Vue d\'ensemble et classement des boutiques',
    route: '/dashboard',
  ),

  /// Espace de travail d'une boutique (ventes, stock, réglages).
  storeDetail(
    label: 'Boutique',
    description: 'Accueil, inventaire, stock et réglages d\'une boutique',
    route: '/store',
  ),

  /// Historiques unifiés (ventes, stock, dépenses, retraits).
  history(
    label: 'Historiques',
    description: 'Navigation unifiée entre les quatre historiques',
    route: '/history',
  ),

  /// Historique des ventes, filtres et vérification de caisse.
  orders(
    label: 'Ventes',
    description: 'Commandes, filtres de période et vérification de caisse',
    route: '/orders',
  ),

  /// Stock : réapprovisionnements et produits sous le seuil.
  stock(
    label: 'Stock',
    description: 'Mouvements de stock et alertes de rupture',
    route: '/stock',
  ),

  /// Dépenses de la boutique.
  expenses(
    label: 'Dépenses',
    description: 'Suivi et édition des dépenses',
    route: '/expenses',
  ),

  /// Retraits d'argent (achats).
  withdrawals(
    label: 'Retraits',
    description: 'Suivi et édition des retraits',
    route: '/withdrawals',
  ),

  /// Catalogue : catégories et produits.
  catalog(
    label: 'Catalogue',
    description: 'Catégories, fiches produits et statistiques produit',
    route: '/catalog',
  ),

  /// Rapports généraux et analyses par catégorie.
  reports(
    label: 'Rapports',
    description: 'Rapport général et analyses par catégorie',
    route: '/reports',
  ),

  /// Abonnement de la boutique.
  subscription(
    label: 'Abonnement',
    description: 'Formule, avantages et contact commercial',
    route: '/subscription',
  );

  const SaaSModule({
    required this.label,
    required this.description,
    required this.route,
  });

  /// Libellé lisible (UI d'administration des modules).
  final String label;

  /// Description courte du périmètre fonctionnel.
  final String description;

  /// Route nommée associée au module (consommée par `core/router/`).
  final String route;

  /// Identifiant stable du module (utilisé en persistance / API SaaS).
  String get id => name;

  /// Tous les modules, dans l'ordre de déclaration.
  static List<SaaSModule> get all => SaaSModule.values;

  /// Module associé à une route nommée, ou `null` si la route n'est pas
  /// pilotée par un module (ex. routes profondes créées par `Navigator.push`).
  static SaaSModule? fromRoute(String? route) {
    if (route == null) return null;
    for (final SaaSModule module in SaaSModule.values) {
      if (module.route == route) return module;
    }
    return null;
  }
}
