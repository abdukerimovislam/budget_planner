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
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      surfaceVariant: AppColors.surfaceVariantLight,
      onBackground: AppColors.textLight,
      onSurface: AppColors.textLight,
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      surfaceVariant: AppColors.surfaceVariantDark,
      onBackground: AppColors.textDark,
      onSurface: AppColors.textDark,
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isLight = colorScheme.brightness == Brightness.light;
    final textColor = isLight ? AppColors.textLight : AppColors.textDark;
    final textFaded = isLight ? AppColors.textFadedLight : AppColors.textFadedDark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      fontFamily: 'Inter', // Если у тебя подключен шрифт, если нет - Flutter использует системный (San Francisco/Roboto), что тоже отлично

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0, // Убирает затемнение при скролле
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0, // Никаких грязных теней
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgBorder,
          side: BorderSide(
            color: colorScheme.surfaceVariant.withOpacity(isLight ? 0.5 : 0.1),
            width: 1,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdBorder),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56), // Большие удобные кнопки
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdBorder),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadii.mdBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdBorder,
          borderSide: BorderSide(color: colorScheme.surfaceVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdBorder,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: textFaded),
        hintStyle: TextStyle(color: textFaded.withOpacity(0.5)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary);
          }
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textFaded);
        }),
      ),
    );
  }
}