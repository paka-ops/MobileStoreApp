import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// ============================================================================
/// APP THEME — ThemeData complet (clair + sombre).
///
/// Un seul point d'entrée : [buildAppTheme]. Toutes les composantes Material
/// (boutons, champs, dialogs, snackbars…) héritent du design system.
/// ============================================================================

/// Transition de page premium : fondu + léger glissement vertical.
class PremiumPageTransitionsBuilder extends PageTransitionsBuilder {
  const PremiumPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final CurvedAnimation curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

ThemeData buildAppTheme(bool dark) {
  final bool isDark = dark;

  // ---------------------------------------------------------------------------
  // COULEURS DE BASE
  // ---------------------------------------------------------------------------
  final Color primary =
      isDark ? AppColors.darkPrimary : AppColors.primary;
  final Color onPrimary =
      isDark ? AppColors.darkOnPrimary : AppColors.onPrimary;
  final Color accent = isDark ? AppColors.darkAccent : AppColors.accent;
  final Color danger = isDark ? AppColors.darkDanger : AppColors.danger;
  final Color success = isDark ? AppColors.darkSuccess : AppColors.success;
  final Color background =
      isDark ? AppColors.darkBackground : AppColors.background;
  final Color card = isDark ? AppColors.darkCard : AppColors.card;
  final Color border = isDark ? AppColors.darkBorder : AppColors.border;
  final Color textPrimary =
      isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  final Color textSecondary =
      isDark ? AppColors.darkTextSecondary : AppColors.textGrey;

  // Couleurs signature du design system
  final Color ink = isDark ? AppColors.darkInk : AppColors.ink;
  final Color onInk = isDark ? AppColors.darkOnInk : AppColors.onInk;
  final Color fill = isDark ? AppColors.darkFill : AppColors.fill;
  final Color rating = isDark ? AppColors.darkRating : AppColors.rating;
  final Color ratingSoft =
      isDark ? AppColors.darkRatingSoft : AppColors.ratingSoft;
  final Color hairline = isDark ? AppColors.darkHairline : AppColors.hairline;

  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: isDark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: isDark
        ? AppColors.darkPrimarySoft
        : AppColors.primarySoft,
    onPrimaryContainer: primary,
    secondary: accent,
    onSecondary: Colors.white,
    secondaryContainer: isDark ? AppColors.darkAccentSoft : AppColors.accentSoft,
    onSecondaryContainer: accent,
    error: danger,
    onError: Colors.white,
    errorContainer: isDark ? AppColors.darkDangerSoft : AppColors.dangerSoft,
    onErrorContainer: danger,
    surface: card,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    tertiary: rating,
    onTertiary: AppColors.ink,
    tertiaryContainer: ratingSoft,
    onTertiaryContainer: textPrimary,
    surfaceContainerLowest: card,
    surfaceContainerLow: card,
    surfaceContainer: fill,
    surfaceContainerHigh: isDark
        ? AppColors.darkCardElevated
        : AppColors.fill,
    surfaceContainerHighest: isDark
        ? AppColors.darkCardElevated
        : AppColors.fill,
    outline: border,
    outlineVariant: hairline,
  );

  // ---------------------------------------------------------------------------
  // TEXTE GLOBAL
  // ---------------------------------------------------------------------------
  final TextTheme textTheme = TextTheme(
    displayLarge: AppTextStyles.display,
    displayMedium: AppTextStyles.h1,
    headlineMedium: AppTextStyles.h2,
    headlineSmall: AppTextStyles.h3,
    titleLarge: AppTextStyles.h3.copyWith(fontSize: 18),
    titleMedium: AppTextStyles.cardTitle,
    titleSmall: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.body,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.button,
    labelMedium: AppTextStyles.caption,
    labelSmall: AppTextStyles.caption.copyWith(fontSize: 10),
  ).apply(
    bodyColor: textPrimary,
    displayColor: textPrimary,
  );

