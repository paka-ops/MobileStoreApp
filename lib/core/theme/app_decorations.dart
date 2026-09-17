import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';

/// ============================================================================
/// APP DECORATIONS — décorations réutilisables (cartes, sheets, champs).
///
/// Le design system impose : cartes blanches, rayons 16–24 px, ombre douce
/// « soft elevation » (blur 20 / y 8 / noir 5 %) et AUCUNE bordure visible
/// sur les cartes de contenu.
/// ============================================================================
class AppDecorations {
  AppDecorations._();

  /// Carte du design system : surface + ombre douce, sans bordure visible.
  static BoxDecoration card(DashColors c, {double radius = AppRadius.xl}) =>
      BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: c.cardShadow,
      );

  /// Carte « flat » du design system : surface + ombre, zéro bordure.
  /// À privilégier pour les nouvelles cartes (CategoryCard, AppointmentCard…).
  static BoxDecoration softCard(DashColors c, {double radius = AppRadius.xl}) =>
      BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: c.cardShadow,
      );

  /// Carte flottante (au-dessus du contenu : rating card, price tag…).
  static BoxDecoration floatingCard(DashColors c,
          {double radius = AppRadius.lg, Color? color}) =>
      BoxDecoration(
        color: color ?? c.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: c.floatingShadow,
      );

  /// Carte « outline » : bordure visible, pas d'ombre.
  static BoxDecoration cardOutlined(DashColors c,
      {double radius = AppRadius.xl, Color? borderColor}) =>
      BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? c.border, width: 1.2),
      );

  /// Carte « filled » : fond gris clair, pas d'ombre, pas de bordure.
  /// (champs de recherche, zones neutres)
  static BoxDecoration cardFilled(DashColors c,
          {double radius = AppRadius.lg, Color? fill}) =>
      BoxDecoration(
        color: fill ?? c.fill,
        borderRadius: BorderRadius.circular(radius),
      );

  /// Pastille douce CARBÉE (icône dans un carré arrondi coloré).
  static BoxDecoration softIconBox(DashColors c,
      {required Color color,
      required Color softColor,
      double radius = AppRadius.md}) =>
      BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(radius),
      );

  /// Pastille douce CIRCULAIRE — fonds pastels des icônes de catégories.
  static BoxDecoration softIconCircle({required Color softColor}) =>
      BoxDecoration(color: softColor, shape: BoxShape.circle);

  /// Tuile pastel d'une grille de catégories (rayon 18, fond pastel).
  static BoxDecoration pastelTile({required Color softColor, double radius = 18}) =>
      BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(radius),
      );

  /// Sheet / modal arrondi en haut.
  static BoxDecoration sheet(DashColors c) => BoxDecoration(
        color: c.card,
        borderRadius: AppRadius.rSheet,
      );

  /// Badge pilule.
  static BoxDecoration pill(DashColors c, {required Color bg}) => BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      );

  /// Surface des barres flottantes (bottom nav) — claire et discrète.
  static BoxDecoration floatingNav(DashColors c) => BoxDecoration(
        color: c.navSurface,
        borderRadius: BorderRadius.circular(AppRadius.navPill),
        boxShadow: c.floatingShadow,
      );

  /// Carte « wash » : dégradé très pâle (teinte → blanc), texte encre.
  /// C'est la carte d'information premium : la couleur n'est qu'une trace.
  static BoxDecoration washCard(DashColors c, {Color? tint, double radius = AppRadius.xl}) =>
      BoxDecoration(
        gradient: c.wash(tint: tint),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: c.cardShadow,
      );

  /// Carte encre (surface forte, texte blanc) — usage rare et volontaire.
  static BoxDecoration inkCard(DashColors c, {double radius = AppRadius.xl}) =>
      BoxDecoration(
        gradient: c.inkWash,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: c.floatingShadow,
      );
}

/// ============================================================================
/// APP GRADIENTS — dégradés du design system.
/// ============================================================================
class AppGradients {
  AppGradients._();

  /// Dégradé de marque (teal profond → teal), diagonal.
  /// ⚠️ Réservé au logo et aux héro : jamais une grande surface saturée.
  static LinearGradient accent(DashColors c) => c.accentGradient;

  /// Alias explicite : dégradé teal du design system.
  static LinearGradient teal(DashColors c) => c.accentGradient;

  /// Dégradé primaire (cartes héro, boutons spéciaux)
  static LinearGradient primary(DashColors c) => LinearGradient(
        colors: [
          c.primary.withValues(alpha: 0.92),
          c.primary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Dégradé encre neutre (bandeaux premium, écrans d'accueil).
  static LinearGradient navyToTeal(DashColors c) => c.inkWash;

  /// Wash très pâle d'une teinte (cartes d'info, tuiles teintées).
  static LinearGradient wash(DashColors c, {Color? tint}) => c.wash(tint: tint);

  /// Voile d'écran : wash très pâle en haut → fond neutre (effet premium).
  static LinearGradient heroWash(DashColors c) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          c.backgroundWash,
          c.background,
        ],
        stops: const [0.0, 0.45],
      );
}
