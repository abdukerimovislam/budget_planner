import 'package:flutter/material.dart';

class AppColors {
  // Главные цвета (Доверие и акценты)
  static const Color primary = Color(0xFF4F46E5); // Глубокий Индиго
  static const Color onPrimary = Colors.white;

  static const Color secondary = Color(0xFF10B981); // Изумрудный (Доходы/Успех)
  static const Color onSecondary = Colors.white;

  // Семантика
  static const Color error = Color(0xFFEF4444); // Чистый красный (Траты/Предупреждения)
  static const Color warning = Color(0xFFF59E0B); // Теплый оранжевый
  static const Color success = Color(0xFF10B981);

  // Фоны - Светлая тема
  static const Color backgroundLight = Color(0xFFF8FAFC); // Очень мягкий серо-голубой
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);

  // Фоны - Темная тема (OLED-friendly, но мягкая)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);

  // Текст
  static const Color textLight = Color(0xFF0F172A);
  static const Color textFadedLight = Color(0xFF64748B);

  static const Color textDark = Color(0xFFF8FAFC);
  static const Color textFadedDark = Color(0xFF94A3B8);
}