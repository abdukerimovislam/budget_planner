import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class HealthScoreExplainerCard extends StatelessWidget {
  final int score;

  const HealthScoreExplainerCard({
    super.key,
    required this.score,
  });

  String _headline(AppLocalizations l10n) {
    if (score >= 80) return l10n.scoreExcellentTitle;
    if (score >= 60) return l10n.scoreGoodTitle;
    if (score >= 40) return l10n.scoreMediumTitle;
    return l10n.scoreWeakTitle;
  }

  String _description(AppLocalizations l10n) {
    if (score >= 80) return l10n.scoreExcellentDescription;
    if (score >= 60) return l10n.scoreGoodDescription;
    if (score >= 40) return l10n.scoreMediumDescription;
    return l10n.scoreWeakDescription;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_headline(l10n), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _description(l10n),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}