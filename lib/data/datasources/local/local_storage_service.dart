import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/storage_keys.dart';
import '../../models/budget_model.dart';
import '../../models/expense_model.dart';
import '../../models/income_profile_model.dart';
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
    final data = expenses.map((e) => e.toMap()).toList();
    await _box.put(StorageKeys.expenses, data);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}