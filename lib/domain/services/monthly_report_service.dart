import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_profile_model.dart';
import 'financial_level_service.dart';
import 'monthly_report_model.dart';

class MonthlyReportService {
  final FinancialLevelService _levelService = FinancialLevelService();

  MonthlyReportModel generate({
    required List<ExpenseModel> monthExpenses,
    required IncomeProfileModel? incomeProfile,
    required double budget,
    required int healthScore,
    required Duration lifeSpent,
    required Map<ExpenseCategory, double> categoryTotals,
  }) {
    final income = incomeProfile?.monthlyIncome ?? 0.0;

    final spent = monthExpenses.fold<double>(
      0.0,
          (sum, e) => sum + e.amount,
    );

    final saved = (income - spent).clamp(0, double.infinity).toDouble();

    final savingsRate = income > 0 ? saved / income : 0.0;

    ExpenseCategory? topCategory;
    double topCategoryAmount = 0;

    if (categoryTotals.isNotEmpty) {
      final sorted = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sorted.first.key;
      topCategoryAmount = sorted.first.value;
    }

    final level = _levelService.resolve(
      healthScore: healthScore,
      savingsRate: savingsRate,
      isOverBudget: budget > 0 ? spent > budget : false,
    );

    return MonthlyReportModel(
      totalIncome: income,
      totalSpent: spent,
      totalSaved: saved,
      savingsRate: savingsRate,
      topCategory: topCategory,
      topCategoryAmount: topCategoryAmount,
      lifeSpent: lifeSpent,
      healthScore: healthScore,
      level: level,
    );
  }
}