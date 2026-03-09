import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isCompactHeight(BuildContext context) {
    return screenHeight(context) < 700;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 700;
  }

  static double pageHorizontalPadding(BuildContext context) {
    if (isTablet(context)) return 32;
    return 16;
  }

  static double pageTopPadding(BuildContext context) {
    if (isCompactHeight(context)) return 12;
    return 16;
  }

  static double cardPadding(BuildContext context) {
    if (isCompactHeight(context)) return 14;
    return 16;
  }

  static double sectionGap(BuildContext context) {
    if (isCompactHeight(context)) return 16;
    return 20;
  }

  static double itemGap(BuildContext context) {
    if (isCompactHeight(context)) return 8;
    return 12;
  }

  static double largeTitleSize(BuildContext context) {
    if (isTablet(context)) return 32;
    if (isCompactHeight(context)) return 24;
    return 28;
  }
}