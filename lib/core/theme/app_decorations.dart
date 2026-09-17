import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';

/// ============================================================================
/// APP DECORATIONS — décorations réutilisables (cartes, sheets, champs).
/// ============================================================================
class AppDecorations {
  AppDecorations._();

  /// Carte premium : surface + bordure fine + ombre douce.
  static BoxDecoration card(DashColors c, {double radius = AppRadius.xl}) =>
      BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: c.border, width: 1),
        boxShadow: c.cardShadow,
      );

  /// Carte « outline » : bordure visible, pas d'ombre.
  static BoxDecoration cardOutlined(DashColors c,
      {double radius = AppRadius.xl, Color? borderColor}) =>
      BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? c.border, width: 1.2),
      );

  /// Carte « filled » : fond légèrement différent, pas de bordure.
  static BoxDecoration cardFilled(DashColors c,
      {double radius = AppRadius.xl, Color? fill}) =>
      BoxDecoration(
        color: fill ?? c.cardElevated,
        borderRadius: BorderRadius.circular(radius),
      );

  /// Pastille douce (icône dans un carré arrondi coloré).
  static BoxDecoration softIconBox(DashColors c,
      {required Color color,
      required Color softColor,
      double radius = AppRadius.md}) =>
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
}

/// ============================================================================
/// APP GRADIENTS — dégradés premium très sobres.
/// ============================================================================
class AppGradients {
  AppGradients._();

  /// Dégradé primaire (cartes héro, boutons spéciaux)
  static LinearGradient primary(DashColors c) => LinearGradient(
        colors: [
          c.primary.withValues(alpha: 0.92),
          c.primary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Dégradé d'accent camel
  static LinearGradient accent(DashColors c) => LinearGradient(
        colors: [
          c.accent.withValues(alpha: 0.92),
          c.accent,
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
