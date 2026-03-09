import 'expense_category.dart';

enum ExpenseSortOption {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount,
}

class ExpenseFilterModel {
  final String query;
  final ExpenseCategory? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final ExpenseSortOption sortOption;

  const ExpenseFilterModel({
    this.query = '',
    this.category,
    this.startDate,
    this.endDate,
    this.sortOption = ExpenseSortOption.newestFirst,
  });

  ExpenseFilterModel copyWith({
    String? query,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    ExpenseSortOption? sortOption,
    bool clearCategory = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return ExpenseFilterModel(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      sortOption: sortOption ?? this.sortOption,
    );
  }

  static const ExpenseFilterModel initial = ExpenseFilterModel();
}