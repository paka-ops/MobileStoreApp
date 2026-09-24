import 'package:flutter/material.dart';

import '../../core/widgets/common/primitives.dart';
import 'store_design.dart';

/// ============================================================================
/// STORE WIDGETS — widgets de présentation DÉDIÉS à `store_page.dart`.
///
/// ⚠️ Ce sont les « jumeaux » restylés des widgets partagés
///    (`AppGreetingHeader`, `CustomTabBar`, `FloatingBottomNavBar`,
///    `CategoryCard`, `CustomTabBar`…) : **mêmes paramètres, mêmes callbacks,
///    même structure de layout** — seuls les jetons visuels changent
///    (nouvelle palette, SF Pro Display, rayons/espacements/ombres).
///
/// Les originaux restent en place pour les autres écrans : aucun autre écran
/// n'est impacté par ce fichier.
///
/// 100 % présentation : aucune logique métier, aucun service, aucun état.
/// ============================================================================

// ============================================================================
// 1. EN-TÊTE (jumeau de AppGreetingHeader)
// ============================================================================
class StoreGreetingHeader extends StatelessWidget {
  /// Petite ligne grise d'accroche (« Bonjour, … »).
  final String greeting;

  /// Nom mis en avant (boutique, utilisateur…).
  final String title;

  /// Sous-texte (localisation, rôle…).
  final String? subtitle;

  final IconData subtitleIcon;
  final bool showSubtitleChevron;

  final VoidCallback? onTapTitle;
  final VoidCallback? onTapSubtitle;

  /// Cloche de notification.
  final VoidCallback? onTapNotifications;
  final int notificationCount;
  final IconData bellIcon;

  /// Avatar : priorité enfant > initiales > icône.
  final Widget? avatar;
  final String? avatarInitials;
  final IconData avatarIcon;
  final VoidCallback? onTapAvatar;

  /// Forme de l'avatar : carré arrondi (défaut) ou cercle.
  final bool avatarRounded;

  /// Couleur de fond de l'avatar.
  final Color? avatarBackground;

  /// Boutons supplémentaires insérés avant la cloche.
  final List<Widget> extraActions;

  /// Contenu optionnel affiché sous la ligne principale.
  final Widget? bottom;

  /// Visibilité de la cloche.
  final bool showBell;

  final EdgeInsetsGeometry padding;

  const StoreGreetingHeader({
    super.key,
    required this.greeting,
    required this.title,
    this.subtitle,
    this.subtitleIcon = Icons.location_on_outlined,
    this.showSubtitleChevron = true,
    this.onTapTitle,
    this.onTapSubtitle,
    this.onTapNotifications,
    this.notificationCount = 0,
    this.bellIcon = Icons.notifications_none_rounded,
    this.avatar,
    this.avatarInitials,
    this.avatarIcon = Icons.storefront_rounded,
    this.onTapAvatar,
    this.avatarRounded = true,
    this.avatarBackground,
    this.extraActions = const <Widget>[],
    this.bottom,
    this.showBell = true,
    this.padding = const EdgeInsets.fromLTRB(
      StoreDimensions.screenPadding,
      14,
      StoreDimensions.screenPadding,
      8,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final StorePalette p = StorePalette(context);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ------------------------------------------------- Bloc gauche
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapTitle ?? onTapSubtitle,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1 — petite ligne grise
                      Text(
                        greeting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StoreTextStyles.eyebrow
                            .copyWith(color: p.textSecondary),
                      ),
                      const SizedBox(height: StoreDimensions.paddingXS),

                      // 2 — titre encre + chevron (sélecteur de boutique)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: StoreTextStyles.heading
                                  .copyWith(color: p.textPrimary),
                            ),
                          ),
                          if (showSubtitleChevron)
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: p.textSecondary,
                            ),
                        ],
                      ),

                      // 3 — localisation (grise, discrète)
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onTapSubtitle ?? onTapTitle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                subtitleIcon,
                                size: 13,
                                color: p.textTertiary,
                              ),
                              const SizedBox(width: StoreDimensions.paddingXS),
                              Flexible(
                                child: Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: StoreTextStyles.caption
                                      .copyWith(color: p.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // ------------------------------------------------- Bloc droit
              ...extraActions,
              if (extraActions.isNotEmpty) const SizedBox(width: 8),
              if (showBell) ...[
                _StoreCircleActionButton(
                  icon: bellIcon,
                  onTap: onTapNotifications,
                  badgeCount: notificationCount,
                  tooltip: "Notifications",
                ),
                const SizedBox(width: 10),
              ],
              _StoreHeaderAvatar(
                onTap: onTapAvatar,
                initials: avatarInitials,
                icon: avatarIcon,
                rounded: avatarRounded,
                background: avatarBackground,
                child: avatar,
              ),
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 14),
            bottom!,
          ],
        ],
      ),
    );
  }
}

