import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/category_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/insight_model.dart';
import '../../../data/models/insight_type.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/apple_section_header.dart';
import '../../widgets/expense_item_card.dart';
import '../../widgets/hero_dashboard_card.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/morphing_fab.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/quick_add_chips.dart';
import '../../widgets/spending_pace_card.dart';
import '../add_expense/add_expense_screen.dart';
import '../ai_advisor/ai_advisor_screen.dart';
import '../expenses/expenses_screen.dart';
import '../premium/premium_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/custom_category_sheet.dart';

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

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  String _formatLifeTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours <= 0 && minutes <= 0) return '0m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String _resolveInsightTitle(BuildContext context, InsightModel insight) {
    final l10n = AppLocalizations.of(context);
    switch (insight.titleKey) {
      case 'insightOverBudgetTitle': return l10n.insightOverBudgetTitle;
      case 'insightHealthyPaceTitle': return l10n.insightHealthyPaceTitle;
      case 'insightTopCategoryTitle': return l10n.insightTopCategoryTitle;
      case 'insightSubscriptionsTitle': return l10n.insightSubscriptionsTitle;
      case 'insightStrongScoreTitle': return l10n.insightStrongScoreTitle;
      case 'insightLowScoreTitle': return l10n.insightLowScoreTitle;
      default: return insight.titleKey;
    }
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
              Container(width: 48, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4))),
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

  void _showCustomCategoryDialog(BuildContext context) async {
    final newCategory = await CustomCategorySheet.show(context);
    if (newCategory != null && context.mounted) {
      Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => AddExpenseScreen(
              initialCustomCategoryId: newCategory.id,
            ),
          )
      );
    }
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

  void _showCurrencyAccountSelector(BuildContext context, HomeProvider provider) {
    if (!provider.canUseFeature(PremiumFeature.multiCurrency)) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }

    // ИСПРАВЛЕНИЕ: Показываем все доступные валюты системы, чтобы юзер мог переключиться на пустой счет
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
                child: Text('Select Account', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: initialIndex),
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    // Переключаем дашборд на выбранную валюту
                    provider.setActiveCurrency(allCurrencies[index]);
                  },
                  children: allCurrencies.map((c) => Center(
                    child: Text('$c Account', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final forecast = provider.forecastFor(now);
    final totalSpent = provider.totalSpentThisMonth(now);
    final healthScore = provider.healthScoreFor(now);
    final latestExpenses = provider.latestExpenses(limit: 5);
    final insights = provider.insightsForMonth(now);
    final dangerousCategory = provider.mostDangerousCategoryThisMonth(now);

    final lifeSpentDuration = provider.spentLifeDurationForMonth(now);
    final lifeSpentFormatted = _formatLifeTime(lifeSpentDuration);

    final itemGap = Responsive.itemGap(context);
    final sectionGap = Responsive.sectionGap(context) * 1.2;

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, 31);
    final safeToSpendDaily = forecast != null && forecast.expectedRemaining > 0
        ? forecast.expectedRemaining / daysLeft : 0.0;

    final activeCurrency = provider.activeCurrency;
    final hasMultipleCurrencies = provider.availableUserCurrencies.length > 1;
    final hasPremium = provider.canUseFeature(PremiumFeature.multiCurrency);

    return PremiumBackground(
      child: GestureDetector(
        onTap: () { if (_isFabExpanded) setState(() => _isFabExpanded = false); },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverAppBar.large(
                    stretch: true,
                    backgroundColor: Colors.transparent,
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
                        padding: const EdgeInsets.only(right: 8.0),
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
                                Text(
                                  activeCurrency,
                                  style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                                ),
                                if (hasPremium && hasMultipleCurrencies) ...[
                                  const SizedBox(width: 4),
                                  Icon(CupertinoIcons.chevron_up_chevron_down, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
                            child: Icon(CupertinoIcons.person, color: Theme.of(context).colorScheme.primary, size: 20),
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

                        // HERO DASHBOARD
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
                                  value: '${_formatNumber(_showRemaining ? (forecast?.expectedRemaining ?? 0) : totalSpent)} $activeCurrency',
                                  isWarning: _showRemaining && (forecast?.isOverBudget ?? false),
                                  bottomWidget: _GlassMetricRow(
                                    isGold: false,
                                    leftIcon: CupertinoIcons.heart_fill,
                                    leftLabel: l10n.healthLabel,
                                    leftValue: '$healthScore/100',
                                    rightIcon: _showRemaining ? CupertinoIcons.calendar_today : CupertinoIcons.clock_fill,
                                    rightLabel: _showRemaining ? l10n.daysLeftLabel : l10n.shareCardLifeSpent,
                                    rightValue: _showRemaining ? '$daysLeft' : lifeSpentFormatted,
                                  ),
                                ),
                              ),
                              HeroDashboardCard(
                                metal: CardMetal.gold,
                                label: l10n.safeToSpendToday,
                                value: '${_formatNumber(safeToSpendDaily)} $activeCurrency',
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
                              color: _currentHeroPage == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
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
                          onTapCategory: (cat) => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => AddExpenseScreen(initialCategory: cat))),
                          onCustomCategoryTap: () => _showCustomCategoryDialog(context),
                        ),

                        SizedBox(height: sectionGap),

                        // AI INSIGHTS
                        if (insights.isNotEmpty && provider.canUseFeature(PremiumFeature.aiInsights)) ...[
                          AppleSectionHeader(
                            title: l10n.aiInsightsTitle,
                            action: 'Ask AI',
                            onActionTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(builder: (_) => const AiAdvisorScreen()),
                              );
                            },
                          ),
                          SizedBox(height: itemGap),
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              clipBehavior: Clip.none,
                              itemCount: insights.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final insight = insights[index];
                                final isWarning = insight.type == InsightType.warning;
                                final color = isWarning ? CupertinoColors.systemOrange : CupertinoColors.activeBlue;
                                final icon = isWarning ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.lightbulb_fill;

                                return GestureDetector(
                                  onTap: () => _showInsightStory(context, insight),
                                  child: Container(
                                    width: 260,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                                              child: Icon(icon, color: color, size: 16),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              isWarning ? l10n.warningLabel.toUpperCase() : l10n.tipLabel.toUpperCase(),
                                              style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 11, letterSpacing: 1.2),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          _resolveInsightTitle(context, insight),
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Theme.of(context).colorScheme.onSurface, height: 1.2),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: sectionGap),
                        ],

                        // ИСПРАВЛЕНИЕ: Оставили только реальные угрозы (Action Plan переехал в AI Advisor)
                        if (dangerousCategory != null) ...[
                          AppleSectionHeader(title: l10n.financialRadarTitle),
                          SizedBox(height: itemGap),
                          SpendingPaceCard(
                            title: l10n.budgetDangerTitle(dangerousCategory.localizedName(context)),
                            subtitle: l10n.budgetDangerSubtitle,
                            isWarning: true,
                          ),
                          SizedBox(height: sectionGap),
                        ],

                        // TRANSACTIONS
                        AppleSectionHeader(
                          title: l10n.recentExpensesTitle,
                          action: l10n.historyAction,
                          onActionTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ExpensesScreen())),
                        ),
                        SizedBox(height: itemGap),
                        if (latestExpenses.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
                            child: Column(
                              children: _buildSections(context, latestExpenses).expand((section) {
                                return [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                                    child: Text(
                                      section.title.toUpperCase(),
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                                        if (!isLast) Padding(padding: const EdgeInsets.only(left: 64), child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
                                      ],
                                    );
                                  }),
                                ];
                              }).toList(),
                            ),
                          ),

                        if (latestExpenses.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
                            child: Center(
                              child: Text('No transactions in $activeCurrency yet', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
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
                onSelectSource: (mode, isIncome) {
                  setState(() => _isFabExpanded = false);
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => AddExpenseScreen(
                        initialIsIncome: isIncome,
                      )
                  ));
                },
              ),
            ],
          ),
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
              color: isGold ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: isGold ? 0.4 : 0.1), width: 1)
          ),
          child: Row(
            children: [
              Expanded(child: _buildItem(leftIcon, leftLabel, leftValue, isGold ? CupertinoColors.systemRed : CupertinoColors.systemPink, textColor, subTextColor)),
              Container(width: 1, height: 35, color: textColor.withValues(alpha: 0.2)),
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
              color: isGold ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: isGold ? 0.4 : 0.1), width: 1)
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