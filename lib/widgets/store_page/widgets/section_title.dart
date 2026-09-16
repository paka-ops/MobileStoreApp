import 'package:flutter/material.dart';
import 'package:mobile_store_app/widgets/premium_kit.dart';

//
// Titre de section — micro-label du thème courant.
// Même paramètre d'entrée (title).
//
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: PremiumMicroLabel(title),
    );
  }
}
