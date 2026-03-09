import 'budget_model.dart';
import 'expense_category.dart';
import 'expense_model.dart';
import 'expense_source_type.dart';
import 'income_profile_model.dart';

extension ExpenseCategorySerializer on ExpenseCategory {
  String get storageValue => name;

  static ExpenseCategory fromStorage(String value) {
    return ExpenseCategory.values.firstWhere(
          (item) => item.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}

extension ExpenseSourceTypeSerializer on ExpenseSourceType {
  String get storageValue => name;

  static ExpenseSourceType fromStorage(String value) {
    return ExpenseSourceType.values.firstWhere(
          (item) => item.name == value,
      orElse: () => ExpenseSourceType.manual,
    );
  }
}

extension ExpenseModelSerializer on ExpenseModel {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'category': category.storageValue,
      'merchant': merchant,
      'note': note,
      'date': date.toIso8601String(),
      'sourceType': sourceType.storageValue,
      'isRecurring': isRecurring,
      'recurringGroupId': recurringGroupId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ExpenseModel fromMap(Map<dynamic, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      category: ExpenseCategorySerializer.fromStorage(
        map['category'] as String? ?? 'other',
      ),
      merchant: map['merchant'] as String? ?? '',
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      sourceType: ExpenseSourceTypeSerializer.fromStorage(
        map['sourceType'] as String? ?? 'manual',
      ),
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurringGroupId: map['recurringGroupId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

extension IncomeProfileModelSerializer on IncomeProfileModel {
  Map<String, dynamic> toMap() {
    return {
      'monthlyIncome': monthlyIncome,
      'workingDaysPerMonth': workingDaysPerMonth,
      'workingHoursPerDay': workingHoursPerDay,
    };
  }

  static IncomeProfileModel fromMap(Map<dynamic, dynamic> map) {
    return IncomeProfileModel(
      monthlyIncome: (map['monthlyIncome'] as num).toDouble(),
      workingDaysPerMonth: map['workingDaysPerMonth'] as int,
      workingHoursPerDay: (map['workingHoursPerDay'] as num).toDouble(),
    );
  }
}

extension BudgetModelSerializer on BudgetModel {
  Map<String, dynamic> toMap() {
    return {
      'monthKey': monthKey,
      'totalBudget': totalBudget,
      'categoryBudgets': categoryBudgets.map(
            (key, value) => MapEntry(key.storageValue, value),
      ),
    };
  }

  static BudgetModel fromMap(Map<dynamic, dynamic> map) {
    final rawCategoryBudgets =
        (map['categoryBudgets'] as Map?)?.cast<dynamic, dynamic>() ?? {};

    return BudgetModel(
      monthKey: map['monthKey'] as String,
      totalBudget: (map['totalBudget'] as num).toDouble(),
      categoryBudgets: rawCategoryBudgets.map(
            (key, value) => MapEntry(
          ExpenseCategorySerializer.fromStorage(key as String),
          (value as num).toDouble(),
        ),
      ),
    );
  }
}