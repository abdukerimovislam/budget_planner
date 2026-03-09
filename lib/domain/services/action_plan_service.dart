import '../../data/models/expense_category.dart';
import '../../data/models/saving_goal_model.dart';
import '../../data/models/subscription_candidate_model.dart';
import 'action_plan_item.dart';
import 'savings_goal_projection.dart';

class ActionPlanService {
  List<ActionPlanItem> generate({
    required ExpenseCategory? dangerousCategory,
    required double dangerousCategorySpent,
    required double dangerousCategoryBudget,
    required List<SubscriptionCandidateModel> subscriptions,
    required SavingsGoalModel? goal,
    required SavingsGoalProjection? goalProjection,
    required int healthScore,
  }) {
    final items = <ActionPlanItem>[];

    if (dangerousCategory != null &&
        dangerousCategoryBudget > 0 &&
        dangerousCategorySpent > dangerousCategoryBudget * 0.8) {
      final overshootRisk = ((dangerousCategorySpent / dangerousCategoryBudget) * 100)
          .clamp(0, 999)
          .toStringAsFixed(0);

      items.add(
        ActionPlanItem(
          type: ActionPlanType.cutCategory,
          titleKey: 'actionPlanCutCategoryTitle',
          descriptionKey: 'actionPlanCutCategoryDescription',
          params: {
            'percent': overshootRisk,
          },
          isPriority: true,
        ),
      );
    }

    if (subscriptions.isNotEmpty) {
      final monthlySubscriptionLoad = subscriptions.fold<double>(
        0,
            (sum, item) => sum + item.estimatedMonthlyCost,
      );

      items.add(
        ActionPlanItem(
          type: ActionPlanType.reduceSubscriptions,
          titleKey: 'actionPlanSubscriptionsTitle',
          descriptionKey: 'actionPlanSubscriptionsDescription',
          params: {
            'amount': _formatNumber(monthlySubscriptionLoad),
            'half': _formatNumber(monthlySubscriptionLoad * 0.5),
          },
          isPriority: monthlySubscriptionLoad > 0,
        ),
      );
    }

    if (goal != null && goalProjection != null) {
      if (!goalProjection.isOnTrack && goalProjection.monthsToTargetDate != null) {
        items.add(
          ActionPlanItem(
            type: ActionPlanType.saveMore,
            titleKey: 'actionPlanGoalTitle',
            descriptionKey: 'actionPlanGoalDescription',
            params: {
              'amount': _formatNumber(goalProjection.recommendedMonthlyContribution),
              'months': goalProjection.monthsToTargetDate!.toString(),
            },
            isPriority: true,
          ),
        );
      }
    }

    if (healthScore < 60) {
      items.add(
        const ActionPlanItem(
          type: ActionPlanType.improveBudgetDiscipline,
          titleKey: 'actionPlanScoreTitle',
          descriptionKey: 'actionPlanScoreDescription',
          isPriority: false,
        ),
      );
    }

    return items.take(4).toList();
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}