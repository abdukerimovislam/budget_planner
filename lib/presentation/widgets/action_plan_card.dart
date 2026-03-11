import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/action_plan_item_model.dart';
import '../../l10n/app_localizations.dart';

class ActionPlanCard extends StatelessWidget {
  final ActionPlanItemModel item;

  const ActionPlanCard({
    super.key,
    required this.item,
  });

  IconData _icon() {
    switch (item.type) {
      case ActionPlanType.cutCategory:
        return CupertinoIcons.scissors;
      case ActionPlanType.reduceSubscriptions:
        return CupertinoIcons.creditcard_fill;
      case ActionPlanType.saveMore:
        return CupertinoIcons.money_dollar_circle_fill;
      case ActionPlanType.improveBudgetDiscipline:
        return CupertinoIcons.shield_fill;
    }
  }

  Color _color() {
    switch (item.type) {
      case ActionPlanType.cutCategory:
        return CupertinoColors.systemOrange;
      case ActionPlanType.reduceSubscriptions:
        return CupertinoColors.systemPurple;
      case ActionPlanType.saveMore:
        return CupertinoColors.systemGreen;
      case ActionPlanType.improveBudgetDiscipline:
        return CupertinoColors.systemBlue;
    }
  }

  String _resolveTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (item.titleKey) {
      case 'actionPlanCutCategoryTitle':
        return l10n.actionPlanCutCategoryTitle;
      case 'actionPlanSubscriptionsTitle':
        return l10n.actionPlanSubscriptionsTitle;
      case 'actionPlanGoalTitle':
        return l10n.actionPlanGoalTitle;
      case 'actionPlanScoreTitle':
        return l10n.actionPlanScoreTitle;
      default:
        return item.titleKey;
    }
  }

  String _resolveDesc(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (item.descriptionKey) {
      case 'actionPlanCutCategoryDescription':
        return l10n.actionPlanCutCategoryDescription(item.params['percent'] ?? '0');
      case 'actionPlanSubscriptionsDescription':
        return l10n.actionPlanSubscriptionsDescription(
          item.params['amount'] ?? '0',
          item.params['half'] ?? '0',
        );
      case 'actionPlanGoalDescription':
        return l10n.actionPlanGoalDescription(
          item.params['amount'] ?? '0',
          item.params['months'] ?? '0',
        );
      case 'actionPlanScoreDescription':
        return l10n.actionPlanScoreDescription;
      default:
        return item.descriptionKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8), // Стеклянный фон
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(_icon(), color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    _resolveTitle(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    )
                ),
                const SizedBox(height: 6),
                Text(
                    _resolveDesc(context),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      height: 1.3,
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}