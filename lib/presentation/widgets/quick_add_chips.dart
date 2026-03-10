import 'package:flutter/material.dart';

import '../../data/models/expense_category.dart';
import '../../l10n/app_localizations.dart';

class QuickAddChips extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final ValueChanged<ExpenseCategory> onTapCategory;
  final VoidCallback onCustomCategoryTap;

  const QuickAddChips({
    super.key,
    required this.categories,
    required this.onTapCategory,
    required this.onCustomCategoryTap,
  });

  String _label(BuildContext context, ExpenseCategory category) {
    final l10n = AppLocalizations.of(context);

    switch (category) {
      case ExpenseCategory.food:
        return l10n.categoryFood;
      case ExpenseCategory.transport:
        return l10n.categoryTransport;
      case ExpenseCategory.subscriptions:
        return l10n.categorySubscriptions;
      case ExpenseCategory.shopping:
        return l10n.categoryShopping;
      case ExpenseCategory.entertainment:
        return l10n.categoryEntertainment;
      case ExpenseCategory.health:
        return l10n.categoryHealth;
      case ExpenseCategory.bills:
        return l10n.categoryBills;
      case ExpenseCategory.education:
        return l10n.categoryEducation;
      case ExpenseCategory.gifts:
        return l10n.categoryGifts;
      case ExpenseCategory.travel:
        return l10n.categoryTravel;
      case ExpenseCategory.other:
        return l10n.categoryOther;
    }
  }

  IconData _icon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_rounded;
      case ExpenseCategory.subscriptions:
        return Icons.subscriptions_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.entertainment:
        return Icons.movie_rounded;
      case ExpenseCategory.health:
        return Icons.favorite_rounded;
      case ExpenseCategory.bills:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.education:
        return Icons.school_rounded;
      case ExpenseCategory.gifts:
        return Icons.card_giftcard_rounded;
      case ExpenseCategory.travel:
        return Icons.flight_takeoff_rounded;
      case ExpenseCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // 1. Умные категории (подставляются снаружи)
        ...categories.map((category) {
          return ActionChip(
            avatar: Icon(_icon(category), size: 18, color: theme.colorScheme.onSurface),
            label: Text(
              _label(context, category),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            backgroundColor: theme.colorScheme.surface,
            side: BorderSide(color: theme.colorScheme.surfaceVariant),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () => onTapCategory(category),
          );
        }),

        // 2. Кнопка для своей категории (Custom)
        ActionChip(
          avatar: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
          label: Text(
            l10n.customCategory,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: onCustomCategoryTap,
        ),
      ],
    );
  }
}