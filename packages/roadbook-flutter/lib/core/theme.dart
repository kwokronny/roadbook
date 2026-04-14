// lib/core/theme.dart
// Frosted Warmth / SandTrail Design System — 小肥路书
import 'dart:ui';
import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Brand Accent ────────────────────────────────────────────────────────
  static const Color primary    = Color(0xFFFF6B3D); // Coral Ember
  static const Color coralGlow  = Color(0x59FF6B3D); // rgba(255,107,61,0.35) — shadow on coral buttons
  static const Color coralTint  = Color(0x1AFF6B3D); // rgba(255,107,61,0.10) — badge/tag bg

  // ─── Dark Accents ────────────────────────────────────────────────────────
  static const Color darkPill      = Color(0xE01C1C1E); // rgba(28,28,30,0.88) — primary CTA
  static const Color darkPillHover = Color(0xBF1C1C1E); // rgba(28,28,30,0.75) — pressed

  // ─── Canvas & Surface ────────────────────────────────────────────────────
  static const Color warmCanvas    = Color(0xFFF2EDE8); // App base background
  static const Color cardFrost     = Color(0x85FFFFFF); // rgba(255,255,255,0.52)
  static const Color cardFrostStrong = Color(0xB8FFFFFF); // rgba(255,255,255,0.72) — sheets
  static const Color cardBorder    = Color(0xA6FFFFFF); // rgba(255,255,255,0.65)
  static const Color dockGlass     = Color(0x4DFFFFFF); // rgba(255,255,255,0.30)

  // ─── Ink (neutral #1C1C1E at varying opacities) ──────────────────────────
  static const Color inkPrimary   = Color(0xE61C1C1E); // rgba(28,28,30,0.90)
  static const Color inkSecondary = Color(0x801C1C1E); // rgba(28,28,30,0.50)
  static const Color inkTertiary  = Color(0x471C1C1E); // rgba(28,28,30,0.28)

  // Backward-compat aliases — screens may still reference these names
  static const Color textPrimary   = inkPrimary;
  static const Color textSecondary = inkSecondary;
  static const Color textTertiary  = inkTertiary;

  // ─── Semantic ────────────────────────────────────────────────────────────
  static const Color destructive = Color(0xFFFF3B30);
  static const Color success     = Color(0xFF34C759);
  static const Color neutral     = Color(0xFF8E8E93);

  // ─── Secondary Accent — Lavender (Hotel / Accommodation) ─────────────────
  static const Color lavender      = Color(0xFF8C5CF6);
  static const Color lavenderTint  = Color(0x1A8C5CF6); // rgba(140,92,246,0.10)
  static const Color lavenderText  = Color(0xFF6D3FC0);
  static const Color lavenderDeep  = Color(0xFF6D3FC0); // deep purple — hotel title text
  static const Color lavenderAddr  = Color(0x808C5CF6); // rgba(140,92,246,0.50) — hotel address
  static const Color lavenderNote  = Color(0x738C5CF6); // rgba(140,92,246,0.45) — hotel notes
  static const Color lavenderFrost = Color(0x148C5CF6); // rgba(140,92,246,0.08) — hotel card tint
  static const Color lavenderFrostBorder = Color(0x268C5CF6); // rgba(140,92,246,0.15) — hotel card border
  static const Color lavenderTimeBg = Color(0x1F8C5CF6); // rgba(140,92,246,0.12) — hotel time badge

  // Backward-compat aliases for hotel
  static const Color hotel       = lavender;
  static const Color hotelLight  = lavenderTint;
  static const Color hotelBorder = Color(0x388C5CF6); // rgba(140,92,246,0.22)

  // ─── Schedule unplanned ──────────────────────────────────────────────────
  static const Color unplanned      = Color(0xFFD4C8BF);
  static const Color unplannedLight = Color(0xFFEDE8E3);

  // ─── Backward compat aliases ─────────────────────────────────────────────
  static const Color primaryLight  = coralTint;
  static const Color primaryBorder = Color(0x38FF6B3D); // rgba(255,107,61,0.22)
  static const Color background    = warmCanvas;
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color border        = Color(0xFFE5E5EA);
  static const Color separator     = Color(0x1A3C3C43);
  static const Color textDisabled  = Color(0xFFC7C7CC);
  static const Color successLight  = Color(0xFFEAFFF0);

  // ─── Accent palette (preserved for legacy screens) ───────────────────────
  static const Color sunstone  = Color(0xFFE08500);
  static const Color skyBlue   = Color(0xFF2A7EF5);
  static const Color spearmint = Color(0xFF0AAD88);
  static const Color petalPink = Color(0xFFE8387A);

  // ─── City tags — unified dark style ──────────────────────────────────────
  static const Color _cityTagBg     = Color(0x0D1C1C1E); // rgba(28,28,30,0.05)
  static const Color _cityTagBorder = Color(0x141C1C1E); // rgba(28,28,30,0.08)

  static Color cityTagColor(int index) => inkSecondary;
  static Color cityTagBg(int index) => _cityTagBg;
  static Color cityTagBorder(int index) => _cityTagBorder;
  static Color cityTagText(int index) => inkSecondary;

  // ─── Status colors (Frosted Warmth) ──────────────────────────────────────
  static Color statusTint(TravelStatusType status) => switch (status) {
    TravelStatusType.ongoing  => const Color(0x0AFF6B3D), // rgba(255,107,61,0.04)
    TravelStatusType.upcoming => const Color(0x0AE08500), // rgba(224,133,0,0.04)
    TravelStatusType.planning => Colors.transparent,
    TravelStatusType.ended    => Colors.transparent,
  };

  static Color statusBadgeBg(TravelStatusType status) => switch (status) {
    TravelStatusType.ongoing  => coralTint,                 // rgba(255,107,61,0.10)
    TravelStatusType.upcoming => const Color(0x1AE08500),   // rgba(224,133,0,0.10)
    TravelStatusType.planning => const Color(0x0F1C1C1E),   // rgba(28,28,30,0.06)
    TravelStatusType.ended    => const Color(0x0A1C1C1E),   // rgba(28,28,30,0.04)
  };

  static Color statusBadgeBorder(TravelStatusType status) => switch (status) {
    TravelStatusType.ongoing  => const Color(0x38FF6B3D),   // rgba(255,107,61,0.22)
    TravelStatusType.upcoming => const Color(0x38E08500),   // rgba(224,133,0,0.22)
    TravelStatusType.planning => const Color(0x1F1C1C1E),   // rgba(28,28,30,0.12)
    TravelStatusType.ended    => const Color(0x141C1C1E),   // rgba(28,28,30,0.08)
  };

  static Color statusBadgeText(TravelStatusType status) => switch (status) {
    TravelStatusType.ongoing  => const Color(0xFFD4410A),   // coral dark
    TravelStatusType.upcoming => const Color(0xFFB56800),   // sunstone dark
    TravelStatusType.planning => inkSecondary,
    TravelStatusType.ended    => inkTertiary,
  };

  // ─── Legacy gradients (preserved for non-redesigned screens) ─────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B3D), Color(0xFFFF8C42)],
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

