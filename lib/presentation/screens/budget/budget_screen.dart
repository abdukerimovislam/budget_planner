import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/category_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/auto_budget_card.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_lock_card.dart';
import '../../widgets/spending_pace_card.dart';
import '../premium/premium_screen.dart';
import '../subscriptions/subscriptions_screen.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  Future<void> _showEditBudgetDialog(BuildContext context) async {
    final provider = context.read<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final currentBudget = provider.budget?.totalBudget;
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
              placeholder: l10n.monthlyBudgetLabel,
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

    // ИСПРАВЛЕНИЕ: Берем валюту из единого источника правды (Профиля), а не из старых транзакций!
    final String currency = provider.incomeProfile?.currency ?? 'USD';

    final totalBudget = provider.budget?.totalBudget ?? 0;
    final spent = provider.totalSpentThisMonth(now);
    final remaining = provider.remainingBudgetFor(now);
    final autoBudget = provider.autoBudgetRecommendation(now);
    final categoryBudgets = provider.effectiveCategoryBudgetsForMonth(now).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dangerousCategory = provider.mostDangerousCategoryThisMonth(now);

    final double overallProgress = totalBudget > 0 ? (spent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final bool isOverOverall = spent > totalBudget && totalBudget > 0;

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar.large(
              stretch: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text(
                l10n.budgetTab,
                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              actions: [
                IconButton(
                  icon: const Icon(CupertinoIcons.pencil_outline),
                  onPressed: () => _showEditBudgetDialog(context),
                ),
              ],
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // 1. ГЛАВНЫЙ КРУГОВОЙ ПРОГРЕСС БЮДЖЕТА
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 16,
                                color: theme.colorScheme.surfaceVariant,
                              ),
                              CircularProgressIndicator(
                                value: overallProgress,
                                strokeWidth: 16,
                                strokeCap: StrokeCap.round,
                                color: isOverOverall ? CupertinoColors.systemRed : theme.colorScheme.primary,
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isOverOverall ? 'Overspent' : 'Remaining',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatNumber(remaining.abs()),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: isOverOverall ? CupertinoColors.systemRed : theme.colorScheme.onSurface,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      currency, // <-- ВАЛЮТА ТЕПЕРЬ ВСЕГДА ВЕРНАЯ
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.currentMonthlyBudgetTitle, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600)),
                                Text('${_formatNumber(totalBudget)} $currency', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.spentThisMonth, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600)),
                                Text('${_formatNumber(spent)} $currency', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.sectionGap(context)),

                  if (dangerousCategory != null) ...[
                    SpendingPaceCard(
                      title: l10n.budgetDangerTitle(dangerousCategory.localizedName(context)),
                      subtitle: l10n.budgetDangerSubtitle,
                      isWarning: true,
                    ),
                    SizedBox(height: Responsive.sectionGap(context)),
                  ],

                  if (autoBudget.recommendedTotalBudget > 0) ...[
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

                  // 2. ДЕТАЛИЗАЦИЯ БЮДЖЕТОВ ПО КАТЕГОРИЯМ
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16),
                    child: Text(
                      l10n.categoryBudgetsTitle,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: theme.colorScheme.onSurface),
                    ),
                  ),

                  if (categoryBudgets.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: theme.colorScheme.surface.withOpacity(0.8), borderRadius: BorderRadius.circular(24)),
                      child: Center(child: Text(l10n.categoryBudgetsEmpty, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)))),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: categoryBudgets.asMap().entries.map((entry) {
                          final isLast = entry.key == categoryBudgets.length - 1;
                          final category = entry.value.key;
                          final budget = entry.value.value;
                          final spentForCategory = provider.spentForCategoryThisMonth(now, category);
                          final isOverBudget = spentForCategory > budget;
                          final progress = budget > 0 ? (spentForCategory / budget).clamp(0.0, 1.0) : 0.0;

                          final catColor = category.dynamicColor(context);

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: catColor.withOpacity(0.15), shape: BoxShape.circle),
                                      child: Icon(category.dynamicIcon(context), color: catColor, size: 20),
                                    ),
                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(category.localizedName(context), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                                              Text(
                                                '${_formatNumber(spentForCategory)} / ${_formatNumber(budget)}',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: isOverBudget ? CupertinoColors.systemRed : theme.colorScheme.onSurface.withOpacity(0.5)
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: Container(
                                              height: 6, width: double.infinity, color: theme.colorScheme.surfaceVariant,
                                              child: FractionallySizedBox(
                                                alignment: Alignment.centerLeft, widthFactor: progress,
                                                child: Container(decoration: BoxDecoration(color: isOverBudget ? CupertinoColors.systemRed : catColor, borderRadius: BorderRadius.circular(4))),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast) Padding(padding: const EdgeInsets.only(left: 64), child: Divider(height: 1, color: theme.colorScheme.surfaceVariant.withOpacity(0.5))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                  SizedBox(height: Responsive.sectionGap(context)),

                  // 3. ПОДПИСКИ
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
                          color: theme.colorScheme.primary.withOpacity(0.1),
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
      ),
    );
  }
}