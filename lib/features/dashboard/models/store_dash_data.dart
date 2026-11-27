/// ============================================================================
/// STORE DASH DATA — agrégat de pilotage d'une boutique sur le tableau de bord.
///
/// Reprise à l'identique du modèle privé `_StoreDashData` de l'écran d'origine
/// (données de démonstration : aucune requête réseau).
/// ============================================================================
class StoreDashData {
  final String id;
  final String name;
  final String location;
  final double chiffreAffaires;
  final double benefice;
  final double depenses;
  final int nbCommandes;
  final double panierMoyen;
  final double tauxConversion;
  final List<double> weeklyRevenue;
  final List<double> weeklyExpense;
  final bool isActive;

  const StoreDashData({
    required this.id,
    required this.name,
    required this.location,
    required this.chiffreAffaires,
    required this.benefice,
    required this.depenses,
    required this.nbCommandes,
    required this.panierMoyen,
    required this.tauxConversion,
    required this.weeklyRevenue,
    required this.weeklyExpense,
    this.isActive = true,
  });
}
