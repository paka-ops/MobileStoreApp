import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// FLOATING RATING CARD — petite carte blanche flottante avec note.
///
///   • Card blanche, BorderRadius.circular(16), ombre flottante
///   • Avatar circulaire + badge rating (étoile jaune + note)
///
///   FloatingRatingCard(
///     name: "Ama Kossi",
///     subtitle: "Vendeuse · 42 ventes",
///     rating: 4.8,
///     initials: "AK",
///   )
///
/// `FloatingRatingCard.compact` n'affiche que l'avatar et le badge : parfait
/// en overlay (Stack) sur une image de boutique / produit.
///
/// ⚠️ Widget d'affichage pur — la note est fournie par l'appelant.
/// ============================================================================
class FloatingRatingCard extends StatelessWidget {
  final String? name;
  final String? subtitle;

  /// Note affichée (ex. 4.8). Null → badge masqué.
  final double? rating;

  /// Nombre d'avis (optionnel, ex. « 128 avis »).
  final String? reviewsLabel;

  /// Avatar : enfant personnalisé > initiales > icône.
  final Widget? avatar;
  final String? initials;
  final IconData avatarIcon;

  final VoidCallback? onTap;

  /// Mode compact : avatar + badge uniquement (overlay).
  final bool compact;

  /// Échelle typographique du nom (13.5 par défaut).
  final double? nameSize;

  final EdgeInsetsGeometry padding;
  final Color? background;

  const FloatingRatingCard({
    super.key,
    this.name,
    this.subtitle,
    this.rating,
    this.reviewsLabel,
    this.avatar,
    this.initials,
    this.avatarIcon = Icons.person_rounded,
    this.onTap,
    this.compact = false,
    this.nameSize,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.background,
  });

  /// Variante overlay : uniquement l'avatar et la note.
  const FloatingRatingCard.compact({
    super.key,
    this.rating,
    this.initials,
    this.avatar,
    this.avatarIcon = Icons.person_rounded,
    this.onTap,
    this.background,
    this.reviewsLabel,
    this.name,
    this.subtitle,
    this.nameSize,
  })  : compact = true,
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return PressableScale(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: background ?? c.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: c.floatingShadow,
          ),
          child: compact ? _buildCompact(c) : _buildFull(c),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildCompact(DashColors c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Avatar(initials: initials, avatar: avatar, icon: avatarIcon, size: 34),
        if (rating != null) ...[
          const SizedBox(width: 8),
          _RatingBadge(c: c, rating: rating!),
        ],
      ],
    );
  }

  Widget _buildFull(DashColors c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Avatar(initials: initials, avatar: avatar, icon: avatarIcon, size: 40),
        if (name != null || subtitle != null) ...[
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name != null)
                  Text(
                    name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: c.textPrimary,
                      fontSize: nameSize ?? 13.5,
                    ),
                  ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(color: c.textSecondary),
                  ),
              ],
            ),
          ),
        ],
        if (rating != null) ...[
          const SizedBox(width: 10),
          _RatingBadge(c: c, rating: rating!),
        ],
      ],
    );
  }
}

/// Badge « étoile jaune + note » (pilule pastel).
class _RatingBadge extends StatelessWidget {
  final DashColors c;
  final double rating;

  const _RatingBadge({required this.c, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: c.ratingSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: c.rating),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.rating.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Avatar circulaire (image / initiales / icône).
class _Avatar extends StatelessWidget {
  final String? initials;
  final Widget? avatar;
  final IconData icon;
  final double size;

  const _Avatar({
    this.initials,
    this.avatar,
    required this.icon,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    if (avatar != null) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipOval(child: FittedBox(fit: BoxFit.cover, child: avatar)),
      );
    }

    final bool hasInitials = initials != null && initials!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasInitials ? c.primarySoft : c.fill,
      ),
      child: hasInitials
          ? Text(
              initials!.trim().substring(0, 1).toUpperCase(),
              style: AppTextStyles.cardTitle.copyWith(
                color: c.primary,
                fontSize: size * 0.38,
              ),
            )
          : Icon(icon, size: size * 0.5, color: c.textSecondary),
    );
  }
}
