import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // <-- Добавили Купертино иконки

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
        return CupertinoIcons.exclamationmark_triangle_fill;
      case InsightType.success:
        return CupertinoIcons.checkmark_seal_fill;
      case InsightType.info:
        return CupertinoIcons.lightbulb_fill;
    }
  }

  Color _colorForType(BuildContext context, InsightType type) {
    final scheme = Theme.of(context).colorScheme;

    switch (type) {
      case InsightType.warning:
        return CupertinoColors.systemOrange; // Более приятный цвет предупреждения
      case InsightType.success:
        return CupertinoColors.systemGreen;
      case InsightType.info:
        return scheme.primary;
    }
  }

  String _resolveText(BuildContext context, String key, Map<String, String> params) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'insightOverBudgetTitle': return l10n.insightOverBudgetTitle;
      case 'insightOverBudgetDescription': return l10n.insightOverBudgetDescription(params['amount'] ?? '0');
      case 'insightHealthyPaceTitle': return l10n.insightHealthyPaceTitle;
      case 'insightHealthyPaceDescription': return l10n.insightHealthyPaceDescription;
      case 'insightTopCategoryTitle': return l10n.insightTopCategoryTitle;
      case 'insightTopCategoryDescription': return l10n.insightTopCategoryDescription(params['percent'] ?? '0');
      case 'insightSubscriptionsTitle': return l10n.insightSubscriptionsTitle;
      case 'insightSubscriptionsDescription': return l10n.insightSubscriptionsDescription(params['amount'] ?? '0', params['percent'] ?? '0');
      case 'insightStrongScoreTitle': return l10n.insightStrongScoreTitle;
      case 'insightStrongScoreDescription': return l10n.insightStrongScoreDescription;
      case 'insightLowScoreTitle': return l10n.insightLowScoreTitle;
      case 'insightLowScoreDescription': return l10n.insightLowScoreDescription;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(context, insight.type);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8), // Стеклянный фон
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Красивая подложка под иконку
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconForType(insight.type), color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _resolveText(context, insight.titleKey, insight.params),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _resolveText(context, insight.descriptionKey, insight.params),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}