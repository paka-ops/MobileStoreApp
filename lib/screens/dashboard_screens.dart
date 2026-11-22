// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// Le tableau de bord vit désormais dans le module `dashboard` :
//   lib/features/dashboard/dashboard_screen.dart
//   lib/features/dashboard/widgets/global_kpi_card.dart
//   lib/features/dashboard/widgets/store_card.dart
//   lib/features/dashboard/models/store_dash_data.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/dashboard/dashboard_screen.dart' show DashboardScreen;
