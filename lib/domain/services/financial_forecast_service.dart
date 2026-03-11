import '../../data/models/expense_model.dart';
import '../../data/models/forecast_result_model.dart';

class FinancialForecastService {
  ForecastResultModel calculate({
    required List<ExpenseModel> expenses,
    required DateTime now,
    required double monthlyBudget,
  }) {
    // ИСПРАВЛЕНИЕ: Архитектурный щит. Игнорируем доходы на уровне домена!
    final currentMonthExpenses = expenses.where(
          (e) => e.date.year == now.year && e.date.month == now.month && !e.isIncome,
    );

    final spent = currentMonthExpenses.fold<double>(
      0,
          (sum, e) => sum + e.amount,
    );

    final daysPassed = now.day.clamp(1, 31);
    final totalDays = DateTime(now.year, now.month + 1, 0).day;

    final avgDailySpend = spent / daysPassed;
    final predictedMonthSpend = avgDailySpend * totalDays;
    final expectedRemaining = monthlyBudget - predictedMonthSpend;

    return ForecastResultModel(
      avgDailySpend: avgDailySpend,
      predictedMonthSpend: predictedMonthSpend,
      expectedRemaining: expectedRemaining,
      isOverBudget: expectedRemaining < 0,
    );
  }
}