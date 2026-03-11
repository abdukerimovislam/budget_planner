import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/category_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/health_score_explainer_card.dart';
import '../../widgets/insight_card.dart';

class _DetailedCategoryStat {
  final ExpenseCategory category;
  final String? customId;
  double amount;
  int count;

  _DetailedCategoryStat({
    required this.category,
    required this.customId,
    this.amount = 0.0,
    this.count = 0,
  });
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedIndex = -1;

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ИСПРАВЛЕНИЕ БАГА: Фильтруем транзакции, оставляем ТОЛЬКО РАСХОДЫ!
    final currentMonthExpenses = provider.expensesForMonth(now).where((e) => !e.isIncome).toList();
    final previousMonthExpenses = provider.expensesForPreviousMonth(now).where((e) => !e.isIncome).toList();

    // ИСПРАВЛЕНИЕ: Берем валюту надежно из профиля пользователя (как мы сделали в других местах)
    final String currency = provider.incomeProfile?.currency ?? 'USD';

    final totalSpent = provider.totalSpentThisMonth(now);
    final lastMonthTotal = previousMonthExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    final diff = totalSpent - lastMonthTotal;
    final diffPercent = lastMonthTotal > 0 ? (diff / lastMonthTotal) * 100 : 0.0;
    final isOverspending = diff > 0;

    final transactionsCount = currentMonthExpenses.length;
    final dailyAvg = now.day > 0 ? totalSpent / now.day : 0.0;

    ExpenseModel? highestExpense;
    if (currentMonthExpenses.isNotEmpty) {
      highestExpense = currentMonthExpenses.reduce((a, b) => a.amount > b.amount ? a : b);
    }

    // ИДЕАЛЬНАЯ ГРУППИРОВКА
    final breakdown = <String, _DetailedCategoryStat>{};
    for (final e in currentMonthExpenses) {
      final key = e.category == ExpenseCategory.custom ? 'custom_${e.customCategoryId}' : e.category.name;
      if (!breakdown.containsKey(key)) {
        breakdown[key] = _DetailedCategoryStat(category: e.category, customId: e.customCategoryId);
      }
      breakdown[key]!.amount += e.amount;
      breakdown[key]!.count += 1;
    }

    final sortedStats = breakdown.values.toList()..sort((a, b) => b.amount.compareTo(a.amount));

    final insights = provider.insightsForMonth(now);
    final healthScore = provider.healthScoreFor(now);

    final sections = sortedStats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final isTouched = index == _touchedIndex;
      final percent = totalSpent > 0 ? (stat.amount / totalSpent) * 100 : 0.0;

      final radius = isTouched ? 45.0 : 32.0;
      final fontSize = isTouched ? 16.0 : 10.0;

