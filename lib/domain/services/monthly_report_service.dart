import 'dart:math'; // Для функции max()
import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_profile_model.dart';
import 'financial_level_service.dart';
import 'monthly_report_model.dart';

class MonthlyReportService {
  final FinancialLevelService _levelService = FinancialLevelService();

  MonthlyReportModel generate({
    required List<ExpenseModel> monthTransactions, // <-- Переименовано для ясности
    required IncomeProfileModel? incomeProfile,
    required double budget,
    required int healthScore,
    required Duration lifeSpent,
    required Map<ExpenseCategory, double> categoryTotals,
  }) {
    // ИСПРАВЛЕНИЕ: Считаем реальный заработок и реальные траты
    final actualIncome = monthTransactions.where((e) => e.isIncome).fold<double>(0.0, (sum, e) => sum + e.amount);
    final spent = monthTransactions.where((e) => !e.isIncome).fold<double>(0.0, (sum, e) => sum + e.amount);

    // Для отчета берем максимум между тем, что ожидали, и тем, что реально пришло (чтобы в начале месяца отчет не был нулевым)
    final expectedIncome = incomeProfile?.expectedMonthlyIncome ?? 0.0;
    final incomeToUse = max(expectedIncome, actualIncome);

    final saved = (incomeToUse - spent).clamp(0, double.infinity).toDouble();
    final savingsRate = incomeToUse > 0 ? saved / incomeToUse : 0.0;

    ExpenseCategory? topCategory;
    double topCategoryAmount = 0;

    if (categoryTotals.isNotEmpty) {
      final sorted = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sorted.first.key;
      topCategoryAmount = sorted.first.value;
    }

    final level = _levelService.resolve(
      healthScore: healthScore,
      savingsRate: savingsRate,
      isOverBudget: budget > 0 ? spent > budget : false,
    );

    return MonthlyReportModel(
      totalIncome: incomeToUse, // <-- Теперь тут точная цифра!
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