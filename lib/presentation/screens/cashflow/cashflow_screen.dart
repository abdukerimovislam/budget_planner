import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/recurring_bill_model.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/cashflow_event_card.dart';
import '../../widgets/premium_lock_card.dart';
import '../../widgets/section_header.dart';
import '../premium/premium_screen.dart';

class CashflowScreen extends StatelessWidget {
  const CashflowScreen({super.key});

  Future<void> _showSalaryDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.salaryDayTitle),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.salaryDayLabel,
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancelButton),
                ),
                FilledButton(
                  onPressed: () async {
                    final value = int.tryParse(controller.text.trim());

                    if (value == null || value < 1 || value > 31) {
                      setState(() {
                        errorText = l10n.salaryDayError;
                      });
                      return;
                    }

                    await context.read<HomeProvider>().setSalaryDay(value);

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

  Future<void> _showRecurringBillDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dayController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? titleError;
        String? amountError;
        String? dayError;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.recurringBillCreateTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: l10n.recurringBillTitleLabel,
                        errorText: titleError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.recurringBillAmountLabel,
                        errorText: amountError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dayController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.recurringBillDayLabel,
                        errorText: dayError,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancelButton),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final amount = double.tryParse(
                      amountController.text.trim().replaceAll(',', '.'),
                    );
                    final day = int.tryParse(dayController.text.trim());

                    setState(() {
                      titleError =
                      title.isEmpty ? l10n.recurringBillTitleError : null;
                      amountError = amount == null || amount <= 0
                          ? l10n.recurringBillAmountError
                          : null;
                      dayError = day == null || day < 1 || day > 31
                          ? l10n.recurringBillDayError
                          : null;
                    });

                    if (titleError != null ||
                        amountError != null ||
                        dayError != null) {
                      return;
                    }

                    await context.read<HomeProvider>().addRecurringBill(
                      RecurringBillModel(
                        id: const Uuid().v4(),
                        title: title,
                        amount: amount!,
                        currency: 'KGS',
                        dayOfMonth: day!,
                        isActive: true,
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final timeline = provider.cashflowTimeline(now);
    final salaryDay = provider.salaryDay;
    final recurringBills = provider.recurringBills;

    if (!provider.canUseFeature(PremiumFeature.cashflowTimeline)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.cashflowTitle),
        ),
        body: AdaptivePagePadding(
          addBottomSafeArea: false,
          child: ListView(
            children: [
              PremiumLockCard(
                title: l10n.premiumLockedCashflowTitle,
                subtitle: l10n.premiumLockedCashflowSubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PremiumScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cashflowTitle),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cashflowSummaryTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      salaryDay == null
                          ? l10n.cashflowNoSalaryDay
                          : l10n.cashflowSalaryDayValue(salaryDay),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.cashflowRecurringBillsValue(recurringBills.length),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            FilledButton(
              onPressed: () => _showSalaryDialog(context),
              child: Text(l10n.salaryDayButton),
            ),
            SizedBox(height: Responsive.itemGap(context)),
            OutlinedButton(
              onPressed: () => _showRecurringBillDialog(context),
              child: Text(l10n.recurringBillCreateButton),
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            SectionHeader(title: l10n.cashflowTimelineTitle),
            SizedBox(height: Responsive.itemGap(context)),
            if (timeline.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  child: Text(
                    l10n.cashflowEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...timeline.map(
                    (event) => Padding(
                  padding: EdgeInsets.only(bottom: Responsive.itemGap(context)),
                  child: CashflowEventCard(event: event),
                ),
              ),
          ],
        ),
      ),
    );
  }
}