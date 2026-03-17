import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/month_key.dart';
import '../../data/datasources/local/isar_database_service.dart'; // <-- ИМПОРТ ISAR
import '../../data/models/budget_model.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/expense_source_type.dart';
import '../../data/models/recurring_bill_model.dart';
import '../../data/models/saving_goal_model.dart';
import '../../data/models/savings_goal_projection_model.dart';
import '../../domain/services/auto_budget_service.dart';
import '../../domain/services/savings_goal_service.dart';
import 'settings_provider.dart';
import 'transactions_provider.dart';

class BudgetProvider extends ChangeNotifier {
  final SettingsProvider settings;
  final TransactionsProvider transactions;

  final AutoBudgetService autoBudgetService = AutoBudgetService();
  final SavingsGoalService savingsGoalService = SavingsGoalService();

  BudgetModel? _budget;
  SavingsGoalModel? _savingsGoal;
  final List<RecurringBillModel> _recurringBills = [];

  BudgetProvider({required this.settings, required this.transactions});

  BudgetModel? get budget => _budget;
  SavingsGoalModel? get savingsGoal => _savingsGoal;
  List<RecurringBillModel> get recurringBills => List.unmodifiable(_recurringBills);

  Future<void> load() async {
    // Грузим бюджеты из Isar
    final allBudgets = await IsarDatabaseService.instance.getAllBudgets();
    try {
      _budget = allBudgets.firstWhere((b) => b.currency == settings.activeCurrency);
    } catch (_) {
      _budget = null;
    }

    // Грузим цели
    final allGoals = await IsarDatabaseService.instance.getAllSavingsGoals();
    _savingsGoal = allGoals.isNotEmpty ? allGoals.last : null;

    // Грузим регулярные платежи
    _recurringBills.clear();
    final loadedBills = await IsarDatabaseService.instance.getAllRecurringBills();
    _recurringBills.addAll(loadedBills);

    await _processPendingSubscriptions();
    notifyListeners();
  }

  // Смена валюты (вызывается из UI, когда юзер меняет активный счет)
  void reloadBudgetForCurrentCurrency() async {
    final allBudgets = await IsarDatabaseService.instance.getAllBudgets();
    try {
      _budget = allBudgets.firstWhere((b) => b.currency == settings.activeCurrency);
    } catch (_) {
      _budget = null;
    }
    notifyListeners();
  }

  // --- БЮДЖЕТ ---

  Future<void> setBudget(BudgetModel newBudget) async {
    await IsarDatabaseService.instance.saveBudget(newBudget);
    await load();
  }

  Future<void> updateMonthlyBudget(double amount, DateTime now) async {
    final updated = BudgetModel(
      monthKey: buildMonthKey(now),
      totalBudget: amount,
      currency: settings.activeCurrency,
      categoryBudgets: _budget?.categoryBudgets ?? const {},
    );
    await IsarDatabaseService.instance.saveBudget(updated);
    await load();
  }

  AutoBudgetRecommendation autoBudgetRecommendation(DateTime now) {
    final start = now.subtract(const Duration(days: 30));
    final last30Days = transactions.expenses.where((e) => e.date.isAfter(start) && !e.isIncome && e.currency == settings.activeCurrency).toList();

    return autoBudgetService.generate(last30DaysExpenses: last30Days);
  }

  Future<void> applyAutoBudget(DateTime now) async {
    final recommendation = autoBudgetRecommendation(now);
    if (recommendation.recommendedTotalBudget <= 0) return;

    final updated = BudgetModel(
      monthKey: buildMonthKey(now),
      totalBudget: recommendation.recommendedTotalBudget,
      currency: settings.activeCurrency,
      categoryBudgets: recommendation.categoryBudgets,
    );

    await IsarDatabaseService.instance.saveBudget(updated);
    await load();
  }

  Map<ExpenseCategory, double> effectiveCategoryBudgetsForMonth(DateTime now) {
    if (_budget?.currency == settings.activeCurrency) {
      final currentBudgetMap = _budget?.categoryBudgets ?? const <ExpenseCategory, double>{};
      if (currentBudgetMap.isNotEmpty) return currentBudgetMap;
    }
    return autoBudgetRecommendation(now).categoryBudgets;
  }

