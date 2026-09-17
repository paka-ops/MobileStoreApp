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
        border: Border.all(color: c.border, width: 1),
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

  /// Surface navy des barres flottantes (bottom nav).
  static BoxDecoration floatingNav(DashColors c) => BoxDecoration(
        color: c.navy,
        borderRadius: BorderRadius.circular(AppRadius.navPill),
        boxShadow: c.floatingShadow,
      );
}

/// ============================================================================
/// APP GRADIENTS — dégradés du design system.
/// ============================================================================
class AppGradients {
  AppGradients._();

  /// Dégradé d'accent TEAL → ÉMERAUDE, diagonal (topLeft → bottomRight).
  /// C'est LE dégradé signature (#0D9488 → #10B981) des cartes d'info.
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

  /// Dégradé caméléon : navy → teal (bandeaux premium, écrans d'accueil)
  static LinearGradient navyToTeal(DashColors c) => LinearGradient(
        colors: [
          c.navy,
          Color.lerp(c.navy, c.primary, 0.55) ?? c.primary,
          c.gradientColors.last,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Voile doux derrière les illustrations
  static LinearGradient heroWash(DashColors c) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          c.primarySoft.withValues(alpha: 0.6),
          c.background,
        ],
      );
}
