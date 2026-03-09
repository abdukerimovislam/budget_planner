enum CashflowEventType {
  income,
  bill,
  plannedExpense,
}

class CashflowEventModel {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final DateTime date;
  final CashflowEventType type;

  const CashflowEventModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
    required this.type,
  });
}