class SavingsGoalProjection {
  final double remainingAmount;
  final double progress;
  final double recommendedMonthlyContribution;
  final int? monthsToTargetDate;
  final int? monthsAtCurrentSavingsRate;
  final bool isOnTrack;

  const SavingsGoalProjection({
    required this.remainingAmount,
    required this.progress,
    required this.recommendedMonthlyContribution,
    required this.monthsToTargetDate,
    required this.monthsAtCurrentSavingsRate,
    required this.isOnTrack,
  });
}