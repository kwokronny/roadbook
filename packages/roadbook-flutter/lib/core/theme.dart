// lib/core/theme.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // 背景 & 表面
  static const Color background    = Color(0xFFFDFAF6);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color border        = Color(0xFFF0EBE3);

  // 主色（暖橙）
  static const Color primary       = Color(0xFFF97316);
  static const Color primaryLight  = Color(0xFFFFF7ED);
  static const Color primaryBorder = Color(0xFFFED7AA);

  // 住宿色（紫）
  static const Color hotel         = Color(0xFF8B5CF6);
  static const Color hotelLight    = Color(0xFFF5F3FF);
  static const Color hotelBorder   = Color(0xFFDDD6FE);

  // 状态色
  static const Color success       = Color(0xFF16A34A);
  static const Color successLight  = Color(0xFFF0FDF4);
  static const Color neutral       = Color(0xFFA8A29E);

  // 文字
  static const Color textPrimary   = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFFA8A29E);
  static const Color textDisabled  = Color(0xFFC4B8B0);

  // 渐变（FAB、保存按钮、旅行中横幅）
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract class AppTextStyles {
  static const TextStyle pageHeroTitle = TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3);
  // TODO: restore GoogleFonts.dmSans once null-cast root cause is identified
  static const TextStyle appBarTitle = TextStyle(
        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get cardTitle => const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get body => const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get caption => const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get micro => const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
}

abstract class AppRadius {
  static const double card        = 14;
  static const double sheet       = 24;
  static const double input       = 8;
  static const double timeCell    = 6;
  static const double badge       = 20;
  static const double fab         = 14;
}

abstract class AppSpacing {
  static const double pageHorizontal = 16;
  static const double cardPadding    = 14;
  static const double cardGap        = 10;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
          // background 在 Flutter 3.18+ 已废弃，统一用 surface
        ),
        fontFamily: 'PingFang SC',
        dividerColor: AppColors.border,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: AppTextStyles.appBarTitle,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
      );
}
