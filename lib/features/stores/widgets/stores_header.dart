import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/shared/widgets/layout/app_brand_header.dart';

/// ============================================================================
/// STORES HEADER — en-tête de la liste des boutiques.
///
///   • marque BouTiKa (sous-titre « Mes Boutiques ») — `AppBrandHeader`
///   • gap 12
///   • trois chips d'information dans un défilement horizontal :
///       – nombre de boutiques (singulier/pluriel)
///       – statut (Admin / Staff)
///       – Dashboard (employeur uniquement, icône cliquable)
///
/// La marge extérieure `fromLTRB(20, 16, 20, 10)` est appliquée au bloc
/// complet (et non au seul en-tête de marque), comme dans l'écran d'origine.
/// ============================================================================
class StoresHeader extends StatelessWidget {
  /// Type d'utilisateur connecté (`employer` ou autre).
  final String userType;

  /// Nombre de boutiques affichées.
  final int storeCount;

  /// Ouvre le tableau de bord (chip « Dashboard »).
  final VoidCallback onOpenDashboard;

  const StoresHeader({
    super.key,
    required this.userType,
    required this.storeCount,
    required this.onOpenDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppBrandHeader(
            subtitle: "Mes Boutiques",
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),

          // Chips d'info — défilement horizontal (anti-overflow)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StoreStatChip(
                  colors: colors,
                  icon: Icons.inventory_2_rounded,
                  label: "$storeCount",
                  sub: storeCount > 1 ? "Boutiques" : "Boutique",
                ),
                const SizedBox(width: 8),
                _StoreStatChip(
                  colors: colors,
                  icon: Icons.verified_user_rounded,
                  label: userType == "employer" ? "Admin" : "Staff",
                  sub: "Statut",
                ),
                if (userType == "employer") ...[
                  const SizedBox(width: 8),
                  _StoreStatChip(
                    colors: colors,
                    icon: Icons.query_stats,
                    buttonIcon: Icons.query_stats,
                    label: "Dashboard",
                    sub: "Info rapide",
                    onPressed: onOpenDashboard,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip d'en-tête : icône (ou bouton 32 × 32) + valeur + légende.
class _StoreStatChip extends StatelessWidget {
  final DashColors colors;
  final IconData icon;
  final String label;
  final String sub;
  final IconData? buttonIcon;
  final VoidCallback? onPressed;

  const _StoreStatChip({
    required this.colors,
    required this.icon,
    required this.label,
    required this.sub,
    this.buttonIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: buttonIcon != null ? 4 : 12,
        right: 12,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (buttonIcon != null)
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onPressed,
                icon: Icon(buttonIcon, color: colors.primary, size: 16),
              ),
            )
          else
            Icon(icon, color: colors.primary, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1.1,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
