import '/data/models/expense_category.dart';

class ParsedExpenseInput {
  final double? amount;
  final String? currency;
  final ExpenseCategory? category;
  final String? merchant;
  final String rawText;

  const ParsedExpenseInput({
    required this.amount,
    required this.currency,
    required this.category,
    required this.merchant,
    required this.rawText,
  });

  bool get isValid => amount != null && amount! > 0;
}