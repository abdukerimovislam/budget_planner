import 'package:flutter/material.dart';

import '../../core/utils/category_extension.dart'; // <-- ИМПОРТ РАСШИРЕНИЯ
import '../../data/models/expense_category.dart';
import '../../data/models/expense_filter_model.dart';
import '../../l10n/app_localizations.dart';

class ExpenseFilterBar extends StatelessWidget {
  final ExpenseFilterModel filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ExpenseCategory?> onCategoryChanged;
  final ValueChanged<ExpenseSortOption> onSortChanged;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onClearDates;

  const ExpenseFilterBar({
    super.key,
    required this.filter,
    required this.onQueryChanged,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onClearDates,
  });

  String _sortLabel(BuildContext context, ExpenseSortOption option) {
    final l10n = AppLocalizations.of(context);

    switch (option) {
      case ExpenseSortOption.newestFirst:
        return l10n.expenseSortNewest;
      case ExpenseSortOption.oldestFirst:
        return l10n.expenseSortOldest;
      case ExpenseSortOption.highestAmount:
        return l10n.expenseSortHighest;
      case ExpenseSortOption.lowestAmount:
        return l10n.expenseSortLowest;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Пока фильтруем только по системным категориям + all
    final availableCategories = ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: l10n.expenseSearchHint,
          ),
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ExpenseCategory?>(
                isExpanded: true,
                value: filter.category,
                items: [
                  DropdownMenuItem<ExpenseCategory?>(
                    value: null,
                    child: Text(
                      l10n.expenseFilterAllCategories,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  ...availableCategories.map(
                        (category) => DropdownMenuItem<ExpenseCategory?>(
                      value: category,
                      child: Text(
                        category.localizedName(context), // ИСПОЛЬЗУЕМ РАСШИРЕНИЕ
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
                onChanged: onCategoryChanged,
                decoration: InputDecoration(
                  labelText: l10n.expenseFilterCategoryLabel,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<ExpenseSortOption>(
                isExpanded: true,
                value: filter.sortOption,
                items: ExpenseSortOption.values.map(
                      (option) => DropdownMenuItem(
                    value: option,
                    child: Text(
                      _sortLabel(context, option),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ).toList(),
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
                decoration: InputDecoration(
                  labelText: l10n.expenseFilterSortLabel,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onPickStartDate,
                child: Text(
                  l10n.expenseFilterStartDate(_formatDate(filter.startDate)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onPickEndDate,
                child: Text(
                  l10n.expenseFilterEndDate(_formatDate(filter.endDate)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onClearDates,
            child: Text(l10n.expenseFilterClearDates),
          ),
        ),
      ],
    );
  }
}