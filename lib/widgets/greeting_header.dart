import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// APP GREETING HEADER — en-tête personnalisé du design system.
///
/// Hiérarchie « calm premium » (inspirée des apps haut de gamme) :
///   1. petite ligne grise  : « Bonjour, Amanda 👋 »
///   2. titre encre net     : nom de la boutique + chevron
///   3. localisation grise  : épingle + ville
///   À droite : cloche dans un cercle gris clair (avec point corail discret)
///   puis l'avatar (carré arrondi, comme les apps premium).
///
///   AppGreetingHeader(
///     greeting: "Bonjour, Amanda 👋",
///     title: store.name,
///     subtitle: store.location,
///     onTapTitle: () => _showStoreSwitcherSheet(context, colors),
///     notificationCount: lowStockProducts.length,
///     onTapNotifications: () => ...,
///   )
///
/// ⚠️ 100 % présentation : uniquement des callbacks, aucune logique métier.
/// ============================================================================
class AppGreetingHeader extends StatelessWidget {
  /// Petite ligne grise d'accroche ("Bonjour," / "Hello").
  final String greeting;

  /// Nom mis en avant (boutique, utilisateur…) — grande taille, encre.
  final String title;

  /// Sous-texte (localisation, rôle…).
  final String? subtitle;

  /// Icône du sous-texte (localisation par défaut).
  final IconData subtitleIcon;

  /// Affiche le chevron de sélection à droite du titre.
  final bool showSubtitleChevron;

  /// Callbacks du bloc gauche.
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

  /// Forme de l'avatar : carré arrondi (défaut premium) ou cercle.
  final bool avatarRounded;

  /// Couleur de fond de l'avatar (sinon teinte de marque très pâle).
  final Color? avatarBackground;

  /// Boutons supplémentaires insérés avant la cloche (ex. bascule de thème).
  final List<Widget> extraActions;

  /// Contenu optionnel affiché sous la ligne principale (ex. recherche).
  final Widget? bottom;

  /// Visibilité de la cloche.
  final bool showBell;

  final EdgeInsetsGeometry padding;

  const AppGreetingHeader({
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
      AppSizes.screenPadding,
      14,
      AppSizes.screenPadding,
      8,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

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
                        style: AppTextStyles.eyebrow
                            .copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(height: 2),

                      // 2 — titre encre + chevron (sélecteur de boutique)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.name
                                  .copyWith(color: c.textPrimary),
                            ),
                          ),
                          if (showSubtitleChevron)
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: c.textSecondary,
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
                                color: c.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.label
                                      .copyWith(color: c.textSecondary),
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
                _CircleActionButton(
                  icon: bellIcon,
                  onTap: onTapNotifications,
                  badgeCount: notificationCount,
                  tooltip: "Notifications",
                ),
                const SizedBox(width: 10),
              ],
              _HeaderAvatar(
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

/// Cercle gris clair contenant une icône (cloche, actions rapides).
class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;
  final String? tooltip;

  const _CircleActionButton({
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    Widget button = PressableScale(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: c.fill,
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: c.textPrimary),
            // Simple point corail : l'accent ne prend jamais de place.
            if (badgeCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: c.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.fill, width: 1.5),
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
class _HeaderAvatar extends StatelessWidget {
  final VoidCallback? onTap;
  final String? initials;
  final IconData icon;
  final Widget? child;
  final bool rounded;
  final Color? background;

  const _HeaderAvatar({
    this.onTap,
    this.initials,
    this.icon = Icons.storefront_rounded,
    this.child,
    this.rounded = true,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final BorderRadius radius =
        BorderRadius.circular(rounded ? 15 : 999);
    final bool hasInitials = initials != null && initials!.trim().isNotEmpty;

    Widget content;
    if (child != null) {
      content = child!;
    } else if (hasInitials) {
      content = Center(
        child: Text(
          initials!.trim().substring(0, 1).toUpperCase(),
          style: AppTextStyles.cardTitle.copyWith(
            color: c.primary,
            fontSize: 16,
          ),
        ),
      );
    } else {
      content = Icon(icon, size: 20, color: c.primary);
    }

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: background ?? c.primarySoft,
          borderRadius: radius,
        ),
        child: content,
      ),
    );
  }
}