// ─── Glass Surface Specs (Frosted Warmth) ────────────────────────────────────

abstract class GlassSpec {
  // Card / Schedule Item
  static ImageFilter cardBlur = ImageFilter.blur(sigmaX: 14, sigmaY: 14);
  static const Color cardBg     = Color(0x8CFFFFFF); // rgba(255,255,255,0.55)
  static const Color cardBorder = Color(0xA6FFFFFF); // rgba(255,255,255,0.65)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 32, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x08000000), blurRadius: 2,  offset: Offset(0, 1)),
  ];

  // Bottom Sheet — blur(50) saturate(1.8)
  static ImageFilter sheetBlur = ImageFilter.blur(sigmaX: 50, sigmaY: 50);
  static const Color sheetBg     = Color(0xB8FFFFFF); // rgba(255,255,255,0.72)
  static const Color sheetBorder = Color(0x8CFFFFFF); // rgba(255,255,255,0.55)
  static const List<BoxShadow> sheetShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 32, offset: Offset(0, -8)),
  ];
  static const Color dragHandle = Color(0x291C1C1E); // rgba(28,28,30,0.16)

  // Navigation Dock (Floating Island) — blur(50) saturate(1.8) brightness(1.05)
  static ImageFilter navBlur = ImageFilter.blur(sigmaX: 50, sigmaY: 50);
  static const Color navBg     = Color(0x4DFFFFFF); // rgba(255,255,255,0.30)
  static const Color navBorder = Color(0x80FFFFFF); // rgba(255,255,255,0.50)
  static const List<BoxShadow> navShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 32, offset: Offset(0, 8)),
  ];
  static const BoxShadow navInsetShadow = BoxShadow(
    color: Color(0x8CFFFFFF), // rgba(255,255,255,0.55)
    blurRadius: 0, offset: Offset(0, 1),
  );

  // Glass Indicator (dock sliding pill)
  static const Color indicatorBg     = Color(0x73FFFFFF); // rgba(255,255,255,0.45)
  static const Color indicatorBorder = Color(0x99FFFFFF); // rgba(255,255,255,0.60)
  static const List<BoxShadow> indicatorShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 2)),
  ];

  // Input (on white sheets)
  static ImageFilter inputBlur = ImageFilter.blur(sigmaX: 16, sigmaY: 16);
  static const Color inputBg          = Color(0x73FFFFFF); // rgba(255,255,255,0.45)
  static const Color inputBorder      = Color(0x99FFFFFF); // rgba(255,255,255,0.60)
  static const Color inputFocusBorder = Color(0x66FF6B3D); // rgba(255,107,61,0.40)

  // Input (on glass / mesh background)
  static const Color inputOnGlassBg     = Color(0x0D1C1C1E); // rgba(28,28,30,0.05)
  static const Color inputOnGlassBorder = Color(0x141C1C1E); // rgba(28,28,30,0.08)

  // Specular highlight — 160deg gradient (subtle)
  static const LinearGradient specularHighlight = LinearGradient(
    begin: Alignment(-0.5, -0.87), // ≈ 160deg from top-left
    end: Alignment(0.5, 0.87),
    colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)], // rgba(255,255,255,0.20) → transparent
    stops: [0.0, 0.40],
  );
}