/// Cercle clair contenant une icône (cloche, actions rapides).
/// Le badge est une pastille CIRCULAIRE rouge posée en haut à droite.
class _StoreCircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;
  final String? tooltip;

  const _StoreCircleActionButton({
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final StorePalette p = StorePalette(context);

    Widget button = PressableScale(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: p.cardBackground,
          shape: BoxShape.circle,
          boxShadow: p.softShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: p.textPrimary),
            if (badgeCount > 0)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: BoxDecoration(
                    color: p.badgeRed,
                    borderRadius:
                        BorderRadius.circular(StoreDimensions.radiusPill),
                    border: Border.all(color: p.cardBackground, width: 1.6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? "99+" : "$badgeCount",
                    style: StoreTextStyles.chip.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// Avatar d'en-tête (photo, initiales ou icône) — carré arrondi par défaut.
class _StoreHeaderAvatar extends StatelessWidget {
  final VoidCallback? onTap;
  final String? initials;
  final IconData icon;
  final Widget? child;
  final bool rounded;
  final Color? background;

  const _StoreHeaderAvatar({
    this.onTap,
    this.initials,
    this.icon = Icons.storefront_rounded,
    this.child,
    this.rounded = true,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final StorePalette p = StorePalette(context);
    final BorderRadius radius = BorderRadius.circular(
      rounded ? StoreDimensions.radiusMedium : StoreDimensions.radiusPill,
    );
    final bool hasInitials = initials != null && initials!.trim().isNotEmpty;

    Widget content;
    if (child != null) {
      content = child!;
    } else if (hasInitials) {
      content = Center(
        child: Text(
          initials!.trim().substring(0, 1).toUpperCase(),
          style: StoreTextStyles.cardTitle.copyWith(
            color: p.ink,
            fontSize: 16,
          ),
        ),
      );
    } else {
      content = Icon(icon, size: 20, color: p.ink);
    }

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: background ?? p.cardBackground,
          borderRadius: radius,
          boxShadow: p.softShadow,
        ),
        child: content,
      ),
    );
  }
}

// ============================================================================
// 2. ONGLETS EN PILULES (jumeau de CustomTabBar)
// ============================================================================
///   • Piste grise arrondie (`pillBackground`), hauteur 44 px
///   • Segment ACTIF : persil blanc + ombre douce, texte noir
///   • Segment INACTIF : texte `pillInactiveText`, fond transparent
class StoreTabBar extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Ligne de séparation fine sous la barre (désactivée par défaut).
  final bool showBottomLine;

  final EdgeInsetsGeometry padding;
  final double height;

  const StoreTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.showBottomLine = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: StoreDimensions.screenPadding,
    ),
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final StorePalette p = StorePalette(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding,
          child: Container(
            height: height,
            padding: const EdgeInsets.all(StoreDimensions.paddingXS),
            decoration: BoxDecoration(
              color: p.pillBackground,
              borderRadius: BorderRadius.circular(StoreDimensions.radiusPill),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final bool selected = index == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? p.cardBackground : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          StoreDimensions.radiusPill,
                        ),
                        boxShadow: selected ? p.activePillShadow : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: StoreDimensions.paddingM,
                        ),
                        child: Text(
                          tabs[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StoreTextStyles.tab.copyWith(
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? StoreColors.pillActiveText
                                : p.textTertiary,
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
        if (showBottomLine) Container(height: 1, color: p.hairline),
      ],
    );
  }
}

// ============================================================================
// 3. BARRE DE NAVIGATION FLOTTANTE (jumeau de FloatingBottomNavBar)
// ============================================================================
class StoreNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const StoreNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class StoreBottomNav extends StatelessWidget {
  final List<StoreNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Nombre de badges par item (index aligné sur [items], 0 = aucun).
  final List<int> badges;

  /// Affiche le libellé sous l'icône (désactivé par défaut : icônes seules).
  final bool showLabels;

  final double height;
  final EdgeInsetsGeometry margin;

  /// Couleur du fond de la barre (blanc par défaut).
  final Color? background;

  const StoreBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.badges = const <int>[],
    this.showLabels = false,
    this.height = 64,
    this.margin = const EdgeInsets.fromLTRB(
      StoreDimensions.paddingL,
      0,
      StoreDimensions.paddingL,
      StoreDimensions.paddingM,
    ),
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final StorePalette p = StorePalette(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: margin,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: background ?? p.navSurface,
            borderRadius: BorderRadius.circular(StoreDimensions.radiusLarge),
            boxShadow: p.floatingShadow,
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final bool selected = currentIndex == index;
              final StoreNavItem item = items[index];
              final int badge = index < badges.length ? badges[index] : 0;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: selected ? 18 : 12,
                        vertical: showLabels ? 7 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? p.navPill : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          StoreDimensions.radiusPill,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  selected ? item.activeIcon : item.icon,
                                  key: ValueKey<bool>(selected),
                                  size: 23,
                                  color: selected ? p.navActive : p.navInactive,
                                ),
                              ),
                              if (showLabels) ...[
                                const SizedBox(height: 3),
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: StoreTextStyles.tab.copyWith(
                                    fontSize: 10,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? p.navActive
                                        : p.navInactive,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Pastille d'alerte circulaire, en haut à droite.
                          if (badges.isNotEmpty && badge > 0)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: p.badgeRed,
                                  borderRadius: BorderRadius.circular(
                                    StoreDimensions.radiusPill,
                                  ),
                                  border: Border.all(
                                    color: p.navSurface,
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  badge > 99 ? "99+" : "$badge",
                                  style: StoreTextStyles.chip.copyWith(
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

// ============================================================================
// 4. TUILE DE CATÉGORIE + GRILLE (jumeaux de CategoryCard / CategoryGrid)
// ============================================================================
/// Même structure que l'original (aucune hauteur imposée, icône adaptative,
/// libellé ellipsé) — seuls les jetons changent.
class StoreCategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final Color? pastel;
  final Color? iconColor;
  final VoidCallback? onTap;
  final int badgeCount;
  final double? height;
  final int maxLines;

  const StoreCategoryCard({
    super.key,
    required this.label,
    required this.icon,
    this.index = 0,
    this.pastel,
    this.iconColor,
    this.onTap,
    this.badgeCount = 0,
    this.height,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final StorePalette p = StorePalette(context);
    final Color soft = pastel ?? p.pastelAt(index);

    return PressableScale(
      onTap: onTap,
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.cardBackground,
          borderRadius: BorderRadius.circular(StoreDimensions.radiusMedium),
          boxShadow: p.cardShadow,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Hauteur réellement disponible dans la cellule de grille.
            final double available = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : (height ?? 116);

            const double padV = 12;
            const double gap = 8;

            // L'icône occupe ~40 % de la hauteur, bornée 32 → 48 px.
            final double iconSize =
                ((available - padV * 2 - gap) * 0.52).clamp(32.0, 48.0);

            // Lignes de texte possibles avec l'espace restant.
            final double textSpace = available - padV * 2 - gap - iconSize;
            final int lines =
                textSpace >= 30 ? maxLines : (textSpace >= 16 ? 1 : 0);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: padV,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: constraints.maxHeight.isFinite
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: soft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: iconSize * 0.46,
                          color: iconColor ?? _deepTint(soft),
                        ),
                      ),
                      if (lines > 0) ...[
                        const SizedBox(height: gap),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: lines,
                          overflow: TextOverflow.ellipsis,
                          style: StoreTextStyles.chip.copyWith(
                            color: p.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.5,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Pastille de comptage : cercle rouge, en haut à droite.
                if (badgeCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 18),
                      decoration: BoxDecoration(
                        color: p.badgeRed,
                        borderRadius: BorderRadius.circular(
                          StoreDimensions.radiusPill,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badgeCount > 99 ? "99+" : "$badgeCount",
                        style: StoreTextStyles.chip.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Assombrit le pastel pour obtenir une teinte d'icône contrastée.
  static Color _deepTint(Color pastel) {
    final HSLColor hsl = HSLColor.fromColor(pastel);
    return hsl
        .withLightness((hsl.lightness - 0.32).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.10).clamp(0.0, 1.0))
        .toColor();
  }
}

/// Grille 3 colonnes de [StoreCategoryCard] — structure identique à l'original.
class StoreCategoryGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const StoreCategoryGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.childAspectRatio = 0.88,
    this.padding = EdgeInsets.zero,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();

    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }
}

// ============================================================================
// 5. CARTE KPI (jumeau de GradientInfoCard, usage « chiffre clé »)
// ============================================================================
///   • Carte blanche, rayon 16, ombre douce, padding 16
///   • Icône dans une pastille claire, valeur en 26/w700, libellés gris
class StoreKpiCard extends StatelessWidget {
  final IconData? icon;
  final String? label;

  /// Valeur principale (« 128 », « 42 500 F »).
  final String? value;

  /// Précision sous la valeur.
  final String? caption;

  /// Teinte du fond (pastel) — lavande par défaut.
  final Color? tint;

  /// Couleur de l'icône (encre par défaut).
  final Color? iconColor;

  /// Élément de droite (remplace le chevron).
  final Widget? trailing;

  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? footer;

  final double radius;
  final EdgeInsetsGeometry padding;

  const StoreKpiCard({
    super.key,
    this.icon,
    this.label,
    this.value,
    this.caption,
    this.tint,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.footer,
    this.radius = StoreDimensions.radiusMedium,
    this.padding = StoreDimensions.paddingAllM,
  });

  @override
  Widget build(BuildContext context) {
    final StorePalette p = StorePalette(context);

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: p.wash(tint: tint ?? p.pastelAt(0)),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: p.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              LayoutBuilder(
                builder: (context, box) {
                  // Icône compacte si la carte est étroite (petits écrans).
                  final double s =
                      box.maxWidth.isFinite && box.maxWidth < 60 ? 34 : 40;
                  return Container(
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      color: p.cardBackground,
                      borderRadius: BorderRadius.circular(
                        StoreDimensions.radiusSmall,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? p.textPrimary,
                      size: s * 0.5,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StoreTextStyles.label.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  if (label != null && value != null) const SizedBox(height: 2),
                  if (value != null)
                    Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StoreTextStyles.metric.copyWith(
                        color: p.textPrimary,
                        fontSize: 24,
                      ),
                    ),
                  if (caption != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      caption!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StoreTextStyles.caption.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                  if (footer != null) ...[
                    const SizedBox(height: 10),
                    footer!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            if (showChevron)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: p.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
