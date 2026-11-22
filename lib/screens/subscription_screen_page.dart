// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// L'écran d'abonnement vit désormais dans le module `subscription` :
//   lib/features/subscription/subscription_screen.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/subscription/subscription_screen.dart'
    show SubscriptionScreenPage;
