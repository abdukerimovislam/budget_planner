import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/health_score_explainer_card.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/section_header.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Color _colorForCategory(ExpenseCategory category, BuildContext context) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.subscriptions:
        return Colors.purple;
      case ExpenseCategory.entertainment:
        return Colors.red;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.health:
        return Colors.green;
      case ExpenseCategory.bills:
        return Colors.teal;
      case ExpenseCategory.education:
        return Colors.indigo;
      case ExpenseCategory.gifts:
        return Colors.amber;
      case ExpenseCategory.travel:
        return Colors.cyan;
      case ExpenseCategory.other:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _labelForCategory(BuildContext context, ExpenseCategory category) {
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

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final categoryTotals = provider.categoryTotalsForMonth(now);
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpent = provider.totalSpentThisMonth(now);
    final insights = provider.insightsForMonth(now);
    final healthScore = provider.healthScoreFor(now);

    final sections = sortedEntries.map((entry) {
      final percent = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;

      return PieChartSectionData(
        color: _colorForCategory(entry.key, context),
        value: entry.value,
        title: percent >= 7 ? '${percent.toStringAsFixed(0)}%' : '',
        radius: Responsive.isCompactHeight(context) ? 54 : 62,
        titleStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analyticsTab),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            if (sortedEntries.isEmpty) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context) + 8),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pie_chart_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.analyticsEmptyTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.analyticsEmptySubtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              _AnalyticsSummaryCard(
                title: l10n.analyticsTotalSpentTitle,
                value: _formatNumber(totalSpent),
                subtitle: l10n.analyticsTotalSpentSubtitle,
              ),
              SizedBox(height: Responsive.itemGap(context)),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: l10n.analyticsCategoriesTitle),
                      SizedBox(height: Responsive.itemGap(context)),
                      SizedBox(
                        height: Responsive.isCompactHeight(context) ? 220 : 260,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius:
                            Responsive.isCompactHeight(context) ? 34 : 42,
                            sections: sections,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Responsive.sectionGap(context)),
              SectionHeader(title: l10n.analyticsBreakdownTitle),
              SizedBox(height: Responsive.itemGap(context)),
              ...sortedEntries.map(
                    (entry) {
                  final percent =
                  totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          _colorForCategory(entry.key, context),
                          radius: 10,
                        ),
                        title: Text(_labelForCategory(context, entry.key)),
                        subtitle: Text('${percent.toStringAsFixed(1)}%'),
                        trailing: Text(
                          _formatNumber(entry.value),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: Responsive.sectionGap(context)),
              if (sortedEntries.isNotEmpty)
                _AnalyticsSummaryCard(
                  title: l10n.analyticsTopCategoryTitle,
                  value: _labelForCategory(context, sortedEntries.first.key),
                  subtitle: l10n.analyticsTopCategorySubtitle(
                    _formatNumber(sortedEntries.first.value),
                  ),
                ),
              SizedBox(height: Responsive.sectionGap(context)),
              SectionHeader(title: l10n.analyticsInsightsTitle),
              SizedBox(height: Responsive.itemGap(context)),
              if (insights.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.cardPadding(context)),
                    child: Text(
                      l10n.emptyInsightsSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else ...[
                ...insights.map(
                      (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: InsightCard(insight: insight),
                  ),
                ),
                HealthScoreExplainerCard(score: healthScore),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _AnalyticsSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _AnalyticsSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: Responsive.largeTitleSize(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}