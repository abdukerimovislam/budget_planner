import 'expense_category.dart';
import 'expense_source_type.dart';

class ExpenseModel {
  final String id;
  final double amount;
  final String currency;
  final ExpenseCategory category;
  final String? customCategoryId;
  final String merchant;
  final String? note;
  final DateTime date;
  final ExpenseSourceType sourceType;
  final bool isRecurring;
  final String? recurringGroupId;
  final DateTime createdAt;
  final bool isIncome;

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.category,
    this.customCategoryId,
    required this.merchant,
    required this.note,
    required this.date,
    required this.sourceType,
    required this.isRecurring,
    required this.recurringGroupId,
    required this.createdAt,
    this.isIncome = false,
  });

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? currency,
    ExpenseCategory? category,
    String? customCategoryId,
    bool clearCustomCategory = false, // ИСПРАВЛЕНИЕ БАГА №1: Флаг принудительной очистки
    String? merchant,
    String? note,
    DateTime? date,
    ExpenseSourceType? sourceType,
    bool? isRecurring,
    String? recurringGroupId,
    DateTime? createdAt,
    bool? isIncome,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      // Если просят очистить - ставим null, иначе берем новое значение или старое
      customCategoryId: clearCustomCategory ? null : (customCategoryId ?? this.customCategoryId),
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      date: date ?? this.date,
      sourceType: sourceType ?? this.sourceType,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringGroupId: recurringGroupId ?? this.recurringGroupId,
      createdAt: createdAt ?? this.createdAt,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}