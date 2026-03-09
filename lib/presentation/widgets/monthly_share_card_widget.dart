import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../data/models/expense_category.dart';
import '../../domain/services/financial_level.dart';
import '../../domain/services/share_card_model.dart';
import '../../l10n/app_localizations.dart';

class MonthlyShareCardWidget extends StatelessWidget {
  final ShareCardModel data;

  const MonthlyShareCardWidget({
    super.key,
    required this.data,
  });

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  String _levelLabel(AppLocalizations l10n, FinancialLevel level) {
    switch (level) {
      case FinancialLevel.survivor:
        return l10n.levelSurvivor;
      case FinancialLevel.planner:
        return l10n.levelPlanner;
      case FinancialLevel.strategist:
        return l10n.levelStrategist;
      case FinancialLevel.investor:
        return l10n.levelInvestor;
    }
  }

  String _categoryLabel(BuildContext context, ExpenseCategory? category) {
    final l10n = AppLocalizations.of(context);

    if (category == null) return l10n.categoryOther;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.isTablet(context) ? 28 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shareCardTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.shareCardSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _MetricRow(
            label: l10n.shareCardIncome,
            value: _formatNumber(data.income),
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: l10n.shareCardSpent,
            value: _formatNumber(data.spent),
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: l10n.shareCardSaved,
            value: _formatNumber(data.saved),
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: l10n.shareCardTopCategory,
            value: _categoryLabel(context, data.topCategory),
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: l10n.shareCardLifeSpent,
            value: data.lifeSpentText,
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: l10n.shareCardHealthScore,
            value: '${data.healthScore}/100',
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: l10n.shareCardLevel,
            value: _levelLabel(l10n, data.level),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.shareCardFooter,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}