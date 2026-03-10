import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../data/models/financial_level_model.dart';
import '../../l10n/app_localizations.dart';

class FinancialLevelCard extends StatelessWidget {
  final FinancialLevel level;
  final VoidCallback? onTapReport;

  const FinancialLevelCard({
    super.key,
    required this.level,
    this.onTapReport,
  });

  String _title(AppLocalizations l10n) {
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

  String _description(AppLocalizations l10n) {
    switch (level) {
      case FinancialLevel.survivor:
        return l10n.levelSurvivorDescription;
      case FinancialLevel.planner:
        return l10n.levelPlannerDescription;
      case FinancialLevel.strategist:
        return l10n.levelStrategistDescription;
      case FinancialLevel.investor:
        return l10n.levelInvestorDescription;
    }
  }

  IconData _icon() {
    switch (level) {
      case FinancialLevel.survivor:
        return Icons.shield_outlined;
      case FinancialLevel.planner:
        return Icons.edit_note_rounded;
      case FinancialLevel.strategist:
        return Icons.insights_rounded;
      case FinancialLevel.investor:
        return Icons.rocket_launch_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon(), color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _title(l10n),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _description(l10n),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onTapReport != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onTapReport,
                child: Text(l10n.openMonthlyReportButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}