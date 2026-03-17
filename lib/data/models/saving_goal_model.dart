import 'package:isar/isar.dart';

// Этот файл сгенерирует Isar
part 'saving_goal_model.g.dart';

@collection
class SavingsGoalModel {
  // Внутренний быстрый ID для базы данных Isar
  Id isarId = Isar.autoIncrement;

  // Твой строковый UUID. Индекс ускоряет поиск, unique не дает создать дубликаты
  @Index(unique: true, replace: true)
  final String id;

  final String title;
  final double targetAmount;
  final double currentAmount;
  final String currency; // ИСПРАВЛЕНИЕ БАГА №4: Валюта цели
  final DateTime? targetDate;
  final DateTime createdAt;

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.targetDate,
    required this.createdAt,
  });

  SavingsGoalModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? targetDate,
    DateTime? createdAt,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}