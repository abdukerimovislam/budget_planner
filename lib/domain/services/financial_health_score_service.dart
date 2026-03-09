class FinancialHealthScoreService {
  int calculate({
    required double income,
    required double totalSpent,
    required double totalBudget,
    required double subscriptionsSpent,
    required double goalProgressRatio, // 0..1
  }) {
    if (income <= 0 || totalBudget <= 0) return 0;

    final savings = (income - totalSpent).clamp(0, income);
    final savingsRate = savings / income;

    final budgetAdherence = totalSpent <= totalBudget
        ? 1.0
        : (1 - ((totalSpent - totalBudget) / totalBudget)).clamp(0.0, 1.0);

    final subscriptionsLoad = (subscriptionsSpent / income).clamp(0.0, 1.0);
    final subscriptionsScore = (1 - subscriptionsLoad).clamp(0.0, 1.0);

    final raw =
        (savingsRate * 30) +
            (budgetAdherence * 35) +
            (subscriptionsScore * 15) +
            (goalProgressRatio.clamp(0.0, 1.0) * 20);

    return raw.round().clamp(0, 100);
  }
}