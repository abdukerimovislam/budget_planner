import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/category_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/auto_budget_card.dart';
import '../../widgets/health_score_explainer_card.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/premium_lock_card.dart';
import '../../widgets/spending_pace_card.dart';
import '../premium/premium_screen.dart';
import '../subscriptions/subscriptions_screen.dart';
import 'category_details_screen.dart';

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

  void _showCurrencyAccountSelector(BuildContext context, HomeProvider provider) {
    if (!provider.canUseFeature(PremiumFeature.multiCurrency)) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }

    final allCurrencies = ['USD', 'EUR', 'GBP', 'RUB', 'KZT', 'KGS', 'UZS', 'UAH', 'BYN'];

    HapticFeedback.lightImpact();
    int initialIndex = allCurrencies.indexOf(provider.activeCurrency);
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
                    provider.setActiveCurrency(allCurrencies[index]);
                  },
                  children: allCurrencies.map((c) => Center(
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

  void _openCategoryDetails(BuildContext context, _DetailedCategoryStat stat, DateTime monthDate) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => CategoryDetailsScreen(
          category: stat.category,
          customCategoryId: stat.customId,
          monthDate: monthDate,
        ),
      ),
    );
  }

  Future<void> _showEditBudgetDialog(BuildContext context) async {
    final provider = context.read<HomeProvider>();
    final l10n = AppLocalizations.of(context);

    final bool hasValidBudget = provider.budget != null && provider.budget!.currency == provider.activeCurrency;
    final currentBudget = hasValidBudget ? provider.budget!.totalBudget : null;

    final controller = TextEditingController(
      text: currentBudget == null ? '' : _formatNumber(currentBudget),
    );

    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(l10n.editBudgetDialogTitle),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: CupertinoTextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              placeholder: '${l10n.monthlyBudgetLabel} (${provider.activeCurrency})',
              autofocus: true,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              isDestructiveAction: true,
              child: Text(l10n.cancelButton),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
                if (value == null || value <= 0) return;

                await provider.updateMonthlyBudget(value, DateTime.now());
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              isDefaultAction: true,
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String currency = provider.activeCurrency;
    final bool hasBudgetForCurrency = provider.budget != null && provider.budget!.currency == currency;
    final totalBudget = hasBudgetForCurrency ? provider.budget!.totalBudget : 0.0;

    final currentMonthExpenses = provider.expensesForMonth(now).where((e) => !e.isIncome).toList();
    final previousMonthExpenses = provider.expensesForPreviousMonth(now).where((e) => !e.isIncome).toList();

    final totalSpent = provider.totalSpentThisMonth(now);
    final remaining = totalBudget > 0 ? (totalBudget - totalSpent) : 0.0;

    final lastMonthTotal = previousMonthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final diff = totalSpent - lastMonthTotal;
    final diffPercent = lastMonthTotal > 0 ? (diff / lastMonthTotal) * 100 : 0.0;
    final isOverspending = diff > 0;

    final double overallProgress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final bool isOverOverall = totalSpent > totalBudget && totalBudget > 0;

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
    final autoBudget = provider.autoBudgetRecommendation(now);
    final dangerousCategory = provider.mostDangerousCategoryThisMonth(now);

    final sections = sortedStats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final isTouched = index == _touchedIndex;
      final percent = totalSpent > 0 ? (stat.amount / totalSpent) * 100 : 0.0;

      final radius = isTouched ? 24.0 : 16.0;

      return PieChartSectionData(
        color: stat.category.dynamicColor(context, customCategoryId: stat.customId),
        value: stat.amount,
        title: '',
        radius: radius,
      );
    }).toList();

    // Если список пустой, добавляем серую заглушку для кольца
    if (sections.isEmpty) {
      sections.add(PieChartSectionData(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), value: 1, title: '', radius: 16.0));
    }

    final hasPremium = provider.canUseFeature(PremiumFeature.multiCurrency);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar.large(
            stretch: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: const Text('Аналитика', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            actions: [
              IconButton(icon: const Icon(CupertinoIcons.pencil_outline), onPressed: () => _showEditBudgetDialog(context)),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () => _showCurrencyAccountSelector(context, provider),
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
                        Text(currency, style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // 1. КОМБИНИРОВАННЫЙ КРУГОВОЙ ГРАФИК (БЮДЖЕТ + КАТЕГОРИИ)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.8 : 1),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (currentMonthExpenses.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOverspending ? CupertinoColors.systemRed.withValues(alpha: 0.1) : CupertinoColors.systemGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isOverspending ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right, size: 14, color: isOverspending ? CupertinoColors.systemRed : CupertinoColors.systemGreen),
                              const SizedBox(width: 4),
                              Text('${diffPercent.abs().toStringAsFixed(1)}% ${l10n.analyticsVsLastMonth}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isOverspending ? CupertinoColors.systemRed : CupertinoColors.systemGreen)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      SizedBox(
                        height: 220,
                        width: 220,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Внутреннее кольцо: Разбивка по категориям
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
                                      if (event is FlTapUpEvent && _touchedIndex >= 0 && _touchedIndex < sortedStats.length) {
                                        _openCategoryDetails(context, sortedStats[_touchedIndex], now);
                                      }
                                    });
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 4,
                                centerSpaceRadius: 75,
                                sections: sections,
                              ),
                            ),

                            // Внешнее кольцо: Общий бюджет
                            if (totalBudget > 0)
                              CircularProgressIndicator(
                                value: overallProgress,
                                strokeWidth: 4,
                                strokeCap: StrokeCap.round,
                                color: isOverOverall ? CupertinoColors.systemRed : theme.colorScheme.primary.withValues(alpha: 0.5),
                              ),

                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (totalBudget == 0) ...[
                                    Text('Нет Бюджета', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                                    const SizedBox(height: 4),
                                    Text(_formatNumber(totalSpent), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, height: 1.1)),
                                  ] else ...[
                                    Text(isOverOverall ? 'Перерасход' : 'Остаток', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                                    const SizedBox(height: 4),
                                    Text(_formatNumber(remaining.abs()), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: isOverOverall ? CupertinoColors.systemRed : theme.colorScheme.onSurface, height: 1.1)),
                                  ],
                                  Text(currency, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (totalBudget == 0) ...[
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => _showEditBudgetDialog(context),
                          icon: const Icon(CupertinoIcons.add),
                          label: Text('Задать бюджет в $currency'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                      ] else ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Бюджет', style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600)),
                                Text('${_formatNumber(totalBudget)} $currency', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Потрачено', style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600)),
                                Text('${_formatNumber(totalSpent)} $currency', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: Responsive.sectionGap(context)),

                // 2. ОПАСНЫЕ ЗОНЫ
                if (dangerousCategory != null && totalBudget > 0) ...[
                  SpendingPaceCard(
                    title: l10n.budgetDangerTitle(dangerousCategory.localizedName(context)),
                    subtitle: l10n.budgetDangerSubtitle,
                    isWarning: true,
                  ),
                  SizedBox(height: Responsive.sectionGap(context)),
                ],

                if (autoBudget.recommendedTotalBudget > 0 && totalBudget == 0) ...[
                  AutoBudgetCard(
                    recommendation: autoBudget,
                    onApplyTap: () async {
                      await provider.applyAutoBudget(now);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.autoBudgetAppliedMessage), behavior: SnackBarBehavior.floating));
                      }
                    },
                  ),
                  SizedBox(height: Responsive.sectionGap(context)),
                ],

                // 3. СПИСОК КАТЕГОРИЙ (ДЕТАЛИЗАЦИЯ)
                if (sortedStats.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16),
                    child: Text('Разбивка расходов', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: theme.colorScheme.onSurface)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: sortedStats.asMap().entries.map((entry) {
                        final isLast = entry.key == sortedStats.length - 1;
                        final stat = entry.value;
                        final percent = totalSpent > 0 ? (stat.amount / totalSpent) : 0.0;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _openCategoryDetails(context, stat, now),
                            borderRadius: isLast
                                ? const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))
                                : entry.key == 0 ? const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)) : BorderRadius.zero,
                            child: _PremiumCategoryRow(
                              categoryName: stat.category.localizedName(context, customCategoryId: stat.customId),
                              categoryColor: stat.category.dynamicColor(context, customCategoryId: stat.customId),
                              iconData: stat.category.dynamicIcon(context, customCategoryId: stat.customId),
                              amount: '${_formatNumber(stat.amount)} $currency',
                              transactionsCountLabel: l10n.analyticsTransactionsCount(stat.count),
                              percent: percent,
                              isLast: isLast,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: Responsive.sectionGap(context)),
                ],

                // 4. ПОДПИСКИ И СЧЕТА
                if (!provider.canUseFeature(PremiumFeature.advancedSubscriptions))
                  PremiumLockCard(
                    title: l10n.premiumLockedSubscriptionsTitle,
                    subtitle: l10n.premiumLockedSubscriptionsSubtitle,
                    onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen())),
                  )
                else
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const SubscriptionsScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.creditcard_fill, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(l10n.openSubscriptionsButton, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
              ]),
            ),
          ),
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
                decoration: BoxDecoration(color: categoryColor.withValues(alpha: 0.15), shape: BoxShape.circle),
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
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 6, width: double.infinity, color: theme.colorScheme.surfaceContainerHighest,
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
                  Text('${(percent * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                ],
              ),
              const SizedBox(width: 8),
              Icon(CupertinoIcons.chevron_right, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
        if (!isLast) Padding(padding: const EdgeInsets.only(left: 64), child: Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
      ],
    );
  }
}