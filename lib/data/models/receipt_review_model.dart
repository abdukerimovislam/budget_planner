import 'expense_category.dart';

class ReceiptReviewModel {
  final double? amount;
  final String currency;
  final String merchant;
  final ExpenseCategory category;
  final DateTime? receiptDate;
  final String rawText;

  const ReceiptReviewModel({
    required this.amount,
    required this.currency,
    required this.merchant,
    required this.category,
    required this.receiptDate,
    required this.rawText,
  });

  ReceiptReviewModel copyWith({
    double? amount,
    String? currency,
    String? merchant,
    ExpenseCategory? category,
    DateTime? receiptDate,
    String? rawText,
  }) {
    return ReceiptReviewModel(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      receiptDate: receiptDate ?? this.receiptDate,
      rawText: rawText ?? this.rawText,
    );
  }
}