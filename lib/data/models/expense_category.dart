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
}

extension ExpenseCategoryX on ExpenseCategory {
  String get key => name;
}