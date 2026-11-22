// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// L'accueil pré-login vit désormais dans le module `welcome` :
//   lib/features/welcome/welcome_pre_login_screen.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/welcome/welcome_pre_login_screen.dart'
    show WelcomePreLoginScreen;
