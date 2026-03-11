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

// Найди класс ExpenseModelSerializer и обнови его так:
class ExpenseModelSerializer {
  static Map<String, dynamic> toMap(ExpenseModel model) {
    return {
      'id': model.id,
      'amount': model.amount,
      'currency': model.currency,
      'category': model.category.name,
      'customCategoryId': model.customCategoryId, // <-- ДОБАВЛЕНО
      'merchant': model.merchant,
      'note': model.note,
      'date': model.date.toIso8601String(),
      'sourceType': model.sourceType.name,
      'isRecurring': model.isRecurring,
      'recurringGroupId': model.recurringGroupId,
      'createdAt': model.createdAt.toIso8601String(),
    };
  }

  static ExpenseModel fromMap(Map map) {
    return ExpenseModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      category: ExpenseCategory.values.firstWhere(
            (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.other, // Fallback
      ),
      customCategoryId: map['customCategoryId'] as String?, // <-- ДОБАВЛЕНО
      merchant: map['merchant'] as String,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      sourceType: ExpenseSourceType.values.firstWhere(
            (e) => e.name == map['sourceType'],
        orElse: () => ExpenseSourceType.smartText,
      ),
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurringGroupId: map['recurringGroupId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
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