import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../domain/services/action_plan_item.dart';
import '../../l10n/app_localizations.dart';

class ActionPlanCard extends StatelessWidget {
  final ActionPlanItem item;

  const ActionPlanCard({
    super.key,
    required this.item,
  });

  IconData _iconForType(ActionPlanType type) {
    switch (type) {
      case ActionPlanType.saveMore:
        return Icons.savings_outlined;
      case ActionPlanType.cutCategory:
        return Icons.tune_rounded;
      case ActionPlanType.reduceSubscriptions:
        return Icons.subscriptions_outlined;
      case ActionPlanType.improveBudgetDiscipline:
        return Icons.track_changes_rounded;
    }
  }

  String _resolveText(
      BuildContext context,
      String key,
      Map<String, String> params,
      ) {
    final l10n = AppLocalizations.of(context);

    switch (key) {
      case 'actionPlanCutCategoryTitle':
        return l10n.actionPlanCutCategoryTitle;
      case 'actionPlanCutCategoryDescription':
        return l10n.actionPlanCutCategoryDescription(
          params['percent'] ?? '0',
        );
      case 'actionPlanSubscriptionsTitle':
        return l10n.actionPlanSubscriptionsTitle;
      case 'actionPlanSubscriptionsDescription':
        return l10n.actionPlanSubscriptionsDescription(
          params['amount'] ?? '0',
          params['half'] ?? '0',
        );
      case 'actionPlanGoalTitle':
        return l10n.actionPlanGoalTitle;
      case 'actionPlanGoalDescription':
        return l10n.actionPlanGoalDescription(
          params['amount'] ?? '0',
          params['months'] ?? '0',
        );
      case 'actionPlanScoreTitle':
        return l10n.actionPlanScoreTitle;
      case 'actionPlanScoreDescription':
        return l10n.actionPlanScoreDescription;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconForType(item.type),
              color: item.isPriority ? scheme.error : scheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resolveText(context, item.titleKey, item.params),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _resolveText(context, item.descriptionKey, item.params),
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