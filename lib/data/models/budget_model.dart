import 'package:isar/isar.dart';

import 'expense_category.dart';

// Файл будет сгенерирован автоматически
part 'budget_model.g.dart';

@collection
class BudgetModel {
  Id isarId = Isar.autoIncrement;

  // Индексируем по месяцу (например, "2026-03") для мгновенного поиска
  @Index(unique: true, replace: true)
  final String monthKey;

  final double totalBudget;
  final String currency;

  // Сделали их nullable (?), чтобы Isar не ругался на несовпадение типов
  List<String>? isarCategoryKeys;
  List<double>? isarCategoryValues;

  // @ignore говорит базе данных не пытаться сохранить эту переменную
  @ignore
  late final Map<ExpenseCategory, double> categoryBudgets;

  BudgetModel({
    required this.monthKey,
    required this.totalBudget,
    required this.currency,
    Map<ExpenseCategory, double>? categoryBudgets,
    this.isarCategoryKeys,
    this.isarCategoryValues,
  }) {
    // Если мы создаем объект в приложении (передаем categoryBudgets)
    if (categoryBudgets != null) {
      this.categoryBudgets = categoryBudgets;
      isarCategoryKeys = categoryBudgets.keys.map((e) => e.name).toList();
      isarCategoryValues = categoryBudgets.values.toList();
    } else {
      // Если Isar достает объект из базы данных
      this.categoryBudgets = {};
      final keys = isarCategoryKeys ?? [];
      final values = isarCategoryValues ?? [];

      for (int i = 0; i < keys.length; i++) {
        if (i < values.length) {
          try {
            final cat = ExpenseCategory.values.byName(keys[i]);
            this.categoryBudgets[cat] = values[i];
          } catch (_) {}
        }
      }
    }
  }
}