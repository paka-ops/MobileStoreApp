
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/material/colors.dart';
class BuildSelctionLabel extends StatelessWidget{
  final String label ;
  const BuildSelctionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2),
    );
  }
}