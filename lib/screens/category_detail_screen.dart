// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// L'écran de détail d'une catégorie vit désormais dans le module `categories` :
//   lib/features/categories/category_detail_screen.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/categories/category_detail_screen.dart'
    show EmployerCategoryDetailScreen;
