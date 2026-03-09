import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/action_plan_card.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/expense_item_card.dart';
import '../../widgets/financial_level_card.dart';
import '../../widgets/health_score_explainer_card.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/premium_lock_card.dart';
import '../../widgets/quick_add_chips.dart';
import '../../widgets/savings_goal_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/spending_pace_card.dart';
import '../../widgets/streak_card.dart';
import '../achievements/achievements_screen.dart';
import '../add_expense/add_expense_screen.dart';
import '../month_close/month_close_screen.dart';
import '../premium/premium_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDuration(BuildContext context, Duration duration) {
    final l10n = AppLocalizations.of(context);
    final totalMinutes = duration.inMinutes;

    if (totalMinutes <= 0) {
      return l10n.durationMinutesOnly(0);
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return l10n.durationMinutesOnly(minutes);
    }

    if (minutes == 0) {
      return l10n.durationHoursOnly(hours);
    }

    return l10n.durationHoursMinutes(hours, minutes);
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isYesterday(DateTime date, DateTime now) {
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return _isSameDay(date, yesterday);
  }

  String _sectionTitle(
      BuildContext context,
      DateTime date,
      DateTime now,
      ) {
    final l10n = AppLocalizations.of(context);

    if (_isSameDay(date, now)) return l10n.todaySection;
    if (_isYesterday(date, now)) return l10n.yesterdaySection;
    return l10n.earlierSection;
  }

  List<_ExpenseSection> _buildSections(
      BuildContext context,
      List<ExpenseModel> expenses,
      ) {
    final now = DateTime.now();
    final sections = <_ExpenseSection>[];

    for (final expense in expenses) {
      final title = _sectionTitle(context, expense.date, now);

      if (sections.isEmpty || sections.last.title != title) {
        sections.add(_ExpenseSection(title: title, items: [expense]));
      } else {
        sections.last.items.add(expense);
      }
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final forecast = provider.forecastFor(now);
    final totalSpent = provider.totalSpentThisMonth(now);
    final healthScore = provider.healthScoreFor(now);
    final lifeDuration = provider.spentLifeDurationForMonth(now);
    final latestExpenses = provider.latestExpenses();
    final sections = _buildSections(context, latestExpenses);
    final insights = provider.insightsForMonth(now);
    final report = provider.monthlyReport(now);
    final dangerousCategory = provider.mostDangerousCategoryThisMonth(now);
    final goal = provider.savingsGoal;
    final goalProjection = provider.savingsGoalProjection(now);
    final actionPlan = provider.actionPlan(now);
    final streak = provider.streakSummary();
    final sectionGap = Responsive.sectionGap(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTab),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            _CardBlock(
              title: l10n.spentThisMonth,
              value: _formatNumber(totalSpent),
              subtitle: l10n.lifeSpent(_formatDuration(context, lifeDuration)),
            ),
            SizedBox(height: Responsive.itemGap(context)),
            _CardBlock(
              title: l10n.financialHealthScore,
              value: l10n.scoreValue(healthScore),
              subtitle: l10n.monthlyFinancialPulse,
            ),
            SizedBox(height: Responsive.itemGap(context)),
            _CardBlock(
              title: l10n.forecast,
              value: forecast == null
                  ? l10n.notAvailableShort
                  : _formatNumber(forecast.expectedRemaining),
              subtitle: forecast == null
                  ? l10n.setBudgetToUnlockForecast
                  : forecast.isOverBudget
                  ? l10n.riskOfOverspending
                  : l10n.withinBudgetPace,
            ),

            SizedBox(height: sectionGap),
            SectionHeader(title: l10n.quickAddTitle),
            SizedBox(height: Responsive.itemGap(context)),
            QuickAddChips(
              onTapCategory: (category) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddExpenseScreen(initialCategory: category),
                  ),
                );
              },
            ),

            SizedBox(height: sectionGap),
            SectionHeader(title: l10n.streakTitle),
            SizedBox(height: Responsive.itemGap(context)),
            StreakCard(
              streak: streak,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AchievementsScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: sectionGap),
            SectionHeader(title: l10n.financialLevelTitle),
            SizedBox(height: Responsive.itemGap(context)),
            FinancialLevelCard(
              level: report.level,
              onTapReport: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MonthlyReportScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: sectionGap),
            SectionHeader(title: l10n.monthCloseTitle),
            SizedBox(height: Responsive.itemGap(context)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.monthCloseHomeTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.monthCloseHomeSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MonthCloseScreen(),
                          ),
                        );
                      },
                      child: Text(l10n.monthCloseOpenButton),
                    ),
                  ],
                ),
              ),
            ),

            if (goal != null && goalProjection != null) ...[
              SizedBox(height: sectionGap),
              SectionHeader(title: l10n.goalsTitle),
              SizedBox(height: Responsive.itemGap(context)),
              SavingsGoalCard(
                goal: goal,
                projection: goalProjection,
              ),
            ],

            if (dangerousCategory != null) ...[
              SizedBox(height: sectionGap),
              SpendingPaceCard(
                title: l10n.budgetDangerTitle(
                  _categoryLabel(context, dangerousCategory),
                ),
                subtitle: l10n.budgetDangerSubtitle,
                isWarning: true,
              ),
            ],

            SizedBox(height: sectionGap),
            SectionHeader(title: l10n.financialRadarTitle),
            SizedBox(height: Responsive.itemGap(context)),
            if (!provider.canUseFeature(PremiumFeature.aiInsights))
              PremiumLockCard(
                title: l10n.premiumLockedInsightsTitle,
                subtitle: l10n.premiumLockedInsightsSubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PremiumScreen(),
                    ),
                  );
                },
              )
            else if (insights.isEmpty)
              const _EmptyInsightsState()
            else ...[
                ...insights.map(
                      (insight) => Padding(
                    padding: EdgeInsets.only(bottom: Responsive.itemGap(context)),
                    child: InsightCard(insight: insight),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: Responsive.itemGap(context)),
                  child: HealthScoreExplainerCard(score: healthScore),
                ),
              ],

            SizedBox(height: sectionGap),
            SectionHeader(title: l10n.actionPlanTitle),
            SizedBox(height: Responsive.itemGap(context)),
            if (!provider.canUseFeature(PremiumFeature.actionPlanner))
              PremiumLockCard(
                title: l10n.premiumLockedActionPlanTitle,
                subtitle: l10n.premiumLockedActionPlanSubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PremiumScreen(),
                    ),
                  );
                },
              )
            else if (actionPlan.isEmpty)
              const _EmptyActionPlanState()
            else
              ...actionPlan.map(
                    (item) => Padding(
                  padding: EdgeInsets.only(bottom: Responsive.itemGap(context)),
                  child: ActionPlanCard(item: item),
                ),
              ),

            SizedBox(height: sectionGap),
            SectionHeader(title: l10n.recentExpensesTitle),
            SizedBox(height: Responsive.itemGap(context)),
            if (latestExpenses.isEmpty)
              const _EmptyExpensesState()
            else
              ...sections.expand((section) {
                return [
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppSpacing.xs,
                      bottom: AppSpacing.xs,
                    ),
                    child: Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ...section.items.map(
                        (expense) => Padding(
                      padding:
                      EdgeInsets.only(bottom: Responsive.itemGap(context)),
                      child: Dismissible(
                        key: ValueKey(expense.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                        ),
                        onDismissed: (_) {
                          context.read<HomeProvider>().deleteExpense(expense.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.expenseDeletedMessage),
                            ),
                          );
                        },
                        child: ExpenseItemCard(
                          expense: expense,
                          incomeProfile: provider.incomeProfile,
                          onTap: () => provider.openExpenseEditor(context, expense),
                        ),
                      ),
                    ),
                  ),
                ];
              }),

            SizedBox(height: 96 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
        },
        tooltip: l10n.addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _CardBlock({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardPadding = Responsive.cardPadding(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: Responsive.largeTitleSize(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _EmptyExpensesState extends StatelessWidget {
  const _EmptyExpensesState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context) + 8),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.emptyExpensesTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyExpensesSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyInsightsState extends StatelessWidget {
  const _EmptyInsightsState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.insights_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.emptyInsightsTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyInsightsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActionPlanState extends StatelessWidget {
  const _EmptyActionPlanState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.actionPlanEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.actionPlanEmptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseSection {
  final String title;
  final List<ExpenseModel> items;

  _ExpenseSection({
    required this.title,
    required this.items,
  });
}