import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_spacing.dart';
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
import '../../widgets/section_header.dart';

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
      const SnackBar(content: Text('Expense duplicated')),
    );
  }

  void _deleteWithUndo(ExpenseModel expense) {
    final provider = context.read<HomeProvider>();
    provider.deleteExpense(expense.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            provider.addExpense(expense);
          },
        ),
      ),
    );
  }

  void _bulkDelete(List<ExpenseModel> allFiltered) {
    final provider = context.read<HomeProvider>();
    final toDelete =
    allFiltered.where((e) => _selectedIds.contains(e.id)).toList();

    for (final expense in toDelete) {
      provider.deleteExpense(expense.id);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${toDelete.length} expenses deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            for (final expense in toDelete) {
              provider.addExpense(expense);
            }
          },
        ),
      ),
    );

    setState(() {
      _selectedIds.clear();
    });
  }

  String _categoryLabel(BuildContext context, ExpenseCategory category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case ExpenseCategory.food:
        return l10n.categoryFood;
      case ExpenseCategory.transport:
        return l10n.categoryTransport;
      case ExpenseCategory.subscriptions:
        return l10n.categorySubscriptions;
      case ExpenseCategory.entertainment:
        return l10n.categoryEntertainment;
      case ExpenseCategory.shopping:
        return l10n.categoryShopping;
      case ExpenseCategory.health:
        return l10n.categoryHealth;
      case ExpenseCategory.bills:
        return l10n.categoryBills;
      case ExpenseCategory.education:
        return l10n.categoryEducation;
      case ExpenseCategory.gifts:
        return l10n.categoryGifts;
      case ExpenseCategory.travel:
        return l10n.categoryTravel;
      case ExpenseCategory.other:
        return l10n.categoryOther;
    }
  }

  Future<void> _bulkChangeCategory(List<ExpenseModel> allFiltered) async {
    final provider = context.read<HomeProvider>();
    final toChange =
    allFiltered.where((e) => _selectedIds.contains(e.id)).toList();

    final category = await showDialog<ExpenseCategory>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ExpenseCategory.values.map((c) {
              return ListTile(
                title: Text(_categoryLabel(context, c)),
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
      setState(() {
        _selectedIds.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${toChange.length} categories updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);

    final filtered = provider.filteredExpenses(_filter);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
        backgroundColor: colorScheme.primaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => setState(() => _selectedIds.clear()),
        ),
        title: Text(
          '${_selectedIds.length}',
          style: TextStyle(color: colorScheme.onPrimaryContainer),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_rounded),
            tooltip: 'Change Category',
            onPressed: () => _bulkChangeCategory(filtered),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Selected',
            onPressed: () => _bulkDelete(filtered),
          ),
        ],
      )
          : AppBar(
        title: Text(l10n.expensesHistoryTitle),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            if (!_isSelectionMode) ...[
              SectionHeader(title: l10n.expensesHistoryTitle),
              SizedBox(height: Responsive.itemGap(context)),
              ExpenseFilterBar(
                filter: _filter,
                onQueryChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(query: value);
                  });
                },
                onCategoryChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(
                      category: value,
                      clearCategory: value == null,
                    );
                  });
                },
                onSortChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(sortOption: value);
                  });
                },
                onPickStartDate: _pickStartDate,
                onPickEndDate: _pickEndDate,
                onClearDates: () {
                  setState(() {
                    _filter = _filter.copyWith(
                      clearStartDate: true,
                      clearEndDate: true,
                    );
                  });
                },
              ),
              SizedBox(height: Responsive.sectionGap(context)),
            ],

            if (filtered.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  child: Text(
                    l10n.expensesHistoryEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...filtered.map((expense) {
                final isSelected = _selectedIds.contains(expense.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GestureDetector(
                    onLongPress: () => _toggleSelection(expense.id),
                    child: Dismissible(
                      key: ValueKey(expense.id),
                      direction: _isSelectionMode
                          ? DismissDirection.none
                          : DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          _duplicateExpense(expense);
                          return false;
                        }
                        return true;
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _deleteWithUndo(expense);
                        }
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
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}