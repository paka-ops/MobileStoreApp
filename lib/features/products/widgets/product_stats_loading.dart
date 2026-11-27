import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/loading/shimmer.dart';
import 'package:mobile_store_app/shared/widgets/loading/boutika_loader.dart';

/// ============================================================================
/// PRODUCT STATS LOADING — squelette de chargement des statistiques.
///
///   • carte hero factice (pastille 52, deux lignes, barre 10 px)
///   • `StatGridSkeleton`
///   • `BouTikaLoader` + « Chargement des statistiques... »
///
/// Le `ListView` n'est pas défilable, comme dans l'original.
/// ============================================================================
class ProductStatsLoading extends StatelessWidget {
  const ProductStatsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        const SizedBox(height: 8),

        // Squelette hero
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerBox(width: 52, height: 52, radius: 16),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(
                          width: double.infinity,
                          height: 16,
                          radius: AppRadius.xs,
                        ),
                        SizedBox(height: 8),
                        ShimmerBox(
                          width: 110,
                          height: 12,
                          radius: AppRadius.xs,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const ShimmerBox(
                width: double.infinity,
                height: 10,
                radius: AppRadius.xs,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const StatGridSkeleton(),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              const BouTikaLoader(),
              const SizedBox(height: 14),
              Text(
                "Chargement des statistiques...",
                style: AppTextStyles.bodySecondary.copyWith(
                  color: c.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
