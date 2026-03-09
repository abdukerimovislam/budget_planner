import '../../data/models/expense_category.dart';

class MonthCloseSummaryModel {
  final double totalIncome;
  final double totalSpent;
  final double totalSaved;
  final double previousMonthSpent;
  final double spendingChangePercent;
  final ExpenseCategory? topCategory;
  final double topCategoryAmount;
  final int healthScore;
  final int previousHealthScore;
  final int healthScoreDelta;
  final Duration lifeSpent;
  final bool improvedVsPreviousMonth;

  const MonthCloseSummaryModel({
    required this.totalIncome,
    required this.totalSpent,
    required this.totalSaved,
    required this.previousMonthSpent,
    required this.spendingChangePercent,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.healthScore,
    required this.previousHealthScore,
    required this.healthScoreDelta,
    required this.lifeSpent,
    required this.improvedVsPreviousMonth,
  });
}