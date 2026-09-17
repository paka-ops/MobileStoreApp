import 'package:flutter/material.dart';

import '../../constants/app_durations.dart';
import '../../constants/app_spacing.dart';
import '../../theme/app_colors.dart';

/// ============================================================================
/// APP BOTTOM NAV — navigation basse premium avec pilule animée et badges.
///
///   AppBottomNav(
///     items: [AppBottomNavItem(...), ...],
///     currentIndex: _currentIndex,
///     onTap: (i) => setState(() => _currentIndex = i),
///     badges: [0, 0, 3, 0],
///   )
/// ============================================================================
class AppBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AppBottomNav extends StatelessWidget {
  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Nombre de badges par item (index aligné sur [items], 0 = aucun).
  final List<int> badges;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.badges = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.floatingNavMarginH,
          0,
          AppSizes.floatingNavMarginH,
          AppSizes.floatingNavMarginB,
        ),
        child: Container(
          height: AppSizes.floatingNavHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: c.navy,
            borderRadius: BorderRadius.circular(AppRadius.navPill),
            boxShadow: c.floatingShadow,
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final bool selected = currentIndex == index;
              final AppBottomNavItem item = items[index];
              final int badge =
                  index < badges.length ? badges[index] : 0;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: AppDurations.normal,
                    curve: AppCurves.standard,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(
                        vertical: 7, horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? c.navPill
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedSwitcher(
                              duration: AppDurations.fast,
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(
                                scale: anim,
                                child: child,
                              ),
                              child: Icon(
                                selected
                                    ? item.activeIcon
                                    : item.icon,
                                key: ValueKey<bool>(selected),
                                color: selected
                                    ? c.navOnNavy
                                    : c.navOnNavyMuted,
                                size: 23,
                              ),
                            ),
                            if (badge > 0)
                              Positioned(
                                right: -4,
                                top: -3,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: c.danger,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: c.navy,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? c.navOnNavy
                                : c.navOnNavyMuted,
                          ),
                        ),
                      ],
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