// ─── Text Styles (Frosted Warmth — PingFang SC, CJK-primary) ─────────────────

abstract class AppTextStyles {
  // Display — ultra-thin large titles
  static const TextStyle display = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w200, color: AppColors.inkPrimary,
    letterSpacing: -1.02, // -0.03em
  );

  // Title — section headers
  static const TextStyle title = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w300, color: AppColors.inkPrimary,
    letterSpacing: -0.44, // -0.02em
  );

  // App Bar Title
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.inkPrimary,
    letterSpacing: -0.18, // -0.01em
  );

  // Headline — card titles, names
  static const TextStyle headline = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.inkPrimary,
  );

  // Body — descriptions, inactive labels
  static const TextStyle body = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.inkSecondary,
  );

  // Caption — small text
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.inkTertiary,
  );

  // Micro — smallest text
  static const TextStyle micro = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.inkTertiary,
  );

  // Subheadline — mid-size body text
  static const TextStyle subheadline = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.inkPrimary,
  );

  // Backward-compat aliases
  static const TextStyle largeTitle = display;
  static const TextStyle title1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w300, color: AppColors.inkPrimary,
    letterSpacing: -0.56,
  );
  static const TextStyle title2 = title;
  static const TextStyle pageHeroTitle = display;
  static const TextStyle cardTitle = headline;
}

// ─── Radius ───────────────────────────────────────────────────────────────────

abstract class AppRadius {
  static const double card     = 24;
  static const double cardSm   = 16;
  static const double cardXs   = 10;
  static const double pill     = 100;
  static const double sheet    = 24;
  static const double cover    = 14; // image/cover radius

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

  static const double pageHorizontal = 20; // page-h
  static const double cardPadding    = 16;
  static const double cardGap        = 14; // travel list gap
  static const double scheduleGap    = 20; // schedule list gap
  static const double dockInset      = 20; // dock from edges
  static const double dockHeight     = 58;
}

// ─── Animation ────────────────────────────────────────────────────────────────

abstract class AppAnimations {
  // Durations
  static const Duration fast   = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow   = Duration(milliseconds: 380);
  static const Duration spring500 = Duration(milliseconds: 500);
  static const Duration spring600 = Duration(milliseconds: 600);

  // Curves
  static const Curve spring     = Cubic(0.34, 1.3, 0.64, 1.0);  // bouncy spring
  static const Curve easeOut    = Cubic(0.22, 0.0, 0.36, 1.0);  // sheet dismiss, tab switch
  static const Curve expressive = Cubic(0.22, 1.0, 0.36, 1.0);  // emphasis, stagger reveals

  // Backward-compat aliases
  static const Curve defaultCurve = easeOut;
  static const Curve springCurve  = spring;
  static const Curve sheetCurve   = expressive;

  // Micro-interaction constants
  static const double pressScale    = 0.92;
  static const double tabPressScale = 0.88;
  static const double cardHoldScale = 0.97;
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
    scaffoldBackgroundColor: AppColors.warmCanvas,
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
      iconTheme: IconThemeData(color: AppColors.inkPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GlassSpec.inputOnGlassBg, // rgba(28,28,30,0.05) on sheets
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cover),
        borderSide: const BorderSide(color: GlassSpec.inputOnGlassBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cover),
        borderSide: const BorderSide(color: GlassSpec.inputOnGlassBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cover),
        borderSide: const BorderSide(color: GlassSpec.inputFocusBorder, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cover),
        borderSide: const BorderSide(color: AppColors.destructive, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cover),
        borderSide: const BorderSide(color: AppColors.destructive, width: 1.5),
      ),
      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.inkSecondary),
      floatingLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary.withValues(alpha: 0.80)),
      hintStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.inkTertiary),
      errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.destructive),
      suffixIconColor: AppColors.inkTertiary,
      prefixIconColor: AppColors.inkTertiary,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.coralTint,
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
        if (states.contains(WidgetState.disabled)) return AppColors.inkTertiary;
        return AppColors.inkPrimary;
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
        return AppColors.inkPrimary;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return null;
      }),
      rangePickerBackgroundColor: AppColors.surface,
      rangePickerSurfaceTintColor: Colors.transparent,
      rangeSelectionBackgroundColor: AppColors.coralTint,
      cancelButtonStyle: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(AppColors.inkSecondary)),
      confirmButtonStyle: const ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.primary),
        textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w500)),
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