  // --- ЦЕЛИ (СБЕРЕЖЕНИЯ) ---

  Future<void> setSavingsGoal(SavingsGoalModel goal) async {
    await IsarDatabaseService.instance.saveSavingsGoal(goal);
    await load();
  }

  Future<void> updateSavingsGoalProgress(String goalId, double amount) async {
    if (_savingsGoal == null || _savingsGoal!.id != goalId) return;
    if (_savingsGoal!.currency != settings.activeCurrency) return;

    final updated = _savingsGoal!.copyWith(
      currentAmount: (_savingsGoal!.currentAmount + amount).clamp(0, _savingsGoal!.targetAmount).toDouble(),
    );

    await IsarDatabaseService.instance.saveSavingsGoal(updated);
    await load();
  }

  SavingsGoalProjectionModel? savingsGoalProjection(DateTime now, double currentMonthlySavings) {
    if (_savingsGoal == null) return null;
    return savingsGoalService.project(goal: _savingsGoal!, currentMonthlySavings: currentMonthlySavings, now: now);
  }

  // --- РЕГУЛЯРНЫЕ ПЛАТЕЖИ (ПОДПИСКИ) ---

  Future<void> addRecurringBill(RecurringBillModel bill) async {
    await IsarDatabaseService.instance.saveRecurringBill(bill);
    await load();
  }

  Future<void> updateRecurringBill(String billId, RecurringBillModel updatedBill) async {
    await IsarDatabaseService.instance.saveRecurringBill(updatedBill);
    await load();
  }

  Future<void> deleteRecurringBill(String billId) async {
    await IsarDatabaseService.instance.deleteRecurringBill(billId);
    await load();
  }

  Future<void> _processPendingSubscriptions() async {
    if (_recurringBills.isEmpty) return;

    final now = DateTime.now();
    bool hasChanges = false;

    for (final bill in _recurringBills) {
      if (!bill.isActive) continue;

      final billExpenses = transactions.expenses.where((e) => e.recurringGroupId == bill.id).toList();
      billExpenses.sort((a, b) => b.date.compareTo(a.date));

      DateTime nextBillingDate;

      if (billExpenses.isNotEmpty) {
        final lastDate = billExpenses.first.date;
        int nextMonth = lastDate.month + 1;
        int nextYear = lastDate.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        int targetDay = bill.dayOfMonth > daysInNextMonth ? daysInNextMonth : bill.dayOfMonth;
        nextBillingDate = DateTime(nextYear, nextMonth, targetDay);
      } else {
        if (bill.createdAt.day <= bill.dayOfMonth) {
          int daysInMonth = DateTime(bill.createdAt.year, bill.createdAt.month + 1, 0).day;
          int targetDay = bill.dayOfMonth > daysInMonth ? daysInMonth : bill.dayOfMonth;
          nextBillingDate = DateTime(bill.createdAt.year, bill.createdAt.month, targetDay);
        } else {
          int nextMonth = bill.createdAt.month + 1;
          int nextYear = bill.createdAt.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }
          int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
          int targetDay = bill.dayOfMonth > daysInNextMonth ? daysInNextMonth : bill.dayOfMonth;
          nextBillingDate = DateTime(nextYear, nextMonth, targetDay);
        }
      }

      while (!nextBillingDate.isAfter(now)) {
        final newExpense = ExpenseModel(
          id: const Uuid().v4(),
          amount: bill.amount,
          currency: bill.currency,
          category: ExpenseCategory.subscriptions,
          merchant: bill.title,
          note: 'Auto-paid subscription',
          date: nextBillingDate,
          sourceType: ExpenseSourceType.smartText,
          isRecurring: true,
          recurringGroupId: bill.id,
          createdAt: now,
          isIncome: false,
        );

        await transactions.addExpense(newExpense);
        hasChanges = true;

        int nextMonth = nextBillingDate.month + 1;
        int nextYear = nextBillingDate.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        int targetDay = bill.dayOfMonth > daysInNextMonth ? daysInNextMonth : bill.dayOfMonth;
        nextBillingDate = DateTime(nextYear, nextMonth, targetDay);
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }
}