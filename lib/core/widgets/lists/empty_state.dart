import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../theme/app_colors.dart';
import '../buttons/app_button.dart';

/// ============================================================================
/// EMPTY STATE — état vide premium (illustration, titre, message, action).
///
///   EmptyState(
///     icon: Icons.inventory_2_outlined,
///     title: 'Aucun produit',
///     message: 'Aucun produit disponible pour le moment.',
///     actionLabel: 'Actualiser',
///     onAction: _loadProducts,
///   )
/// ============================================================================
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final Color? iconSoftColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSoftColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxHeight < 340;
        final double circle = compact ? 76 : 116;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: compact ? 12 : 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: circle,
                      height: circle,
                      decoration: BoxDecoration(
                        color: iconSoftColor ?? c.primarySoft,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border),
                      ),
                      child: Icon(
                        icon,
                        size: circle * 0.42,
                        color: iconColor ?? c.primary,
                      ),
                    ),
                    SizedBox(height: compact ? 14 : 26),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: compact ? 16.5 : 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: compact ? 6 : 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: compact ? 12.5 : 13.5,
                        height: 1.5,
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      SizedBox(height: compact ? 14 : 24),
                      AppButton.primary(
                        label: actionLabel!,
                        onPressed: onAction,
                        icon: Icons.refresh_rounded,
                        expand: false,
                        height: compact ? 42 : 48,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ============================================================================
/// ERROR STATE — état d'erreur avec bouton « Réessayer ».
/// ============================================================================
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Erreur de chargement',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: c.danger,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.5),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton.primary(
                label: 'Réessayer',
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// INFO CALLOUT — encart d'information coloré (ex : « Stock actuel : 3.0 »).
/// ============================================================================
class InfoCallout extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color softColor;

  const InfoCallout({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(AppRadius.mlg),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
