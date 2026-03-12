import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/storage_keys.dart';
import '../../models/budget_model.dart';
import '../../models/expense_model.dart';
import '../../models/income_profile_model.dart';
import '../../models/custom_category_model.dart';
import '../../models/saving_goal_model.dart'; // <-- ИМПОРТ ЦЕЛЕЙ
import '../../models/recurring_bill_model.dart'; // <-- ИМПОРТ ПОДПИСОК
import '../../models/model_serializers.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  Box<dynamic> get _box => Hive.box<dynamic>(StorageKeys.appBox);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(StorageKeys.appBox);
  }

  bool getOnboardingCompleted() {
    return _box.get(StorageKeys.onboardingCompleted, defaultValue: false) as bool;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _box.put(StorageKeys.onboardingCompleted, value);
  }

  String? getLocaleCode() {
    return _box.get(StorageKeys.localeCode) as String?;
  }

  Future<void> setLocaleCode(String? code) async {
    if (code == null || code.isEmpty) {
      await _box.delete(StorageKeys.localeCode);
      return;
    }
    await _box.put(StorageKeys.localeCode, code);
  }

  IncomeProfileModel? getIncomeProfile() {
    final map = _box.get(StorageKeys.incomeProfile);
    if (map is Map) {
      return IncomeProfileModelSerializer.fromMap(map);
    }
    return null;
  }

  Future<void> saveIncomeProfile(IncomeProfileModel profile) async {
    await _box.put(StorageKeys.incomeProfile, profile.toMap());
  }

  BudgetModel? getBudget() {
    final map = _box.get(StorageKeys.budget);
    if (map is Map) {
      return BudgetModelSerializer.fromMap(map);
    }
    return null;
  }

  Future<void> saveBudget(BudgetModel budget) async {
    await _box.put(StorageKeys.budget, budget.toMap());
  }

  List<ExpenseModel> getExpenses() {
    final rawList = _box.get(StorageKeys.expenses, defaultValue: <dynamic>[]) as List<dynamic>;
    return rawList
        .whereType<Map>()
        .map(ExpenseModelSerializer.fromMap)
        .toList();
  }

  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    final data = expenses.map((e) => ExpenseModelSerializer.toMap(e)).toList();
    await _box.put(StorageKeys.expenses, data);
  }

  List<CustomCategoryModel> getCustomCategories() {
    final rawList = _box.get(StorageKeys.customCategories, defaultValue: <dynamic>[]) as List<dynamic>;
    return rawList
        .whereType<Map>()
        .map((map) => CustomCategoryModel.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> saveCustomCategories(List<CustomCategoryModel> categories) async {
    final data = categories.map((c) => c.toMap()).toList();
    await _box.put(StorageKeys.customCategories, data);
  }

  // --- НОВЫЕ МЕТОДЫ: ЦЕЛИ ---
  SavingsGoalModel? getSavingsGoal() {
    final map = _box.get('savingsGoal'); // Ключ напрямую, так как мы не добавляли его в StorageKeys
    if (map is Map) {
      return SavingsGoalModelSerializer.fromMap(map);
    }
    return null;
  }

  Future<void> saveSavingsGoal(SavingsGoalModel goal) async {
    await _box.put('savingsGoal', goal.toMap());
  }

  Future<void> deleteSavingsGoal() async {
    await _box.delete('savingsGoal');
  }

  // --- НОВЫЕ МЕТОДЫ: ПОДПИСКИ ---
  List<RecurringBillModel> getRecurringBills() {
    final rawList = _box.get('recurringBills', defaultValue: <dynamic>[]) as List<dynamic>;
    return rawList
        .whereType<Map>()
        .map(RecurringBillModelSerializer.fromMap)
        .toList();
  }

  Future<void> saveRecurringBills(List<RecurringBillModel> bills) async {
    final data = bills.map((b) => b.toMap()).toList();
    await _box.put('recurringBills', data);
  }

  // --- ДЕНЬ ЗАРПЛАТЫ ---
  int? getSalaryDay() {
    return _box.get('salaryDay') as int?;
  }

  Future<void> saveSalaryDay(int day) async {
    await _box.put('salaryDay', day);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}