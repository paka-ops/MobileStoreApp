import 'package:flutter/material.dart';

import '../core/constants/app_durations.dart';
import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// ============================================================================
/// CUSTOM TAB BAR — onglets texte du design system.
///
///   • Row de textes (Services, Reviews, Education, Rewards)
///   • Onglet actif : teal + indicateur (underline) teal dessous
///   • Onglets inactifs : gris
///
///   CustomTabBar(
///     tabs: const ["Services", "Avis", "Formation", "Récompenses"],
///     currentIndex: _tabIndex,
///     onTap: (i) => setState(() => _tabIndex = i),   // logique inchangée
///   )
///
/// Variante `CustomTabBar.scrollable` si les libellés sont longs/nombreux.
/// Le widget ne gère PAS le contenu : fournissez votre IndexedStack /
/// PageView comme avant (le callback reste identique).
/// ============================================================================
class CustomTabItem {
  final String label;

  /// Compteur optionnel affiché dans une petite pastille.
  final int badgeCount;

  const CustomTabItem(this.label, {this.badgeCount = 0});
}

class CustomTabBar extends StatelessWidget {
  final List<CustomTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Scroll horizontal (au lieu de répartir sur la largeur).
  final bool scrollable;

  /// Affiche une ligne de séparation fine sous la barre.
  final bool showBottomLine;

  final EdgeInsetsGeometry padding;
  final Color? activeColor;

  const CustomTabBar({
    super.key,
    required List<String> tabs,
    required this.currentIndex,
    required this.onTap,
    this.scrollable = false,
    this.showBottomLine = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.screenPadding,
    ),
    this.activeColor,
  }) : items = tabs
            .map((String label) => CustomTabItem(label))
            .toList(growable: false);

  /// Constructeur riche : libellés + compteurs.
  const CustomTabBar.items({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.scrollable = false,
    this.showBottomLine = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.screenPadding,
    ),
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final Color active = activeColor ?? c.primary;

    final List<CustomTabItem> tabs = items.isNotEmpty
        ? items
        : const <CustomTabItem>[CustomTabItem("Sans titre")];

    final List<Widget> children = List.generate(tabs.length, (index) {
      final bool selected = index == currentIndex;
      final CustomTabItem tab = tabs[index];

      final Widget tabChild = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 14.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? active : c.textSecondary,
                    ),
                  ),
                  if (tab.badgeCount > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? c.primarySoft : c.fill,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        tab.badgeCount > 99 ? "99+" : "${tab.badgeCount}",
                        style: AppTextStyles.label.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: selected ? active : c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 7),
              // Indicateur (underline) teal animé sous l'onglet actif
              AnimatedContainer(
                duration: AppDurations.normal,
                curve: AppCurves.standard,
                height: 3,
                width: selected ? 24 : 0,
                decoration: BoxDecoration(
                  color: active,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ],
          ),
        ),
      );

      if (scrollable) {
        return Padding(
          padding: const EdgeInsets.only(right: 22),
          child: tabChild,
        );
      }
      return Expanded(child: Center(child: tabChild));
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding,
          child: scrollable
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: children),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: children,
                ),
        ),
        if (showBottomLine) Container(height: 1, color: c.hairline),
      ],
    );
  }
}
