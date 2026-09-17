import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// ============================================================================
/// SEARCH BAR WIDGET — barre de recherche du design system.
///
///   • Container arrondi BorderRadius.circular(16)
///   • Fond gris clair (#F3F4F6), AUCUNE bordure
///   • Icône recherche + hint gris
///   • Hauteur ~52 px
///
///   SearchBarWidget(
///     controller: _searchCtrl,
///     hint: "Rechercher un produit",
///     onChanged: _filterProducts,      // logique existante conservée
///   )
///
/// Le widget ne fait que relayer les callbacks : il ne filtre rien lui-même.
/// ============================================================================
class SearchBarWidget extends StatefulWidget {
  /// Contrôleur externe (optionnel — un contrôleur interne est créé sinon).
  final TextEditingController? controller;

  /// Texte d'invite.
  final String hint;

  /// Callbacks relayés tels quels.
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onCleared;

  /// Icône de gauche (recherche par défaut).
  final IconData icon;

  /// Mode lecture seule (ouvre un écran de recherche dédié).
  final bool readOnly;
  final bool autofocus;
  final bool enabled;

  /// Action optionnelle à droite (ex. filtres).
  final Widget? trailing;
  final VoidCallback? onTapTrailing;

  final double height;
  final EdgeInsetsGeometry margin;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.hint = "Rechercher…",
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onCleared,
    this.icon = Icons.search_rounded,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.trailing,
    this.onTapTrailing,
    this.height = AppSizes.searchBarHeight,
    this.margin = EdgeInsets.zero,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onTextChanged);
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = TextEditingController();
        _ownsController = true;
      }
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  /// Rafraîchit uniquement l'affichage du bouton d'effacement.
  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call("");
    widget.onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final bool hasText = _controller.text.isNotEmpty;

    return Padding(
      padding: widget.margin,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(AppRadius.search),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 20, color: c.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: widget.readOnly
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            color: c.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : TextField(
                        controller: _controller,
                        enabled: widget.enabled,
                        autofocus: widget.autofocus,
                        readOnly: widget.readOnly,
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                        textInputAction: TextInputAction.search,
                        cursorColor: c.primary,
                        style: AppTextStyles.body.copyWith(
                          color: c.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: widget.hint,
                          hintStyle: AppTextStyles.body.copyWith(
                            color: c.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
              // Bouton d'effacement instantané
              if (hasText && widget.enabled)
                GestureDetector(
                  onTap: _handleClear,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: c.textSecondary,
                    ),
                  ),
                ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: widget.onTapTrailing,
                  behavior: HitTestBehavior.opaque,
                  child: widget.trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
