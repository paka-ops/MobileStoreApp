// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// Le parcours de création de compte vit désormais dans le module `auth` :
//   lib/features/auth/signup_screen.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/auth/signup_screen.dart' show EmployerFormPage;
