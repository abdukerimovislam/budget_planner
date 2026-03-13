import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/category_extension.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../providers/home_provider.dart';
import '../../widgets/expense_item_card.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final ExpenseCategory category;
  final String? customCategoryId;
  final DateTime monthDate;

  const CategoryDetailsScreen({
    super.key,
    required this.category,
    required this.customCategoryId,
    required this.monthDate,
  });

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Фильтруем транзакции только для этой категории в выбранном месяце
    final categoryExpenses = provider.expensesForMonth(monthDate).where((e) {
      if (e.isIncome) return false;
      if (e.category == ExpenseCategory.custom) {
        return e.customCategoryId == customCategoryId;
      }
      return e.category == category;
    }).toList();

    // Сортируем от новых к старым
    categoryExpenses.sort((a, b) => b.date.compareTo(a.date));

    final totalAmount = categoryExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final categoryName = category.localizedName(context, customCategoryId: customCategoryId);
    final categoryColor = category.dynamicColor(context, customCategoryId: customCategoryId);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
      appBar: CupertinoNavigationBar(
        backgroundColor: (isDark ? Colors.black : const Color(0xFFF2F2F7)).withValues(alpha: 0.8),
        middle: Text(categoryName, style: TextStyle(color: theme.colorScheme.onSurface)),
        previousPageTitle: 'Back',
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.dynamicIcon(context, customCategoryId: customCategoryId),
                      color: categoryColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Spent',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatNumber(totalAmount)} ${provider.activeCurrency}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${categoryExpenses.length} transactions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (categoryExpenses.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No transactions found', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final expense = categoryExpenses[index];
                    final isFirst = index == 0;
                    final isLast = index == categoryExpenses.length - 1;

                    return Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.vertical(
                          top: isFirst ? const Radius.circular(24) : Radius.zero,
                          bottom: isLast ? const Radius.circular(24) : Radius.zero,
                        ),
                      ),
                      child: Column(
                        children: [
                          Dismissible(
                            key: ValueKey(expense.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: CupertinoColors.destructiveRed,
                                borderRadius: BorderRadius.vertical(
                                  top: isFirst ? const Radius.circular(24) : Radius.zero,
                                  bottom: isLast ? const Radius.circular(24) : Radius.zero,
                                ),
                              ),
                              child: const Icon(CupertinoIcons.trash, color: Colors.white),
                            ),
                            onDismissed: (_) => provider.deleteExpense(expense.id),
                            child: ExpenseItemCard(
                              expense: expense,
                              incomeProfile: provider.incomeProfile,
                              onTap: () => provider.openExpenseEditor(context, expense),
                            ),
                          ),
                          if (!isLast)
                            Padding(
                              padding: const EdgeInsets.only(left: 64),
                              child: Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: categoryExpenses.length,
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
          )
        ],
      ),
    );
  }
}