import 'package:flutter/material.dart';

/// État du thème partagé par toute l'application.
final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(false);

// =============================================================================
// DESIGN TOKENS — Spacing / Radius / Durations / Shadows
// =============================================================================
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double xl3 = 32;
  static const double xl4 = 40;
  static const double xl5 = 48;
}

class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double full = 999;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 250);
}

class AppShadows {
  // Light — extrêmement subtil, uniquement pour cartes flottantes
  static List<BoxShadow> get cardLight => [
        BoxShadow(
          color: const Color(0x0F0F172A), // 6% slate 900
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: const Color(0x080F172A), // 3%
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get subtleLight => [
        BoxShadow(
          color: const Color(0x0A0F172A),
          blurRadius: 16,
          offset: const Offset(0, -2),
        ),
      ];

  static List<BoxShadow> get cardDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get subtleDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];

  static List<BoxShadow> get none => [];
}

// =============================================================================
// THEME EXTENSION — tokens sémantiques premium
// =============================================================================
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color card;
  final Color cardElevated;
  final Color cardHover;

  final Color foreground;
  final Color mutedForeground;
  final Color muted;

  final Color primary;
  final Color primaryForeground;
  final Color primarySoft;

  final Color secondary;
  final Color secondaryForeground;

  final Color accent;
  final Color accentSoft;

  final Color border;
  final Color outline;

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;

  final Color disabled;
  final Color overlay;

  const AppThemeExtension({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.card,
    required this.cardElevated,
    required this.cardHover,
    required this.foreground,
    required this.mutedForeground,
    required this.muted,
    required this.primary,
    required this.primaryForeground,
    required this.primarySoft,
    required this.secondary,
    required this.secondaryForeground,
    required this.accent,
    required this.accentSoft,
    required this.border,
    required this.outline,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.disabled,
    required this.overlay,
  });

