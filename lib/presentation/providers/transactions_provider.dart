import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/month_key.dart';
import '../../data/datasources/local/local_storage_service.dart';
import '../../data/datasources/local/isar_database_service.dart'; // <-- ИМПОРТ ISAR
import '../../data/models/debt_model.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/expense_filter_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/expense_source_type.dart';
import '../widgets/expense_edit_sheet.dart';
import 'settings_provider.dart';

class TransactionsProvider extends ChangeNotifier {
  final SettingsProvider settings;

  final List<ExpenseModel> _expenses = [];
  final List<DebtModel> _debts = [];

  bool _needsMonthClose = false;

  TransactionsProvider({required this.settings});

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  List<DebtModel> get debts => List.unmodifiable(_debts);
  bool get needsMonthClose => _needsMonthClose;

  // ИСПРАВЛЕНИЕ: Теперь грузим из Isar, а не из LocalStorage
  Future<void> load() async {
    _expenses.clear();
    final loadedExpenses = await IsarDatabaseService.instance.getAllExpenses();
    loadedExpenses.sort((a, b) => b.date.compareTo(a.date));
    _expenses.addAll(loadedExpenses);

    _debts.clear();
    final loadedDebts = await IsarDatabaseService.instance.getAllDebts();
    loadedDebts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _debts.addAll(loadedDebts);

    _checkMonthCloseTransition();

    // Обновляем кэш валют в настройках при загрузке транзакций
    settings.updateCurrencyCache(_expenses.map((e) => e.currency).toList());

    notifyListeners();
  }

  // --- EXPENSES ---

  Future<void> addExpense(ExpenseModel expense) async {
    await IsarDatabaseService.instance.saveExpense(expense);
    await load(); // Перезагружаем список из базы
  }

  Future<void> duplicateExpense(ExpenseModel expense) async {
    final newExpense = expense.copyWith(
      id: const Uuid().v4(),
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await addExpense(newExpense);
  }

  Future<void> updateExpense(String expenseId, ExpenseEditResult result) async {
    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index == -1) return;

    final old = _expenses[index];
    final updated = old.copyWith(
      amount: result.amount,
      merchant: result.merchant,
      note: result.note.isEmpty ? null : result.note,
      category: result.category,
      customCategoryId: result.customCategoryId,
      clearCustomCategory: result.clearCustomCategory,
      date: result.date,
      isIncome: result.isIncome,
      currency: result.currency,
    );

    await IsarDatabaseService.instance.saveExpense(updated);
    await load();
  }

  Future<void> deleteExpense(String expenseId) async {
    await IsarDatabaseService.instance.deleteExpense(expenseId);
    await load();
  }

  // Получить расходы за конкретный месяц в АКТИВНОЙ валюте
  List<ExpenseModel> expensesForMonth(DateTime date) {
    return _expenses.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.currency == settings.activeCurrency;
    }).toList();
  }

  // --- ФИЛЬТРЫ ---

  List<ExpenseModel> filteredExpenses(ExpenseFilterModel filter) {
    var list = List<ExpenseModel>.from(_expenses.where((e) => e.currency == settings.activeCurrency));

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
      list = list.where((e) => !e.date.isBefore(DateTime(filter.startDate!.year, filter.startDate!.month, filter.startDate!.day))).toList();
    }

    if (filter.endDate != null) {
      final inclusiveEnd = DateTime(filter.endDate!.year, filter.endDate!.month, filter.endDate!.day, 23, 59, 59);
      list = list.where((e) => !e.date.isAfter(inclusiveEnd)).toList();
    }

    switch (filter.sortOption) {
      case ExpenseSortOption.newestFirst: list.sort((a, b) => b.date.compareTo(a.date)); break;
      case ExpenseSortOption.oldestFirst: list.sort((a, b) => a.date.compareTo(b.date)); break;
      case ExpenseSortOption.highestAmount: list.sort((a, b) => b.amount.compareTo(a.amount)); break;
      case ExpenseSortOption.lowestAmount: list.sort((a, b) => a.amount.compareTo(b.amount)); break;
    }

    return list;
  }

  // --- ДОЛГИ ---

  Future<void> addDebt(DebtModel debt) async {
    await IsarDatabaseService.instance.saveDebt(debt);
    await load();
  }

  Future<void> updateDebt(DebtModel updatedDebt) async {
    await IsarDatabaseService.instance.saveDebt(updatedDebt);
    await load();
  }

  Future<void> deleteDebt(String id) async {
    await IsarDatabaseService.instance.deleteDebt(id);
    await load();
  }

  Future<void> markDebtAsPaid(String id) async {
    final index = _debts.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final debt = _debts[index];
    if (debt.isPaid) return;

    final updatedDebt = debt.copyWith(isPaid: true);
    await IsarDatabaseService.instance.saveDebt(updatedDebt);

    // Добавляем транзакцию возврата долга (IsarDatabaseService внутри addExpense сделает load())
    final transaction = ExpenseModel(
      id: const Uuid().v4(),
      amount: debt.amount,
      currency: debt.currency,
      category: ExpenseCategory.gifts,
      merchant: debt.personName,
      note: debt.isOwedToMe ? 'Возврат долга от ${debt.personName}' : 'Я вернул долг ${debt.personName}',
      date: DateTime.now(),
      sourceType: ExpenseSourceType.smartText,
      isIncome: debt.isOwedToMe,
      isRecurring: false,
      recurringGroupId: null,
      createdAt: DateTime.now(),
    );

    await addExpense(transaction);
  }

  // --- MONTH CLOSE ---

  void _checkMonthCloseTransition() {
    if (_expenses.isEmpty) return;

    final now = DateTime.now();
    final prevMonthDate = DateTime(now.year, now.month - 1, 1);
    final previousMonthKey = buildMonthKey(prevMonthDate);

    // Отметку о просмотре экрана мы всё еще храним в SharedPreferences (LocalStorageService)
    final hasSeen = LocalStorageService.instance.isMonthCloseSeen(previousMonthKey);

    if (!hasSeen) {
      final hasExpensesInPrevMonth = _expenses.any((e) => e.date.month == prevMonthDate.month && e.date.year == prevMonthDate.year);
      if (hasExpensesInPrevMonth) {
        _needsMonthClose = true;
      }
    }
  }

  void markMonthCloseAsSeen() {
    _needsMonthClose = false;
    final now = DateTime.now();
    final previousMonthKey = buildMonthKey(DateTime(now.year, now.month - 1, 1));
    LocalStorageService.instance.setMonthCloseSeen(previousMonthKey);
    notifyListeners();
  }
}