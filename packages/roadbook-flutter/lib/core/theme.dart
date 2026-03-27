// lib/core/theme.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Brand ───────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFFFF5B2E); // coral orange
  static const Color primaryLight = Color(0xFFFFEFEB); // light tint for bg/selections
  static const Color primaryBorder = Color(0xFFFFCBBD); // matching border

  // ─── Backgrounds ─────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF2F2F7); // iOS system gray
  static const Color surface    = Color(0xFFFFFFFF);

  // ─── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary  = Color(0xFFC7C7CC);
  static const Color textDisabled  = Color(0xFFC7C7CC); // alias

  // ─── Borders & Separators ────────────────────────────────────────────────
  static const Color border    = Color(0xFFE5E5EA); // iOS gray5 — used by preserved sheets
  static const Color separator = Color(0x1A3C3C43); // rgba(60,60,67,0.1) for 0.5px dividers

  // ─── Semantic ────────────────────────────────────────────────────────────
  static const Color destructive  = Color(0xFFFF3B30);
  static const Color success      = Color(0xFF34C759);
  static const Color successLight = Color(0xFFEAFFF0);
  static const Color neutral      = Color(0xFF8E8E93);

  // ─── Hotel (preserved) ───────────────────────────────────────────────────
  static const Color hotel       = Color(0xFF8B5CF6);
  static const Color hotelLight  = Color(0xFFF5F3FF);
  static const Color hotelBorder = Color(0xFFDDD6FE);

  // ─── Schedule "unplanned" dot (preserved) ────────────────────────────────
  static const Color unplanned      = Color(0xFFD4C8BF);
  static const Color unplannedLight = Color(0xFFEDE8E3);

  // ─── Travel status gradients (cards only) ────────────────────────────────
  static const LinearGradient ongoingGradient = LinearGradient(
    colors: [Color(0xFFFF5B2E), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient upcomingGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient planningGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient endedGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Primary gradient (main buttons / FABs) ──────────────────────────────
  // Same colors as ongoingGradient by design — these may diverge if brand/status colors change.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5B2E), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract class AppTextStyles {
  // iOS-spec sizes
  static const TextStyle largeTitle = TextStyle(
      fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5);
  static const TextStyle appBarTitle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get subheadline => const TextStyle(
      fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get body => const TextStyle(
      fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get caption => const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get micro => const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  // Aliases kept for preserved components
  static TextStyle get pageHeroTitle => largeTitle;
  static TextStyle get cardTitle => const TextStyle(
      fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
}

abstract class AppRadius {
  static const double card        = 14; // status gradient cards
  static const double contentCard = 12; // white content cards (discover, profile menus)
  static const double sheet       = 24;
  static const double input       = 10;
  static const double badge       =  6;
  static const double iconBox     =  6;
  static const double fab         = 14; // kept for preserved sheets that use gradient FAB containers
  static const double timeCell    =  6; // kept for schedule_timeline_item
}

abstract class AppSpacing {
  static const double pageHorizontal = 16;
  static const double cardPadding    = 12;
  static const double cardGap        =  8;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
        ),
        fontFamily: 'PingFang SC',
        dividerColor: AppColors.separator,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: AppTextStyles.appBarTitle,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
      );
}
