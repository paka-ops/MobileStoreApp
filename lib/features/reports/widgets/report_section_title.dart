import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';

/// Titre de section d'un rapport (16 / w800, interligne serré −0.2).
class ReportSectionTitle extends StatelessWidget {
  final String title;

  const ReportSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: colors.textPrimary,
      ),
    );
  }
}
