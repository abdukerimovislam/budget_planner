import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/models/expense_category.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/providers/home_provider.dart';

extension ExpenseCategoryUI on ExpenseCategory {

  String localizedName(BuildContext context, {String? customCategoryId}) {
    if (this == ExpenseCategory.custom && customCategoryId != null) {
      final customCat = context.read<HomeProvider>().getCustomCategoryById(customCategoryId);
      // ВОТ ТУТ МЫ ВОЗВРАЩАЕМ РЕАЛЬНОЕ ИМЯ (НАПРИМЕР "Курс")
      if (customCat != null) return customCat.name;
    }

    final l10n = AppLocalizations.of(context);
    switch (this) {
      case ExpenseCategory.food: return l10n.categoryFood;
      case ExpenseCategory.transport: return l10n.categoryTransport;
      case ExpenseCategory.subscriptions: return l10n.categorySubscriptions;
      case ExpenseCategory.entertainment: return l10n.categoryEntertainment;
      case ExpenseCategory.shopping: return l10n.categoryShopping;
      case ExpenseCategory.health: return l10n.categoryHealth;
      case ExpenseCategory.bills: return l10n.categoryBills;
      case ExpenseCategory.education: return l10n.categoryEducation;
      case ExpenseCategory.gifts: return l10n.categoryGifts;
      case ExpenseCategory.travel: return l10n.categoryTravel;
      case ExpenseCategory.other: return l10n.categoryOther;
      case ExpenseCategory.custom: return l10n.categoryCustom; // Локализованный фоллбэк
    }
  }

  Color dynamicColor(BuildContext context, {String? customCategoryId}) {
    if (this == ExpenseCategory.custom && customCategoryId != null) {
      final customCat = context.read<HomeProvider>().getCustomCategoryById(customCategoryId);
      if (customCat != null) return Color(customCat.colorValue);
    }

    switch (this) {
      case ExpenseCategory.food: return CupertinoColors.systemOrange;
      case ExpenseCategory.transport: return CupertinoColors.systemBlue;
      case ExpenseCategory.subscriptions: return CupertinoColors.systemPurple;
      case ExpenseCategory.entertainment: return CupertinoColors.systemRed;
      case ExpenseCategory.shopping: return CupertinoColors.systemPink;
      case ExpenseCategory.health: return CupertinoColors.systemGreen;
      case ExpenseCategory.bills: return CupertinoColors.systemTeal;
      case ExpenseCategory.education: return CupertinoColors.systemIndigo;
      case ExpenseCategory.gifts: return CupertinoColors.systemYellow;
      case ExpenseCategory.travel: return CupertinoColors.activeBlue;
      case ExpenseCategory.other: return CupertinoColors.systemGrey;
      case ExpenseCategory.custom: return CupertinoColors.systemGrey;
    }
  }

  IconData dynamicIcon(BuildContext context, {String? customCategoryId}) {
    if (this == ExpenseCategory.custom && customCategoryId != null) {
      final customCat = context.read<HomeProvider>().getCustomCategoryById(customCategoryId);
      if (customCat != null) return IconData(customCat.iconCodePoint, fontFamily: 'CupertinoIcons', fontPackage: CupertinoIcons.iconFontPackage);
    }

    switch (this) {
      case ExpenseCategory.food: return CupertinoIcons.cart_fill;
      case ExpenseCategory.transport: return CupertinoIcons.car_detailed;
      case ExpenseCategory.subscriptions: return CupertinoIcons.creditcard_fill;
      case ExpenseCategory.entertainment: return CupertinoIcons.tv_fill;
      case ExpenseCategory.shopping: return CupertinoIcons.bag_fill;
      case ExpenseCategory.health: return CupertinoIcons.bandage_fill;
      case ExpenseCategory.bills: return CupertinoIcons.doc_text_fill;
      case ExpenseCategory.education: return CupertinoIcons.book_fill;
      case ExpenseCategory.gifts: return CupertinoIcons.gift_fill;
      case ExpenseCategory.travel: return CupertinoIcons.airplane;
      case ExpenseCategory.other: return CupertinoIcons.square_grid_2x2;
      case ExpenseCategory.custom: return CupertinoIcons.square_grid_2x2;
    }
  }
}