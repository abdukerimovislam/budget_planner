import '/data/models/expense_model.dart';
import 'forecast_result.dart';

class FinancialForecastService {
  ForecastResult calculate({
    required List<ExpenseModel> expenses,
    required DateTime now,
    required double monthlyBudget,
  }) {
    final currentMonthExpenses = expenses.where(
          (e) => e.date.year == now.year && e.date.month == now.month,
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

    return ForecastResult(
      avgDailySpend: avgDailySpend,
      predictedMonthSpend: predictedMonthSpend,
      expectedRemaining: expectedRemaining,
      isOverBudget: expectedRemaining < 0,
    );
  }
}