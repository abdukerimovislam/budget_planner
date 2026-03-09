import '../../data/models/expense_category.dart';
import 'financial_level.dart';

class ShareCardModel {
  final double income;
  final double spent;
  final double saved;
  final int healthScore;
  final FinancialLevel level;
  final ExpenseCategory? topCategory;
  final String lifeSpentText;

  const ShareCardModel({
    required this.income,
    required this.spent,
    required this.saved,
    required this.healthScore,
    required this.level,
    required this.topCategory,
    required this.lifeSpentText,
  });
}