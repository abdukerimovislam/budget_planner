import 'package:isar/isar.dart';

import 'expense_category.dart';
import 'expense_source_type.dart';

// Этот файл будет сгенерирован автоматически на следующем шаге
part 'expense_model.g.dart';

@collection
class ExpenseModel {
  // Внутренний быстрый ID для базы данных Isar
  Id isarId = Isar.autoIncrement;

  // Твой строковый UUID. Индекс ускоряет поиск, unique не дает создать дубликаты
  @Index(unique: true, replace: true)
  final String id;

  final double amount;
  final String currency;

  @Enumerated(EnumType.name)
  final ExpenseCategory category;

  final String? customCategoryId;
  final String merchant;
  final String? note;
  final DateTime date;

  @Enumerated(EnumType.name)
  final ExpenseSourceType sourceType;

  final bool isRecurring;
  final String? recurringGroupId;
  final DateTime createdAt;
  final bool isIncome;

  ExpenseModel({
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
    bool clearCustomCategory = false,
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