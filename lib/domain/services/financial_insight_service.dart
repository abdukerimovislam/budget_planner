import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/insight_model.dart';
import '../../data/models/insight_type.dart';

class FinancialInsightService {
  List<InsightModel> generate({
    required List<ExpenseModel> currentMonthExpenses,
    required double totalBudget,
    required double totalSpent,
    required double remainingBudget,
    required Map<ExpenseCategory, double> categoryTotals,
    required double subscriptionsSpent,
    required int healthScore,
  }) {
    final insights = <InsightModel>[];

    if (currentMonthExpenses.isEmpty) {
      return insights;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedCategories.isNotEmpty ? sortedCategories.first : null;
    final topCategoryShare = (topCategory != null && totalSpent > 0)
        ? topCategory.value / totalSpent
        : 0.0;

    if (remainingBudget < 0) {
      insights.add(
        InsightModel(
          id: 'over_budget',
          type: InsightType.warning,
          titleKey: 'insightOverBudgetTitle',
          descriptionKey: 'insightOverBudgetDescription',
          params: {
            'amount': _formatNumber(remainingBudget.abs()),
          },
        ),
      );
    } else if (totalBudget > 0 && totalSpent / totalBudget <= 0.7) {
      insights.add(
        const InsightModel(
          id: 'healthy_pace',
          type: InsightType.success,
          titleKey: 'insightHealthyPaceTitle',
          descriptionKey: 'insightHealthyPaceDescription',
        ),
      );
    }

    if (topCategory != null && topCategoryShare >= 0.4) {
      insights.add(
        InsightModel(
          id: 'top_category_dominates',
          type: InsightType.info,
          titleKey: 'insightTopCategoryTitle',
          descriptionKey: 'insightTopCategoryDescription',
          category: topCategory.key,
          params: {
            'percent': (topCategoryShare * 100).toStringAsFixed(0),
          },
        ),
      );
    }

    if (subscriptionsSpent > 0 && totalSpent > 0) {
      final subscriptionShare = subscriptionsSpent / totalSpent;
      if (subscriptionShare >= 0.15) {
        insights.add(
          InsightModel(
            id: 'high_subscriptions',
            type: InsightType.warning,
            titleKey: 'insightSubscriptionsTitle',
            descriptionKey: 'insightSubscriptionsDescription',
            params: {
              'amount': _formatNumber(subscriptionsSpent),
              'percent': (subscriptionShare * 100).toStringAsFixed(0),
            },
            category: ExpenseCategory.subscriptions,
          ),
        );
      }
    }

    if (healthScore >= 80) {
      insights.add(
        const InsightModel(
          id: 'strong_score',
          type: InsightType.success,
          titleKey: 'insightStrongScoreTitle',
          descriptionKey: 'insightStrongScoreDescription',
        ),
      );
    } else if (healthScore > 0 && healthScore < 50) {
      insights.add(
        const InsightModel(
          id: 'low_score',
          type: InsightType.warning,
          titleKey: 'insightLowScoreTitle',
          descriptionKey: 'insightLowScoreDescription',
        ),
      );
    }

    return insights.take(4).toList();
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}