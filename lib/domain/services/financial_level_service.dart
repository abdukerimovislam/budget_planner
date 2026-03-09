import 'financial_level.dart';

class FinancialLevelService {
  FinancialLevel resolve({
    required int healthScore,
    required double savingsRate,
    required bool isOverBudget,
  }) {
    if (isOverBudget || healthScore < 40 || savingsRate < 0.05) {
      return FinancialLevel.survivor;
    }

    if (healthScore < 60 || savingsRate < 0.10) {
      return FinancialLevel.planner;
    }

    if (healthScore < 80 || savingsRate < 0.20) {
      return FinancialLevel.strategist;
    }

    return FinancialLevel.investor;
  }
}