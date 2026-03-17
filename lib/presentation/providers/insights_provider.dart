import 'dart:math';
import 'package:flutter/material.dart';

import '../../data/models/achievement_model.dart';
import '../../data/models/action_plan_item_model.dart';
import '../../data/models/cashflow_event_model.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/forecast_result_model.dart';
import '../../data/models/insight_model.dart';
import '../../data/models/month_close_summary_model.dart';
import '../../data/models/subscription_candidate_model.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/action_plan_service.dart';
import '../../domain/services/cashflow_timeline_service.dart';
import '../../domain/services/financial_forecast_service.dart';
import '../../domain/services/financial_health_score_service.dart';
import '../../domain/services/financial_insight_service.dart';
import '../../domain/services/life_value_service.dart';
import '../../domain/services/month_close_service.dart';
import '../../domain/services/monthly_report_model.dart';
import '../../domain/services/monthly_report_service.dart';
import '../../domain/services/premium_feature.dart';
import '../../domain/services/streak_service.dart';
import '../../domain/services/streak_summary_model.dart';
import '../../domain/services/subscription_detector_service.dart';

import 'settings_provider.dart';
import 'transactions_provider.dart';
import 'budget_provider.dart';

class InsightsProvider extends ChangeNotifier {
  final SettingsProvider settings;
  final TransactionsProvider transactions;
  final BudgetProvider budgetProvider;

  final FinancialForecastService forecastService;
  final FinancialHealthScoreService scoreService;
  final LifeValueService lifeValueService;

  final FinancialInsightService insightService = FinancialInsightService();
  final SubscriptionDetectorService subscriptionDetectorService = SubscriptionDetectorService();
  final MonthlyReportService monthlyReportService = MonthlyReportService();
  final CashflowTimelineService cashflowTimelineService = CashflowTimelineService();
  final ActionPlanService actionPlanService = ActionPlanService();
  final MonthCloseService monthCloseService = MonthCloseService();
  final StreakService streakService = StreakService();
  final AchievementService achievementService = AchievementService();

  final List<Map<String, dynamic>> _aiChatHistory = [];

  InsightsProvider({
    required this.settings,
    required this.transactions,
    required this.budgetProvider,
    required this.forecastService,
    required this.scoreService,
    required this.lifeValueService,
  });

  List<Map<String, dynamic>> get aiChatHistory => List.unmodifiable(_aiChatHistory);

  void addAiChatMessage(bool isUser, String text) {
    _aiChatHistory.add({'isUser': isUser, 'text': text});
    notifyListeners();
  }

  // --- БАЗОВЫЕ РАСЧЕТЫ ---

  double totalSpentForMonth(DateTime date) {
    return transactions.expensesForMonth(date).where((e) => !e.isIncome).fold<double>(0, (sum, e) => sum + e.amount);
  }

  double actualIncomeForMonth(DateTime date) {
    return transactions.expensesForMonth(date).where((e) => e.isIncome).fold<double>(0, (sum, e) => sum + e.amount);
  }

  double subscriptionsSpentForMonth(DateTime date) {
    return transactions.expensesForMonth(date).where((e) => !e.isIncome && e.category == ExpenseCategory.subscriptions).fold<double>(0, (sum, e) => sum + e.amount);
  }

