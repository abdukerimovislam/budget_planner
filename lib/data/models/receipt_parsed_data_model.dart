import 'package:budget_planner/data/models/receipt_candidate_amount_view.dart';

import 'expense_category.dart';
import 'receipt_field_confidence_model.dart';

class ReceiptParsedDataModel {
  final double? amount;
  final List<ReceiptCandidateAmountModel> amountCandidates;
  final String? currency;
  final String? merchant;
  final DateTime? receiptDate;
  final ExpenseCategory? category;
  final double confidence;
  final ReceiptFieldConfidenceModel fieldConfidence;
  final String rawText;

  const ReceiptParsedDataModel({
    required this.amount,
    required this.amountCandidates,
    required this.currency,
    required this.merchant,
    required this.receiptDate,
    required this.category,
    required this.confidence,
    required this.fieldConfidence,
    required this.rawText,
  });

  bool get hasEnoughData => amount != null && amount! > 0;
}