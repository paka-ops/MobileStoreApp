import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common/primitives.dart';

/// ============================================================================
/// APP GREETING HEADER — en-tête personnalisé du design system.
///
/// Structure :
///   • Gauche  : greeting 24/Bold + sous-texte (icône localisation + chevron)
///   • Droite  : cloche de notification (cercle gris clair) + avatar circulaire
///   • Padding horizontal 20 px
///
///   AppGreetingHeader(
///     greeting: "Bonjour,",
///     title: widget.store.name,
///     subtitle: "Lomé, Togo",
///     onTapSubtitle: _showStoreSwitcherSheet,
///     notificationCount: lowStockProducts.length,
///     onTapNotifications: () => ...,
///     onTapAvatar: () => ...,
///   )
///
/// ⚠️ 100 % présentation : aucune logique métier, uniquement des callbacks.
/// ============================================================================
class AppGreetingHeader extends StatelessWidget {
  /// Ligne d'accroche ("Bonjour," / "Hello").
  final String greeting;

  /// Nom mis en avant (boutique, utilisateur…).
  final String title;

  /// Sous-texte (localisation, rôle…).
  final String? subtitle;

  /// Icône du sous-texte (localisation par défaut).
  final IconData subtitleIcon;

  /// Affiche le chevron de sélection à droite du sous-texte.
  final bool showSubtitleChevron;

  /// Callback du bloc gauche (greeting + sous-texte).
  final VoidCallback? onTapTitle;
  final VoidCallback? onTapSubtitle;

  /// Cloche de notification.
  final VoidCallback? onTapNotifications;
  final int notificationCount;
  final IconData bellIcon;

  /// Avatar (avatar → priorité enfant > initiales > icône).
  final Widget? avatar;
  final String? avatarInitials;
  final IconData avatarIcon;
  final VoidCallback? onTapAvatar;

  /// Boutons supplémentaires insérés avant la cloche (ex. bascule de thème).
  final List<Widget> extraActions;

  /// Contenu optionnel affiché sous la ligne principale (ex. recherche).
  final Widget? bottom;

  /// Visibilité de la cloche (masquée, ex. libellé vide).
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
    this.extraActions = const <Widget>[],
    this.bottom,
    this.showBell = true,
    this.padding = const EdgeInsets.fromLTRB(
      AppSizes.screenPadding,
      12,
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
              // ------------------------------------------------ Bloc gauche
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapTitle ?? onTapSubtitle,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting — 24 / Bold
                      Text(
                        greeting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.greeting
                            .copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: 3),

                      // Nom / localisation — icône + texte + chevron
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTapSubtitle ?? onTapTitle,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              subtitleIcon,
                              size: 15,
                              color: c.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.subtitle.copyWith(
                                  color: c.textSecondary,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                            if (showSubtitleChevron) ...[
                              const SizedBox(width: 3),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: c.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 1),
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
              ),

              const SizedBox(width: 12),

              // ------------------------------------------------ Bloc droit
              ...extraActions,
              if (extraActions.isNotEmpty) const SizedBox(width: 8),
              if (showBell)
                _CircleActionButton(
                  icon: bellIcon,
                  onTap: onTapNotifications,
                  badgeCount: notificationCount,
                  tooltip: "Notifications",
                ),
              const SizedBox(width: 10),
              _HeaderAvatar(
                onTap: onTapAvatar,
                initials: avatarInitials,
                icon: avatarIcon,
                child: avatar,
              ),
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 16),
            bottom!,
          ],
        ],
      ),
    );
  }
}

/// Cercle gris clair contenant un icône (cloche, actions rapides).
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: c.card,
          shape: BoxShape.circle,
          boxShadow: c.cardShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 21, color: c.textPrimary),
            if (badgeCount > 0)
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                  decoration: BoxDecoration(
                    gradient: c.accentGradient,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: c.card, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? "99+" : "$badgeCount",
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
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

/// Avatar circulaire du header (photo, initiales ou icône).
class _HeaderAvatar extends StatelessWidget {
  final VoidCallback? onTap;
  final String? initials;
  final IconData icon;
  final Widget? child;

  const _HeaderAvatar({
    this.onTap,
    this.initials,
    this.icon = Icons.storefront_rounded,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    Widget content;
    if (child != null) {
      content = child!;
    } else if (initials != null && initials!.trim().isNotEmpty) {
      content = Center(
        child: Text(
          initials!.trim().substring(0, 1).toUpperCase(),
          style: AppTextStyles.cardTitle.copyWith(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      );
    } else {
      content = Icon(icon, size: 20, color: Colors.white);
    }

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: c.accentGradient,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: child == null
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: c.accentGradient,
                  ),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}
