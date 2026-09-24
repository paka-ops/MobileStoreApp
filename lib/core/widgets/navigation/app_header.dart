import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../buttons/app_button.dart';

/// ============================================================================
/// APP SCREEN HEADER — en-tête standard des écrans de détail :
/// bouton retour + titre + sous-titre + actions (icônes carrées).
/// ============================================================================
class AppScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: c.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      AppTextStyles.label.copyWith(color: c.textSecondary, fontSize: 12.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            actions[i],
          ],
        ],
      ),
    );
  }
}

/// ============================================================================
/// APP BRAND MARK — logo / wordmark « BouTiKa » réutilisable.
/// ============================================================================
class AppBrandMark extends StatelessWidget {
  final double fontSize;

  const AppBrandMark({super.key, this.fontSize = 18});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.primary.withValues(alpha: 0.15)),
      ),
      child: Text(
        'BouTiKa',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: c.primary,
        ),
      ),
    );
  }
}
