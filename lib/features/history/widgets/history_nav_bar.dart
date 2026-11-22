import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_durations.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/features/history/history_tabs.dart';

/// ============================================================================
/// HISTORY NAV BAR — barre de navigation horizontale premium.
///
///   • bandeau en verre dépoli (flou σ 16) hauteur 48, rayon 20, bordure 1.2
///   • marge extérieure 16·6·16·4, ombre douce
///   • pilule sélectionnée : fond carte élevée (0.92 sombre / 0.96 clair),
///     bordure d'accent 18 %, ombre de pilule active, libellé w700
///   • icône + libellé réduits par `FittedBox` pour éviter tout débordement
///
/// Toutes les constantes, durées et courbes sont celles de l'écran d'origine.
/// ============================================================================
class HistoryNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const HistoryNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: c.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: c.card.withValues(alpha: c.isDark ? 0.65 : 0.72),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: c.isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.80),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(HistoryTabs.items.length, (index) {
                  final HistoryTabMeta tab = HistoryTabs.items[index];
                  final bool selected = index == currentIndex;
                  final Color accent = HistoryTabs.accentFor(index, c);

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelected(index),
                      child: AnimatedContainer(
                        duration: AppDurations.normal,
                        curve: AppCurves.standard,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? (c.isDark
                                  ? c.cardElevated.withValues(alpha: 0.92)
                                  : c.card.withValues(alpha: 0.96))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: selected
                              ? Border.all(
                                  color: accent.withValues(alpha: 0.18),
                                  width: 1,
                                )
                              : null,
                          boxShadow: selected ? c.activePillShadow : null,
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  selected ? tab.activeIcon : tab.icon,
                                  size: 15,
                                  color: selected ? accent : c.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  tab.label,
                                  maxLines: 1,
                                  style: AppTextStyles.pillText.copyWith(
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? c.pillActiveText
                                        : c.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
