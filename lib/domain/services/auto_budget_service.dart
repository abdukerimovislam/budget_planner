import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';

class AutoBudgetRecommendation {
  final double recommendedTotalBudget;
  final Map<ExpenseCategory, double> categoryBudgets;

  const AutoBudgetRecommendation({
    required this.recommendedTotalBudget,
    required this.categoryBudgets,
  });
}

class AutoBudgetService {
  AutoBudgetRecommendation generate({
    required List<ExpenseModel> last30DaysExpenses,
  }) {
    if (last30DaysExpenses.isEmpty) {
      return const AutoBudgetRecommendation(
        recommendedTotalBudget: 0,
        categoryBudgets: {},
      );
    }

    double total = 0;
    final Map<ExpenseCategory, double> categoryTotals = {};

    for (final expense in last30DaysExpenses) {
      total += expense.amount;
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Небольшая “подушка”: не просто копируем прошлое, а добавляем 5%
    final recommendedTotal = total * 1.05;

    final categoryBudgets = <ExpenseCategory, double>{};
    for (final entry in categoryTotals.entries) {
      categoryBudgets[entry.key] = entry.value * 1.05;
    }

    return AutoBudgetRecommendation(
      recommendedTotalBudget: recommendedTotal,
      categoryBudgets: categoryBudgets,
    );
  }
}