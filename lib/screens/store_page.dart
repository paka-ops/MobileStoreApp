// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// La page boutiquier vit désormais dans le module `store_detail` :
//   lib/features/store_detail/store_detail_screen.dart
//   lib/features/store_detail/widgets/store_category_card.dart
//   lib/features/store_detail/widgets/store_category_action_button.dart
//   lib/features/store_detail/utils/get_low_stock_product.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/store_detail/store_detail_screen.dart'
    show OrderLine, StoreDetailScreen;
