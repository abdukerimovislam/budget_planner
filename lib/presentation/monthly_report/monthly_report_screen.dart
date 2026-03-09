import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../domain/services/financial_level.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../screens/share_card/share_card_screen.dart';
import '../widgets/adaptive_page_padding.dart';
import '../widgets/monthly_report_card.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

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

  String _levelLabel(AppLocalizations l10n, FinancialLevel level) {
    switch (level) {
      case FinancialLevel.survivor:
        return l10n.levelSurvivor;
      case FinancialLevel.planner:
        return l10n.levelPlanner;
      case FinancialLevel.strategist:
        return l10n.levelStrategist;
      case FinancialLevel.investor:
        return l10n.levelInvestor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final report = provider.monthlyReport(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.monthlyReportTitle),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            MonthlyReportCard(
              report: report,
              topCategoryLabel: _categoryLabel(context, report.topCategory),
              lifeSpentText: _formatDuration(context, report.lifeSpent),
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.monthlyReportLevelTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _levelLabel(l10n, report.level),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: Responsive.largeTitleSize(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.monthlyReportShareHint,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ShareCardScreen(),
                          ),
                        );
                      },
                      child: Text(l10n.openShareCardButton),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}