import 'package:flutter/material.dart';
import 'package:mobile_store_app/widgets/premium_kit.dart';

//
// Micro-label de section — capitales espacées du thème courant.
//
class BuildSelctionLabel extends StatelessWidget {
  final String label;
  const BuildSelctionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return PremiumMicroLabel(label);
  }
}
