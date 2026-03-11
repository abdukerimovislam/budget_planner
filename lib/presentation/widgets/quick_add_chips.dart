import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/utils/category_extension.dart';
import '../../data/models/expense_category.dart';
import '../../l10n/app_localizations.dart'; // <-- ИМПОРТ

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context); // <-- ЛОКАЛИЗАЦИЯ

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(color: theme.colorScheme.surfaceVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                avatar: Icon(
                    category.dynamicIcon(context),
                    color: category.dynamicColor(context),
                    size: 16
                ),
                label: Text(
                  category.localizedName(context),
                  style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                ),
                onPressed: () => onTapCategory(category),
              ),
            );
          }),

          // Кнопка "Новая" вместо "Custom"
          ActionChip(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            side: const BorderSide(color: Colors.transparent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            avatar: Icon(CupertinoIcons.add, color: theme.colorScheme.primary, size: 16),
            label: Text(
                l10n.newCategoryButton, // <-- ИСПОЛЬЗУЕМ ЛОКАЛИЗАЦИЮ
                style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)
            ),
            onPressed: onCustomCategoryTap,
          ),
        ],
      ),
    );
  }
}