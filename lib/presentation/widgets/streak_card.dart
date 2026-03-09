import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../domain/services/streak_summary_model.dart';
import '../../l10n/app_localizations.dart';

class StreakCard extends StatelessWidget {
  final StreakSummaryModel streak;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(Responsive.cardPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.streakTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.streakCurrentValue(streak.currentStreakDays),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: Responsive.largeTitleSize(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.streakBestValue(streak.bestStreakDays),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                streak.hasActivityToday
                    ? l10n.streakTodayDone
                    : l10n.streakTodayMissing,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}