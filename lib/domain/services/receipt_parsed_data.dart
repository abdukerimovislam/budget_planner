import 'package:budget_planner/domain/services/reciept_candidate_amount.dart';
import 'package:budget_planner/domain/services/reciept_field_confidence.dart';

import '../../data/models/expense_category.dart';

class ReceiptParsedData {
  final double? amount;
  final List<ReceiptCandidateAmount> amountCandidates;
  final String? currency;
  final String? merchant;
  final DateTime? receiptDate;
  final ExpenseCategory? category;
  final double confidence;
  final ReceiptFieldConfidence fieldConfidence;
  final String rawText;

  const ReceiptParsedData({
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