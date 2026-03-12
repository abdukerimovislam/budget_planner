import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/utils/month_key.dart';
import '../../data/datasources/local/local_storage_service.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/action_plan_item_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/cashflow_event_model.dart';
import '../../data/models/custom_category_model.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/expense_filter_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/forecast_result_model.dart';
import '../../data/models/income_profile_model.dart';
import '../../data/models/insight_model.dart';
import '../../data/models/month_close_summary_model.dart';
import '../../data/models/recurring_bill_model.dart';
import '../../data/models/saving_goal_model.dart';
import '../../data/models/savings_goal_projection_model.dart';
import '../../data/models/subscription_candidate_model.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/action_plan_service.dart';
import '../../domain/services/auto_budget_service.dart';
import '../../domain/services/cashflow_timeline_service.dart';
import '../../domain/services/financial_forecast_service.dart';
import '../../domain/services/financial_health_score_service.dart';
import '../../domain/services/financial_insight_service.dart';
import '../../domain/services/life_value_service.dart';
import '../../domain/services/month_close_service.dart';
import '../../domain/services/monthly_report_model.dart';
import '../../domain/services/monthly_report_service.dart';
import '../../domain/services/premium_access_service.dart';
import '../../domain/services/premium_feature.dart';
import '../../domain/services/savings_goal_service.dart';
import '../../domain/services/streak_service.dart';
import '../../domain/services/streak_summary_model.dart';
import '../../domain/services/subscription_detector_service.dart';
import '../widgets/expense_edit_sheet.dart';

class HomeProvider extends ChangeNotifier {
  final FinancialForecastService forecastService;
  final FinancialHealthScoreService scoreService;
  final LifeValueService lifeValueService;

  final FinancialInsightService insightService = FinancialInsightService();
  final AutoBudgetService autoBudgetService = AutoBudgetService();
  final SubscriptionDetectorService subscriptionDetectorService = SubscriptionDetectorService();
  final MonthlyReportService monthlyReportService = MonthlyReportService();
  final SavingsGoalService savingsGoalService = SavingsGoalService();
  final CashflowTimelineService cashflowTimelineService = CashflowTimelineService();
  final ActionPlanService actionPlanService = ActionPlanService();
  final PremiumAccessService premiumAccessService = PremiumAccessService();
  final MonthCloseService monthCloseService = MonthCloseService();
  final StreakService streakService = StreakService();
  final AchievementService achievementService = AchievementService();

  HomeProvider({
    required this.forecastService,
    required this.scoreService,
    required this.lifeValueService,
  });

  final List<ExpenseModel> _expenses = [];
  final List<CustomCategoryModel> _customCategories = [];

  IncomeProfileModel? _incomeProfile;
  BudgetModel? _budget;
  bool _isInitialized = false;
  bool _isPremium = false;
  SavingsGoalModel? _savingsGoal;
  int? _salaryDay;
  final List<RecurringBillModel> _recurringBills = [];

  String? _activeCurrency;
  // ИСПРАВЛЕНИЕ БАГА №6 (FPS Drop): Кэшируем список валют
  List<String> _cachedCurrencies = [];

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  List<CustomCategoryModel> get customCategories => List.unmodifiable(_customCategories);

  IncomeProfileModel? get incomeProfile => _incomeProfile;
  BudgetModel? get budget => _budget;
  bool get isInitialized => _isInitialized;
  bool get isPremium => _isPremium;
  SavingsGoalModel? get savingsGoal => _savingsGoal;
  int? get salaryDay => _salaryDay;
  List<RecurringBillModel> get recurringBills => List.unmodifiable(_recurringBills);

  String get activeCurrency => _activeCurrency ?? _incomeProfile?.currency ?? 'USD';

  // Теперь возвращает мгновенно закэшированный список без лагов
  List<String> get availableUserCurrencies => List.unmodifiable(_cachedCurrencies);

  // Вспомогательный метод для обновления кэша валют
  void _updateCurrencyCache() {
    final set = <String>{_incomeProfile?.currency ?? 'USD'};
    for (final e in _expenses) {
      set.add(e.currency);
    }
    final list = set.toList();
    list.sort();
    _cachedCurrencies = list;
  }

  void setActiveCurrency(String currency) {
    _activeCurrency = currency;
    notifyListeners();
  }

