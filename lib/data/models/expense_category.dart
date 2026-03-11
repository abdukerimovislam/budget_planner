enum ExpenseCategory {
  food,
  transport,
  subscriptions,
  entertainment,
  shopping,
  health,
  bills,
  education,
  gifts,
  travel,
  other,
  custom, // <-- ДОБАВЛЕНО: Флаг для пользовательской категории
}

extension ExpenseCategoryX on ExpenseCategory {
  String get key => name;
}