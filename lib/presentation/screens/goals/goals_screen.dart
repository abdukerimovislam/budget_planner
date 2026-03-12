import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/saving_goal_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/action_plan_card.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/savings_goal_card.dart';
import '../../widgets/section_header.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  Future<void> _showCreateGoalDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? targetDate;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? titleError;
        String? amountError;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.goalCreateTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.goalTitleLabel,
                      errorText: titleError,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      // ИСПРАВЛЕНИЕ: Добавляем текущую валюту в Label, чтобы пользователь понимал, в чем он копит
                      labelText: '${l10n.goalTargetAmountLabel} (${context.read<HomeProvider>().activeCurrency})',
                      errorText: amountError,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: now.add(const Duration(days: 90)),
                        firstDate: now,
                        lastDate: DateTime(now.year + 10),
                      );

                      if (picked != null) {
                        setState(() {
                          targetDate = picked;
                        });
                      }
                    },
                    child: Text(
                      targetDate == null
                          ? l10n.goalPickDateButton
                          : l10n.goalPickedDateButton(
                        '${targetDate!.day.toString().padLeft(2, '0')}.'
                            '${targetDate!.month.toString().padLeft(2, '0')}.'
                            '${targetDate!.year}',
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancelButton),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final targetAmount = double.tryParse(
                      amountController.text.trim().replaceAll(',', '.'),
                    );

                    setState(() {
                      titleError = title.isEmpty ? l10n.goalTitleError : null;
                      amountError = targetAmount == null || targetAmount <= 0
                          ? l10n.goalAmountError
                          : null;
                    });

                    if (titleError != null || amountError != null) return;

                    final provider = context.read<HomeProvider>();

                    await provider.setSavingsGoal(
                      SavingsGoalModel(
                        id: const Uuid().v4(),
                        title: title,
                        targetAmount: targetAmount!,
                        currentAmount: 0,
                        currency: provider.activeCurrency, // <-- ИСПРАВЛЕНИЕ: Передаем валюту
                        targetDate: targetDate,
                        createdAt: DateTime.now(),
                      ),
                    );

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

  Future<void> _showAddProgressDialog(
      BuildContext context,
      SavingsGoalModel goal,
      ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? amountError;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.goalAddProgressTitle),
              content: TextField(
                controller: controller,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '${l10n.goalAddProgressLabel} (${goal.currency})', // Подсказываем валюту
                  errorText: amountError,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancelButton),
                ),
                FilledButton(
                  onPressed: () async {
                    final value = double.tryParse(
                      controller.text.trim().replaceAll(',', '.'),
                    );

                    if (value == null || value <= 0) {
                      setState(() {
                        amountError = l10n.goalAmountError;
                      });
                      return;
                    }

                    await context.read<HomeProvider>().updateSavingsGoalProgress(
                      goal.id,
                      value,
                    );

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

    final goal = provider.savingsGoal;
    final projection = goal == null ? null : provider.savingsGoalProjection(now);
    final actionPlan = provider.actionPlan(now);

    // ИСПРАВЛЕНИЕ: Показываем цель, только если она в текущей активной валюте
    final bool isGoalVisible = goal != null && goal.currency == provider.activeCurrency;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goalsTab),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            SectionHeader(title: l10n.goalsTitle),
            SizedBox(height: Responsive.itemGap(context)),
            if (!isGoalVisible)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  child: Column(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        // Если цель есть, но в другой валюте, мы мягко объясняем это пользователю
                        goal != null ? 'No goals for ${provider.activeCurrency}' : l10n.goalsEmptyTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal != null ? 'Switch to ${goal.currency} account to view your active goal' : l10n.goalsEmptySubtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (goal == null)
                        FilledButton(
                          onPressed: () => _showCreateGoalDialog(context),
                          child: Text(l10n.goalCreateButton),
                        ),
                    ],
                  ),
                ),
              )
            else ...[
              SavingsGoalCard(
                goal: goal,
                projection: projection!,
              ),
              SizedBox(height: Responsive.sectionGap(context)),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.goalProjectionTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        projection.monthsToTargetDate == null
                            ? l10n.goalProjectionNoDate
                            : l10n.goalProjectionWithDate(
                          '${_formatNumber(projection.recommendedMonthlyContribution)} ${goal.currency}',
                          projection.monthsToTargetDate!,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        projection.monthsAtCurrentSavingsRate == null
                            ? l10n.goalProjectionNoCurrentRate
                            : l10n.goalProjectionCurrentRate(
                          projection.monthsAtCurrentSavingsRate!,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Responsive.sectionGap(context)),
              SectionHeader(title: l10n.actionPlanTitle),
              SizedBox(height: Responsive.itemGap(context)),
              if (actionPlan.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.cardPadding(context)),
                    child: Text(
                      l10n.actionPlanEmptySubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ...actionPlan.map(
                      (item) => Padding(
                    padding:
                    EdgeInsets.only(bottom: Responsive.itemGap(context)),
                    child: ActionPlanCard(item: item),
                  ),
                ),
              SizedBox(height: Responsive.sectionGap(context)),
              FilledButton(
                onPressed: () => _showAddProgressDialog(context, goal),
                child: Text(l10n.goalAddProgressButton),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: !isGoalVisible
          ? null
          : FloatingActionButton(
        onPressed: () => _showCreateGoalDialog(context),
        tooltip: l10n.goalReplaceButton,
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }
}