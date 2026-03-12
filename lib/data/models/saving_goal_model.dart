class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String currency; // ИСПРАВЛЕНИЕ БАГА №4: Валюта цели
  final DateTime? targetDate;
  final DateTime createdAt;

  const SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency, // <-- ДОБАВЛЕНО
    required this.targetDate,
    required this.createdAt,
  });

  SavingsGoalModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? currency, // <-- ДОБАВЛЕНО
    DateTime? targetDate,
    DateTime? createdAt,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency, // <-- ДОБАВЛЕНО
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}