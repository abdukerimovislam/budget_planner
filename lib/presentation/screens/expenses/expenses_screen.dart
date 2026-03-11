import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/category_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_filter_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/expense_edit_sheet.dart';
import '../../widgets/expense_filter_bar.dart';
import '../../widgets/expense_item_card.dart';
import '../../widgets/premium_background.dart'; // <-- ИМПОРТ ФОНА

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
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _duplicateExpense(ExpenseModel expense) {
    final provider = context.read<HomeProvider>();
    final duplicated = expense.copyWith(
      id: const Uuid().v4(),
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    provider.addExpense(duplicated);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Expense duplicated'), behavior: SnackBarBehavior.floating),
    );
  }

  void _deleteWithUndo(ExpenseModel expense) {
    final provider = context.read<HomeProvider>();
    provider.deleteExpense(expense.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => provider.addExpense(expense),
        ),
      ),
    );
  }

  void _bulkDelete(List<ExpenseModel> allFiltered) {
    final provider = context.read<HomeProvider>();
    final toDelete = allFiltered.where((e) => _selectedIds.contains(e.id)).toList();

    for (final expense in toDelete) {
      provider.deleteExpense(expense.id);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${toDelete.length} expenses deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            for (final expense in toDelete) provider.addExpense(expense);
          },
        ),
      ),
    );

    setState(() => _selectedIds.clear());
  }

  Future<void> _bulkChangeCategory(List<ExpenseModel> allFiltered) async {
    final provider = context.read<HomeProvider>();
    final toChange = allFiltered.where((e) => _selectedIds.contains(e.id)).toList();

    final availableCategories = ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();

    final category = await showDialog<ExpenseCategory>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableCategories.map((c) {
              return ListTile(
                title: Text(c.localizedName(context)),
                onTap: () => Navigator.of(ctx).pop(c),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (category != null) {
      for (final expense in toChange) {
        provider.updateExpense(
          expense.id,
          ExpenseEditResult(
            amount: expense.amount,
            category: category,
            merchant: expense.merchant,
            note: expense.note ?? '',
            date: expense.date,
          ),
        );
      }
      setState(() => _selectedIds.clear());

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${toChange.length} categories updated'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);

    final filtered = provider.filteredExpenses(_filter);
    final colorScheme = Theme.of(context).colorScheme;

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // ПРОЗРАЧНЫЙ ФОН
        appBar: _isSelectionMode
            ? AppBar(
          backgroundColor: colorScheme.primaryContainer.withOpacity(0.9),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.clear),
            onPressed: () => setState(() => _selectedIds.clear()),
          ),
          title: Text(
            '${_selectedIds.length} Selected',
            style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.folder_fill),
              tooltip: 'Change Category',
              onPressed: () => _bulkChangeCategory(filtered),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.trash_fill),
              tooltip: 'Delete Selected',
              onPressed: () => _bulkDelete(filtered),
            ),
          ],
        )
            : AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Text(l10n.expensesHistoryTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: AdaptivePagePadding(
          addBottomSafeArea: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              if (!_isSelectionMode) ...[
                // Фильтры в стильной полупрозрачной карточке
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.surfaceVariant.withOpacity(0.5)),
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
                    color: colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: colorScheme.surfaceVariant.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.doc_text_search, size: 48, color: colorScheme.primary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(l10n.expensesHistoryEmpty, style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                )
              else
              // Единый блок-список транзакций (Apple Wallet Style)
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.surfaceVariant.withOpacity(0.5)),
                  ),
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
                            child: Dismissible(
                              key: ValueKey(expense.id),
                              direction: _isSelectionMode ? DismissDirection.none : DismissDirection.horizontal,
                              background: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                color: colorScheme.primary,
                                child: const Icon(CupertinoIcons.doc_on_clipboard_fill, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                color: CupertinoColors.destructiveRed,
                                child: const Icon(CupertinoIcons.trash_fill, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  _duplicateExpense(expense);
                                  return false;
                                }
                                return true;
                              },
                              onDismissed: (direction) {
                                if (direction == DismissDirection.endToStart) _deleteWithUndo(expense);
                              },
                              child: Stack(
                                children: [
                                  ExpenseItemCard(
                                    expense: expense,
                                    incomeProfile: provider.incomeProfile,
                                    onTap: () {
                                      if (_isSelectionMode) {
                                        _toggleSelection(expense.id);
                                      } else {
                                        provider.openExpenseEditor(context, expense);
                                      }
                                    },
                                  ),
                                  if (isSelected)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary.withOpacity(0.15),
                                          border: Border.all(color: colorScheme.primary, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast) Padding(padding: const EdgeInsets.only(left: 64), child: Divider(height: 1, color: colorScheme.surfaceVariant.withOpacity(0.5))),
                        ],
                      );
                    }).toList(),
                  ),
                ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
            ],
          ),
        ),
      ),
    );
  }
}