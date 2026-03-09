import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/action_plan_card.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/month_close_summary_card.dart';
import '../../widgets/section_header.dart';

class MonthCloseScreen extends StatelessWidget {
  const MonthCloseScreen({super.key});

  String _formatDuration(BuildContext context, Duration duration) {
    final l10n = AppLocalizations.of(context);
    final totalMinutes = duration.inMinutes;

    if (totalMinutes <= 0) {
      return l10n.durationMinutesOnly(0);
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) return l10n.durationMinutesOnly(minutes);
    if (minutes == 0) return l10n.durationHoursOnly(hours);

    return l10n.durationHoursMinutes(hours, minutes);
  }

  String _categoryLabel(BuildContext context, ExpenseCategory? category) {
    final l10n = AppLocalizations.of(context);
    if (category == null) return l10n.categoryOther;

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final summary = provider.monthCloseSummary(now);
    final actionPlan = provider.actionPlan(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.monthCloseTitle),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            MonthCloseSummaryCard(
              summary: summary,
              topCategoryLabel: _categoryLabel(context, summary.topCategory),
              lifeSpentText: _formatDuration(context, summary.lifeSpent),
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.improvedVsPreviousMonth
                          ? l10n.monthCloseWinTitle
                          : l10n.monthCloseFocusTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary.improvedVsPreviousMonth
                          ? l10n.monthCloseWinSubtitle
                          : l10n.monthCloseFocusSubtitle,
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
                  padding: EdgeInsets.only(bottom: Responsive.itemGap(context)),
                  child: ActionPlanCard(item: item),
                ),
              ),
            SizedBox(height: Responsive.sectionGap(context)),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.monthCloseStartNextMonthButton),
            ),
          ],
        ),
      ),
    );
  }
}