  Map<ExpenseCategory, double> categoryTotalsForMonth(DateTime date) {
    final Map<ExpenseCategory, double> totals = {};
    for (final expense in transactions.expensesForMonth(date).where((e) => !e.isIncome)) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  double spentForCategoryThisMonth(DateTime now, ExpenseCategory category) {
    return transactions.expensesForMonth(now).where((e) => !e.isIncome && e.category == category).fold<double>(0, (sum, e) => sum + e.amount);
  }

  double remainingBudgetFor(DateTime now) {
    final totalBudget = budgetProvider.budget?.currency == settings.activeCurrency ? (budgetProvider.budget?.totalBudget ?? 0) : 0.0;
    return totalBudget - totalSpentForMonth(now);
  }

  ExpenseCategory? mostDangerousCategoryThisMonth(DateTime now) {
    final budgets = budgetProvider.effectiveCategoryBudgetsForMonth(now);
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

  // --- СЛОЖНАЯ АНАЛИТИКА ---

  ForecastResultModel? forecastFor(DateTime now) {
    final currentBudget = budgetProvider.budget?.currency == settings.activeCurrency ? budgetProvider.budget?.totalBudget : null;
    if (currentBudget == null || currentBudget <= 0) return null;

    return forecastService.calculate(
      expenses: transactions.expenses.where((e) => !e.isIncome && e.currency == settings.activeCurrency).toList(),
      now: now,
      monthlyBudget: currentBudget,
    );
  }

  int healthScoreFor(DateTime now) {
    final profile = settings.incomeProfile;
    final b = budgetProvider.budget;

    if (profile == null || b == null || b.currency != settings.activeCurrency || profile.currency != settings.activeCurrency) return 0;

    final actualIncome = actualIncomeForMonth(now);
    final incomeToUse = max(profile.expectedMonthlyIncome, actualIncome);

    return scoreService.calculate(
      income: incomeToUse,
      totalSpent: totalSpentForMonth(now),
      totalBudget: b.totalBudget,
      subscriptionsSpent: subscriptionsSpentForMonth(now),
      goalProgressRatio: 0.3,
    );
  }

  Duration spentLifeDurationForMonth(DateTime now) {
    final profile = settings.incomeProfile;
    if (profile == null || profile.currency != settings.activeCurrency) return Duration.zero;

    final actualIncome = actualIncomeForMonth(now);
    final minuteValue = profile.valuePerMinute(actualIncomeThisMonth: actualIncome);

    if (minuteValue <= 0) return Duration.zero;

    final totalSpent = totalSpentForMonth(now);
    final minutes = (totalSpent / minuteValue).round();

    return Duration(minutes: minutes);
  }

  List<InsightModel> insightsForMonth(DateTime now) {
    if (!settings.canUseFeature(PremiumFeature.aiInsights)) return const [];

    final totalBudget = budgetProvider.budget?.currency == settings.activeCurrency ? (budgetProvider.budget?.totalBudget ?? 0) : 0.0;

    return insightService.generate(
      currentMonthExpenses: transactions.expensesForMonth(now).where((e) => !e.isIncome).toList(),
      totalBudget: totalBudget,
      totalSpent: totalSpentForMonth(now),
      remainingBudget: remainingBudgetFor(now),
      categoryTotals: categoryTotalsForMonth(now),
      subscriptionsSpent: subscriptionsSpentForMonth(now),
      healthScore: healthScoreFor(now),
    );
  }

  List<SubscriptionCandidateModel> detectedSubscriptions() {
    if (!settings.canUseFeature(PremiumFeature.advancedSubscriptions)) return const [];

    return subscriptionDetectorService.detect(
      expenses: List<ExpenseModel>.from(transactions.expenses.where((e) => !e.isIncome && e.currency == settings.activeCurrency)),
    );
  }

  MonthlyReportModel monthlyReport(DateTime now) {
    return monthlyReportService.generate(
      monthTransactions: transactions.expensesForMonth(now),
      incomeProfile: settings.incomeProfile,
      activeCurrency: settings.activeCurrency,
      budget: budgetProvider.budget?.currency == settings.activeCurrency ? (budgetProvider.budget?.totalBudget ?? 0) : 0.0,
      healthScore: healthScoreFor(now),
      lifeSpent: spentLifeDurationForMonth(now),
      categoryTotals: categoryTotalsForMonth(now),
    );
  }

  List<CashflowEventModel> cashflowTimeline(DateTime now) {
    if (!settings.canUseFeature(PremiumFeature.cashflowTimeline)) return const [];

    return cashflowTimelineService.buildTimeline(
      now: now,
      salaryDay: settings.salaryDay,
      monthlyIncome: settings.incomeProfile?.expectedMonthlyIncome ?? 0,
      currency: settings.activeCurrency,
      recurringBills: budgetProvider.recurringBills,
      daysAhead: 30,
    );
  }

  List<ActionPlanItemModel> actionPlan(DateTime now) {
    if (!settings.canUseFeature(PremiumFeature.actionPlanner)) return const [];

    final dangerousCategory = mostDangerousCategoryThisMonth(now);
    final report = monthlyReport(now);

    return actionPlanService.generate(
      dangerousCategory: dangerousCategory,
      dangerousCategorySpent: dangerousCategory == null ? 0 : spentForCategoryThisMonth(now, dangerousCategory),
      dangerousCategoryBudget: dangerousCategory == null ? 0 : (budgetProvider.effectiveCategoryBudgetsForMonth(now)[dangerousCategory] ?? 0),
      subscriptions: detectedSubscriptions(),
      goal: budgetProvider.savingsGoal,
      goalProjection: budgetProvider.savingsGoalProjection(now, report.totalSaved),
      healthScore: healthScoreFor(now),
    );
  }

  StreakSummaryModel streakSummary() {
    return streakService.calculate(transactions.expenses);
  }

  List<AchievementModel> achievements() {
    final streak = streakSummary();
    final goal = budgetProvider.savingsGoal;

    return achievementService.build(
      expenses: transactions.expenses,
      streak: streak,
      hasGoal: goal != null,
      hasGoalProgress: goal != null && goal.currentAmount > 0,
      hasMonthCloseSignal: transactions.expenses.isNotEmpty,
      hasNoOverspendMonth: (budgetProvider.budget?.currency == settings.activeCurrency) &&
          (budgetProvider.budget?.totalBudget ?? 0) > 0 &&
          totalSpentForMonth(DateTime.now()) <= (budgetProvider.budget?.totalBudget ?? 0),
    );
  }

  MonthCloseSummaryModel monthCloseSummary(DateTime now) {
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final currentExpensesOnly = transactions.expensesForMonth(now).where((e) => !e.isIncome).toList();
    final previousExpensesOnly = transactions.expensesForMonth(previousMonth).where((e) => !e.isIncome).toList();

    return monthCloseService.build(
      currentMonthExpenses: currentExpensesOnly,
      previousMonthExpenses: previousExpensesOnly,
      incomeProfile: settings.incomeProfile,
      healthScore: healthScoreFor(now),
      previousHealthScore: healthScoreFor(previousMonth),
      lifeSpent: spentLifeDurationForMonth(now),
      currentCategoryTotals: categoryTotalsForMonth(now),
    );
  }
}