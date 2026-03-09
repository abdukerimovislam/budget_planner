import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/auto_budget_card.dart';
import '../../widgets/category_budget_progress_card.dart';
import '../../widgets/premium_lock_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/spending_pace_card.dart';
import '../premium/premium_screen.dart';
import '../subscriptions/subscriptions_screen.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
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

  Future<void> _showEditBudgetDialog(BuildContext context) async {
    final provider = context.read<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final currentBudget = provider.budget?.totalBudget;
    final controller = TextEditingController(
      text: currentBudget == null ? '' : _formatNumber(currentBudget),
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.editBudgetDialogTitle),
              content: TextField(
                controller: controller,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.monthlyBudgetLabel,
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(l10n.cancelButton),
                ),
                FilledButton(
                  onPressed: () async {
                    final value = double.tryParse(
                      controller.text.trim().replaceAll(',', '.'),
                    );

                    if (value == null || value <= 0) {
                      setState(() {
                        errorText = l10n.validationEnterPositiveBudget;
                      });
                      return;
                    }

                    await provider.updateMonthlyBudget(value, DateTime.now());

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(l10n.saveButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final totalBudget = provider.budget?.totalBudget ?? 0;
    final spent = provider.totalSpentThisMonth(now);
    final remaining = provider.remainingBudgetFor(now);
    final autoBudget = provider.autoBudgetRecommendation(now);
    final categoryBudgets =
    provider.effectiveCategoryBudgetsForMonth(now).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dangerousCategory = provider.mostDangerousCategoryThisMonth(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetTab),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            _BudgetCard(
              title: l10n.currentMonthlyBudgetTitle,
              value: totalBudget > 0
                  ? _formatNumber(totalBudget)
                  : l10n.notAvailableShort,
              subtitle: l10n.currentMonthlyBudgetSubtitle,
            ),
            SizedBox(height: Responsive.itemGap(context)),
            _BudgetCard(
              title: l10n.spentThisMonth,
              value: _formatNumber(spent),
              subtitle: l10n.budgetSpentSubtitle,
            ),
            SizedBox(height: Responsive.itemGap(context)),
            _BudgetCard(
              title: l10n.remainingBudgetTitle,
              value: _formatNumber(remaining),
              subtitle: remaining < 0
                  ? l10n.remainingBudgetNegativeSubtitle
                  : l10n.remainingBudgetPositiveSubtitle,
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            if (dangerousCategory != null)
              SpendingPaceCard(
                title: l10n.budgetDangerTitle(
                  _categoryLabel(context, dangerousCategory),
                ),
                subtitle: l10n.budgetDangerSubtitle,
                isWarning: true,
              ),
            if (dangerousCategory != null)
              SizedBox(height: Responsive.sectionGap(context)),
            if (autoBudget.recommendedTotalBudget > 0)
              AutoBudgetCard(
                recommendation: autoBudget,
                onApplyTap: () async {
                  await provider.applyAutoBudget(now);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.autoBudgetAppliedMessage),
                      ),
                    );
                  }
                },
              ),
            SizedBox(height: Responsive.sectionGap(context)),
            SectionHeader(title: l10n.categoryBudgetsTitle),
            SizedBox(height: Responsive.itemGap(context)),
            if (categoryBudgets.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  child: Text(
                    l10n.categoryBudgetsEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...categoryBudgets.map((entry) {
                final category = entry.key;
                final budget = entry.value;
                final spentForCategory =
                provider.spentForCategoryThisMonth(now, category);
                final isOverBudget = spentForCategory > budget;

                return Padding(
                  padding: EdgeInsets.only(bottom: Responsive.itemGap(context)),
                  child: CategoryBudgetProgressCard(
                    categoryLabel: _categoryLabel(context, category),
                    spent: spentForCategory,
                    budget: budget,
                    isOverBudget: isOverBudget,
                  ),
                );
              }),
            SizedBox(height: Responsive.sectionGap(context)),
            FilledButton(
              onPressed: () => _showEditBudgetDialog(context),
              child: Text(l10n.editBudgetButton),
            ),
            SizedBox(height: Responsive.itemGap(context)),
            if (!provider.canUseFeature(PremiumFeature.advancedSubscriptions))
              PremiumLockCard(
                title: l10n.premiumLockedSubscriptionsTitle,
                subtitle: l10n.premiumLockedSubscriptionsSubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PremiumScreen(),
                    ),
                  );
                },
              )
            else
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionsScreen(),
                    ),
                  );
                },
                child: Text(l10n.openSubscriptionsButton),
              ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _BudgetCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
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