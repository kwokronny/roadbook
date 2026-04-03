// lib/core/theme.dart
import 'dart:ui';
import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Brand ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF5B2E);

  // ─── Liquid Glass Accent Palette ─────────────────────────────────────────
  static const Color skyBlue   = Color(0xFF2A7EF5);
  static const Color spearmint = Color(0xFF0AAD88);
  static const Color petalPink = Color(0xFFE8387A);
  static const Color sunstone  = Color(0xFFE08500);
  static const Color lavender  = Color(0xFF7C55F0);

  // ─── Text (blue-tinted dark) ─────────────────────────────────────────────
  static const Color textPrimary   = Color(0xEB1E243C); // rgba(30,36,60,0.92)
  static const Color textSecondary = Color(0x8C1E243C); // rgba(30,36,60,0.55)
  static const Color textTertiary  = Color(0x591E243C); // rgba(30,36,60,0.35)

  // ─── Semantic ────────────────────────────────────────────────────────────
  static const Color destructive = Color(0xFFFF3B30);
  static const Color success     = Color(0xFF34C759);
  static const Color neutral     = Color(0xFF8E8E93);

  // ─── Hotel (preserved for schedule screens) ──────────────────────────────
  static const Color hotel       = Color(0xFF8B5CF6);
  static const Color hotelLight  = Color(0xFFF5F3FF);
  static const Color hotelBorder = Color(0xFFDDD6FE);

  // ─── Schedule unplanned (preserved) ──────────────────────────────────────
  static const Color unplanned      = Color(0xFFD4C8BF);
  static const Color unplannedLight = Color(0xFFEDE8E3);

  // ─── Backward compat aliases (used by preserved screens) ─────────────────
  static const Color primaryLight  = Color(0xFFFFEFEB);
  static const Color primaryBorder = Color(0xFFFFCBBD);
  static const Color background    = Color(0xFFF2F2F7);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color border        = Color(0xFFE5E5EA);
  static const Color separator     = Color(0x1A3C3C43);
  static const Color textDisabled  = Color(0xFFC7C7CC);
  static const Color successLight  = Color(0xFFEAFFF0);

  // ─── City tag color cycle ────────────────────────────────────────────────
  static const List<Color> tagAccents = [lavender, spearmint, petalPink, sunstone, skyBlue];

  static Color cityTagColor(int index) => tagAccents[index % tagAccents.length];
  static Color cityTagBg(int index) => cityTagColor(index).withValues(alpha: 0.10);
  static Color cityTagBorder(int index) => cityTagColor(index).withValues(alpha: 0.22);
  static Color cityTagText(int index) {
    const darkVariants = [
      Color(0xFF5C38CC), // lavender
      Color(0xFF0A8A6D), // spearmint
      Color(0xFFC02060), // petalPink
      Color(0xFFB56800), // sunstone
      Color(0xFF1A5FC8), // skyBlue
    ];
    return darkVariants[index % darkVariants.length];
  }

  // ─── Status colors ───────────────────────────────────────────────────────
  static Color statusTint(TravelStatusType status) => switch (status) {
    TravelStatusType.ongoing  => const Color(0x0F0AAD88),
    TravelStatusType.upcoming => const Color(0x0FE08500),
    TravelStatusType.planning => const Color(0x0D2A7EF5),
    TravelStatusType.ended    => Colors.transparent,
  };

  static Color statusBadgeBg(TravelStatusType status) => switch (status) {
    TravelStatusType.ongoing  => spearmint.withValues(alpha: 0.10),
    TravelStatusType.upcoming => sunstone.withValues(alpha: 0.10),
    TravelStatusType.planning => skyBlue.withValues(alpha: 0.10),
    TravelStatusType.ended    => const Color(0x0D1E243C),
  };

  static Color statusBadgeBorder(TravelStatusType status) => switch (status) {
    TravelStatusType.ongoing  => spearmint.withValues(alpha: 0.22),
    TravelStatusType.upcoming => sunstone.withValues(alpha: 0.22),
    TravelStatusType.planning => skyBlue.withValues(alpha: 0.22),
    TravelStatusType.ended    => const Color(0x1E1E243C),
  };

  static Color statusBadgeText(TravelStatusType status) => switch (status) {
    TravelStatusType.ongoing  => const Color(0xFF0A8A6D),
    TravelStatusType.upcoming => const Color(0xFFB56800),
    TravelStatusType.planning => const Color(0xFF1A5FC8),
    TravelStatusType.ended    => const Color(0x661E243C),
  };

  // ─── Legacy gradients (preserved for non-redesigned screens) ─────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5B2E), Color(0xFFFF8C42)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient ongoingGradient  = primaryGradient;
  static const LinearGradient upcomingGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient planningGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient endedGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}

/// Travel status type — moved here so theme can reference it without importing travel_card.
enum TravelStatusType { ongoing, upcoming, planning, ended }

// ─── Glass Surface Specs ──────────────────────────────────────────────────────

