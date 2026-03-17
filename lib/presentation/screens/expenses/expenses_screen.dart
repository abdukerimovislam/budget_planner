import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/utils/category_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_filter_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/expense_edit_sheet.dart';
import '../../widgets/expense_filter_bar.dart';
import '../../widgets/expense_item_card.dart';
import '../../widgets/premium_background.dart';
import '../premium/premium_screen.dart';

// НОВЫЕ ПРОВАЙДЕРЫ
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  ExpenseFilterModel _filter = ExpenseFilterModel.initial;
  final Set<String> _selectedIds = {};

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filter.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _filter = _filter.copyWith(startDate: picked);
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filter.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _filter = _filter.copyWith(endDate: picked);
      });
    }
  }

  void _toggleSelection(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _duplicateExpense(ExpenseModel expense) {
    final tx = context.read<TransactionsProvider>();
    final duplicated = expense.copyWith(
      id: const Uuid().v4(),
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    tx.addExpense(duplicated);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Транзакция продублирована'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteWithUndo(ExpenseModel expense) {
    final tx = context.read<TransactionsProvider>();
    tx.deleteExpense(expense.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Транзакция удалена'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Отмена',
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () => tx.addExpense(expense),
        ),
      ),
    );
  }

  void _bulkDelete(List<ExpenseModel> allFiltered) {
    HapticFeedback.mediumImpact();
    final tx = context.read<TransactionsProvider>();
    final toDelete = allFiltered.where((e) => _selectedIds.contains(e.id)).toList();

    for (final expense in toDelete) {
      tx.deleteExpense(expense.id);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Удалено транзакций: ${toDelete.length}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Отмена',
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            for (final expense in toDelete) tx.addExpense(expense);
          },
        ),
      ),
    );

    setState(() => _selectedIds.clear());
  }

  Future<void> _bulkChangeCategory(List<ExpenseModel> allFiltered) async {
    HapticFeedback.lightImpact();
    final tx = context.read<TransactionsProvider>();
    final toChange = allFiltered.where((e) => _selectedIds.contains(e.id)).toList();

    final availableCategories = ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();

    final category = await showDialog<ExpenseCategory>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Изменить категорию', style: TextStyle(fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableCategories.map((c) {
              return ListTile(
                leading: Icon(c.dynamicIcon(context), color: c.dynamicColor(context)),
                title: Text(c.localizedName(context), style: const TextStyle(fontWeight: FontWeight.w500)),
                onTap: () => Navigator.of(ctx).pop(c),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (category != null) {
      for (final expense in toChange) {
        tx.updateExpense(
          expense.id,
          ExpenseEditResult(
            amount: expense.amount,
            category: category,
            customCategoryId: null,
            clearCustomCategory: true,
            merchant: expense.merchant,
            note: expense.note ?? '',
            date: expense.date,
            isIncome: expense.isIncome,
            currency: expense.currency,
          ),
        );
      }
      setState(() => _selectedIds.clear());

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Категория обновлена для ${toChange.length} записей'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showCurrencyAccountSelector(BuildContext context, SettingsProvider settings) {
    if (!settings.canUseFeature(PremiumFeature.multiCurrency)) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }

    final available = settings.availableUserCurrencies;
    if (available.length <= 1) return;

    HapticFeedback.lightImpact();
    int initialIndex = available.indexOf(settings.activeCurrency);
    if (initialIndex == -1) initialIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Выберите счет', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: initialIndex),
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    settings.setActiveCurrency(available[index]);
                  },
                  children: available.map((c) => Center(
                    child: Text(c, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final settings = context.watch<SettingsProvider>();
    final tx = context.watch<TransactionsProvider>();

    final filtered = tx.filteredExpenses(_filter);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeCurrency = settings.activeCurrency;
    final hasMultipleCurrencies = settings.availableUserCurrencies.length > 1;
    final hasPremium = settings.canUseFeature(PremiumFeature.multiCurrency);

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _isSelectionMode
            ? AppBar(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.clear),
            onPressed: () => setState(() => _selectedIds.clear()),
          ),
          title: Text(
            'Выбрано: ${_selectedIds.length}',
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.folder_fill),
              tooltip: 'Изменить категорию',
              onPressed: () => _bulkChangeCategory(filtered),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.trash_fill, color: CupertinoColors.destructiveRed),
              tooltip: 'Удалить выбранные',
              onPressed: () => _bulkDelete(filtered),
            ),
          ],
        )
            : AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: const Text('История', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () => _showCurrencyAccountSelector(context, settings),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!hasPremium) ...[
                        const Icon(CupertinoIcons.lock_fill, size: 12, color: CupertinoColors.systemYellow),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        activeCurrency,
                        style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                      ),
                      if (hasPremium && hasMultipleCurrencies) ...[
                        const SizedBox(width: 4),
                        Icon(CupertinoIcons.chevron_up_chevron_down, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: AdaptivePagePadding(
          addBottomSafeArea: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              if (!_isSelectionMode) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                  ),
                  child: ExpenseFilterBar(
                    filter: _filter,
                    onQueryChanged: (value) => setState(() => _filter = _filter.copyWith(query: value)),
                    onCategoryChanged: (value) => setState(() => _filter = _filter.copyWith(category: value, clearCategory: value == null)),
                    onSortChanged: (value) => setState(() => _filter = _filter.copyWith(sortOption: value)),
                    onPickStartDate: _pickStartDate,
                    onPickEndDate: _pickEndDate,
                    onClearDates: () => setState(() => _filter = _filter.copyWith(clearStartDate: true, clearEndDate: true)),
                  ),
                ),
              ],

              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.doc_text_search, size: 48, color: colorScheme.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('Транзакции не найдены', style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                  ),
                  clipBehavior: Clip.antiAlias, // Важно для скругления свайпов
                  child: Column(
                    children: filtered.asMap().entries.map((entry) {
                      final index = entry.key;
                      final expense = entry.value;
                      final isSelected = _selectedIds.contains(expense.id);
                      final isLast = index == filtered.length - 1;

                      return Column(
                        children: [
                          GestureDetector(
                            onLongPress: () => _toggleSelection(expense.id),
                            child: Slidable(
                              key: ValueKey(expense.id),
                              enabled: !_isSelectionMode, // Отключаем свайпы в режиме выделения
                              startActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) {
                                      HapticFeedback.lightImpact();
                                      _duplicateExpense(expense);
                                    },
                                    backgroundColor: CupertinoColors.activeBlue,
                                    foregroundColor: Colors.white,
                                    icon: CupertinoIcons.doc_on_doc,
                                    label: 'Повторить',
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) {
                                      HapticFeedback.mediumImpact();
                                      _deleteWithUndo(expense);
                                    },
                                    backgroundColor: CupertinoColors.destructiveRed,
                                    foregroundColor: Colors.white,
                                    icon: CupertinoIcons.trash,
                                    label: 'Удалить',
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  ExpenseItemCard(
                                    expense: expense,
                                    incomeProfile: settings.incomeProfile,
                                    onTap: () async {
                                      if (_isSelectionMode) {
                                        _toggleSelection(expense.id);
                                      } else {
                                        final result = await showModalBottomSheet<ExpenseEditResult>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (_) => ExpenseEditSheet(expense: expense),
                                        );
                                        if (result != null) {
                                          await tx.updateExpense(expense.id, result);
                                        }
                                      }
                                    },
                                  ),
                                  if (isSelected)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary.withValues(alpha: 0.15),
                                          border: Border.all(color: colorScheme.primary, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast) Padding(padding: const EdgeInsets.only(left: 64), child: Divider(height: 1, color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
                        ],
                      );
                    }).toList(),
                  ),
                ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
            ],
          ),
        ),
      ),
    );
  }
}