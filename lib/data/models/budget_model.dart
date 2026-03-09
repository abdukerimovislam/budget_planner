import 'expense_category.dart';

class BudgetModel {
  final String monthKey; // 2026-03
  final double totalBudget;
  final Map<ExpenseCategory, double> categoryBudgets;

  const BudgetModel({
    required this.monthKey,
    required this.totalBudget,
    required this.categoryBudgets,
  });
}