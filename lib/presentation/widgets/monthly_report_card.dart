import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../domain/services/monthly_report_model.dart';
import '../../l10n/app_localizations.dart';

class MonthlyReportCard extends StatelessWidget {
  final MonthlyReportModel report;
  final String topCategoryLabel;
  final String lifeSpentText;

  const MonthlyReportCard({
    super.key,
    required this.report,
    required this.topCategoryLabel,
    required this.lifeSpentText,
  });

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyReportTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.monthlyReportIncome(_formatNumber(report.totalIncome)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.monthlyReportSpent(_formatNumber(report.totalSpent)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.monthlyReportSaved(_formatNumber(report.totalSaved)),
              style: Theme.of(context).textTheme.bodyMedium,
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
              l10n.monthlyReportScore(report.healthScore),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}