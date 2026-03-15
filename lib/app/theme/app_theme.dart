import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radii.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      surface: AppColors.surfaceLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurface: AppColors.textLight,
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme, AppColors.backgroundLight);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      surface: AppColors.surfaceDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurface: AppColors.textDark,
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme, AppColors.backgroundDark);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Color backgroundColor) {
    final isLight = colorScheme.brightness == Brightness.light;
    final textColor = isLight ? AppColors.textLight : AppColors.textDark;
    final textFaded = isLight ? AppColors.textFadedLight : AppColors.textFadedDark;

    // Очень мягкая, широкая тень (Apple-style Drop Shadow)
    final softShadow = [
      BoxShadow(
        color: colorScheme.primary.withValues(alpha: isLight ? 0.04 : 0.02),
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isLight ? 0.02 : 0.2),
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ];

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      // Inter отлично подходит для финтеха (цифры читаются идеально)
      fontFamily: 'Inter',

      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        systemOverlayStyle: isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Максимально мягкие углы
          side: BorderSide(
            color: isLight
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05), // Тонкий стеклянный блик в даркмоде
            width: 1,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isLight
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.4),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.4),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isLight
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5), width: 2),
        ),
        labelStyle: TextStyle(color: textFaded, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: textFaded.withValues(alpha: 0.5), fontWeight: FontWeight.w400),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        modalBackgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.9), // Слегка прозрачный бар
        indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: colorScheme.primary);
          }
          return TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: -0.2, color: textFaded);
        }),
      ),

      // Добавляем стиль для свитчей (переключателей)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return textFaded;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}