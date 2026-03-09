import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_profile_model.dart';
import 'month_close_summary_model.dart';

class MonthCloseService {
  MonthCloseSummaryModel build({
    required List<ExpenseModel> currentMonthExpenses,
    required List<ExpenseModel> previousMonthExpenses,
    required IncomeProfileModel? incomeProfile,
    required int healthScore,
    required int previousHealthScore,
    required Duration lifeSpent,
    required Map<ExpenseCategory, double> currentCategoryTotals,
  }) {
    final totalIncome = incomeProfile?.monthlyIncome ?? 0.0;

    final totalSpent = currentMonthExpenses.fold<double>(
      0.0,
          (sum, e) => sum + e.amount,
    );

    final previousMonthSpent = previousMonthExpenses.fold<double>(
      0.0,
          (sum, e) => sum + e.amount,
    );

    final totalSaved = (totalIncome - totalSpent).clamp(0, double.infinity).toDouble();

    final spendingChangePercent = previousMonthSpent > 0
        ? ((totalSpent - previousMonthSpent) / previousMonthSpent) * 100
        : 0.0;

    ExpenseCategory? topCategory;
    double topCategoryAmount = 0.0;

    if (currentCategoryTotals.isNotEmpty) {
      final sorted = currentCategoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sorted.first.key;
      topCategoryAmount = sorted.first.value;
    }

    final healthScoreDelta = healthScore - previousHealthScore;
    final improvedVsPreviousMonth =
        totalSpent <= previousMonthSpent || healthScoreDelta > 0;

    return MonthCloseSummaryModel(
      totalIncome: totalIncome,
      totalSpent: totalSpent,
      totalSaved: totalSaved,
      previousMonthSpent: previousMonthSpent,
      spendingChangePercent: spendingChangePercent,
      topCategory: topCategory,
      topCategoryAmount: topCategoryAmount,
      healthScore: healthScore,
      previousHealthScore: previousHealthScore,
      healthScoreDelta: healthScoreDelta,
      lifeSpent: lifeSpent,
      improvedVsPreviousMonth: improvedVsPreviousMonth,
    );
  }
}