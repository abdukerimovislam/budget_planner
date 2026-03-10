import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../data/models/insight_model.dart';
import '../../data/models/insight_type.dart';
import '../../l10n/app_localizations.dart';

class InsightCard extends StatelessWidget {
  final InsightModel insight;

  const InsightCard({
    super.key,
    required this.insight,
  });

  IconData _iconForType(InsightType type) {
    switch (type) {
      case InsightType.warning:
        return Icons.warning_amber_rounded;
      case InsightType.success:
        return Icons.check_circle_outline_rounded;
      case InsightType.info:
        return Icons.insights_rounded;
    }
  }

  Color _colorForType(BuildContext context, InsightType type) {
    final scheme = Theme.of(context).colorScheme;

    switch (type) {
      case InsightType.warning:
        return scheme.tertiary;
      case InsightType.success:
        return Colors.green;
      case InsightType.info:
        return scheme.primary;
    }
  }

  String _resolveText(
      BuildContext context,
      String key,
      Map<String, String> params,
      ) {
    final l10n = AppLocalizations.of(context);

    switch (key) {
      case 'insightOverBudgetTitle':
        return l10n.insightOverBudgetTitle;
      case 'insightOverBudgetDescription':
        return l10n.insightOverBudgetDescription(params['amount'] ?? '0');
      case 'insightHealthyPaceTitle':
        return l10n.insightHealthyPaceTitle;
      case 'insightHealthyPaceDescription':
        return l10n.insightHealthyPaceDescription;
      case 'insightTopCategoryTitle':
        return l10n.insightTopCategoryTitle;
      case 'insightTopCategoryDescription':
        return l10n.insightTopCategoryDescription(params['percent'] ?? '0');
      case 'insightSubscriptionsTitle':
        return l10n.insightSubscriptionsTitle;
      case 'insightSubscriptionsDescription':
        return l10n.insightSubscriptionsDescription(
          params['amount'] ?? '0',
          params['percent'] ?? '0',
        );
      case 'insightStrongScoreTitle':
        return l10n.insightStrongScoreTitle;
      case 'insightStrongScoreDescription':
        return l10n.insightStrongScoreDescription;
      case 'insightLowScoreTitle':
        return l10n.insightLowScoreTitle;
      case 'insightLowScoreDescription':
        return l10n.insightLowScoreDescription;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(context, insight.type);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconForType(insight.type),
              color: color,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resolveText(context, insight.titleKey, insight.params),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _resolveText(context, insight.descriptionKey, insight.params),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}