      return PieChartSectionData(
        color: stat.category.dynamicColor(context, customCategoryId: stat.customId),
        value: stat.amount,
        title: percent >= 4 ? '${percent.toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.15),
                    theme.colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.1),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar.large(
                stretch: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  l10n.analyticsTab,
                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    if (sortedStats.isEmpty) ...[
                      _buildEmptyState(context, l10n, theme),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(isDark ? 0.8 : 1),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.05),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isOverspending
                                    ? CupertinoColors.systemRed.withOpacity(0.1)
                                    : CupertinoColors.systemGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isOverspending ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right,
                                    size: 14,
                                    color: isOverspending ? CupertinoColors.systemRed : CupertinoColors.systemGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${diffPercent.abs().toStringAsFixed(1)}% ${l10n.analyticsVsLastMonth}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isOverspending ? CupertinoColors.systemRed : CupertinoColors.systemGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              height: 240,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 140, height: 140,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary.withOpacity(0.2),
                                            blurRadius: 40,
                                          )
                                        ]
                                    ),
                                  ),
                                  PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                          setState(() {
                                            if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                              _touchedIndex = -1;
                                              return;
                                            }
                                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                          });
                                        },
                                      ),
                                      borderData: FlBorderData(show: false),
                                      sectionsSpace: 4,
                                      centerSpaceRadius: Responsive.isCompactHeight(context) ? 65 : 85,
                                      sections: sections,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l10n.spentThisMonth.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatNumber(totalSpent),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: theme.colorScheme.onSurface,
                                          height: 1.1,
                                        ),
                                      ),
                                      Text(
                                        currency, // ВАЛЮТА В ЦЕНТРЕ ГРАФИКА
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.itemGap(context)),

                      Row(
                        children: [
                          Expanded(child: _MiniStatCard(icon: CupertinoIcons.calendar, title: l10n.analyticsDailyAvg, value: '${_formatNumber(dailyAvg)} $currency')),
                          const SizedBox(width: 8),
                          Expanded(child: _MiniStatCard(icon: CupertinoIcons.tag_fill, title: l10n.analyticsTransactions, value: transactionsCount.toString())),
                        ],
                      ),

                      if (highestExpense != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: CupertinoColors.systemYellow.withOpacity(0.15), shape: BoxShape.circle),
                                child: const Icon(CupertinoIcons.star_fill, color: CupertinoColors.systemYellow, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.analyticsLargestTransaction, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CupertinoColors.systemGrey)),
                                    const SizedBox(height: 2),
                                    Text(
                                      highestExpense.merchant.isNotEmpty ? highestExpense.merchant : highestExpense.category.localizedName(context, customCategoryId: highestExpense.customCategoryId),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // ВАЛЮТА ДЛЯ САМОЙ БОЛЬШОЙ ТРАТЫ
                              Text(
                                '${_formatNumber(highestExpense.amount)} $currency',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: Responsive.sectionGap(context)),

                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 16),
                        child: Text(
                          l10n.analyticsBreakdownTitle,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: theme.colorScheme.onSurface),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: sortedStats.asMap().entries.map((entry) {
                            final isLast = entry.key == sortedStats.length - 1;
                            final stat = entry.value;
                            final percent = totalSpent > 0 ? (stat.amount / totalSpent) : 0.0;

                            return _PremiumCategoryRow(
                              categoryName: stat.category.localizedName(context, customCategoryId: stat.customId),
                              categoryColor: stat.category.dynamicColor(context, customCategoryId: stat.customId),
                              iconData: stat.category.dynamicIcon(context, customCategoryId: stat.customId),
                              amount: '${_formatNumber(stat.amount)} $currency', // ВАЛЮТА ДЛЯ КАТЕГОРИИ
                              transactionsCountLabel: l10n.analyticsTransactionsCount(stat.count),
                              percent: percent,
                              isLast: isLast,
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: Responsive.sectionGap(context)),

                      if (insights.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Text(
                            l10n.analyticsInsightsTitle,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: theme.colorScheme.onSurface),
                          ),
                        ),
                        ...insights.map(
                              (insight) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: InsightCard(insight: insight),
                          ),
                        ),
                        const SizedBox(height: 8),
                        HealthScoreExplainerCard(score: healthScore),
                      ],
                    ],

                    SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(CupertinoIcons.chart_pie_fill, size: 48, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(l10n.analyticsEmptyTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(l10n.analyticsEmptySubtitle, style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniStatCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CupertinoColors.systemGrey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _PremiumCategoryRow extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData iconData;
  final String amount;
  final String transactionsCountLabel;
  final double percent;
  final bool isLast;

  const _PremiumCategoryRow({
    required this.categoryName,
    required this.categoryColor,
    required this.iconData,
    required this.amount,
    required this.transactionsCountLabel,
    required this.percent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: categoryColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(iconData, color: categoryColor, size: 20),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(categoryName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text(
                      transactionsCountLabel,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 6, width: double.infinity, color: theme.colorScheme.surfaceVariant,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft, widthFactor: percent,
                          child: Container(decoration: BoxDecoration(color: categoryColor, borderRadius: BorderRadius.circular(4))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('${(percent * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) Padding(padding: const EdgeInsets.only(left: 64), child: Divider(height: 1, color: theme.colorScheme.surfaceVariant.withOpacity(0.5))),
      ],
    );
  }
}