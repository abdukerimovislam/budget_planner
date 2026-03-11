import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/category_extension.dart'; // <-- ИМПОРТ
import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../data/models/financial_level_model.dart';
import '../providers/home_provider.dart';
import '../screens/share_card/share_card_screen.dart';
import '../widgets/adaptive_page_padding.dart';
import '../widgets/monthly_report_card.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  String _formatDuration(BuildContext context, Duration duration) {
    final l10n = AppLocalizations.of(context);
    final totalMinutes = duration.inMinutes;

    if (totalMinutes <= 0) return l10n.durationMinutesOnly(0);

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) return l10n.durationMinutesOnly(minutes);
    if (minutes == 0) return l10n.durationHoursOnly(hours);

    return l10n.durationHoursMinutes(hours, minutes);
  }

  String _levelLabel(AppLocalizations l10n, FinancialLevel level) {
    switch (level) {
      case FinancialLevel.survivor: return l10n.levelSurvivor;
      case FinancialLevel.planner: return l10n.levelPlanner;
      case FinancialLevel.strategist: return l10n.levelStrategist;
      case FinancialLevel.investor: return l10n.levelInvestor;
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
              // ИСПОЛЬЗУЕМ РАСШИРЕНИЕ ВМЕСТО SWITCH:
              topCategoryLabel: report.topCategory?.localizedName(context) ?? l10n.categoryOther,
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