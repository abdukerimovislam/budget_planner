import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_model.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/apple_section_header.dart';
import '../../widgets/expense_edit_sheet.dart';
import '../../widgets/expense_item_card.dart';
import '../../widgets/hero_dashboard_card.dart';
import '../expenses/expenses_screen.dart';
import '../premium/premium_screen.dart';
import '../profile/profile_screen.dart';
import '../budget/budget_screen.dart';

// ПРОВАЙДЕРЫ
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/insights_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showRemaining = false;
  String _searchQuery = '';

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context);
    if (hour >= 5 && hour < 12) return l10n.greetingMorning;
    if (hour >= 12 && hour < 17) return l10n.greetingAfternoon;
    if (hour >= 17 && hour < 22) return l10n.greetingEvening;
    return l10n.greetingNight;
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

  void _showCurrencyAccountSelector(BuildContext context, SettingsProvider settings) {
    if (!settings.canUseFeature(PremiumFeature.multiCurrency)) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }

    final allCurrencies = ['USD', 'EUR', 'GBP', 'RUB', 'KZT', 'KGS', 'UZS', 'UAH', 'BYN'];

    HapticFeedback.lightImpact();
    int initialIndex = allCurrencies.indexOf(settings.activeCurrency);
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
                    settings.setActiveCurrency(allCurrencies[index]);
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

  List<ExpenseModel> _getDisplayExpenses(TransactionsProvider tx, String activeCurrency) {
    final activeExpenses = tx.expenses.where((e) => e.currency == activeCurrency).toList();
    if (_searchQuery.isEmpty) {
      return activeExpenses.take(15).toList();
    } else {
      final query = _searchQuery.toLowerCase();
      final filtered = activeExpenses.where((e) =>
      e.merchant.toLowerCase().contains(query) ||
          (e.note ?? '').toLowerCase().contains(query) ||
          e.category.name.toLowerCase().contains(query)
      ).toList();
      return filtered.take(15).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final settings = context.watch<SettingsProvider>();
    final tx = context.watch<TransactionsProvider>();
    final insights = context.watch<InsightsProvider>();

    final forecast = insights.forecastFor(now);
    final totalSpent = insights.totalSpentForMonth(now);
    final healthScore = insights.healthScoreFor(now);

    final displayExpenses = _getDisplayExpenses(tx, settings.activeCurrency);
    final lifeSpentDuration = insights.spentLifeDurationForMonth(now);
    final lifeSpentFormatted = _formatLifeTime(lifeSpentDuration);

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, 31);

    final activeCurrency = settings.activeCurrency;
    final hasPremium = settings.canUseFeature(PremiumFeature.multiCurrency);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // ФОНОВЫЙ ГРАДИЕНТ
            Positioned(
              top: -100,
              left: -50,
              right: -50,
              height: 400,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.15),
                      theme.colorScheme.secondary.withValues(alpha: isDark ? 0.2 : 0.1),
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
                // --- ЗАКРЕПЛЕННЫЙ МАТОВЫЙ APPBAR ---
                SliverAppBar(
                  pinned: true,
                  backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.8), // Полупрозрачный
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Эффект матового стекла
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  centerTitle: false,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getGreeting(context).toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: theme.colorScheme.primary),
                      ),
                      Text(
                        l10n.homeTab,
                        style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5, color: theme.colorScheme.onSurface, fontSize: 24),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => _showCurrencyAccountSelector(context, settings),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.surfaceContainerHighest),
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
                                style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface, fontSize: 14),
                              ),
                              if (hasPremium) ...[
                                const SizedBox(width: 4),
                                Icon(CupertinoIcons.chevron_up_chevron_down, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
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
                          decoration: BoxDecoration(color: theme.colorScheme.surface, shape: BoxShape.circle),
                          child: Icon(CupertinoIcons.person, color: theme.colorScheme.primary, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),

                // Поиск
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: CupertinoSearchTextField(
                      placeholder: 'Поиск транзакций...',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                ),

                // Основной контент
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),

                      if (_searchQuery.isEmpty) ...[
                        SizedBox(
                          height: 240,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const BudgetScreen()));
                                },
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
                              Positioned(
                                top: 20,
                                right: 20,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _showRemaining = !_showRemaining);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(CupertinoIcons.arrow_2_squarepath, color: Colors.white, size: 14),
                                            const SizedBox(width: 6),
                                            Text(
                                              _showRemaining ? 'Расход' : 'Остаток',
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      AppleSectionHeader(
                        title: _searchQuery.isEmpty ? l10n.recentExpensesTitle : 'Результаты поиска',
                        action: _searchQuery.isEmpty ? l10n.historyAction : null,
                        onActionTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ExpensesScreen())),
                      ),
                      const SizedBox(height: 12),

                      if (displayExpenses.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                            boxShadow: [
                              BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.03), blurRadius: 20)
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: _buildSections(context, displayExpenses).expand((section) {
                              return [
                                if (_searchQuery.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                                    child: Text(
                                      section.title.toUpperCase(),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                                      Slidable(
                                        key: ValueKey(expense.id),
                                        startActionPane: ActionPane(
                                          motion: const StretchMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (_) {
                                                HapticFeedback.lightImpact();
                                                tx.duplicateExpense(expense);
                                              },
                                              backgroundColor: CupertinoColors.activeBlue,
                                              foregroundColor: Colors.white,
                                              icon: CupertinoIcons.doc_on_doc,
                                              label: 'Повторить',
                                            ),
                                          ],
                                        ),
                                        endActionPane: ActionPane(
                                          motion: const StretchMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (_) async {
                                                HapticFeedback.mediumImpact();
                                                await tx.deleteExpense(expense.id);
                                              },
                                              backgroundColor: CupertinoColors.destructiveRed,
                                              foregroundColor: Colors.white,
                                              icon: CupertinoIcons.trash,
                                              label: 'Удалить',
                                            ),
                                          ],
                                        ),
                                        child: ExpenseItemCard(
                                            expense: expense,
                                            incomeProfile: settings.incomeProfile,
                                            onTap: () async {
                                              final result = await showModalBottomSheet<ExpenseEditResult>(
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (_) => ExpenseEditSheet(expense: expense),
                                              );
                                              if (result != null) {
                                                await tx.updateExpense(expense.id, result);
                                              }
                                            }
                                        ),
                                      ),
                                      if (!isLast) Padding(padding: const EdgeInsets.only(left: 64), child: Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
                                    ],
                                  );
                                }),
                              ];
                            }).toList(),
                          ),
                        ),

                      if (displayExpenses.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: theme.colorScheme.surface.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
                          child: Center(
                            child: Text(
                              _searchQuery.isEmpty ? 'Нет транзакций в $activeCurrency' : 'По запросу "$_searchQuery" ничего не найдено',
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                      SizedBox(height: 140 + MediaQuery.of(context).padding.bottom),
                    ]),
                  ),
                ),
              ],
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

class _ExpenseSection {
  final String title;
  final List<ExpenseModel> items;

  _ExpenseSection({required this.title, required this.items});
}