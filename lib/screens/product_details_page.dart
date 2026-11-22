// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// Les statistiques produit vivent désormais dans le module `products` :
//   lib/features/products/product_details_screen.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/products/product_details_screen.dart'
    show ProductStatsScreen;
