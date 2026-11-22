// ============================================================================
// COMPATIBILITÉ — ce fichier ne contient plus d'implémentation.
//
// L'historique des retraits et le formulaire associé vivent désormais dans le
// module `withdrawals` :
//   lib/features/withdrawals/withdrawal_screen.dart
//   lib/features/withdrawals/widgets/withdrawal_form_dialog.dart
//
// Ce shim conserve l'ancien chemin d'import le temps de la migration.
// Il sera supprimé à l'étape de purge (routage SaaS).
// ============================================================================

export '../features/withdrawals/widgets/withdrawal_form_dialog.dart'
    show showWithdrawalFormDialog;
export '../features/withdrawals/withdrawal_screen.dart' show WithdrawalScreen;