  Future<void> load() async {
    _incomeProfile = LocalStorageService.instance.getIncomeProfile();
    _budget = LocalStorageService.instance.getBudget();

    _expenses.clear();
    final loadedExpenses = LocalStorageService.instance.getExpenses();
    loadedExpenses.sort((a, b) => b.date.compareTo(a.date));
    _expenses.addAll(loadedExpenses);

    _customCategories
      ..clear()
      ..addAll(LocalStorageService.instance.getCustomCategories());

    _activeCurrency = _incomeProfile?.currency ?? 'USD';
    _updateCurrencyCache(); // Инициализируем кэш

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setPremium(bool value) async {
    _isPremium = value;
    notifyListeners();
  }

  bool canUseFeature(PremiumFeature feature) {
    return premiumAccessService.canUse(
      isPremium: _isPremium,
      feature: feature,
      activeGoalsCount: _savingsGoal == null ? 0 : 1,
    );
  }

  Future<void> addCustomCategory(CustomCategoryModel category) async {
    _customCategories.add(category);
    await LocalStorageService.instance.saveCustomCategories(_customCategories);
    notifyListeners();
  }

  Future<void> deleteCustomCategory(String id) async {
    _customCategories.removeWhere((c) => c.id == id);
    await LocalStorageService.instance.saveCustomCategories(_customCategories);

    bool needsExpenseUpdate = false;
    for (int i = 0; i < _expenses.length; i++) {
      if (_expenses[i].customCategoryId == id) {
        // ИСПРАВЛЕНИЕ БАГА №1: Используем clearCustomCategory: true
        _expenses[i] = _expenses[i].copyWith(
          category: ExpenseCategory.other,
          clearCustomCategory: true,
        );
        needsExpenseUpdate = true;
      }
    }

    if (needsExpenseUpdate) {
      await LocalStorageService.instance.saveExpenses(_expenses);
    }
    notifyListeners();
  }

  CustomCategoryModel? getCustomCategoryById(String id) {
    try {
      return _customCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ExpenseModel> expensesForPreviousMonth(DateTime now) {
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    return expensesForMonth(previousMonth);
  }

  int previousMonthHealthScore(DateTime now) {
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final profile = _incomeProfile;
    final budget = _budget;

    if (profile == null || budget == null) return 0;

    // ИСПРАВЛЕНИЕ: Если валюта бюджета не совпадает с активной валютой, баллы не считаем (чтобы не было галлюцинаций)
    if (budget.currency != activeCurrency) return 0;

    final actualIncomePrevMonth = actualIncomeForMonth(previousMonth);
    final incomeToUse = max(profile.expectedMonthlyIncome, actualIncomePrevMonth);

    return scoreService.calculate(
      income: incomeToUse,
      totalSpent: totalSpentForMonth(previousMonth),
      totalBudget: budget.totalBudget,
      subscriptionsSpent: subscriptionsSpentForMonth(previousMonth),
      goalProgressRatio: 0.3,
    );
  }

  MonthCloseSummaryModel monthCloseSummary(DateTime now) {
    final currentExpensesOnly = expensesForMonth(now).where((e) => !e.isIncome).toList();
    final previousExpensesOnly = expensesForPreviousMonth(now).where((e) => !e.isIncome).toList();

    return monthCloseService.build(
      currentMonthExpenses: currentExpensesOnly,
      previousMonthExpenses: previousExpensesOnly,
      incomeProfile: _incomeProfile,
      healthScore: healthScoreFor(now),
      previousHealthScore: previousMonthHealthScore(now),
      lifeSpent: spentLifeDurationForMonth(now),
      currentCategoryTotals: categoryTotalsForMonth(now),
    );
  }

  StreakSummaryModel streakSummary() {
    return streakService.calculate(_expenses);
  }

  List<AchievementModel> achievements() {
    final streak = streakSummary();
    final goal = _savingsGoal;

    return achievementService.build(
      expenses: _expenses,
      streak: streak,
      hasGoal: goal != null,
      hasGoalProgress: goal != null && goal.currentAmount > 0,
      hasMonthCloseSignal: _expenses.isNotEmpty,
      hasNoOverspendMonth: (_budget?.totalBudget ?? 0) > 0 &&
          totalSpentThisMonth(DateTime.now()) <= (_budget?.totalBudget ?? 0),
    );
  }

  Future<void> setIncomeProfile(IncomeProfileModel profile) async {
    _incomeProfile = profile;
    await LocalStorageService.instance.saveIncomeProfile(profile);

    _activeCurrency = profile.currency;
    _updateCurrencyCache(); // Обновляем кэш
    notifyListeners();
  }

  Future<void> setBudget(BudgetModel budget) async {
    _budget = budget;
    await LocalStorageService.instance.saveBudget(budget);
    notifyListeners();
  }

  Future<void> updateMonthlyBudget(double amount, DateTime now) async {
    // ИСПРАВЛЕНИЕ БАГА №2: Сохраняем бюджет с привязкой к активной валюте
    final updated = BudgetModel(
      monthKey: buildMonthKey(now),
      totalBudget: amount,
      currency: activeCurrency,
      categoryBudgets: _budget?.categoryBudgets ?? const {},
    );
    _budget = updated;
    await LocalStorageService.instance.saveBudget(updated);
    notifyListeners();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    _expenses.insert(0, expense);
    await LocalStorageService.instance.saveExpenses(_expenses);
    _updateCurrencyCache(); // Обновляем кэш при добавлении новой транзакции
    notifyListeners();
  }

  Future<void> updateExpense(String expenseId, ExpenseEditResult result) async {
    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index == -1) return;

    final old = _expenses[index];

    _expenses[index] = old.copyWith(
      amount: result.amount,
      merchant: result.merchant,
      note: result.note.isEmpty ? null : result.note,
      category: result.category,
      date: result.date,
      isIncome: result.isIncome,
      currency: result.currency,
    );

    await LocalStorageService.instance.saveExpenses(_expenses);
    _updateCurrencyCache(); // Вдруг валюта поменялась
    notifyListeners();
  }

  Map<String, double> detailedCategoryTotalsForMonth(DateTime date) {
    final Map<String, double> totals = {};

    for (final expense in expensesForMonth(date).where((e) => !e.isIncome)) {
      String key;
      if (expense.category == ExpenseCategory.custom && expense.customCategoryId != null) {
        key = 'custom_${expense.customCategoryId}';
      } else {
        key = expense.category.name;
      }

      totals[key] = (totals[key] ?? 0) + expense.amount;
    }

    return totals;
  }

  Future<void> deleteExpense(String expenseId) async {
    _expenses.removeWhere((e) => e.id == expenseId);
    await LocalStorageService.instance.saveExpenses(_expenses);
    _updateCurrencyCache(); // Вдруг мы удалили последнюю транзакцию в этой валюте
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _expenses.clear();
    _customCategories.clear();
    _incomeProfile = null;
    _budget = null;
    _activeCurrency = null;
    _cachedCurrencies.clear();
    await LocalStorageService.instance.clearAll();
    notifyListeners();
  }

  Future<void> openExpenseEditor(
      BuildContext context,
      ExpenseModel expense,
      ) async {
    final result = await showModalBottomSheet<ExpenseEditResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExpenseEditSheet(expense: expense),
    );

    if (result == null) return;
    await updateExpense(expense.id, result);
  }

  List<ExpenseModel> expensesForMonth(DateTime date) {
    return _expenses.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.currency == activeCurrency;
    }).toList();
  }

  List<ExpenseModel> latestExpenses({int limit = 20}) {
    final sorted = List<ExpenseModel>.from(_expenses.where((e) => e.currency == activeCurrency))
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  List<ExpenseModel> filteredExpenses(ExpenseFilterModel filter) {
    // В истории транзакций теперь показываем только активную валюту
    var list = List<ExpenseModel>.from(_expenses.where((e) => e.currency == activeCurrency));

    final query = filter.query.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((expense) {
        final merchant = expense.merchant.toLowerCase();
        final note = (expense.note ?? '').toLowerCase();
        return merchant.contains(query) || note.contains(query);
      }).toList();
    }

    if (filter.category != null) {
      list = list.where((e) => e.category == filter.category).toList();
    }

    if (filter.startDate != null) {
      list = list
          .where(
            (e) => !e.date.isBefore(
          DateTime(
            filter.startDate!.year,
            filter.startDate!.month,
            filter.startDate!.day,
          ),
        ),
      )
          .toList();
    }

    if (filter.endDate != null) {
      final inclusiveEnd = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
      );

      list = list.where((e) => !e.date.isAfter(inclusiveEnd)).toList();
    }

    switch (filter.sortOption) {
      case ExpenseSortOption.newestFirst:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case ExpenseSortOption.oldestFirst:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case ExpenseSortOption.highestAmount:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case ExpenseSortOption.lowestAmount:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return list;
  }

  double totalSpentForMonth(DateTime date) {
    return expensesForMonth(date)
        .where((e) => !e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  double actualIncomeForMonth(DateTime date) {
    return expensesForMonth(date)
        .where((e) => e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  double subscriptionsSpentForMonth(DateTime date) {
    return expensesForMonth(date)
        .where((e) => !e.isIncome && e.category == ExpenseCategory.subscriptions)
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  Map<ExpenseCategory, double> categoryTotalsForMonth(DateTime date) {
    final Map<ExpenseCategory, double> totals = {};

    for (final expense in expensesForMonth(date).where((e) => !e.isIncome)) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  double totalSpentThisMonth(DateTime now) {
    return totalSpentForMonth(now);
  }

  double remainingBudgetFor(DateTime now) {
    final totalBudget = _budget?.currency == activeCurrency ? (_budget?.totalBudget ?? 0) : 0.0;
    return totalBudget - totalSpentForMonth(now);
  }

  ForecastResultModel? forecastFor(DateTime now) {
    final currentBudget = _budget?.currency == activeCurrency ? _budget?.totalBudget : null;
    if (currentBudget == null || currentBudget <= 0) return null;

    return forecastService.calculate(
      expenses: _expenses.where((e) => !e.isIncome && e.currency == activeCurrency).toList(),
      now: now,
      monthlyBudget: currentBudget,
    );
  }

  int healthScoreFor(DateTime now) {
    final profile = _incomeProfile;
    final budget = _budget;

    // Считаем здоровье только если мы смотрим на базовую валюту профиля
    if (profile == null || budget == null || budget.currency != activeCurrency || profile.currency != activeCurrency) return 0;

    final actualIncome = actualIncomeForMonth(now);
    final incomeToUse = max(profile.expectedMonthlyIncome, actualIncome);

    return scoreService.calculate(
      income: incomeToUse,
      totalSpent: totalSpentForMonth(now),
      totalBudget: budget.totalBudget,
      subscriptionsSpent: subscriptionsSpentForMonth(now),
      goalProgressRatio: 0.3,
    );
  }

  Duration spentLifeDurationForMonth(DateTime now) {
    final profile = _incomeProfile;
    if (profile == null || profile.currency != activeCurrency) return Duration.zero;

    final actualIncome = actualIncomeForMonth(now);
    final minuteValue = profile.valuePerMinute(actualIncomeThisMonth: actualIncome);

    if (minuteValue <= 0) return Duration.zero;

    final totalSpent = totalSpentForMonth(now);
    final minutes = (totalSpent / minuteValue).round();

    return Duration(minutes: minutes);
  }

  String currentMonthKey(DateTime now) => buildMonthKey(now);

  List<InsightModel> insightsForMonth(DateTime now) {
    if (!canUseFeature(PremiumFeature.aiInsights)) {
      return const [];
    }

    final totalBudget = _budget?.currency == activeCurrency ? (_budget?.totalBudget ?? 0) : 0.0;
    final totalSpent = totalSpentForMonth(now);
    final remainingBudget = remainingBudgetFor(now);
    final categoryTotals = categoryTotalsForMonth(now);
    final subscriptionsSpent = subscriptionsSpentForMonth(now);
    final healthScore = healthScoreFor(now);

    return insightService.generate(
      currentMonthExpenses: expensesForMonth(now).where((e) => !e.isIncome).toList(),
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      remainingBudget: remainingBudget,
      categoryTotals: categoryTotals,
      subscriptionsSpent: subscriptionsSpent,
      healthScore: healthScore,
    );
  }

  List<ExpenseModel> expensesLast30Days(DateTime now) {
    final start = now.subtract(const Duration(days: 30));
    return _expenses.where((e) => e.date.isAfter(start) && !e.isIncome && e.currency == activeCurrency).toList();
  }

  AutoBudgetRecommendation autoBudgetRecommendation(DateTime now) {
    return autoBudgetService.generate(
      last30DaysExpenses: List<ExpenseModel>.from(expensesLast30Days(now)),
    );
  }

  List<SubscriptionCandidateModel> detectedSubscriptions() {
    if (!canUseFeature(PremiumFeature.advancedSubscriptions)) {
      return const [];
    }

    return subscriptionDetectorService.detect(
      expenses: List<ExpenseModel>.from(_expenses.where((e) => !e.isIncome && e.currency == activeCurrency)),
    );
  }

  Future<void> applyAutoBudget(DateTime now) async {
    final recommendation = autoBudgetRecommendation(now);
    if (recommendation.recommendedTotalBudget <= 0) return;

    final updated = BudgetModel(
      monthKey: buildMonthKey(now),
      totalBudget: recommendation.recommendedTotalBudget,
      currency: activeCurrency,
      categoryBudgets: recommendation.categoryBudgets,
    );

    _budget = updated;
    await LocalStorageService.instance.saveBudget(updated);
    notifyListeners();
  }

  Map<ExpenseCategory, double> effectiveCategoryBudgetsForMonth(DateTime now) {
    if (_budget?.currency == activeCurrency) {
      final currentBudgetMap = _budget?.categoryBudgets ?? const <ExpenseCategory, double>{};
      if (currentBudgetMap.isNotEmpty) {
        return currentBudgetMap;
      }
    }

    final recommendation = autoBudgetRecommendation(now);
    return recommendation.categoryBudgets;
  }

  double spentForCategoryThisMonth(DateTime now, ExpenseCategory category) {
    return expensesForMonth(now)
        .where((e) => !e.isIncome && e.category == category)
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  double remainingForCategoryThisMonth(DateTime now, ExpenseCategory category) {
    final budget = effectiveCategoryBudgetsForMonth(now)[category] ?? 0;
    final spent = spentForCategoryThisMonth(now, category);
    return budget - spent;
  }

  double progressForCategoryThisMonth(DateTime now, ExpenseCategory category) {
    final budget = effectiveCategoryBudgetsForMonth(now)[category] ?? 0;
    if (budget <= 0) return 0;
    return spentForCategoryThisMonth(now, category) / budget;
  }

  ExpenseCategory? mostDangerousCategoryThisMonth(DateTime now) {
    final budgets = effectiveCategoryBudgetsForMonth(now);
    if (budgets.isEmpty) return null;

    ExpenseCategory? worstCategory;
    double worstRatio = 0;

    for (final entry in budgets.entries) {
      if (entry.value <= 0) continue;
      final ratio = spentForCategoryThisMonth(now, entry.key) / entry.value;
      if (ratio > worstRatio) {
        worstRatio = ratio;
        worstCategory = entry.key;
      }
    }

    return worstCategory;
  }

  MonthlyReportModel monthlyReport(DateTime now) {
    return monthlyReportService.generate(
      monthTransactions: expensesForMonth(now),
      incomeProfile: _incomeProfile,
      budget: _budget?.currency == activeCurrency ? (_budget?.totalBudget ?? 0) : 0.0,
      healthScore: healthScoreFor(now),
      lifeSpent: spentLifeDurationForMonth(now),
      categoryTotals: categoryTotalsForMonth(now),
    );
  }

  Future<void> setSavingsGoal(SavingsGoalModel goal) async {
    _savingsGoal = goal;
    notifyListeners();
  }

  Future<void> updateSavingsGoalProgress(String goalId, double amount) async {
    if (_savingsGoal == null || _savingsGoal!.id != goalId) return;

    _savingsGoal = _savingsGoal!.copyWith(
      currentAmount: (_savingsGoal!.currentAmount + amount)
          .clamp(0, _savingsGoal!.targetAmount)
          .toDouble(),
    );

    notifyListeners();
  }

  SavingsGoalProjectionModel? savingsGoalProjection(DateTime now) {
    final goal = _savingsGoal;
    if (goal == null) return null;

    final report = monthlyReport(now);

    return savingsGoalService.project(
      goal: goal,
      currentMonthlySavings: report.totalSaved,
      now: now,
    );
  }

  Future<void> setSalaryDay(int day) async {
    _salaryDay = day;
    notifyListeners();
  }

  Future<void> addRecurringBill(RecurringBillModel bill) async {
    _recurringBills.add(bill);
    notifyListeners();
  }

  List<CashflowEventModel> cashflowTimeline(DateTime now) {
    if (!canUseFeature(PremiumFeature.cashflowTimeline)) {
      return const [];
    }

    return cashflowTimelineService.buildTimeline(
      now: now,
      salaryDay: _salaryDay,
      monthlyIncome: _incomeProfile?.expectedMonthlyIncome ?? 0,
      currency: activeCurrency,
      recurringBills: _recurringBills,
      daysAhead: 30,
    );
  }

  List<ActionPlanItemModel> actionPlan(DateTime now) {
    if (!canUseFeature(PremiumFeature.actionPlanner)) {
      return const [];
    }

    final dangerousCategory = mostDangerousCategoryThisMonth(now);
    final subscriptions = detectedSubscriptions();
    final goal = _savingsGoal;
    final projection = savingsGoalProjection(now);

    return actionPlanService.generate(
      dangerousCategory: dangerousCategory,
      dangerousCategorySpent: dangerousCategory == null
          ? 0
          : spentForCategoryThisMonth(now, dangerousCategory),
      dangerousCategoryBudget: dangerousCategory == null
          ? 0
          : (effectiveCategoryBudgetsForMonth(now)[dangerousCategory] ?? 0),
      subscriptions: subscriptions,
      goal: goal,
      goalProjection: projection,
      healthScore: healthScoreFor(now),
    );
  }
}