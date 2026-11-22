// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// L'écran unifié des historiques vit désormais dans le module `history` :
//   lib/features/history/history_screen.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/history/history_screen.dart' show HistoryScreen;
