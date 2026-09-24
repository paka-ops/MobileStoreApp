import 'package:flutter/material.dart';

import '../core/constants/app_durations.dart';
import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// ============================================================================
/// FLOATING BOTTOM NAV BAR — barre de navigation flottante du design system.
///
///   • Container flottant, AppRadius.navPill, surface CLAIRE
///   • Margin horizontal 24 px, bottom 16 px
///   • Icônes grises ; l'active passe en encre sur une pilule gris clair
///   • Ombre très diffuse (effet flottant sans lourdeur)
///
///   FloatingBottomNavBar(
///     items: [
///       FloatingNavItem(icon: Icons.home_outlined,
///                       activeIcon: Icons.home_rounded, label: "Accueil"),
///       ...
///     ],
///     currentIndex: _currentIndex,
///     onTap: (i) => setState(() => _currentIndex = i),   // logique inchangée
///     badges: [0, 0, lowStockProducts.length, 0],
///   )
///
/// ⚠️ Aucune logique : l'index et le callback viennent de l'écran.
/// ============================================================================
class FloatingNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class FloatingBottomNavBar extends StatelessWidget {
  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Nombre de badges par item (index aligné sur [items], 0 = aucun).
  final List<int> badges;

  /// Affiche le libellé sous l'icône (désactivé par défaut : icônes seules).
  final bool showLabels;

  final double height;
  final EdgeInsetsGeometry margin;

  /// Couleur du fond de la barre (navy par défaut).
  final Color? background;

  const FloatingBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.badges = const <int>[],
    this.showLabels = false,
    this.height = AppSizes.floatingNavHeight,
    this.margin = const EdgeInsets.fromLTRB(
      AppSizes.floatingNavMarginH,
      0,
      AppSizes.floatingNavMarginH,
      AppSizes.floatingNavMarginB,
    ),
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: margin,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: background ?? c.navSurface,
            borderRadius: BorderRadius.circular(AppRadius.navPill),
            boxShadow: [
              BoxShadow(
                color: c.navShadowColor,
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final bool selected = currentIndex == index;
              final FloatingNavItem item = items[index];
              final int badge = index < badges.length ? badges[index] : 0;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Center(
                    child: AnimatedContainer(
                      duration: AppDurations.normal,
                      curve: AppCurves.standard,
                      padding: EdgeInsets.symmetric(
                        horizontal: selected ? 18 : 12,
                        vertical: showLabels ? 7 : 10,
                      ),
                      decoration: BoxDecoration(
                        // Pilule gris clair sous l'icône active
                        color: selected ? c.navPill : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: AppDurations.fast,
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  selected ? item.activeIcon : item.icon,
                                  key: ValueKey<bool>(selected),
                                  size: 23,
                                  color: selected
                                      ? c.navActive
                                      : c.navInactive,
                                ),
                              ),
                              if (showLabels) ...[
                                const SizedBox(height: 3),
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 10,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? c.navActive
                                        : c.navInactive,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (badge > 0)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: c.badgeRed,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: c.navSurface,
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  badge > 99 ? "99+" : "$badge",
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
