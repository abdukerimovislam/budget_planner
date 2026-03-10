import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../data/models/month_close_summary_model.dart';
import '../../l10n/app_localizations.dart';

class MonthCloseSummaryCard extends StatelessWidget {
  final MonthCloseSummaryModel summary;
  final String topCategoryLabel;
  final String lifeSpentText;

  const MonthCloseSummaryCard({
    super.key,
    required this.summary,
    required this.topCategoryLabel,
    required this.lifeSpentText,
  });

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  String _formatSignedPercent(num value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthCloseCardTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.monthlyReportIncome(_formatNumber(summary.totalIncome)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.monthlyReportSpent(_formatNumber(summary.totalSpent)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.monthlyReportSaved(_formatNumber(summary.totalSaved)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.monthCloseSpentChange(
                _formatSignedPercent(summary.spendingChangePercent),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: summary.spendingChangePercent <= 0
                    ? scheme.primary
                    : scheme.error,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.monthlyReportTopCategory(topCategoryLabel),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.monthlyReportLifeSpent(lifeSpentText),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.monthCloseHealthDelta(summary.healthScoreDelta),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}