import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';

/// ============================================================================
/// LOW STOCK HEADER — en-tête « Stock critique ».
///
///   • `AppScreenHeader` (titre + sous-titre)
///   • pastille 44 × 44 rayon 12 : verte avec coche quand aucune alerte,
///     rouge avec triangle d'alerte sinon (bordure teintée à 25 %)
/// ============================================================================
class LowStockHeader extends StatelessWidget {
  /// `true` lorsque la liste des produits en alerte est vide.
  final bool hasNoAlerts;

  const LowStockHeader({super.key, required this.hasNoAlerts});

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return AppScreenHeader(
      title: "Stock critique",
      subtitle: "Produits nécessitant un restockage",
      actions: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: hasNoAlerts ? c.successSoft : c.dangerSoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: (hasNoAlerts ? c.success : c.danger)
                  .withValues(alpha: 0.25),
            ),
          ),
          child: Icon(
            hasNoAlerts
                ? Icons.check_circle_outline_rounded
                : Icons.warning_amber_rounded,
            size: 20,
            color: hasNoAlerts ? c.success : c.danger,
          ),
        ),
      ],
    );
  }
}
