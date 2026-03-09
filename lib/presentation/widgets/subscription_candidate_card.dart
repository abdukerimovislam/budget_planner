import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../data/models/subscription_candidate_model.dart';
import '../../l10n/app_localizations.dart';

class SubscriptionCandidateCard extends StatelessWidget {
  final SubscriptionCandidateModel candidate;

  const SubscriptionCandidateCard({
    super.key,
    required this.candidate,
  });

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
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
            Text(
              candidate.merchant,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.subscriptionEstimatedMonthlyCost(
                _formatNumber(candidate.estimatedMonthlyCost),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.subscriptionOccurrences(
                candidate.occurrences,
                candidate.averageIntervalDays,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}