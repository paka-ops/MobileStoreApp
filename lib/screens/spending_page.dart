// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// L'historique des dépenses vit désormais dans le module `spending` :
//   lib/features/spending/spending_screen.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/spending/spending_screen.dart' show ExpensesScreen;
