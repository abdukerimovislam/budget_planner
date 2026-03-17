import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Импортируем все наши модели
import '../../models/budget_model.dart';
import '../../models/custom_category_model.dart';
import '../../models/debt_model.dart';
import '../../models/expense_model.dart';
import '../../models/recurring_bill_model.dart';
import '../../models/saving_goal_model.dart';

class IsarDatabaseService {
  // Реализуем паттерн Singleton, чтобы база была одна на всё приложение
  static final IsarDatabaseService _instance = IsarDatabaseService._internal();
  static IsarDatabaseService get instance => _instance;
  IsarDatabaseService._internal();

  late Isar isar;

  // Инициализация базы данных
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        ExpenseModelSchema,
        BudgetModelSchema,
        DebtModelSchema,
        RecurringBillModelSchema,
        SavingsGoalModelSchema,
        CustomCategoryModelSchema,
      ],
      directory: dir.path,
    );
  }

  // === ТРАНЗАКЦИИ (EXPENSES) ===
  Future<List<ExpenseModel>> getAllExpenses() async {
    return await isar.expenseModels.where().findAll();
  }

  Future<void> saveExpense(ExpenseModel expense) async {
    await isar.writeTxn(() async => await isar.expenseModels.put(expense));
  }

  Future<void> deleteExpense(String id) async {
    await isar.writeTxn(() async {
      await isar.expenseModels.filter().idEqualTo(id).deleteAll();
    });
  }

  // === БЮДЖЕТЫ (BUDGETS) ===
  Future<List<BudgetModel>> getAllBudgets() async {
    return await isar.budgetModels.where().findAll();
  }

  Future<void> saveBudget(BudgetModel budget) async {
    await isar.writeTxn(() async => await isar.budgetModels.put(budget));
  }

  // === ДОЛГИ (DEBTS) ===
  Future<List<DebtModel>> getAllDebts() async {
    return await isar.debtModels.where().findAll();
  }

  Future<void> saveDebt(DebtModel debt) async {
    await isar.writeTxn(() async => await isar.debtModels.put(debt));
  }

  Future<void> deleteDebt(String id) async {
    await isar.writeTxn(() async {
      await isar.debtModels.filter().idEqualTo(id).deleteAll();
    });
  }

  // === РЕГУЛЯРНЫЕ ПЛАТЕЖИ (RECURRING BILLS) ===
  Future<List<RecurringBillModel>> getAllRecurringBills() async {
    return await isar.recurringBillModels.where().findAll();
  }

  Future<void> saveRecurringBill(RecurringBillModel bill) async {
    await isar.writeTxn(() async => await isar.recurringBillModels.put(bill));
  }

  Future<void> deleteRecurringBill(String id) async {
    await isar.writeTxn(() async {
      await isar.recurringBillModels.filter().idEqualTo(id).deleteAll();
    });
  }

  // === ФИНАНСОВЫЕ ЦЕЛИ (SAVINGS GOALS) ===
  Future<List<SavingsGoalModel>> getAllSavingsGoals() async {
    return await isar.savingsGoalModels.where().findAll();
  }

  Future<void> saveSavingsGoal(SavingsGoalModel goal) async {
    await isar.writeTxn(() async => await isar.savingsGoalModels.put(goal));
  }

  Future<void> deleteSavingsGoal(String id) async {
    await isar.writeTxn(() async {
      await isar.savingsGoalModels.filter().idEqualTo(id).deleteAll();
    });
  }

  // === СВОИ КАТЕГОРИИ (CUSTOM CATEGORIES) ===
  Future<List<CustomCategoryModel>> getAllCustomCategories() async {
    return await isar.customCategoryModels.where().findAll();
  }

  Future<void> saveCustomCategory(CustomCategoryModel category) async {
    await isar.writeTxn(() async => await isar.customCategoryModels.put(category));
  }

  Future<void> deleteCustomCategory(String id) async {
    await isar.writeTxn(() async {
      await isar.customCategoryModels.filter().idEqualTo(id).deleteAll();
    });
  }

  // === ОЧИСТКА ДАННЫХ ===
  Future<void> clearAll() async {
    await isar.writeTxn(() async => await isar.clear());
  }
}