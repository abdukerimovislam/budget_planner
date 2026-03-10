import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/expense_source_type.dart';
import '../../../data/models/insight_model.dart';
import '../../../data/models/insight_type.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/action_plan_card.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/apple_section_header.dart';
import '../../widgets/expense_item_card.dart';
import '../../widgets/hero_dashboard_card.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/morphing_fab.dart';
import '../../widgets/premium_lock_card.dart';
import '../../widgets/quick_add_chips.dart';
import '../../widgets/spending_pace_card.dart';
import '../add_expense/add_expense_screen.dart';
import '../expenses/expenses_screen.dart';
import '../premium/premium_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _heroPageController = PageController();
  int _currentHeroPage = 0;
  bool _showRemaining = false;
  bool _isFabExpanded = false;

  @override
  void dispose() {
    _heroPageController.dispose();
    super.dispose();
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context);
    if (hour >= 5 && hour < 12) return l10n.greetingMorning;
    if (hour >= 12 && hour < 17) return l10n.greetingAfternoon;
    if (hour >= 17 && hour < 22) return l10n.greetingEvening;
    return l10n.greetingNight;
  }

  List<ExpenseCategory> _getSmartCategories() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return [ExpenseCategory.food, ExpenseCategory.transport, ExpenseCategory.bills];
    if (hour >= 11 && hour < 16) return [ExpenseCategory.food, ExpenseCategory.shopping, ExpenseCategory.other];
    return [ExpenseCategory.entertainment, ExpenseCategory.food, ExpenseCategory.transport];
  }

  // --- ВОТ ТОТ САМЫЙ МЕТОД, КОТОРЫЙ МЫ ВЕРНУЛИ ---
  String _categoryLabel(BuildContext context, ExpenseCategory category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case ExpenseCategory.food: return l10n.categoryFood;
      case ExpenseCategory.transport: return l10n.categoryTransport;
      case ExpenseCategory.subscriptions: return l10n.categorySubscriptions;
      case ExpenseCategory.entertainment: return l10n.categoryEntertainment;
      case ExpenseCategory.shopping: return l10n.categoryShopping;
      case ExpenseCategory.health: return l10n.categoryHealth;
      case ExpenseCategory.bills: return l10n.categoryBills;
      case ExpenseCategory.education: return l10n.categoryEducation;
      case ExpenseCategory.gifts: return l10n.categoryGifts;
      case ExpenseCategory.travel: return l10n.categoryTravel;
      case ExpenseCategory.other: return l10n.categoryOther;
    }
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  void _showInsightStory(BuildContext context, InsightModel insight) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 24),
              InsightCard(insight: insight),
              const SizedBox(height: 24),
              FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.gotItButton)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomCategoryDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addCustomCategoryTitle),
        content: Text(l10n.addCustomCategorySubtitle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isYesterday(DateTime date, DateTime now) {
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return _isSameDay(date, yesterday);
  }

  String _sectionTitle(BuildContext context, DateTime date, DateTime now) {
    final l10n = AppLocalizations.of(context);
    if (_isSameDay(date, now)) return l10n.todaySection;
    if (_isYesterday(date, now)) return l10n.yesterdaySection;
    return l10n.earlierSection;
  }

  List<_ExpenseSection> _buildSections(BuildContext context, List<ExpenseModel> expenses) {
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
    final materialL10n = MaterialLocalizations.of(context);
    final now = DateTime.now();

    final forecast = provider.forecastFor(now);
    final totalSpent = provider.totalSpentThisMonth(now);
    final healthScore = provider.healthScoreFor(now);
    final latestExpenses = provider.latestExpenses(limit: 5);
    final insights = provider.insightsForMonth(now);
    final actionPlan = provider.actionPlan(now);
    final dangerousCategory = provider.mostDangerousCategoryThisMonth(now);

    final itemGap = Responsive.itemGap(context);
    final sectionGap = Responsive.sectionGap(context) * 1.2;

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, 31);
    final safeToSpendDaily = forecast != null && forecast.expectedRemaining > 0
        ? forecast.expectedRemaining / daysLeft : 0.0;

    return GestureDetector(
      onTap: () { if (_isFabExpanded) setState(() => _isFabExpanded = false); },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverAppBar.large(
                  stretch: true,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  surfaceTintColor: Colors.transparent,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getGreeting(context).toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Theme.of(context).colorScheme.primary),
                      ),
                      Text(l10n.homeTab, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
                        child: Icon(CupertinoIcons.person, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),

                      // HERO DASHBOARD (BANK CARDS)
                      SizedBox(
                        height: 250,
                        child: PageView(
                          controller: _heroPageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (idx) => setState(() => _currentHeroPage = idx),
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _showRemaining = !_showRemaining),
                              child: HeroDashboardCard(
                                metal: CardMetal.platinum,
                                label: _showRemaining ? l10n.leftToSpend : l10n.spentThisMonth.toUpperCase(),
                                value: _formatNumber(_showRemaining ? (forecast?.expectedRemaining ?? 0) : totalSpent),
                                isWarning: _showRemaining && (forecast?.isOverBudget ?? false),
                                bottomWidget: _GlassMetricRow(
                                  isGold: false,
                                  leftIcon: CupertinoIcons.heart_fill, leftLabel: l10n.healthLabel, leftValue: '$healthScore/100',
                                  rightIcon: CupertinoIcons.calendar_today, rightLabel: l10n.daysLeftLabel, rightValue: '$daysLeft',
                                ),
                              ),
                            ),
                            HeroDashboardCard(
                              metal: CardMetal.gold,
                              label: l10n.safeToSpendToday,
                              value: _formatNumber(safeToSpendDaily),
                              withSparkline: true,
                              bottomWidget: _GlassTextBanner(text: l10n.keepPaceBudget, isGold: true),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6, width: _currentHeroPage == index ? 24 : 6,
                          decoration: BoxDecoration(
                            color: _currentHeroPage == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                      ),

                      SizedBox(height: sectionGap),

                      // QUICK ADD
                      AppleSectionHeader(title: l10n.quickAddTitle),
                      SizedBox(height: itemGap),
                      QuickAddChips(
                        categories: _getSmartCategories(),
                        onTapCategory: (cat) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddExpenseScreen(initialCategory: cat))),
                        onCustomCategoryTap: () => _showCustomCategoryDialog(context),
                      ),

                      SizedBox(height: sectionGap),

                      // AI INSIGHTS
                      if (insights.isNotEmpty && provider.canUseFeature(PremiumFeature.aiInsights)) ...[
                        AppleSectionHeader(title: l10n.aiInsightsTitle, action: l10n.seeAllAction),
                        SizedBox(height: itemGap),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), clipBehavior: Clip.none,
                            itemCount: insights.length, separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final insight = insights[index];
                              final isWarning = insight.type == InsightType.warning;
                              return GestureDetector(
                                onTap: () => _showInsightStory(context, insight),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: isWarning ? [Colors.orange, Colors.red] : [Colors.blue, Colors.purple])),
                                      child: Container(
                                        padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
                                        child: Icon(isWarning ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.lightbulb_fill, color: isWarning ? Colors.red : Colors.purple),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(isWarning ? l10n.warningLabel : l10n.tipLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: sectionGap),
                      ],

                      // ПЛАН ДЕЙСТВИЙ (AI ADVISOR)
                      if (dangerousCategory != null || actionPlan.isNotEmpty) ...[
                        AppleSectionHeader(title: l10n.financialRadarTitle),
                        SizedBox(height: itemGap),
                        if (dangerousCategory != null) ...[
                          SpendingPaceCard(
                            title: l10n.budgetDangerTitle(_categoryLabel(context, dangerousCategory)), // Ошибка была здесь! Теперь всё работает.
                            subtitle: l10n.budgetDangerSubtitle,
                            isWarning: true,
                          ),
                          SizedBox(height: itemGap),
                        ],
                        if (actionPlan.isNotEmpty) ...actionPlan.map((item) => Padding(
                          padding: EdgeInsets.only(bottom: itemGap),
                          child: ActionPlanCard(item: item),
                        )),
                        SizedBox(height: sectionGap),
                      ],

                      // TRANSACTIONS
                      AppleSectionHeader(
                        title: l10n.recentExpensesTitle,
                        action: l10n.historyAction,
                        onActionTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExpensesScreen())),
                      ),
                      SizedBox(height: itemGap),
                      if (latestExpenses.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: _buildSections(context, latestExpenses).expand((section) {
                              return [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                                  child: Text(
                                    section.title.toUpperCase(),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                ...section.items.asMap().entries.map((entry) {
                                  final expense = entry.value;
                                  final isLast = entry.key == section.items.length - 1;
                                  return Column(
                                    children: [
                                      Dismissible(
                                        key: ValueKey(expense.id),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                          color: CupertinoColors.destructiveRed,
                                          child: const Icon(CupertinoIcons.trash, color: Colors.white),
                                        ),
                                        onDismissed: (_) => context.read<HomeProvider>().deleteExpense(expense.id),
                                        child: ExpenseItemCard(expense: expense, incomeProfile: provider.incomeProfile, onTap: () => provider.openExpenseEditor(context, expense)),
                                      ),
                                      if (!isLast) Padding(padding: const EdgeInsets.only(left: 64), child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceVariant)),
                                    ],
                                  );
                                }),
                              ];
                            }).toList(),
                          ),
                        ),

                      SizedBox(height: 140 + MediaQuery.of(context).padding.bottom),
                    ]),
                  ),
                ),
              ],
            ),

            // MORPHING FAB
            MorphingFab(
              isExpanded: _isFabExpanded,
              onToggle: () => setState(() => _isFabExpanded = !_isFabExpanded),
              onSelectSource: (mode) {
                setState(() => _isFabExpanded = false);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassMetricRow extends StatelessWidget {
  final bool isGold;
  final IconData leftIcon; final String leftLabel; final String leftValue;
  final IconData rightIcon; final String rightLabel; final String rightValue;
  const _GlassMetricRow({required this.isGold, required this.leftIcon, required this.leftLabel, required this.leftValue, required this.rightIcon, required this.rightLabel, required this.rightValue});

  @override
  Widget build(BuildContext context) {
    final textColor = isGold ? const Color(0xFF3E2B08) : Colors.white;
    final subTextColor = isGold ? const Color(0xFF7A5C22) : const Color(0xFFEBEBF5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isGold ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(isGold ? 0.4 : 0.1), width: 1)
          ),
          child: Row(
            children: [
              Expanded(child: _buildItem(leftIcon, leftLabel, leftValue, isGold ? CupertinoColors.systemRed : CupertinoColors.systemPink, textColor, subTextColor)),
              Container(width: 1, height: 35, color: textColor.withOpacity(0.2)),
              const SizedBox(width: 16),
              Expanded(child: _buildItem(rightIcon, rightLabel, rightValue, isGold ? CupertinoColors.systemBlue : CupertinoColors.activeBlue, textColor, subTextColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, String value, Color iconColor, Color textColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 14, color: iconColor), const SizedBox(width: 6), Text(label, style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w600))]),
        const SizedBox(height: 6), Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _GlassTextBanner extends StatelessWidget {
  final String text;
  final bool isGold;
  const _GlassTextBanner({required this.text, required this.isGold});

  @override
  Widget build(BuildContext context) {
    final textColor = isGold ? const Color(0xFF3E2B08) : Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
              color: isGold ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(isGold ? 0.4 : 0.1), width: 1)
          ),
          child: Row(children: [
            Icon(CupertinoIcons.sparkles, color: isGold ? Colors.deepOrange : Colors.amber, size: 16),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600))
          ]),
        ),
      ),
    );
  }
}

class _ExpenseSection {
  final String title;
  final List<ExpenseModel> items;

  _ExpenseSection({required this.title, required this.items});
}