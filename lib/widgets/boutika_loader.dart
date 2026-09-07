import 'package:flutter/material.dart';

import 'package:mobile_store_app/utils/app_colors.dart' show appDarkMode;

// ---------------------------------------------------------------------------
// BouTikaLoader — chargeur standard de toute l'application
//
// Le mot « BouTika » est affiché et chaque lettre est parcourue par une
// lumière : un reflet doux glisse sur le mot, comme un rayon de lumière
// qui passe sur une vitre, mais avec une réflexion volontairement très
// discrète (les lettres restent mates, seule une fine lueur les traverse).
//
// Deux variantes :
//  - BouTikaLoader()          → chargement de page / d'écran (centré, 42 px),
//                               teintes de verre adaptées au clair / sombre
//  - BouTikaLoader.compact()  → chargement à l'intérieur d'un bouton coloré
//                               (16 px, verre clair sur fond de couleur)
//
// Toute nouvelle zone de chargement de l'application doit utiliser ce widget.
// ---------------------------------------------------------------------------
class BouTikaLoader extends StatefulWidget {
  /// Taille du mot (42 par défaut ; 16 pour la variante compacte).
  final double fontSize;

  /// Espacement des lettres.
  final double letterSpacing;

  /// Couleur des lettres « au repos » (verre dépoli). Si null, elle est
  /// choisie automatiquement selon le mode clair / sombre.
  final Color? baseColor;

  /// Couleur de la traînée lumineuse (halo doux). Si null : automatique.
  final Color? glowColor;

  /// Couleur du cœur du reflet (la partie la plus brillante). Si null :
  /// automatique.
  final Color? coreColor;

  /// Petit texte optionnel affiché sous le mot (ex. « Chargement… »).
  final String? message;

  /// Style du texte [message].
  final TextStyle? messageStyle;

  const BouTikaLoader({
    super.key,
    this.fontSize = 42,
    this.letterSpacing = 3,
    this.baseColor,
    this.glowColor,
    this.coreColor,
    this.message,
    this.messageStyle,
  });

  /// Variante compacte pour l'intérieur des boutons sur fond coloré :
  /// lettres en verre clair balayées par la même lumière discrète.
  const BouTikaLoader.compact({
    super.key,
    this.fontSize = 16,
    this.letterSpacing = 1.5,
    this.baseColor = const Color(0x73FFFFFF),
    this.glowColor = const Color(0xD9FFFFFF),
    this.coreColor = Colors.white,
    this.message,
    this.messageStyle,
  });

  @override
  State<BouTikaLoader> createState() => _BouTikaLoaderState();
}

class _BouTikaLoaderState extends State<BouTikaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  double _stopAt(double v) => v.clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, isDark, _) {
        // Lettres « verre dépoli » (mates, peu visibles) + lueur chaude
        // discrète — sauf si des couleurs personnalisées sont fournies
        // (variante compacte sur bouton coloré, par exemple).
        final base = widget.baseColor ??
            (isDark ? const Color(0xFF44454C) : const Color(0xFFB6BAC3));
        final glow = widget.glowColor ??
            (isDark ? const Color(0xFF6E5A43) : const Color(0xFFC99C73));
        final core = widget.coreColor ??
            (isDark ? const Color(0xFFCBA97E) : const Color(0xFFB0713C));

        final word = AnimatedBuilder(
          animation: _sweepController,
          builder: (context, _) {
            // Position du reflet : il traverse le mot de gauche à droite,
            // avec une courte pause avant chaque nouveau passage.
            final t = -0.35 + _sweepController.value * 1.7;

            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                return LinearGradient(
                  // Léger biais diagonal : la lumière « glisse » sur la vitre.
                  begin: const Alignment(-1.0, -0.25),
                  end: const Alignment(1.0, 0.25),
                  colors: [base, glow, core, glow, base],
                  stops: [
                    0.0,
                    _stopAt(t - 0.18),
                    _stopAt(t - 0.03),
                    _stopAt(t + 0.09),
                    1.0,
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'BouTika',
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: widget.letterSpacing,
                  color: Colors.white,
                ),
              ),
            );
          },
        );

        if (widget.message == null) return word;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            word,
            const SizedBox(height: 14),
            Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: widget.messageStyle ??
                  TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF8A8D95)
                        : const Color(0xFF85888F),
                  ),
            ),
          ],
        );
      },
    );
  }
}
