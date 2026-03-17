import 'package:flutter/material.dart';
import '../../data/datasources/local/local_storage_service.dart';
import '../../data/datasources/local/isar_database_service.dart'; // <-- ИМПОРТ ISAR
import '../../data/models/custom_category_model.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/income_profile_model.dart';
import '../../domain/services/premium_access_service.dart';
import '../../domain/services/premium_feature.dart';

class SettingsProvider extends ChangeNotifier {
  final PremiumAccessService premiumAccessService;

  IncomeProfileModel? _incomeProfile;
  bool _isPremium = false;
  int? _salaryDay;
  String? _activeCurrency;
  List<String> _cachedCurrencies = [];
  final List<CustomCategoryModel> _customCategories = [];

  bool _isInitialized = false;

  SettingsProvider({required this.premiumAccessService});

  IncomeProfileModel? get incomeProfile => _incomeProfile;
  bool get isPremium => _isPremium;
  int? get salaryDay => _salaryDay;
  String get activeCurrency => _activeCurrency ?? _incomeProfile?.currency ?? 'USD';
  List<String> get availableUserCurrencies => List.unmodifiable(_cachedCurrencies);
  List<CustomCategoryModel> get customCategories => List.unmodifiable(_customCategories);
  bool get isInitialized => _isInitialized;

  Future<void> load() async {
    // Простые настройки грузим из SharedPrefs / JSON
    _incomeProfile = LocalStorageService.instance.getIncomeProfile();
    _salaryDay = LocalStorageService.instance.getSalaryDay();

    // Списки грузим из сверхбыстрой БД Isar
    final loadedCategories = await IsarDatabaseService.instance.getAllCustomCategories();
    _customCategories.clear();
    _customCategories.addAll(loadedCategories);

    final lastCurrency = LocalStorageService.instance.getLastActiveCurrency();
    _activeCurrency = lastCurrency ?? _incomeProfile?.currency ?? 'USD';

    _isInitialized = true;
    notifyListeners();
  }

  void updateCurrencyCache(List<String> usedCurrencies) {
    final set = <String>{_incomeProfile?.currency ?? 'USD'};
    if (_activeCurrency != null) set.add(_activeCurrency!);
    set.addAll(usedCurrencies);

    final list = set.toList();
    list.sort();

    // Обновляем только если список реально изменился, чтобы избежать лишних ререндеров
    if (_cachedCurrencies.join(',') != list.join(',')) {
      _cachedCurrencies = list;
      notifyListeners();
    }
  }

  void setActiveCurrency(String currency) {
    _activeCurrency = currency;
    LocalStorageService.instance.setLastActiveCurrency(currency);
    notifyListeners();
  }

  Future<void> setIncomeProfile(IncomeProfileModel profile) async {
    _incomeProfile = profile;
    await LocalStorageService.instance.saveIncomeProfile(profile);
    _activeCurrency = profile.currency;
    notifyListeners();
  }

  Future<void> setSalaryDay(int day) async {
    _salaryDay = day;
    await LocalStorageService.instance.saveSalaryDay(day);
    notifyListeners();
  }

  Future<void> setPremium(bool value) async {
    _isPremium = value;
    notifyListeners();
  }

  bool canUseFeature(PremiumFeature feature, {int activeGoalsCount = 0}) {
    return premiumAccessService.canUse(
      isPremium: _isPremium,
      feature: feature,
      activeGoalsCount: activeGoalsCount,
    );
  }

  // --- КАСТОМНЫЕ КАТЕГОРИИ (ISAR) ---

  Future<void> addCustomCategory(CustomCategoryModel category) async {
    await IsarDatabaseService.instance.saveCustomCategory(category);
    await load();
  }

  Future<void> deleteCustomCategory(String id) async {
    await IsarDatabaseService.instance.deleteCustomCategory(id);
    await load();
  }
}