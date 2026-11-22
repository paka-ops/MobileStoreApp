// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// L'écran de stock critique vit désormais dans le module `stock` :
//   lib/features/stock/low_stock_screen.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/stock/low_stock_screen.dart'
    show LowStockProductDetailsScreen;
