import 'package:flutter/material.dart';

import '../../constants/app_durations.dart';
import '../../constants/app_radius.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_colors.dart';

/// ============================================================================
/// SHIMMER — effet de chargement « squelette » pour les listes et cartes.
///
///   ShimmerBox(width: 120, height: 14)
///   ProductListSkeleton(itemCount: 5)
/// ============================================================================
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = AppRadius.xs,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * t, 0),
              end: Alignment(0.0 + 2 * t, 0),
              colors: [
                c.shimmerBase,
                c.shimmerHighlight,
                c.shimmerBase,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Squelette d'un élément de liste « produit / commande / dépense ».
class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 46, height: 46, radius: AppRadius.md),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: double.infinity,
                  height: 13,
                  radius: AppRadius.xs,
                ),
                const SizedBox(height: 8),
                ShimmerBox(width: 130, height: 11, radius: AppRadius.xs),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const ShimmerBox(width: 56, height: 22, radius: AppRadius.sm),
        ],
      ),
    );
  }
}

/// Squelette d'une liste complète.
class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ListRowSkeleton(),
    );
  }
}

/// Squelette d'une grille de KPI (2 colonnes).
class StatGridSkeleton extends StatelessWidget {
  const StatGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: _StatTileSkeleton()),
            SizedBox(width: 10),
            Expanded(child: _StatTileSkeleton()),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(child: _StatTileSkeleton()),
            SizedBox(width: 10),
            Expanded(child: _StatTileSkeleton()),
          ],
        ),
      ],
    );
  }
}

class _StatTileSkeleton extends StatelessWidget {
  const _StatTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Container(
      height: 92,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 34, height: 34, radius: AppRadius.sm),
          const Spacer(),
          ShimmerBox(width: 90, height: 13, radius: AppRadius.xs),
          const SizedBox(height: 7),
          ShimmerBox(width: 56, height: 10, radius: AppRadius.xs),
        ],
      ),
    );
  }
}

/// Spinners compact réutilisable hors bouton.
class AppSpinner extends StatelessWidget {
  final double size;
  final Color? color;

  const AppSpinner({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.6,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? c.primary),
      ),
    );
  }
}
