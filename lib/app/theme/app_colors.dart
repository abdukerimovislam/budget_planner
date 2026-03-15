import 'package:flutter/material.dart';

class AppColors {
  // Главные цвета (Premium Fintech Style)
  static const Color primary = Color(0xFF0A84FF); // Глубокий, но яркий синий (Apple Blue)
  static const Color onPrimary = Colors.white;

  static const Color secondary = Color(0xFF34C759); // Элегантный зеленый (Доходы)
  static const Color onSecondary = Colors.white;

  // Семантика (Мягкие iOS-like оттенки)
  static const Color error = Color(0xFFFF3B30); // Мягкий красный
  static const Color warning = Color(0xFFFF9500); // Янтарный оранжевый
  static const Color success = Color(0xFF34C759);

  // Фоны - Светлая тема (Стиль Apple Grouped Background)
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariantLight = Color(0xFFE5E5EA);

  // Фоны - Темная тема (OLED Pure Black & Glass Surfaces)
  static const Color backgroundDark = Colors.black; // Настоящий черный для OLED экранов
  static const Color surfaceDark = Color(0xFF1C1C1E); // Фирменный цвет плашек iOS
  static const Color surfaceVariantDark = Color(0xFF2C2C2E);

  // Текст
  static const Color textLight = Color(0xFF000000);
  static const Color textFadedLight = Color(0xFF8E8E93);

  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textFadedDark = Color(0xFF98989D);
}