import 'package:flutter/material.dart';
import 'package:mobile_store_app/widgets/premium_kit.dart';

//
// État vide générique — médaillon premium du thème courant.
// Même paramètre d'entrée (message), désormais réellement affiché.
//
class BuildEmptyState extends StatelessWidget {
  final String message;
  const BuildEmptyState({required this.message});
  @override
  Widget build(BuildContext context) {
    return PremiumEmptyState(
      icon: Icons.store_outlined,
      title: "Pas de boutique trouvée",
      message: message,
    );
  }
}