abstract class GlassSpec {
  static ImageFilter cardBlur = ImageFilter.blur(sigmaX: 28, sigmaY: 28);
  static const Color cardBg          = Color(0x8CFFFFFF);
  static const Color cardBorder      = Color(0xE6FFFFFF);
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x1A6478B4), blurRadius: 24, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x126478B4), blurRadius: 4,  offset: Offset(0, 1)),
  ];

  static ImageFilter navBlur = ImageFilter.blur(sigmaX: 40, sigmaY: 40);
  static const Color navBg     = Color(0x8CFFFFFF);
  static const Color navBorder = Color(0xE6FFFFFF);
  static const List<BoxShadow> navShadow = [
    BoxShadow(color: Color(0x1E6478B4), blurRadius: 24, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x146478B4), blurRadius: 4,  offset: Offset(0, 1)),
  ];

  static ImageFilter inputBlur = ImageFilter.blur(sigmaX: 16, sigmaY: 16);
  static const Color inputBg       = Color(0x80FFFFFF);
  static const Color inputBorder   = Color(0xCCFFFFFF);
  static const Color inputFocusBorder = Color(0x732A7EF5);

  static const LinearGradient specularHighlight = LinearGradient(
    begin: Alignment(-0.6, -0.8),
    end: Alignment(0.6, 0.8),
    colors: [Color(0x80FFFFFF), Color(0x00FFFFFF)],
    stops: [0.0, 0.45],
  );
}

// ─── Text Styles (Liquid Glass lightweight) ───────────────────────────────────

abstract class AppTextStyles {
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w300, color: AppColors.textPrimary,
    letterSpacing: -0.85,
  );
  static const TextStyle title1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    letterSpacing: -0.56,
  );
  static const TextStyle title2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    letterSpacing: -0.33,
  );
  static const TextStyle headline = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary,
  );

  // Backward-compat aliases for preserved screens
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    letterSpacing: -0.30,
  );
  static TextStyle get subheadline => const TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static TextStyle get micro => const TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static TextStyle get pageHeroTitle => largeTitle;
  static TextStyle get cardTitle => headline;
}

// ─── Radius ───────────────────────────────────────────────────────────────────

abstract class AppRadius {
  static const double card     = 20;
  static const double cardSm   = 14;
  static const double cardXs   = 10;
  static const double pill     = 100;
  static const double sheet    = 24;

  // Backward-compat aliases
  static const double contentCard = 12;
  static const double input       = 14;
  static const double badge       = 6;
  static const double iconBox     = 6;
  static const double fab         = 14;
  static const double timeCell    = 6;
}

// ─── Spacing ──────────────────────────────────────────────────────────────────

abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double touch = 44;

  // Backward-compat aliases
  static const double pageHorizontal = 16;
  static const double cardPadding    = 16;
  static const double cardGap        = 8;
}

// ─── Animation ────────────────────────────────────────────────────────────────

abstract class AppAnimations {
  static const Duration fast   = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow   = Duration(milliseconds: 380);

  static const Curve spring     = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Curve easeOut    = Cubic(0.22, 0.0, 0.36, 1.0);
  static const Curve expressive = Cubic(0.22, 1.0, 0.36, 1.0);

  // Backward-compat aliases
  static const Curve defaultCurve = easeOut;
  static const Curve springCurve  = spring;
  static const Curve sheetCurve   = Cubic(0.22, 1.0, 0.36, 1.0);
}

// ─── ThemeData ────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
    useMaterial3: true,
    splashFactory: NoSplash.splashFactory,
    highlightColor: AppColors.primary.withValues(alpha: 0.06),
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: AppColors.surface,
    ),
    fontFamily: 'PingFang SC',
    dividerColor: AppColors.separator,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.appBarTitle,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x0D1E243C), // rgba(30,36,60,0.05) — subtle tint on white sheets
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardSm),
        borderSide: const BorderSide(color: Color(0x141E243C), width: 1), // rgba(30,36,60,0.08)
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardSm),
        borderSide: const BorderSide(color: Color(0x141E243C), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardSm),
        borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.45), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardSm),
        borderSide: const BorderSide(color: AppColors.destructive, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardSm),
        borderSide: const BorderSide(color: AppColors.destructive, width: 1.5),
      ),
      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      floatingLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.skyBlue.withValues(alpha: 0.80)),
      hintStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textTertiary),
      errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.destructive),
      suffixIconColor: AppColors.textTertiary,
      prefixIconColor: AppColors.textTertiary,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primaryLight,
      selectionHandleColor: AppColors.primary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sheet)),
      titleTextStyle: AppTextStyles.appBarTitle,
      contentTextStyle: AppTextStyles.body,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sheet)),
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
      dayStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        if (states.contains(WidgetState.disabled)) return AppColors.textTertiary;
        return AppColors.textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return null;
      }),
      todayForegroundColor: const WidgetStatePropertyAll(AppColors.primary),
      todayBackgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      todayBorder: const BorderSide(color: AppColors.primary, width: 1),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.textPrimary;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return null;
      }),
      rangePickerBackgroundColor: AppColors.surface,
      rangePickerSurfaceTintColor: Colors.transparent,
      rangeSelectionBackgroundColor: AppColors.primaryLight,
      cancelButtonStyle: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(AppColors.textSecondary)),
      confirmButtonStyle: const ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.primary),
        textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w600)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
    ),
  );
}
