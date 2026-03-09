import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_filter_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);

    final filtered = provider.filteredExpenses(_filter);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expensesHistoryTitle),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
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
              ...filtered.map(
                    (expense) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ExpenseItemCard(
                    expense: expense,
                    incomeProfile: provider.incomeProfile,
                    onTap: () => provider.openExpenseEditor(context, expense),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}