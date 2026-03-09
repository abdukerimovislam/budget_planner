import '../../data/models/expense_model.dart';
import '../../data/models/subscription_candidate_model.dart';

class SubscriptionDetectorService {
  List<SubscriptionCandidateModel> detect({
    required List<ExpenseModel> expenses,
  }) {
    if (expenses.isEmpty) return const [];

    final Map<String, List<ExpenseModel>> grouped = {};

    for (final expense in expenses) {
      final merchant = expense.merchant.trim().toLowerCase();
      if (merchant.isEmpty) continue;

      grouped.putIfAbsent(merchant, () => []).add(expense);
    }

    final List<SubscriptionCandidateModel> result = [];

    for (final entry in grouped.entries) {
      final items = entry.value..sort((a, b) => a.date.compareTo(b.date));
      if (items.length < 2) continue;

      final intervals = <int>[];
      for (int i = 1; i < items.length; i++) {
        final days = items[i].date.difference(items[i - 1].date).inDays.abs();
        if (days > 0) {
          intervals.add(days);
        }
      }

      if (intervals.isEmpty) continue;

      final avgInterval =
          intervals.reduce((a, b) => a + b) / intervals.length;
      final avgAmount =
          items.map((e) => e.amount).reduce((a, b) => a + b) / items.length;

      final amountVarianceOk = items.every(
            (e) => (e.amount - avgAmount).abs() <= avgAmount * 0.25,
      );

      final intervalLooksRecurring =
          avgInterval >= 20 && avgInterval <= 40 ||
              avgInterval >= 6 && avgInterval <= 9;

      if (!amountVarianceOk || !intervalLooksRecurring) continue;

      final monthlyCost = avgInterval <= 9
          ? avgAmount * 4.0
          : avgAmount;

      result.add(
        SubscriptionCandidateModel(
          merchant: items.first.merchant.isNotEmpty
              ? items.first.merchant
              : entry.key,
          averageAmount: avgAmount,
          occurrences: items.length,
          averageIntervalDays: avgInterval.round(),
          estimatedMonthlyCost: monthlyCost,
        ),
      );
    }

    result.sort((a, b) => b.estimatedMonthlyCost.compareTo(a.estimatedMonthlyCost));
    return result;
  }
}