  // ---------------------------------------------------------------------------
  // CHAMPS DE FORMULAIRE
  // ---------------------------------------------------------------------------
  final InputDecorationTheme inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: TextStyle(color: textSecondary, fontSize: 14),
    labelStyle: TextStyle(color: textSecondary, fontSize: 14),
    helperStyle: AppTextStyles.caption.copyWith(color: textSecondary),
    errorStyle: AppTextStyles.caption.copyWith(
      color: danger,
      fontWeight: FontWeight.w600,
    ),
    prefixIconColor: textSecondary,
    suffixIconColor: textSecondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: Colors.transparent),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: Colors.transparent),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: primary, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: danger, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: danger, width: 1.8),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: border),
    ),
  );

  // ---------------------------------------------------------------------------
  // BOUTONS
  // ---------------------------------------------------------------------------
  final OutlinedButtonThemeData outlinedBtn = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: textPrimary,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      side: BorderSide(color: border, width: 1.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      textStyle: AppTextStyles.button.copyWith(color: textPrimary),
    ),
  );

  final TextButtonThemeData textBtn = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: AppTextStyles.button.copyWith(color: primary),
    ),
  );

  // ---------------------------------------------------------------------------
  // THÈME FINAL
  // ---------------------------------------------------------------------------
  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    fontFamily: AppTextStyles.fontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    cardColor: card,
    dividerColor: border,
    splashFactory: InkSparkle.splashFactory,
    highlightColor: ink.withValues(alpha: 0.03),
    splashColor: ink.withValues(alpha: 0.05),

    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h3.copyWith(
        fontSize: 17,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary, size: 22),
    ),

    inputDecorationTheme: inputTheme,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: onInk,
        disabledBackgroundColor:
            isDark ? AppColors.darkCardElevated : const Color(0xFFD6DAE3),
        disabledForegroundColor: isDark
            ? AppColors.darkTextSecondary
            : const Color(0xFF9AA1AD),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTextStyles.button.copyWith(color: onInk),
      ),
    ),
    outlinedButtonTheme: outlinedBtn,
    textButtonTheme: textBtn,

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: onInk,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTextStyles.button.copyWith(color: onInk),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: textSecondary,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ink,
      foregroundColor: onInk,
      elevation: 6,
      highlightElevation: 8,
      shape: const CircleBorder(),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: border),
      ),
      elevation: isDark ? 14 : 12,
      titleTextStyle: AppTextStyles.h3.copyWith(
        fontSize: 17.5,
        color: textPrimary,
      ),
      contentTextStyle: AppTextStyles.body.copyWith(color: textSecondary),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: card,
      modalBarrierColor: Colors.black.withValues(alpha: isDark ? 0.6 : 0.45),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.rSheet),
      showDragHandle: false,
      elevation: isDark ? 12 : 8,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: card,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: isDark
          ? AppColors.darkPrimarySoft
          : AppColors.primarySoft,
      elevation: 0,
      height: 68,
    ),

    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      iconColor: textSecondary,
      titleTextStyle:
          AppTextStyles.cardTitle.copyWith(color: textPrimary),
      subtitleTextStyle:
          AppTextStyles.bodySmall.copyWith(color: textSecondary),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: fill,
      labelStyle: AppTextStyles.chip.copyWith(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: Colors.transparent),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ink,
      contentTextStyle: AppTextStyles.body.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      elevation: 4,
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: border,
      circularTrackColor: border.withValues(alpha: 0.4),
    ),

    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: AppTextStyles.body.copyWith(color: textPrimary),
    ),

    iconTheme: IconThemeData(color: textSecondary, size: 22),

    dividerTheme: DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return onPrimary;
        return isDark ? AppColors.darkTextSecondary : Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return isDark ? AppColors.darkBorder : const Color(0xFFD8DCE2);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return Colors.transparent;
      }),
      side: BorderSide(color: border, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),

    datePickerTheme: DatePickerThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      headerForegroundColor: textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: PremiumPageTransitionsBuilder(),
        TargetPlatform.iOS: PremiumPageTransitionsBuilder(),
        TargetPlatform.macOS: PremiumPageTransitionsBuilder(),
        TargetPlatform.linux: PremiumPageTransitionsBuilder(),
        TargetPlatform.windows: PremiumPageTransitionsBuilder(),
      },
    ),
  );
}
