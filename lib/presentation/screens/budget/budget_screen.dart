import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/category_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/apple_section_header.dart';
import '../../widgets/auto_budget_card.dart';
import '../../widgets/premium_lock_card.dart';
import '../../widgets/spending_pace_card.dart';
import '../premium/premium_screen.dart';
import '../subscriptions/subscriptions_screen.dart';

// ПРОВАЙДЕРЫ
import '../../providers/settings_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/insights_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  Future<void> _showEditBudgetDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final budgetProv = context.read<BudgetProvider>();
    final l10n = AppLocalizations.of(context);

    final bool hasValidBudget = budgetProv.budget != null && budgetProv.budget!.currency == settings.activeCurrency;
    final currentBudget = hasValidBudget ? budgetProv.budget!.totalBudget : null;

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
              placeholder: '${l10n.monthlyBudgetLabel} (${settings.activeCurrency})',
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

                await budgetProv.updateMonthlyBudget(value, DateTime.now());
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
    final settings = context.watch<SettingsProvider>();
    final budgetProv = context.watch<BudgetProvider>();
    final insights = context.watch<InsightsProvider>();

    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final theme = Theme.of(context);

    final String currency = settings.activeCurrency;
    final bool hasBudgetForCurrency = budgetProv.budget != null && budgetProv.budget!.currency == currency;
    final totalBudget = hasBudgetForCurrency ? budgetProv.budget!.totalBudget : 0.0;

    final spent = insights.totalSpentForMonth(now);
    final remaining = totalBudget > 0 ? (totalBudget - spent) : 0.0;

    // Безопасное получение рекомендаций авто-бюджета
    final autoBudget = budgetProv.autoBudgetRecommendation(now);

    final categoryBudgets = budgetProv.effectiveCategoryBudgetsForMonth(now).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dangerousCategory = insights.mostDangerousCategoryThisMonth(now);

    final double overallProgress = totalBudget > 0 ? (spent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final bool isOverOverall = spent > totalBudget && totalBudget > 0;

    return Scaffold(
      // Делаем фон полностью прозрачным, чтобы просвечивал глобальный градиент
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // --- ЗАКРЕПЛЕННЫЙ МАТОВЫЙ APPBAR ---
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
            scrolledUnderElevation: 0,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(color: Colors.transparent),
              ),
            ),
            centerTitle: false,
            title: Text(
              l10n.budgetTab,
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5, color: theme.colorScheme.onSurface, fontSize: 24),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(CupertinoIcons.pencil_circle_fill, color: theme.colorScheme.primary, size: 28),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showEditBudgetDialog(context);
                  },
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // --- КРУГОВОЙ ПРОГРЕСС БЮДЖЕТА ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)),
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
                              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            ),
                            if (totalBudget > 0)
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
                                  if (totalBudget == 0) ...[
                                    Icon(CupertinoIcons.chart_pie_fill, size: 32, color: theme.colorScheme.primary.withOpacity(0.5)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Бюджет не задан',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      isOverOverall ? 'ПЕРЕТРАТА' : 'ОСТАТОК',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _formatNumber(remaining.abs()),
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w800,
                                          color: isOverOverall ? CupertinoColors.systemRed : theme.colorScheme.onSurface,
                                          height: 1.1,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      currency,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      if (totalBudget == 0) ...[
                        FilledButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showEditBudgetDialog(context);
                          },
                          icon: const Icon(CupertinoIcons.add),
                          label: Text('Установить бюджет в $currency'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.currentMonthlyBudgetTitle, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('${_formatNumber(totalBudget)} $currency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.spentThisMonth, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('${_formatNumber(spent)} $currency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: Responsive.sectionGap(context)),

                // --- ПРЕДУПРЕЖДЕНИЯ ---
                if (dangerousCategory != null && totalBudget > 0) ...[
                  SpendingPaceCard(
                    title: '${dangerousCategory.localizedName(context)}: превышение',
                    subtitle: l10n.budgetDangerSubtitle,
                    isWarning: true,
                  ),
                  SizedBox(height: Responsive.sectionGap(context)),
                ],

                // --- АВТОБЮДЖЕТ ---
                if (autoBudget != null && autoBudget.recommendedTotalBudget > 0 && totalBudget == 0) ...[
                  AutoBudgetCard(
                    recommendation: autoBudget,
                    onApplyTap: () async {
                      await budgetProv.applyAutoBudget(now);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.autoBudgetAppliedMessage), behavior: SnackBarBehavior.floating));
                      }
                    },
                  ),
                  SizedBox(height: Responsive.sectionGap(context)),
                ],

                // --- ПРОГРЕСС ПО КАТЕГОРИЯМ ---
                if (totalBudget > 0 && categoryBudgets.isNotEmpty) ...[
                  AppleSectionHeader(title: l10n.categoryBudgetsTitle),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: categoryBudgets.asMap().entries.map((entry) {
                        final isLast = entry.key == categoryBudgets.length - 1;
                        final category = entry.value.key;
                        final budget = entry.value.value;
                        final spentForCategory = insights.spentForCategoryThisMonth(now, category);
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
                                            // Защита от переполнения длинными названиями
                                            Expanded(
                                              child: Text(
                                                category.localizedName(context),
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
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
                                            height: 6, width: double.infinity, color: theme.colorScheme.surfaceContainerHighest,
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
                            if (!isLast) Padding(padding: const EdgeInsets.only(left: 64), child: Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: Responsive.sectionGap(context)),
                ],

                // --- ПОДПИСКИ ---
                if (!settings.canUseFeature(PremiumFeature.advancedSubscriptions))
                  PremiumLockCard(
                    title: l10n.premiumLockedSubscriptionsTitle,
                    subtitle: l10n.premiumLockedSubscriptionsSubtitle,
                    onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen())),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const SubscriptionsScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.creditcard_fill, color: theme.colorScheme.primary, size: 24),
                          const SizedBox(width: 12),
                          Text(l10n.openSubscriptionsButton, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 140 + MediaQuery.of(context).padding.bottom),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}