  // Light tokens — sobriété absolue, jamais de saturation
  static const light = AppThemeExtension(
    background: Color(0xFFFAFAF9), // Stone 50 warm, jamais blanc pur
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF8FAFC), // Slate 50
    card: Color(0xFFFFFFFF),
    cardElevated: Color(0xFFF8FAFC),
    cardHover: Color(0xFFF1F5F9),
    foreground: Color(0xFF0F172A), // Slate 900
    mutedForeground: Color(0xFF64748B), // Slate 500 — lisible mais doux
    muted: Color(0xFFF1F5F9), // Slate 100
    primary: Color(0xFF334155), // Slate 700 — sobre, pro, apaisant
    primaryForeground: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFF1F5F9),
    secondary: Color(0xFFF8FAFC),
    secondaryForeground: Color(0xFF334155),
    accent: Color(0xFFE7E5E4), // Stone 200 — ultra discret
    accentSoft: Color(0xFFF5F5F4),
    border: Color(0xFFE7E5E4), // Stone 200
    outline: Color(0xFFE2E8F0), // Slate 200
    success: Color(0xFF5A8A7A), // Desaturated sage
    successSoft: Color(0xFFEEF5F2),
    warning: Color(0xFFA68B5E), // Desaturated amber
    warningSoft: Color(0xFFFBF6EC),
    danger: Color(0xFF9F6B6B), // Desaturated clay
    dangerSoft: Color(0xFFFDF2F2),
    info: Color(0xFF6B7F9A), // Desaturated blue-gray
    infoSoft: Color(0xFFEEF2F7),
    disabled: Color(0xFF94A3B8),
    overlay: Color(0x1A0F172A),
  );

  static const dark = AppThemeExtension(
    background: Color(0xFF0F1419), // Jamais noir pur, bleu-nuit très sombre
    surface: Color(0xFF151B23),
    surfaceMuted: Color(0xFF1A2332),
    card: Color(0xFF151B23), // Légèrement au-dessus du background
    cardElevated: Color(0xFF1C2532),
    cardHover: Color(0xFF1E2A3A),
    foreground: Color(0xFFE5E7EB), // Slate 200
    mutedForeground: Color(0xFF94A3B8), // Slate 400
    muted: Color(0xFF1E293B),
    primary: Color(0xFF94A8C0), // Bleu-gris clair désaturé, jamais éblouissant
    primaryForeground: Color(0xFF0F1419),
    primarySoft: Color(0xFF1E2E42),
    secondary: Color(0xFF1E293B),
    secondaryForeground: Color(0xFFE5E7EB),
    accent: Color(0xFF2A3441),
    accentSoft: Color(0xFF1E293B),
    border: Color(0xFF222E3E), // #1F2937 / #263041 -> 222E3E
    outline: Color(0xFF2A3441),
    success: Color(0xFF7AA89A),
    successSoft: Color(0xFF13211D),
    warning: Color(0xFFC2A87A),
    warningSoft: Color(0xFF221E12),
    danger: Color(0xFFC48A8A),
    dangerSoft: Color(0xFF261616),
    info: Color(0xFF8AA0BC),
    infoSoft: Color(0xFF161E2A),
    disabled: Color(0xFF475569),
    overlay: Color(0x66000000),
  );

  @override
  AppThemeExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? card,
    Color? cardElevated,
    Color? cardHover,
    Color? foreground,
    Color? mutedForeground,
    Color? muted,
    Color? primary,
    Color? primaryForeground,
    Color? primarySoft,
    Color? secondary,
    Color? secondaryForeground,
    Color? accent,
    Color? accentSoft,
    Color? border,
    Color? outline,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerSoft,
    Color? info,
    Color? infoSoft,
    Color? disabled,
    Color? overlay,
  }) {
    return AppThemeExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      card: card ?? this.card,
      cardElevated: cardElevated ?? this.cardElevated,
      cardHover: cardHover ?? this.cardHover,
      foreground: foreground ?? this.foreground,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      muted: muted ?? this.muted,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      primarySoft: primarySoft ?? this.primarySoft,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      border: border ?? this.border,
      outline: outline ?? this.outline,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      disabled: disabled ?? this.disabled,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardElevated: Color.lerp(cardElevated, other.cardElevated, t)!,
      cardHover: Color.lerp(cardHover, other.cardHover, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryForeground: Color.lerp(primaryForeground, other.primaryForeground, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryForeground: Color.lerp(secondaryForeground, other.secondaryForeground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      border: Color.lerp(border, other.border, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}

// =============================================================================
// THEME BUILDER
// =============================================================================
ThemeData buildAppTheme(bool dark) {
  final ext = dark ? AppThemeExtension.dark : AppThemeExtension.light;

  final colorScheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: ext.primary,
    onPrimary: ext.primaryForeground,
    primaryContainer: ext.primarySoft,
    onPrimaryContainer: ext.foreground,
    secondary: ext.secondary,
    onSecondary: ext.secondaryForeground,
    secondaryContainer: ext.muted,
    onSecondaryContainer: ext.foreground,
    tertiary: ext.info,
    onTertiary: ext.primaryForeground,
    error: ext.danger,
    onError: Colors.white,
    errorContainer: ext.dangerSoft,
    onErrorContainer: ext.danger,
    background: ext.background,
    onBackground: ext.foreground,
    surface: ext.card,
    onSurface: ext.foreground,
    surfaceVariant: ext.surfaceMuted,
    onSurfaceVariant: ext.mutedForeground,
    outline: ext.border,
    outlineVariant: ext.outline,
    scrim: ext.overlay,
    shadow: Colors.black,
    inverseSurface: dark ? AppThemeExtension.light.foreground : AppThemeExtension.dark.foreground,
    onInverseSurface: dark ? AppThemeExtension.light.background : AppThemeExtension.dark.background,
    inversePrimary: dark ? AppThemeExtension.light.primary : AppThemeExtension.dark.primary,
  );

  // Typographie — Inter pour lecture prolongée, hiérarchie claire
  const baseFont = 'Inter';
  final textTheme = (dark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
        fontFamily: baseFont,
        bodyColor: ext.foreground,
        displayColor: ext.foreground,
      ).copyWith(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.5, color: ext.foreground),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.4, color: ext.foreground),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.25, color: ext.foreground),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, color: ext.foreground),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: ext.foreground),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, color: ext.foreground),
        titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.35, letterSpacing: 0.1, color: ext.foreground),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: ext.foreground),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: ext.foreground),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.45, color: ext.mutedForeground),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: ext.foreground),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3, letterSpacing: 0.2, color: ext.mutedForeground),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.6, color: ext.mutedForeground),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: ext.background,
    canvasColor: ext.background,
    cardColor: ext.card,
    dividerColor: ext.border,
    fontFamily: baseFont,
    textTheme: textTheme,
    extensions: [ext],
    appBarTheme: AppBarTheme(
      backgroundColor: ext.background,
      foregroundColor: ext.foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ext.foreground, fontFamily: baseFont),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ext.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: ext.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: ext.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: ext.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: ext.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: ext.danger, width: 1.2),
      ),
      labelStyle: TextStyle(color: ext.mutedForeground, fontSize: 13.5, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: ext.mutedForeground.withOpacity(0.7), fontSize: 13.5),
      prefixIconColor: ext.mutedForeground,
      suffixIconColor: ext.mutedForeground,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ext.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      elevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ext.card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl2))),
      showDragHandle: false,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ext.card,
      selectedItemColor: ext.primary,
      unselectedItemColor: ext.mutedForeground,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ext.primary,
      foregroundColor: ext.primaryForeground,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ext.primary,
        foregroundColor: ext.primaryForeground,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.1),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ext.mutedForeground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ext.foreground,
        side: BorderSide(color: ext.border, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      iconColor: ext.mutedForeground,
      textColor: ext.foreground,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ext.foreground,
      contentTextStyle: TextStyle(color: ext.background, fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ext.muted,
      labelStyle: TextStyle(color: ext.foreground, fontSize: 12, fontWeight: FontWeight.w500),
      side: BorderSide(color: ext.border, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    iconTheme: IconThemeData(color: ext.mutedForeground, size: 20),
    dividerTheme: DividerThemeData(color: ext.border, thickness: 1, space: 1),
  );
}

// =============================================================================
// LEGACY PALETTE — conservée pour compatibilité, valeurs premium mises à jour
// =============================================================================
class AppColors {
  // Light — sobre premium
  static const primary = Color(0xFF334155);
  static const primarySoft = Color(0xFFF1F5F9);

  static const accent = Color(0xFF64748B);
  static const accentSoft = Color(0xFFF8FAFC);

  static const danger = Color(0xFF9F6B6B);
  static const dangerSoft = Color(0xFFFDF2F2);

  static const success = Color(0xFF5A8A7A);
  static const successSoft = Color(0xFFEEF5F2);

  static const info = Color(0xFF6B7F9A);
  static const infoSoft = Color(0xFFEEF2F7);

  static const warning = Color(0xFFA68B5E);
  static const warningSoft = Color(0xFFFBF6EC);

  static const background = Color(0xFFFAFAF9);
  static const card = Colors.white;
  static const border = Color(0xFFE7E5E4);
  static const textDark = Color(0xFF0F172A);
  static const textGrey = Color(0xFF64748B);

  // Dark — jamais noir pur, jamais éblouissant
  static const darkPrimary = Color(0xFF94A8C0);
  static const darkPrimarySoft = Color(0xFF1E2E42);

  static const darkAccent = Color(0xFF94A3B8);
  static const darkAccentSoft = Color(0xFF1E293B);

  static const darkDanger = Color(0xFFC48A8A);
  static const darkDangerSoft = Color(0xFF261616);

  static const darkSuccess = Color(0xFF7AA89A);
  static const darkSuccessSoft = Color(0xFF13211D);

  static const darkInfo = Color(0xFF8AA0BC);
  static const darkInfoSoft = Color(0xFF161E2A);

  static const darkWarning = Color(0xFFC2A87A);
  static const darkWarningSoft = Color(0xFF221E12);

  static const darkBackground = Color(0xFF0F1419);
  static const darkCard = Color(0xFF151B23);
  static const darkCardElevated = Color(0xFF1C2532);
  static const darkBorder = Color(0xFF222E3E);
  static const darkTextPrimary = Color(0xFFE5E7EB);
  static const darkTextSecondary = Color(0xFF94A3B8);
}

// =============================================================================
// HELPER — résout la couleur selon le thème courant (compatibilité + nouveau)
// =============================================================================
class DashColors {
  final BuildContext context;
  late final bool _isDark;
  late final AppThemeExtension _ext;

  DashColors(this.context) {
    _isDark = appDarkMode.value;
    _ext = Theme.of(context).extension<AppThemeExtension>() ?? (_isDark ? AppThemeExtension.dark : AppThemeExtension.light);
  }

  // Primaire
  Color get primary => _ext.primary;
  Color get primarySoft => _ext.primarySoft;

  // Accent
  Color get accent => _ext.accent;
  Color get accentSoft => _ext.accentSoft;

  // Danger
  Color get danger => _ext.danger;
  Color get dangerSoft => _ext.dangerSoft;

  // Succès
  Color get success => _ext.success;
  Color get successSoft => _ext.successSoft;

  // Info
  Color get info => _ext.info;
  Color get infoSoft => _ext.infoSoft;

  // Warning
  Color get warning => _ext.warning;
  Color get warningSoft => _ext.warningSoft;

  // Surfaces
  Color get background => _ext.background;
  Color get card => _ext.card;
  Color get cardElevated => _ext.cardElevated;
  Color get border => _ext.border;

  // Textes
  Color get textPrimary => _ext.foreground;
  Color get textSecondary => _ext.mutedForeground;

  // Ombres
  List<BoxShadow> get cardShadow => _isDark ? AppShadows.cardDark : AppShadows.cardLight;
  List<BoxShadow> get subtleShadow => _isDark ? AppShadows.subtleDark : AppShadows.subtleLight;

  // Greeting pill — désormais sobre, plus d'orange agressif
  Color get greetingPill => _isDark ? _ext.cardElevated : _ext.surfaceMuted;
  Color get topBarIcon => _ext.mutedForeground;
  Color get topBarIconBg => _ext.card;
  Color get badgeBg => _ext.muted;

  // Nouveaux helpers premium
  Color get surfaceMuted => _ext.surfaceMuted;
  Color get foreground => _ext.foreground;
  Color get mutedForeground => _ext.mutedForeground;
  Color get muted => _ext.muted;
  bool get isDark => _isDark;
  AppThemeExtension get ext => _ext;
}
