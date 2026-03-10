import 'package:flutter/material.dart';

class AppRadii {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;   // Для кнопок и мелких плашек
  static const double lg = 24.0;   // Основной радиус для карточек
  static const double xl = 32.0;   // Для Bottom Sheets и крупных блоков

  static const BorderRadius xsBorder = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
}