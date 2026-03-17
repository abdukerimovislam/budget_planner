import 'package:isar/isar.dart';

// Этот файл сгенерирует Isar
part 'recurring_bill_model.g.dart';

@collection
class RecurringBillModel {
  // Внутренний быстрый ID для базы данных Isar
  Id isarId = Isar.autoIncrement;

  // Твой строковый UUID. Индекс ускоряет поиск, unique не дает создать дубликаты
  @Index(unique: true, replace: true)
  final String id;

  final String title;
  final double amount;
  final String currency;
  final int dayOfMonth;
  final bool isActive;
  final DateTime createdAt;

  RecurringBillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.dayOfMonth,
    required this.isActive,
    required this.createdAt,
  });

  RecurringBillModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? currency,
    int? dayOfMonth,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringBillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}