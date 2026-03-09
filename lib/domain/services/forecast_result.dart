class ForecastResult {
  final double avgDailySpend;
  final double predictedMonthSpend;
  final double expectedRemaining;
  final bool isOverBudget;

  const ForecastResult({
    required this.avgDailySpend,
    required this.predictedMonthSpend,
    required this.expectedRemaining,
    required this.isOverBudget,
  });
}