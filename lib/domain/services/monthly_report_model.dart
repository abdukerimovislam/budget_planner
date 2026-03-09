import '../../data/models/expense_category.dart';
import 'financial_level.dart';

class MonthlyReportModel {
  final double totalIncome;
  final double totalSpent;
  final double totalSaved;
  final double savingsRate;
  final ExpenseCategory? topCategory;
  final double topCategoryAmount;
  final Duration lifeSpent;
  final int healthScore;
  final FinancialLevel level;

  const MonthlyReportModel({
    required this.totalIncome,
    required this.totalSpent,
    required this.totalSaved,
    required this.savingsRate,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.lifeSpent,
    required this.healthScore,
    required this.level,
  });
}