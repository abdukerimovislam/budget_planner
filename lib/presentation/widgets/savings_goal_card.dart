import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../data/models/saving_goal_model.dart';
import '../../domain/services/savings_goal_projection.dart';
import '../../l10n/app_localizations.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final SavingsGoalProjection projection;
  final VoidCallback? onTap;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    required this.projection,
    this.onTap,
  });

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

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
                goal.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: projection.progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(999),
                color: projection.isOnTrack ? scheme.primary : scheme.error,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.goalProgressValue(
                  _formatNumber(goal.currentAmount),
                  _formatNumber(goal.targetAmount),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.goalRemainingValue(
                  _formatNumber(projection.remainingAmount),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (projection.monthsToTargetDate != null) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.goalRecommendedPerMonth(
                    _formatNumber(projection.recommendedMonthlyContribution),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}